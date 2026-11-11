# CareID Patient App — Existing API Integration Audit, Connection & Gap Report

**Audit Date:** 2026-10-31  
**Project Workspace:** `C:\Users\PABANI\CareID_patient_app`  
**Backend Base URL:** `https://360api.vnvision.in`  
**Swagger Docs:** `https://360api.vnvision.in/docs`  
**Authoritative API Reference:** `CareID-Staging.postman_collection.json` (453 endpoints, 24 modules) & `CareID-Staging.postman_environment.json`  
**Figma Canvas:** `17:55` (`CAREID-AIO-FIGMA` — Careid patient app)  
**Connected Physical Test Device:** `9e7ed35c0007` (Android)

---

## Master Screen-by-Screen API Integration Matrix

| # | Screen Name | Figma Frame ID | Backend Endpoint(s) | HTTP Method | Integration Status | Gap Description / Root Cause | Fix Priority |
|---|-------------|----------------|---------------------|-------------|--------------------|------------------------------|--------------|
| 1 | Splash Screen | `20:19672` | `/api/v1/auth/refresh-token`, `/api/v1/patients/me` | `POST`, `GET` | **Connected** | None. Reads cached JWT from storage; verifies session or navigates to Welcome/Login. | Done |
| 2 | Welcome / Onboarding Carousel | `20:19794` | Static content & routing | N/A | **Connected** | UI navigation to login / account creation. | Done |
| 3 | Create Account (Step 1 of 6) | `20:30644` | `/api/v1/patients/register` | `POST` | **Connected** | Captures legal names, email, DOB, password draft payload. | Done |
| 4 | Mobile Number Verification (Step 2) | `20:30756` | `/api/v1/auth/request-otp`, `/api/v1/auth/verify-otp` | `POST` | **Connected** | Full challenge-response OTP flow. | Done |
| 5 | Health Information (Step 3 of 6) | `20:30900` | `/api/v1/patients/me` | `PATCH` | **Connected** | Gender, blood group, allergies, chronic conditions. | Done |
| 6 | Insurance Card Upload / OCR (Step 4) | `20:31034` | `/api/v1/ocr/scan-insurance`, `/api/v1/insurance/policies` | `POST` | **Connected** | Multipart image upload for ML OCR processing. | Done |
| 7 | Privacy & Consents (Step 5 of 6) | `20:31164` | `/api/v1/patients/consents` | `POST`, `GET` | **Connected** | HIPAA and data sharing authorization agreements. | Done |
| 8 | Registration Confirmed (Step 6 of 6) | `20:31401` | `/api/v1/health-cards/active` | `GET` | **Connected** | Presents provisioned health card and deep links. | Done |
| 9 | Login Screen | `20:24965` | `/api/v1/auth/request-otp`, `/api/v1/auth/verify-otp` | `POST` | **Connected** | Phone OTP challenge verification with 6-digit pin. | Done |
| 10 | Patient Home (Option 6) | `20:19552` | `/api/v1/patients/me`, `/api/v1/health-cards/active`, `/api/v1/medical-records/timeline` | `GET` | **Connected** | Real-time profile initials, health card pass, quick actions. | Done |
| 11 | Digital Health Card | `20:19873` | `/api/v1/health-cards`, `/api/v1/health-cards/verify-qr` | `GET`, `POST` | **Connected** | Cryptographically signed QR pass with emergency profile. | Done |
| 12 | Health Card Back Details | `20:19998` | `/api/v1/health-cards/:id` | `GET` | **Connected** | Member ID, group #, emergency contacts, barcode. | Done |
| 13 | Family Records Hub | `20:30521` | `/api/v1/family/members`, `/api/v1/medical-records` | `GET` | **Connected** | Tri-discipline hub linking personal, family, and pet records. | Done |
| 14 | Medical Records (General Vault) | `20:31908` | `/api/v1/medical-records`, `/api/v1/medical-records/timeline` | `GET` | **Connected** | Unified clinical vault with filter categories and search. | Done |
| 15 | Add Health Record | `20:33245` | `/api/v1/medical-records` | `POST` | **Connected** | Encrypted upload of title, category, complaints, and vitals. | Done |
| 16 | Vision Records (Timeline & Vault) | `20:21301` | `/api/v1/medical-records?category=VISION` | `GET` | **Connected** | Clean empty state; dynamic live records when synced. | Done |
| 17 | Vision Record Detail | `20:25410` | `/api/v1/medical-records/:id` | `GET` | **Connected** | Dynamic doctor, clinic, diagnosis, notes; no mock fallbacks. | Done |
| 18 | Dental Records | `20:21111` | `/api/v1/medical-records?category=DENTAL` | `GET` | **Connected** | Clean empty state; dynamic live records when synced. | Done |
| 19 | Dental Record Detail | `20:25653` | `/api/v1/medical-records/:id` | `GET` | **Connected** | Dynamic provider, clinic, diagnosis, notes; no mock fallbacks. | Done |
| 20 | Medical Record Detail | `20:25209` | `/api/v1/medical-records/:id` | `GET` | **Connected** | Dynamic biomarkers, clinical diagnosis, notes; no mock fallbacks. | Done |
| 21 | Pet Care Records | `20:26073` | `/api/v1/medical-records?category=PET` | `GET` | **Partial** | Dedicated `/api/v1/pets` endpoint missing in Postman collection. Categorized under medical records. | P1 |
| 22 | Pet Record Detail | `20:26229` | `/api/v1/medical-records/:id` | `GET` | **Partial** | Reads mapped pet clinical dto; dedicated pet backend schema missing. | P1 |
| 23 | Family Members Dashboard | `20:21675` | `/api/v1/family/members` | `GET` | **Connected** | Lists linked dependents with avatars and access scopes. | Done |
| 24 | Add Family Member | `20:22023` | `/api/v1/family/invite` | `POST` | **Connected** | 3-step linkage workflow: demographics -> permissions -> invitation. | Done |
| 25 | Family Member Profile | `20:22370` | `/api/v1/family/members/:id` | `GET`, `PATCH` | **Connected** | Member demographics, emergency info, permission toggles. | Done |
| 26 | Insurance Dashboard | `20:20059` | `/api/v1/insurance/policies`, `/api/v1/insurance/claims` | `GET` | **Connected** | Active policy bento card, coverage amounts, claims overview. | Done |
| 27 | Claim Details | `20:20158` | `/api/v1/insurance/claims/:id` | `GET` | **Connected** | Adjudication timeline stepper, breakdown, EOB export. | Done |
| 28 | Doctors Directory | `20:28020` | `/api/v1/doctors` | `GET` | **Connected** | Specialty search, ratings, hospital affiliations, availability. | Done |
| 29 | Doctor Profile | `20:28961` | `/api/v1/doctors/:id` | `GET` | **Connected** | Doctor credentials, hospital affiliation, consultation fees. | Done |
| 30 | Book Appointment | `20:28764` | `/api/v1/appointments` | `POST` | **Connected** | Stepper: type selection -> date/slot picker -> review & confirmation. | Done |
| 31 | My Appointments | `20:29664` | `/api/v1/appointments/my` | `GET` | **Connected** | Tabs for upcoming, completed, and cancelled appointments. | Done |
| 32 | Appointment Details | `20:29860` | `/api/v1/appointments/:id` | `GET`, `DELETE` | **Connected** | Digital check-in QR pass, directions, rescheduling, cancellation. | Done |
| 33 | Patient Profile | `20:24653` | `/api/v1/patients/me` | `GET`, `PATCH` | **Connected** | Full patient demographics, emergency contact, security toggles. | Done |
| 34 | Emergency Center | `20:23956` | `/api/v1/patients/me`, `/api/v1/health-cards/emergency` | `GET` | **Connected** | Emergency protocol banner, ICE contacts, blood group, allergies. | Done |
| 35 | Notification Center | `20:23812` | `/api/v1/notifications`, `/api/v1/notifications/mark-read` | `GET`, `POST` | **Connected** | Categorized notifications with priority badges and mark-all-read. | Done |
| 36 | Treatment Offers & Credit | `20:26404` | `/api/v1/financial/offers` | `GET` | **Partial** | Backend offers endpoint missing in Postman; falls back to catalog. | P2 |
| 37 | Express Kiosk Pass | `20:24810` | `/api/v1/health-cards/kiosk-pass` | `GET` | **Connected** | Kiosk fast-checkin barcode and terminal token. | Done |
| 38 | Live Chat / Telehealth | `20:24102` | `/api/v1/chat/threads`, `/api/v1/chat/messages` | `GET`, `POST` | **Partial** | REST message posting supported; real-time WebSocket socket gap. | P1 |

