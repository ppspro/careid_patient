# 06. Missing Backend API Requirements — CareID Patient App
**Project:** `C:\Users\PABANI\CareID_patient_app`  
**Backend:** `https://360api.vnvision.in`  
**Authoritative Reference:** `CareID-Staging.postman_collection.json`  
**Audit Date:** October 31, 2026  

---

## 1. Summary of Genuinely Missing Endpoints

The complete Postman collection was exhaustively queried for all patient app domains. The following features present in the approved Figma design (`CAREID-AIO-FIGMA`, canvas `17:55`) have **ZERO** supporting endpoints in the backend collection.

> [!IMPORTANT]
> **PROPOSED BACKEND APIS — NOT CURRENTLY AVAILABLE IN POSTMAN.**
> These recommendations represent legitimate gaps between Figma designs/PRD and the staging API contract. They must be developed by the backend team.

---

## 2. Prioritized Backend API Request List

| Module | Figma Screen | Missing Functionality | Suggested Method | Suggested Endpoint | Required Fields / Payload | Priority |
|---|---|---|---|---|---|---|
| **Treatment Financing** | `TreatmentOffersScreen (20:26404)` | List healthcare financing packages & partner offers | `GET` | `/api/v1/treatment-offers` | `category`, `tenureMonths`, `interestRate`, `savings` | **P1 (High)** |
| **Treatment Financing** | `TreatmentOffersScreen (20:26404)` | Calculate monthly loan repayment rate | `POST` | `/api/v1/treatment-offers/calculate` | `loanAmount`, `tenureMonths` -> `monthlyEmi`, `apr` | **P1 (High)** |
| **Treatment Financing** | `TreatmentOfferDetailsScreen (20:26692)` | Submit treatment financing application | `POST` | `/api/v1/treatment-offers/apply` | `offerId`, `applicantIncome`, `requestedTenure` | **P1 (High)** |
| **Specialized Dental** | `DentalRecordsScreen (20:21111)` | Structured odontogram & FDI tooth-by-tooth charting | `GET` | `/api/v1/medical-records/dental/chart` | `patientProfileId` -> `toothNumber (1-32)`, `condition`, `restorations` | **P2 (Medium)** |
| **Specialized Vision** | `VisionRecordsScreen (20:21240)` | Optical prescription matrix (OD/OS Sphere, Cyl, Axis, PD) | `GET` | `/api/v1/medical-records/vision/prescriptions` | `sphereOD`, `cylinderOD`, `axisOD`, `addOD`, `pdMm` | **P2 (Medium)** |
| **Emergency Center** | `EmergencyCenterScreen (20:23700)` | Broadcast active emergency distress alert to nearby hospitals | `POST` | `/api/v1/emergency/broadcast` | `latitude`, `longitude`, `bloodGroup`, `primaryCondition` | **P2 (Medium)** |
| **Biometric Auth** | `BiometricSetupScreen (20:24850)` | Register device cryptographic public key for biometric pass | `POST` | `/api/v1/auth/biometric/register` | `publicKey`, `deviceModel`, `signature` | **P3 (Low)** |

---

## 3. Staging Backend Defects Requiring Immediate Fixes

1. **`GET /api/v1/appointments/patient/my-appointments`:**
   - **Error:** Returns `HTTP 500 InternalServerError`: `"An unexpected database error occurred."`
   - **Remediation:** Fix database SQL join or table constraint in appointments table on staging.
2. **`GET /api/v1/security/consents`:**
   - **Error:** Returns `HTTP 403 ForbiddenException`: `"Forbidden resource"`.
   - **Remediation:** Permit patient token scope to read their own security consent grants.
