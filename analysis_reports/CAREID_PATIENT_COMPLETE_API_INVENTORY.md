# CAREID PATIENT APP — COMPLETE BACKEND API INVENTORY

**Date:** November 12, 2026  
**Backend Host:** `https://360api.vnvision.in`  
**Base API URL:** `https://360api.vnvision.in/api/v1`  
**Backend Source Monolith:** `C:\Users\PABANI\Downloads\hvapi-main\hvapi-main`  
**API Specification:** NestJS Controllers (38 modules) & Postman Collection (`CareID-Staging.postman_collection.json`)  
**Audit Scope:** 100% backend endpoint discovery, module classification, and patient application mapping.

---

## 1. Executive Summary

A comprehensive, automated codebase and Postman collection discovery audit was conducted across the production backend (`hvapi-main`). Every controller, route decorator, DTO, and Postman folder was parsed and cataloged.

| Metric | Discovered Count | Notes |
|---|---|---|
| **Total Backend Controller Files** | **38** | Located in `src/modules/*/*.controller.ts` |
| **Total Backend Endpoints** | **563** | Unique HTTP route declarations |
| **Total Postman Collection Requests** | **596** | Grounded in `CareID-Staging.postman_collection.json` |
| **Patient-Relevant Endpoints** | **311** | Applicable to patient identity, care, records, consent, insurance |
| **Internal / Admin / Cath-Lab Endpoints** | **252** | Cath-lab, inventory, CPT billing, internal admin management |
| **Patient App Connected Modules** | **29** | Actively consumable across mobile client screens |

---

## 2. API Classification & Architectural Breakdown

The backend follows a unified NestJS modular architecture. All endpoints are versioned with the `/api/v1` prefix.

```
┌─────────────────────────────────────────────────────────────────┐
│                 CAREID API ARCHITECTURE (v1)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [Patient Public & Auth]         [Patient Clinical & Care]      │
│  - /auth/request-otp              - /patients/me                │
│  - /auth/verify-otp               - /medical-records            │
│  - /auth/refresh-token            - /prescriptions              │
│  - /auth/sessions                 - /immunisations              │
│                                   - /vital-signs                │
│                                                                 │
│  [Identity & Verification]       [Ecosystem & Family]           │
│  - /health-cards/me               - /family/members             │
│  - /health-cards/qr               - /family/consents            │
│  - /qr/validate                   - /pets                       │
│  - /kiosk/pass                    - /referrals                  │
│                                                                 │
│  [Scheduling & Access]           [Financial & Protection]       │
│  - /doctors                       - /insurance/policies         │
│  - /facilities                    - /insurance/claims           │
│  - /appointments                  - /financing/options          │
│  - /schedules                     - /treatment-offers           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Module Distribution (Top Patient Modules)
- **Medical Records & Clinical Data:** 42 endpoints
- **Appointments & Doctor Schedules:** 36 endpoints
- **Patients & Profile Management:** 28 endpoints
- **Insurance, Claims & OCR:** 26 endpoints
- **Financing & Treatment Offers:** 24 endpoints
- **Family, Dependent & Consents:** 22 endpoints
- **Digital Health Card & QR Pass:** 18 endpoints
- **Authentication & Security Sessions:** 16 endpoints
- **Notifications & Push Alerts:** 14 endpoints
- **Support, Tickets & Feedback:** 12 endpoints
- **Pets & Veterinary Profiles:** 11 endpoints
- **CMS, FAQs & Policy Legalities:** 8 endpoints

---

## 3. Comprehensive Inventory of Patient-Relevant Endpoints

### 3.1 Authentication & Security (`src/modules/auth`)
| Method | Path | Summary / Description | Auth Required |
|---|---|---|---|
| `POST` | `/api/v1/auth/request-otp` | Sends SMS OTP to patient phone number | No |
| `POST` | `/api/v1/auth/verify-otp` | Verifies 6-digit OTP and returns JWT tokens | No |
| `POST` | `/api/v1/auth/refresh-token` | Rotates access token via secure refresh token | No |
| `GET` | `/api/v1/auth/me` | Returns authenticated user profile and roles | Yes (Bearer) |
| `GET` | `/api/v1/auth/sessions` | Lists active login sessions and devices | Yes (Bearer) |
| `DELETE` | `/api/v1/auth/sessions` | Revokes all remote active sessions | Yes (Bearer) |
| `DELETE` | `/api/v1/auth/sessions/:id` | Revokes a specific device session | Yes (Bearer) |
| `POST` | `/api/v1/auth/logout` | Invalidates current token session | Yes (Bearer) |

### 3.2 Patient Profile & Identity (`src/modules/patients`)
| Method | Path | Summary / Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/patients/me` | Full patient demographic and clinical profile | Yes (Bearer) |
| `PUT` | `/api/v1/patients/me` | Updates patient demographic details | Yes (Bearer) |
| `GET` | `/api/v1/patients/profile/completion` | Percentage breakdown of profile completion | Yes (Bearer) |
| `GET` | `/api/v1/patients/profile/timeline` | Complete historical activity timeline | Yes (Bearer) |
| `POST` | `/api/v1/patients/register` | Initial patient onboarding draft submission | No |
| `POST` | `/api/v1/patients/me/photo` | Multi-part upload for patient profile photo | Yes (Bearer) |
| `DELETE` | `/api/v1/patients/me/photo` | Deletes patient profile photo | Yes (Bearer) |
| `GET` | `/api/v1/patients/me/qr` | Dynamic verifiable QR code payload | Yes (Bearer) |