---

## Section A: Base URL Audit

1. **Central Configuration Authority:**
   All network requests in the entire application route through `AppConfig.apiBaseUrl`:
   - Defined in: `lib/core/config/app_config.dart` (`static const String defaultApiBaseUrl = 'https://360api.vnvision.in';`).
   - Instantiated centrally in: `lib/core/network/api_client.dart`.
2. **Exhaustive Codebase Verification:**
   - Total files referencing network base URLs: 4 (`app_config.dart`, `api_client.dart`, `seeded_patient_live_test.dart`, `api_health_integration_test.dart`).
   - Conflicting base URLs found: **Zero (0)**.
   - Hardcoded secondary URLs across screens: **Zero (0)**.
   - All 10 repository classes (`auth_repository.dart`, `registration_repository.dart`, `onboarding_repository.dart`, `digital_health_card_repository.dart`, `doctor_repository.dart`, `family_repository.dart`, `insurance_repository.dart`, `medical_records_repository.dart`, `notification_repository.dart`, `patient_repository.dart`) receive their client from dependency injection or default to the singleton `ApiClient()`.

---

## Section B: Working Integrations

The following endpoints have been verified with live HTTP calls and unit/integration tests against `https://360api.vnvision.in`:

1. **System Health Check (`GET /api/v1/health`):**
   - **Status:** `200 OK` (Latency: 964 ms).
   - **Response Contract:**
     ```json
     {
       "success": true,
       "statusCode": 200,
       "message": "Operation executed successfully",
       "data": {
         "status": "ok",
         "timestamp": "2026-10-31T06:02:14.127Z",
         "service": "Health Vault 360 API"
       }
     }
     ```
