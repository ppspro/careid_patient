# CareID Patient App — Missing Backend API Requirements & Runtime Gaps Report

**Report Date:** 2026-11-02  
**Target Backend:** `https://360api.vnvision.in`  
**API Reference:** `CareID-Staging.postman_collection.json`  
**Figma Canvas:** `17:55` (`CAREID-AIO-FIGMA` — Careid patient app)  
**Document ID:** `docs/api_audit/06_missing_backend_api_requirements.md`

---

## 1. Executive Summary

During the comprehensive audit of the CareID Patient App (86 Figma screens spanning Canvas `17:55` and the 126 backend endpoints in `CareID-Staging.postman_collection.json`), four distinct functional modules implemented in the approved UI currently lack backend API backing in the staging environment. Additionally, two core runtime APIs in the Postman collection throw HTTP 500 and HTTP 403 errors when called by authenticated patient sessions.

Per the strict architecture guidelines of this project:
- **Zero Fake Mock APIs:** No simulated success responses or unauthorized backend alterations have been introduced.
- **Contract Fidelity:** The Postman collection serves as the authoritative source of truth.
- **Specification for Backend Engineering:** This report provides clear, standardized REST contract proposals for the backend team to implement.

---

## 2. Four Unbacked Functional UI Areas

### 2.1 Pet Health Records & Discipline Vault
- **Figma Reference:**
  - Frame `20:26073` ("Care ID - Health Records (Pets)", 390×1272)
  - Frame `20:26229` ("Pet Record Details", 390×1118)
- **Current App Status:**
  The frontend includes `PetRecordsScreen` and `PetRecordDetailScreen` displaying pet identification (species, breed, microchip ID, weight, vaccination history, and clinical logs). Currently, it gracefully displays empty states or falls back to generic medical records filtered by category.
- **Proposed Backend API Endpoints:**

#### `GET /api/v1/pets`
- **Method:** `GET`
- **Authentication:** `Bearer <patient_token>`
- **Description:** Returns all registered pets associated with the authenticated patient account.
- **Response Format (`200 OK`):**
```json
{
  "status": "success",
  "data": [
    {
      "id": "pet-001-uuid",
      "patientId": "787e5187-7859-4320-bb1a-465a57dd086a",
      "name": "Milo",
      "species": "Canine",
      "breed": "Golden Retriever",
      "ageYears": 4,
      "weightKg": 31.5,
      "microchipId": "985141002348102",
      "primaryVeterinarian": "Dr. Amanda Perez, DVM",
      "clinicName": "Metropolitan Animal Hospital",
      "avatarUrl": "https://cdn.vnvision.in/careid/pets/milo.png",
      "vaccinationStatus": "UP_TO_DATE",
      "createdAt": "2026-03-15T10:00:00Z"
    }
  ]
}
```

#### `GET /api/v1/pets/:id/records`
- **Method:** `GET`
- **Authentication:** `Bearer <patient_token>`
- **Description:** Lists vaccination certificates, treatment notes, and lab reports for a specific pet.
- **Response Format (`200 OK`):**
```json
{
  "status": "success",
  "data": [
    {
      "id": "pet-rec-881",
      "petId": "pet-001-uuid",
      "category": "VACCINATION",
      "title": "Rabies & DHPP Booster",
      "recordDate": "2026-08-10",
      "veterinarian": "Dr. Amanda Perez",
      "notes": "Annual booster administered without adverse reaction.",
      "documentUrl": "https://cdn.vnvision.in/careid/pet-docs/rabies_cert.pdf"
    }
  ]
}
```

---

### 2.2 Insurance Card Optical Character Recognition (OCR) Engine
- **Figma Reference:**
  - Frame `20:20258` ("Insurance Card Scanner - Viewfinder", 390×844)
  - Frame `20:20415` ("OCR Processing - Insurance Card", 390×844)
  - Frame `20:20517` ("Insurance OCR Results", 390×1100)
- **Current App Status:**
  The frontend features camera viewfinder alignment, real-time bounding box guides, multi-step progress animation ("Boundary Alignment", "OCR Parsing", "Field Validation"), and a verification form with confidence indicators. It currently allows users to review and manually confirm captured data into `POST /api/v1/insurance/policies`.
