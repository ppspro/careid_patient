# CAREID — COMPREHENSIVE SERVICE RECOVERY RUNBOOK

**Product:** CareID Clinical Network  
**Target Environment:** Staging & Production aaPanel Contabo VPS (`161.97.89.183`)  
**Document Version:** 2.0.0  
**Effective Date:** November 10, 2026  
**Auditor & Author:** Antigravity Autonomous Systems Engineering Team  
**Service Level Agreements (SLA):**
- **Recovery Time Objective (RTO):** Critical API & Database < 5 minutes; OCR & Storage < 15 minutes.
- **Recovery Point Objective (RPO):** PostgreSQL RPO < 1 hour; Object Storage RPO < 0 (immutable write-once).

---

## 1. Core Services Lifecycle Management

### 1.1 CareID Backend API Monolith (aaPanel PM2)

#### Normal Operations:
```bash
# Check status, memory, CPU, and restart count of the backend process
pm2 status careid-backend-api

# Stream real-time merged logs
pm2 logs careid-backend-api --lines 100

# Graceful reload (zero-downtime)
pm2 reload ecosystem.config.js

# Hard restart
pm2 restart careid-backend-api

# Stop service
pm2 stop careid-backend-api
```

#### Diagnostic Verification Post-Restart:
```bash
# Check local loopback HTTP status
curl -i http://127.0.0.1:3073/api/v1/health

# Check public HTTPS ingress status
curl -i https://360api.vnvision.in/api/v1/ready
```

---

### 1.2 Persistent PaddleOCR Worker Service

#### Normal Operations:
```bash
# Navigate to worker directory
cd /www/wwwroot/careid-backend/services/ocr-worker

# Start persistent worker in background via PM2 or systemd
pm2 start server.py --name careid-ocr-worker --interpreter python3 -- --port 5050

# Inspect worker logs
pm2 logs careid-ocr-worker

# Restart worker
pm2 restart careid-ocr-worker
```

#### Health Probe Verification:
```bash
curl -i http://127.0.0.1:5050/health
# Expected JSON response: {"status":"ok","worker":"CareID-Persistent-PaddleOCR","engineReady":true}
```

---

### 1.3 Local Development Docker PostgreSQL

#### Normal Operations:
```bash
# Check container status
docker ps --filter "name=careid-test-postgres"

# Restart container
docker restart careid-test-postgres

# View container logs
docker logs careid-test-postgres --tail 100
```

---

## 2. Emergency Incident Response Procedures

### 2.1 Scenario: Backend Process Crash Loop or Out-Of-Memory (OOM)
- **Symptoms:** PM2 restart count incrementing rapidly; `pm2 status` shows `errored`; HTTP 502 Bad Gateway from Nginx.
- **Procedure:**
  1. Inspect error logs immediately:
     ```bash
     tail -n 100 /www/wwwroot/careid-backend/logs/pm2-error.log
     ```
  2. If memory leak detected (>1GB memory consumption):
     ```bash
     # Verify memory restart threshold in ecosystem.config.js (max_memory_restart: '1G')
     pm2 restart careid-backend-api --update-env
     ```
  3. If node module or build error:
     ```bash
     cd /www/wwwroot/careid-backend
     # Re-generate Prisma client bindings
     npx prisma generate
     # Rebuild NestJS distribution
     npm run build
     # Restart process
     pm2 restart careid-backend-api
     ```

---

### 2.2 Scenario: PostgreSQL Connection Pool Exhaustion
- **Symptoms:** `/api/v1/ready` returns HTTP 503 (`database: disconnected`); NestJS logs show `Timed out fetching a new connection from the pool`.
- **Diagnosis:**
  ```sql
  -- Connect to PostgreSQL via psql
  psql -U careid_staging_user -d careid_staging_db -h 127.0.0.1

  -- Check active connections count
  SELECT count(*) FROM pg_stat_activity WHERE datname = 'careid_staging_db';

  -- Identify idle in transaction queries holding locks
  SELECT pid, now() - pg_stat_activity.query_start AS duration, query, state
  FROM pg_stat_activity
  WHERE state != 'idle' AND datname = 'careid_staging_db'
  ORDER BY duration DESC;
  ```
- **Remediation:**
  ```sql
  -- Terminate stuck backend connections (replace <PID> with offending process id)
  SELECT pg_terminate_backend(pid) 
  FROM pg_stat_activity 
  WHERE datname = 'careid_staging_db' 
    AND pid <> pg_backend_pid() 
    AND state = 'idle in transaction' 
    AND now() - query_start > interval '2 minutes';
  ```
  In `.env`:
  ```ini
  # Ensure connection pool max is aligned with PostgreSQL max_connections
  DB_POOL_MAX=15
  DB_CONNECTION_TIMEOUT_MS=5000
  DB_IDLE_TIMEOUT_MS=10000
  ```
  Then reload PM2:
  ```bash
  pm2 reload careid-backend-api
  ```