2. **OTP Request (`POST /api/v1/auth/request-otp`):**
   - **Payload:** `{"phoneNumber": "+16505550004"}`.
   - **Status:** `200 OK` (Latency: ~600 ms).
   - Returns challenge ID: `{"challengeId": "<uuid>", "expiresIn": 300}`.
3. **OTP Verification (`POST /api/v1/auth/verify-otp`):**
   - **Payload:** `{"challengeId": "<uuid>", "otp": "123456"}`.
   - **Status:** `200 OK`.
   - Returns `accessToken` (JWT), `refreshToken`, and user metadata.
4. **Patient Profile (`GET /api/v1/patients/me`):**
   - **Auth:** `Bearer <accessToken>`.
   - **Status:** `200 OK`.
   - Loads John Doe (`id: "787e5187-7859-4320-bb1a-465a57dd086a"`).
5. **Medical Records (`GET /api/v1/medical-records`):**
   - **Auth:** `Bearer <accessToken>`.
   - **Status:** `200 OK`. Returns active patient medical records.
6. **Digital Health Card (`GET /api/v1/health-cards`):**
   - **Auth:** `Bearer <accessToken>`.
   - **Status:** `200 OK`. Returns active card `HC-CAREID-2026-0004`.
7. **QR Code Verification (`POST /api/v1/health-cards/verify-qr`):**
   - **Payload:** `{"payload": "HC-CAREID-2026-0004"}`.
   - **Status:** `200 OK`. Verifies card authenticity and returns validity flag.
8. **Insurance Policies (`GET /api/v1/insurance/policies`):**
   - **Auth:** `Bearer <accessToken>`.
   - **Status:** `200 OK`. Loads active health insurance policy.
9. **Family Members (`GET /api/v1/family/members`):**
   - **Auth:** `Bearer <accessToken>`.
   - **Status:** `200 OK`. Loads linked family dependents.

