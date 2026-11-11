# Missing & Recommended APIs for CareID Patient App

**Project:** `C:\Users\PABANI\CareID_patient_app`  
**Backend:** `https://360api.vnvision.in`  
**Status:** PROPOSED APIS — NOT CURRENTLY AVAILABLE IN POSTMAN  
**Date:** October 31, 2026  

---

## 1. Context & Business Rationale

A complete audit of `CareID-Staging.postman_collection.json` against the Figma designs (`CAREID-AIO-FIGMA`, canvas `17:55`) and the approved PRD reveals features where client UI is fully designed and scaffolded, but supporting backend endpoints are absent from Postman.

Per strict guidelines:
- **No LLM / Chatbots:** AI features remain strictly restricted to Document & Insurance Card OCR.
- **RESTful Conventions:** All proposed routes follow the existing `/api/v1/` prefix and camelCase/kebab-case standards.
- **Authorization:** Protected endpoints mandate Bearer JWT authentication and strict patient-context isolation.

---

## 2. Proposed Missing APIs Inventory

### PROPOSAL 1: Treatment Financing & 0% APR Offers

- **Module:** Treatment Financing & Credit
- **Related Figma Screens:** `20:26404` (Treatment Offers), `20:26922` (Offer Details & Loan Terms)
- **Business Requirement:** CareID offers approved 0% APR treatment financing packages (e.g. dental implants, periodontal scaling, orthodontic alignment). Patients need to view pre-approved offers, calculate monthly installment plans, and accept/sign terms.
- **Why Existing APIs Are Insufficient:** The current `/api/v1/insurance/*` endpoints only cover traditional insurance claims and payer policies; they provide zero loan underwriting, installment estimation, or credit terms.
- **Suggested Endpoint:** `GET /api/v1/financing/offers`
- **Suggested Method:** `GET`
- **Request Headers:** `Authorization: Bearer <token>`
- **Suggested Response:**
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "off-001",
        "title": "Comprehensive Dental Restoration & Scaling",
        "standardPrice": 1450.00,
        "careIdPrice": 920.00,
        "savings": 530.00,
        "monthlyRate": 76.67,
        "tenureMonths": 12,
        "apr": 0.0,
        "status": "PRE_APPROVED",
        "providerName": "Apex Dental Institute"
      }
    ]
  }
  ```
- **Priority:** **HIGH**

---

### PROPOSAL 2: Treatment Offer Acceptance & E-Signature

- **Module:** Treatment Financing & Credit
- **Related Figma Screen:** `20:26922` (Treatment Offer Details — Accept Offer CTA)
- **Business Requirement:** Legally binding acceptance of an installment loan or procedure package.
- **Why Existing APIs Are Insufficient:** No mechanism exists to convert an offer into an active financing agreement.
- **Suggested Endpoint:** `POST /api/v1/financing/offers/{id}/accept`
- **Suggested Method:** `POST`
- **Request Body:**
  ```json
  {
    "tenureMonths": 12,
    "agreeToTerms": true,
    "signatureConsent": "John Doe",
    "paymentMethodId": "pm-card-9921"
  }
  ```
- **Suggested Response:**
  ```json
  {
    "success": true,
    "data": {
      "agreementId": "agr-2026-9021",
      "status": "ACTIVE",
      "firstPaymentDueDate": "2026-12-01",
      "confirmationPassUrl": "https://360api.vnvision.in/passes/agr-2026-9021.pdf"
    }
  }
  ```
- **Priority:** **HIGH**

---

### PROPOSAL 3: Prescription Schedules & Medication Refill

- **Module:** Medication Reminders
- **Related Figma Screen:** `20:24101` (Medication Reminder Detail)
- **Business Requirement:** Renders active patient medications (e.g., Atorvastatin 20mg, Lisinopril 10mg), dosage frequencies, pharmacy location (`City Health Apothecary`), and a "Mark as Collected" / "Request Refill" action.
- **Why Existing APIs Are Insufficient:** Postman has general `/api/v1/medical-records`, but no dedicated prescription schedule or pharmacy linkage endpoints.
- **Suggested Endpoint:** `GET /api/v1/prescriptions` and `POST /api/v1/prescriptions/{id}/refill`
- **Suggested Method:** `GET` / `POST`
- **Request Body for Refill:**
  ```json
  {
    "pharmacyId": "phm-001",
    "notes": "Refill authorized by Dr. Sarah Jenkins"
  }
  ```
- **Priority:** **HIGH**

---

### PROPOSAL 4: Emergency SOS Dispatch Notification

- **Module:** Emergency & Security
- **Related Figma Screen:** `20:23956` (Emergency Center — Red SOS Hero Button)
- **Business Requirement:** When a patient initiates an emergency trigger, the backend must instantly send priority push notifications and emergency SMS alerts with GPS coordinates to the patient's primary ICE contacts and registered trauma center.
- **Why Existing APIs Are Insufficient:** The app currently loads ICE contacts via `GET /api/v1/patients/me/full`, but has no trigger endpoint to broadcast the emergency event.
- **Suggested Endpoint:** `POST /api/v1/emergency/sos`
- **Suggested Method:** `POST`
- **Request Body:**
  ```json
  {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "triggerType": "MANUAL_BUTTON",
    "timestamp": "2026-10-31T11:05:00Z"
  }
  ```
- **Suggested Response:**
  ```json
  {
    "success": true,
    "data": {
      "alertId": "sos-787e-9011",
      "contactsNotified": 1,
      "traumaCenterNotified": true,
      "dispatchedAt": "2026-10-31T11:05:01Z"
    }
  }
  ```
- **Priority:** **CRITICAL**

---

### PROPOSAL 5: Single Appointment Schedule Details

- **Module:** Doctors & Appointments
- **Related Figma Screen:** `20:29860` (Appointment Details & Digital Check-In Pass)
- **Business Requirement:** Fetch detailed consultation notes, facility kiosk check-in passcodes, and cancellation policies for a single appointment.
- **Why Existing APIs Are Insufficient:** Postman currently only defines `GET /api/v1/schedules` (returns list). There is no dedicated single-item getter `GET /api/v1/schedules/{id}`.
- **Suggested Endpoint:** `GET /api/v1/schedules/{id}`
- **Suggested Method:** `GET`
- **Priority:** **MEDIUM**

---

### PROPOSAL 6: Appointment Rescheduling

- **Module:** Doctors & Appointments
- **Related Figma Screen:** `20:29512` (Reschedule Appointment)
- **Business Requirement:** Allow patients to reschedule an upcoming consultation to a different open slot without completely cancelling and re-booking.
- **Why Existing APIs Are Insufficient:** Currently only `DELETE /api/v1/schedules/{id}` and `POST /api/v1/schedules` exist.
- **Suggested Endpoint:** `PUT /api/v1/schedules/{id}/reschedule`
- **Suggested Method:** `PUT`
- **Request Body:**
  ```json
  {
    "newSlotId": "slot-99401",
    "newDateTime": "2026-11-12T14:30:00Z",
    "rescheduleReason": "Work conflict"
  }
  ```
- **Priority:** **HIGH**

---

### PROPOSAL 7: Granular Family Member Permissions

- **Module:** Family Management
- **Related Figma Screen:** `20:22307` (Member Permissions & Sharing)
- **Business Requirement:** Allows patients to toggle sharing permissions for dependents or family circle members (Medical Records: ON/OFF, Dental: ON/OFF, Vision: ON/OFF, Lab Reports: ON/OFF, Access Expiry: 30 days, 90 days, Permanent).
- **Why Existing APIs Are Insufficient:** The current `GET /api/v1/family/members` only returns demographics; there is no granular permission update route per member.
- **Suggested Endpoint:** `PATCH /api/v1/family/members/{id}/permissions`
- **Suggested Method:** `PATCH`
- **Request Body:**
  ```json
  {
    "shareMedical": true,
    "shareDental": true,
    "shareVision": false,
    "shareLabs": true,
    "accessExpiry": "90_DAYS"
  }
  ```
- **Priority:** **HIGH**

---

### PROPOSAL 8: Secure Clinical Document Download (Signed URLs)

- **Module:** Health Records
- **Related Figma Screen:** `document_viewer_screen.dart` (DICOM & PDF Export)
- **Business Requirement:** Generate temporary pre-signed, HIPAA-compliant Cloud Storage URLs for viewing high-resolution dental X-rays, retinal fundus images, and laboratory PDFs.
- **Why Existing APIs Are Insufficient:** Medical record DTOs currently contain filename strings, but Postman has no patient-accessible signed URL resolver.
- **Suggested Endpoint:** `GET /api/v1/medical-records/{id}/document-url`
- **Suggested Method:** `GET`
- **Suggested Response:**
  ```json
  {
    "success": true,
    "data": {
      "signedUrl": "https://storage.googleapis.com/careid-vault/rec-test-1.pdf?signature=...",
      "expiresInSeconds": 300
    }
  }
  ```
- **Priority:** **HIGH**

---

### PROPOSAL 9: Patient-Doctor Real-Time Consultation Chat

- **Module:** Communication & Care Team
- **Related Figma Screen:** `20:29012` (Live Chat Screen)
- **Business Requirement:** Text-based secure clinical messaging with attending care team regarding pre-op preparation or prescription clarifications.
- **Why Existing APIs Are Insufficient:** Real-time chat endpoints are absent from the staging Postman collection.
- **Suggested Endpoint:** `GET /api/v1/chat/conversations/{doctorId}/messages` and `POST /api/v1/chat/conversations/{doctorId}/messages`
- **Priority:** **MEDIUM**

---

### PROPOSAL 10: Pet Records Subsystem (If Supported by Product Scope)

- **Module:** Specialized Dependent Vault
- **Related Figma Screen:** `20:33450` (Pet Health Records)
- **Business Requirement:** CareID dependent management includes domestic pet vaccination and veterinary records.
- **Why Existing APIs Are Insufficient:** No `/api/v1/pets/*` endpoints exist in Postman.
- **Suggested Endpoint:** `GET /api/v1/pets/records`
- **Priority:** **LOW (Requires Product Alignment)**