- **Proposed Backend API Endpoint:**

#### `POST /api/v1/insurance/ocr-scan`
- **Method:** `POST`
- **Content-Type:** `multipart/form-data`
- **Authentication:** `Bearer <patient_token>`
- **Request Parameters:**
  - `cardFront`: Binary image file (JPEG / PNG, max 10MB)
  - `cardBack`: Optional binary image file (JPEG / PNG, max 10MB)
- **Response Format (`200 OK`):**
```json
{
  "status": "success",
  "data": {
    "ocrSessionId": "ocr_sess_993410294",
    "overallConfidence": 0.94,
    "fields": {
      "providerName": { "value": "BlueCross BlueShield", "confidence": 0.98 },
      "policyNumber": { "value": "BCBS-88912401", "confidence": 0.96 },
      "groupNumber": { "value": "GRP-7720", "confidence": 0.91 },
      "subscriberName": { "value": "John Doe", "confidence": 0.95 },
      "copayPrimary": { "value": "$25", "confidence": 0.90 },
      "copaySpecialist": { "value": "$50", "confidence": 0.88 },
      "rxBin": { "value": "003858", "confidence": 0.97 },
      "rxPcn": { "value": "A4", "confidence": 0.95 }
    },
    "rawText": "BlueCross BlueShield ... Member ID: BCBS-88912401 ...",
    "processedAt": "2026-11-02T12:00:00Z"
  }
}
```

---

### 2.3 Treatment Financing & 0% APR Installment Plans
- **Figma Reference:**
  - Frame `20:26404` ("0% APR Financing & Treatment Offers", 390×1150)
  - Frame `20:26580` ("Financing Offer Details & Loan Schedule", 390×1200)
- **Current App Status:**
  The frontend provides an interactive payment calculator, installment duration selector (6, 12, 18, 24 months), total cost vs monthly breakdown, and approved medical credit lines.
- **Proposed Backend API Endpoints:**

#### `GET /api/v1/financing/offers`
- **Method:** `GET`
- **Authentication:** `Bearer <patient_token>`
- **Description:** Retrieves pre-qualified financing options, partner lenders (CareCredit, Scratchpay), and current patient credit tier.
- **Response Format (`200 OK`):**
```json
{
  "status": "success",
  "data": {
    "preQualifiedAmount": 5000.00,
    "availableTermMonths": [6, 12, 18, 24],
    "aprPercentage": 0.0,
    "promotionalPeriodMonths": 12,
    "lenderName": "CareCredit Healthcare Financing",
    "termsUrl": "https://360api.vnvision.in/terms/financing-0-apr.pdf"
  }
}
```

#### `POST /api/v1/financing/applications`
- **Method:** `POST`
- **Authentication:** `Bearer <patient_token>`
- **Request Body:**
```json
{
  "procedureType": "DENTAL_IMPLANTS",
  "requestedAmount": 2800.00,
  "termMonths": 12,
  "monthlyPayment": 233.33,
  "consentSoftCreditCheck": true
}
```
- **Response Format (`201 Created`):**
```json
{
  "status": "success",
  "data": {
    "applicationId": "fin_app_4481029",
    "status": "APPROVED",
    "approvedAmount": 2800.00,
    "firstPaymentDueDate": "2026-12-01",
    "agreementId": "agr_991823"
  }
}
```

---

### 2.4 Charity Care & Sliding Scale Financial Assistance
- **Figma Reference:**
  - Frame `20:26700` ("Uninsured & Sliding Scale Assistance", 390×1080)
- **Current App Status:**
  The frontend features household size calculation, federal poverty level (FPL) percentage estimation, required document checklists (W2, Paystub, Tax Return), and an application submission flow.
- **Proposed Backend API Endpoints:**

#### `GET /api/v1/assistance/programs`
- **Method:** `GET`
- **Authentication:** `Bearer <patient_token>`
- **Description:** Lists available community benefit programs, sliding scale discounts, and state assistance.
- **Response Format (`200 OK`):**
```json
{
  "status": "success",
  "data": [
    {
      "programId": "prog-charity-01",
      "name": "Community Health Sliding Scale Assistance",
      "maxFplPercentage": 300,
      "discountRange": "50% - 100% off billed charges",
      "requiredDocuments": ["GOVERNMENT_ID", "PROOF_OF_INCOME", "RESIDENCY_PROOF"]
    }
  ]
}
```