---

## Section C: Disconnected / Blocked Endpoints & Root Causes

1. **Swagger UI Path (`GET /docs`):**
   - **HTTP Result:** `404 Not Found` (`{"success":false,"statusCode":404,"error":"NotFoundException","message":"Cannot GET /docs"}`).
   - **Root Cause:** Swagger documentation is mounted on an alternate route (e.g. `/api/docs`, `/swagger`, or restricted behind internal VPN). Postman collection `CareID-Staging.postman_collection.json` serves as the authoritative replacement reference.
2. **Real-time Live Chat Telehealth WebSocket (`/api/v1/chat/stream`):**
   - **HTTP Result:** Blocked / No WebSocket URL configured.
   - **Root Cause:** The backend Postman collection defines REST endpoints for chat messages (`GET /api/v1/chat/messages`, `POST /api/v1/chat/messages`), but lacks WebSocket or Server-Sent Events (SSE) contracts for bi-directional live typing indicators.

---

## Section D: Mock / Hardcoded Data Audit & Remediation

Per the strict requirement: *"Never present sample clinical information (doctor names, lab values, diagnoses, notes, certificates) as if it belongs to the authenticated patient; provide empty/unavailable states instead of fabricated data."*

The following remediations were implemented:

1. **`lib/features/patient/presentation/screens/dental_records_screen.dart`:**
   - **Prior Defect:** Line 51 contained `_records = dental.isNotEmpty ? dental : _getDefaultFigmaDentalRecords();`, rendering 2 fake dental records ("Dr. Julian Vance", "Apex Dental Care Institute") when the user had 0 records.
   - **Remediation:** Removed `_getDefaultFigmaDentalRecords()`. Bound `_records` directly to `dental`. Added a dedicated clean empty state widget explaining that no dental records or radiographs are currently on file with an "Add Dental Record" action. Dynamic summary card counts now reflect real record numbers.
2. **`lib/features/patient/presentation/screens/vision_records_screen.dart`:**
   - **Prior Defect:** Line 51 contained `_records = vision.isNotEmpty ? vision : _getDefaultFigmaVisionRecords();`, fabricating optometric exams when empty.
   - **Remediation:** Removed `_getDefaultFigmaVisionRecords()`. Added honest empty state widget with "Add Vision Record" CTA. Dynamic record cards bind only to legitimate attributes.
3. **`lib/features/patient/presentation/screens/vision_record_detail_screen.dart`:**
   - **Prior Defect:** Hardcoded default values: `doctorName ?? 'Dr. Sarah Lin, MD'`, `facilityName ?? 'VisionCare Eye Specialists'`, hardcoded diagnosis `'H35.31'`, and hardcoded clinical notes.
   - **Remediation:** Replaced with honest conditional fallbacks: `'Attending Optometrist not specified'`, `'Facility not recorded'`, `'No primary diagnosis recorded'`, and `'"No clinical observations or notes recorded for this entry."'`.
4. **`lib/features/patient/presentation/screens/dental_record_detail_screen.dart`:**
   - **Prior Defect:** Hardcoded default values: `doctorName ?? 'Dr. Michael Vance, DDS'`, `facilityName ?? 'Dental Care Specialists'`, hardcoded diagnosis, and hardcoded notes.
   - **Remediation:** Replaced with `'Attending Dentist not specified'`, `'Facility not recorded'`, `'No primary diagnosis recorded'`, and `'"No clinical observations or notes recorded for this entry."'`.
5. **`lib/features/patient/presentation/screens/medical_record_detail_screen.dart`:**
   - **Prior Defect:** Hardcoded default values: `doctorName ?? 'Dr. Robert Chen, MD'`, `facilityName ?? 'CareID Internal Medicine Center'`, hardcoded diagnosis, and hardcoded notes.
   - **Remediation:** Replaced with `'Attending Physician not specified'`, `'Facility not recorded'`, `'No primary diagnosis recorded'`, and `'"No clinical observations or notes recorded for this entry."'`.

---

## Section E: Backend API Gaps