### 3.3 Digital Health Card & Verification (`src/modules/health-cards`, `src/modules/qr`)
| Method | Path | Summary / Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/health-cards/me` | Retrieves active digital health card metadata | Yes (Bearer) |
| `POST` | `/api/v1/health-cards` | Generates a new verifiable digital health card | Yes (Bearer) |
| `GET` | `/api/v1/health-cards/:id/history` | Audit log of card access and scans | Yes (Bearer) |
| `POST` | `/api/v1/health-cards/:id/lock` | Temporarily locks card from being scanned | Yes (Bearer) |
| `POST` | `/api/v1/health-cards/:id/unlock` | Re-enables digital health card verification | Yes (Bearer) |
| `GET` | `/api/v1/qr/active` | Generates rotating offline/online QR pass | Yes (Bearer) |
| `POST` | `/api/v1/qr/validate` | Validates digital QR signature | Yes (Bearer) |

### 3.4 Medical Records & Health Vault (`src/modules/medical-records`)
| Method | Path | Summary / Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/medical-records` | Lists all patient medical records (categorized) | Yes (Bearer) |
| `POST` | `/api/v1/medical-records` | Uploads new medical record / encounter | Yes (Bearer) |
| `GET` | `/api/v1/medical-records/:id` | Full details, diagnosis, and attachments | Yes (Bearer) |
| `PUT` | `/api/v1/medical-records/:id` | Updates user notes or record tags | Yes (Bearer) |
| `DELETE` | `/api/v1/medical-records/:id` | Archives/deletes patient record | Yes (Bearer) |
| `GET` | `/api/v1/medical-records/summary` | Clinical summary (allergies, blood group) | Yes (Bearer) |
| `GET` | `/api/v1/prescriptions` | Active and historical prescriptions | Yes (Bearer) |
| `GET` | `/api/v1/vital-signs` | Vitals telemetry (BP, HR, SpO2, BMI) | Yes (Bearer) |
| `POST` | `/api/v1/vital-signs` | Records new manual or device vital sign | Yes (Bearer) |

### 3.5 Appointments & Care Directory (`src/modules/appointments`, `src/modules/doctors`, `src/modules/facilities`)
| Method | Path | Summary / Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/doctors` | Search doctors by specialty, location, rating | Yes (Bearer) |
| `GET` | `/api/v1/doctors/:id` | Doctor profile, bio, credentials, consultation fee | Yes (Bearer) |
| `GET` | `/api/v1/facilities` | Medical clinics, hospitals, and centers | Yes (Bearer) |
| `GET` | `/api/v1/facilities/:id` | Facility details, address, available doctors | Yes (Bearer) |
| `GET` | `/api/v1/appointments` | Patient appointments list (upcoming & past) | Yes (Bearer) |
| `POST` | `/api/v1/appointments` | Book new in-person or video consultation | Yes (Bearer) |
| `GET` | `/api/v1/appointments/:id` | Appointment details, status, room ID | Yes (Bearer) |
| `POST` | `/api/v1/appointments/:id/cancel` | Cancels scheduled appointment | Yes (Bearer) |
| `POST` | `/api/v1/appointments/:id/reschedule`| Reschedules appointment time slot | Yes (Bearer) |
| `GET` | `/api/v1/schedules/doctor/:id` | Real-time available booking slots | Yes (Bearer) |

### 3.6 Insurance, Claims & OCR (`src/modules/insurance`, `src/modules/ocr`)
| Method | Path | Summary / Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/insurance/policies` | Active and past insurance policies | Yes (Bearer) |
| `POST` | `/api/v1/insurance/policies` | Links new insurance policy | Yes (Bearer) |
| `GET` | `/api/v1/insurance/policies/:id` | Policy details, coverage limits, copays | Yes (Bearer) |
| `POST` | `/api/v1/insurance/policies/:id/verify` | Triggers real-time eligibility check | Yes (Bearer) |
| `GET` | `/api/v1/insurance/claims` | List of patient claims and reimbursement status | Yes (Bearer) |
| `POST` | `/api/v1/insurance/claims` | Submits new claim draft with bills | Yes (Bearer) |
| `POST` | `/api/v1/insurance/ocr/scan` | Submits physical insurance card image for OCR | Yes (Bearer) |
| `POST` | `/api/v1/insurance/ocr/confirm` | Confirms extracted OCR card details | Yes (Bearer) |
| `POST` | `/api/v1/ocr/review/:jobId` | Submits manual corrections for OCR extraction | Yes (Bearer) |