---

### 2.3 Scenario: Redis / Cache Corruption or Memory Saturation
- **Symptoms:** Backend throws Redis connection or parsing errors; rate-limiting freezes legitimate users.
- **Remediation:**
  ```bash
  # Check Redis connectivity
  redis-cli ping

  # Flush non-persistent cache keys safely
  redis-cli -n 0 FLUSHDB ASYNC

  # Verify memory usage
  redis-cli info memory
  ```
  *Note:* The CareID backend architecture is decoupled from Redis; if Redis daemon is stopped, backend session lookups gracefully degrade to direct PostgreSQL queries without clinical data disruption.

---

### 2.4 Scenario: PaddleOCR Microservice Hanging on Large PDF
- **Symptoms:** OCR worker CPU at 100% for >180s; memory exceeds 1.5GB; subsequent uploads timeout.
- **Remediation:**
  1. Kill hanging Python worker:
     ```bash
     pm2 restart careid-ocr-worker
     ```
  2. Clear temporary processing directory:
     ```bash
     rm -rf /www/wwwroot/careid-backend/services/ocr-worker/tmp/*
     ```
  3. Mark orphaned database jobs as failed:
     ```sql
     UPDATE "OCRJob" 
     SET status = 'FAILED', 
         "failureReason" = 'Worker timeout during heavy PDF rasterization - switched to manual verification' 
     WHERE status = 'PROCESSING' AND "updatedAt" < NOW() - INTERVAL '5 minutes';
     ```

---

### 2.5 Scenario: Third-Party SMS / Email Provider (Brevo) Outage
- **Symptoms:** Patients cannot receive login verification OTP via email/SMS.
- **Remediation:**
  1. Verify Brevo API status via external command:
     ```bash
     curl -H "api-key: <BREVO_API_KEY>" https://api.brevo.com/v3/account
     ```
  2. In staging/test environments, activate test OTP allowlist:
     ```ini
     ENABLE_TEST_OTP=true
     TEST_OTP_CODE=123456
     TEST_PHONE_NUMBERS="+16505550001,+16505550002,+16505550003,+16505550004"
     ```
  3. In production, temporarily route phone authentication to Firebase Admin SDK fallback provider.

---

## 3. Disaster Recovery: Backup & Restore Procedures

### 3.1 Database Backup Procedure (`pg_dump`)
Execute daily automated and pre-deployment manual backups:
```bash
# Define backup destination and timestamp
BACKUP_DIR="/www/backup/careid_database"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Perform consistent custom-format dump
pg_dump -U careid_staging_user -h 127.0.0.1 -F c -b -v -f "$BACKUP_DIR/careid_db_$TIMESTAMP.dump" careid_staging_db

# Compute and log SHA-256 integrity hash
sha256sum "$BACKUP_DIR/careid_db_$TIMESTAMP.dump" > "$BACKUP_DIR/careid_db_$TIMESTAMP.dump.sha256"
```

### 3.2 Database Rollback / Restore Procedure (`pg_restore`)
```bash
# 1. Stop backend API to prevent active transactions
pm2 stop careid-backend-api

# 2. Terminate existing database connections
psql -U postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'careid_staging_db';"

# 3. Drop and recreate clean database
dropdb -U postgres careid_staging_db
createdb -U postgres -O careid_staging_user careid_staging_db

# 4. Restore from verified dump file
pg_restore -U careid_staging_user -h 127.0.0.1 -d careid_staging_db -v "$BACKUP_DIR/careid_db_<TIMESTAMP>.dump"

# 5. Start backend API and verify health
pm2 start careid-backend-api
curl -i https://360api.vnvision.in/api/v1/ready
```

---

## 4. Post-Deployment Rollback Runbook

If a new backend deployment introduces critical regressions:
1. Revert to previous release artifact:
   ```bash
   cd /www/wwwroot/careid-backend
   cp -r /www/backup/releases/careid-backend-previous/* .
   ```
2. Re-apply Prisma schema if migrations need rollback:
   ```bash
   npx prisma migrate resolve --rolled-back "<MIGRATION_NAME>"
   ```
3. Restart PM2 and verify live endpoints:
   ```bash
   pm2 reload ecosystem.config.js
   curl -i https://360api.vnvision.in/api/v1/health
   curl -i https://360api.vnvision.in/api/v1/ready
   ```
4. Verify from physical mobile client:
   - Launch Patient App on Xiaomi Redmi 8A Dual.
   - Verify digital health card renders with valid cryptographic QR.