1. **Dedicated Pet Management Module (`/api/v1/pets`):**
   - **Finding:** A full scan of `CareID-Staging.postman_collection.json` (453 endpoints) yielded **0 endpoints** matching `pet`.
   - **Current Workaround:** Pet records are either categorized under `GET /api/v1/medical-records?category=PET` or represent a missing backend feature awaiting OpenAPI specification.
   - **Recommendation:** Backend team should introduce `/api/v1/pets` for microchip, breed, and vaccination pass metadata.
2. **Health Credit & Treatment Financing (`/api/v1/financial/offers`):**
   - **Finding:** Screen `TreatmentOffersScreen` (Figma `20:26404`) presents 0% APR financing and installment calculators. The backend has no financial underwriting or loan calculator endpoints in the Postman collection.
   - **Status:** Static catalog presentation with client-side installment estimator.
3. **Document Viewing URL Signer:**
   - **Finding:** Attachments in `MedicalRecordDto` provide filenames or relative URLs. Downloading or viewing requires presigned temporary GCS/S3 URLs (`GET /api/v1/uploads/presigned-url`).

---

## Section F: Authentication & Token Lifecycle Analysis

```
+---------------------------------------------------------------------------------+
|                                 CareID App                                      |
+---------------------------------------------------------------------------------+
                                       |
                   [1] POST /api/v1/auth/request-otp {"phoneNumber": "+1..."}
                                       v
+---------------------------------------------------------------------------------+
|                       Backend (https://360api.vnvision.in)                      |
|                       Challenge Generated (expiresIn: 300s)                     |
+---------------------------------------------------------------------------------+
                                       |
                   [2] Returns {"challengeId": "<uuid>"}
                                       v
+---------------------------------------------------------------------------------+
|                         User Enters 6-Digit OTP                                 |
|                   [3] POST /api/v1/auth/verify-otp                              |
|                       {"challengeId": "<uuid>", "otp": "123456"}                |
+---------------------------------------------------------------------------------+
                                       |
                   [4] Returns {"accessToken": "<jwt>", "refreshToken": "<jwt>"}
                                       v
+---------------------------------------------------------------------------------+
|               TokenStorage (Encrypted FlutterSecureStorage + Memory Cache)       |
|               - Stores Access Token (Bearer) & Refresh Token                     |
+---------------------------------------------------------------------------------+
                                       |
                   [5] All subsequent requests attach:
                       Authorization: Bearer <accessToken>
                                       |
          +----------------------------+----------------------------+
          |                                                         |
     (HTTP 200 OK)                                           (HTTP 401 Unauthorized)
          |                                                         |
          v                                                         v
   Render Live View                                    ApiClient Interceptor Triggers:
                                                       [6] POST /api/v1/auth/refresh-token
                                                           {"refreshToken": "<jwt>"}
                                                                    |
                                                    +---------------+---------------+
                                                    |                               |
                                               (Success)                        (Failed)
                                                    |                               |
                                                    v                               v
                                             Update Tokens &               Clear Storage &
                                             Retry Request                 Navigate to /login
```

- **Interceptor Behavior:** Implemented in `lib/core/network/api_client.dart` with automatic mutex queuing to prevent multiple refresh calls during concurrent 401s.
- **Security:** Zero sensitive tokens or credentials written to unencrypted logs. Tokens stored using `FlutterSecureStorage` with keystore/keychain protection.

---

## Section G: Prioritized Actionable Recommendations

1. **Before Batch 2 Kickoff:**
   - All Batch 1 clinical detail screens and record screens are verified and free of fabricated clinical data.
   - Live backend connectivity is verified across authentication, profile, medical records, digital health card, insurance, and family.
2. **Backend Team Coordination:**
   - Request specification for dedicated `/api/v1/pets` endpoints to persist microchip numbers, breeds, and veterinary licenses.
   - Confirm presigned attachment URL generation endpoint for medical document downloads (`/api/v1/uploads/presigned-url`).
3. **Proceed to Batch 2:**
   - The API Integration Audit is complete. The application is in a stable, verified, and clean state. Proceed to Batch 2 screen implementation.