#### `POST /api/v1/assistance/applications`
- **Method:** `POST`
- **Authentication:** `Bearer <patient_token>`
- **Request Body:**
```json
{
  "programId": "prog-charity-01",
  "householdSize": 3,
  "annualHouseholdIncome": 34000.00,
  "employmentStatus": "PART_TIME",
  "documentKeys": ["doc_proof_income_1.pdf", "doc_gov_id_2.jpg"]
}
```
- **Response Format (`201 Created`):**
```json
{
  "status": "success",
  "data": {
    "applicationId": "charity_app_11928",
    "status": "UNDER_REVIEW",
    "estimatedDecisionDays": 3,
    "submittedAt": "2026-11-02T12:00:00Z"
  }
}
```

---

## 3. Two Identified Runtime Staging API Issues

### Issue 1: `GET /api/v1/appointments/patient/my-appointments` Returns HTTP 500
- **Endpoint:** `GET https://360api.vnvision.in/api/v1/appointments/patient/my-appointments`
- **Observed Behavior:**
  When invoked with a valid authenticated patient Bearer token (e.g. for patient `787e5187-7859-4320-bb1a-465a57dd086a`), the staging backend responds with:
  ```json
  HTTP/1.1 500 Internal Server Error
  Content-Type: application/json
  {
    "statusCode": 500,
    "message": "Internal server error"
  }
  ```
- **Root Cause Analysis:**
  The appointments service performs an unhandled SQL `INNER JOIN` against the `doctors` or `facilities` table on records where `doctor_id` or `facility_id` is null, or queries an uninitialized relation for accounts without previously booked visits.
- **Recommended Backend Fix:**
  1. Wrap the database query with `LEFT OUTER JOIN doctors ON appointments.doctor_id = doctors.id`.
  2. If the user has zero appointments, return an empty array `{"status": "success", "data": []}` with HTTP 200 rather than throwing an unhandled exception.
  3. Ensure doctor object serialization handles nullable fields (`specialty`, `avatar_url`, `office_address`).

---

### Issue 2: `GET /api/v1/security/consents` Returns HTTP 403 Forbidden
- **Endpoint:** `GET https://360api.vnvision.in/api/v1/security/consents`
- **Observed Behavior:**
  When requested with a valid patient JWT token, the backend returns:
  ```json
  HTTP/1.1 403 Forbidden
  Content-Type: application/json
  {
    "statusCode": 403,
    "message": "Forbidden resource"
  }
  ```
- **Root Cause Analysis:**
  The route guard for `/api/v1/security/consents` is currently protected by a role guard requiring `ROLE_ADMIN` or `ROLE_PROVIDER`. However, the Patient App Figma designs (Frames `20:31164`, `20:24805`, `20:23450`) explicitly require patients to view and toggle their own HIPAA privacy, biometric consent, and provider data-sharing preferences.
- **Recommended Backend Fix:**
  1. Update the permission guard on `/api/v1/security/consents` (or introduce `/api/v1/security/consents/my-consents`) to permit `ROLE_PATIENT`.
  2. Scope the query automatically to the authenticated patient: `WHERE user_id = :jwt_user_id`.
  3. Support `PUT /api/v1/security/consents` with payload `{"consentKey": "HIPAA_DATA_SHARING", "granted": true}`.

---

## 4. Frontend Resilience Strategy

To guarantee a stable user experience on connected Android hardware:
1. **Network Error Boundaries:** Screens gracefully catch 500 and 403 responses, rendering structured empty states and informative offline guidance rather than crashing.
2. **Local Caching & State Continuity:** Critical patient preferences (biometric toggles, language, local emergency card info) are persisted in secure device storage (`TokenStorage` / `SharedPreferences`) when the backend is unreachable.
3. **Seamless API Activation:** As soon as the backend team deploys these proposed routes to `https://360api.vnvision.in`, the Flutter application's service architecture (`ApiClient`, `PatientRepository`, `MedicalRecordsRepository`) is prepared to immediately consume them.