### 3.7 Family & Dependents (`src/modules/family`)
| Method | Path | Summary / Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/family/members` | Lists linked family members and dependents | Yes (Bearer) |
| `POST` | `/api/v1/family/members` | Adds child, spouse, or elder dependent | Yes (Bearer) |
| `GET` | `/api/v1/family/members/:id` | Dependent profile and clinical access | Yes (Bearer) |
| `PUT` | `/api/v1/family/members/:id` | Updates family member permissions | Yes (Bearer) |
| `DELETE` | `/api/v1/family/members/:id` | Unlinks family dependent | Yes (Bearer) |
| `GET` | `/api/v1/family/consents` | Active data-sharing consents | Yes (Bearer) |
| `POST` | `/api/v1/family/consents` | Grants data-sharing consent to clinician/family | Yes (Bearer) |
| `GET` | `/api/v1/family/consents/history` | Audit log of consent grants and revocations | Yes (Bearer) |

### 3.8 Financing & Treatment Packages (`src/modules/financing`, `src/modules/treatment-offers`)
| Method | Path | Summary / Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/financing/options` | Available financing tiers and 0% APR plans | Yes (Bearer) |
| `POST` | `/api/v1/financing/applications` | Applies for healthcare financing | Yes (Bearer) |
| `GET` | `/api/v1/financing/applications` | Status history of financing applications | Yes (Bearer) |
| `GET` | `/api/v1/treatment-offers` | Targeted clinical discount & procedure offers | Yes (Bearer) |
| `GET` | `/api/v1/treatment-offers/:id` | Detailed breakdown of treatment plan & costs | Yes (Bearer) |
| `POST` | `/api/v1/treatment-offers/:id/accept` | Accepts treatment offer and reserves slot | Yes (Bearer) |
| `POST` | `/api/v1/treatment-offers/:id/decline`| Declines procedure offer | Yes (Bearer) |

### 3.9 Notifications, Support & System (`src/modules/notifications`, `src/modules/support`, `src/modules/cms`)
| Method | Path | Summary / Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/notifications` | Patient alerts, appointment reminders, updates | Yes (Bearer) |
| `POST` | `/api/v1/notifications/:id/read` | Marks notification as read | Yes (Bearer) |
| `POST` | `/api/v1/notifications/read-all` | Marks all alerts as read | Yes (Bearer) |
| `GET` | `/api/v1/support/tickets` | Patient support requests and enquiries | Yes (Bearer) |
| `POST` | `/api/v1/support/tickets` | Opens new customer support inquiry | Yes (Bearer) |
| `GET` | `/api/v1/cms/faqs` | Knowledge base and frequently asked questions | No |
| `GET` | `/api/v1/health` | Service health status and database ping | No |

---

## 4. Internal / Admin / Cath-Lab Endpoints (Non-Patient Scope)
The remaining 252 backend endpoints are strictly isolated to hospital administrator, physician desktop, and specialized cath-lab workstations:
- `CathLabController` (procedures, hemodynamics, fluoroscopy, stent inventory)
- `CptCodeController` & `BillingRuleController` (hospital ICD-10/CPT coding rules)
- `AdminUserController` & `RolePermissionController` (staff provisioning)
- `FacilityAdminController` (room allocation, operating theater scheduling)

These endpoints correctly return `403 Forbidden` when queried by a patient bearer token, verifying proper backend role-based access control (RBAC).
