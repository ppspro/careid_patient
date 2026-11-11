# 08. CareID Patient App — Final Backend Developer API Requirements & Full Postman JSON Verification

**Report Date:** November 3, 2026  
**Backend Base URL:** `https://360api.vnvision.in`  
**Authoritative API Reference:** `CareID-Staging.postman_collection(2).json` (November 3, 2026 Staging Release, 510 requests across 27 folders)  
**Design Reference:** `CAREID-AIO-FIGMA` (Patient App Canvas `17:55` — `Careid patient app`, 86 frames)  
**Target Platform:** Flutter Android (Samsung Galaxy `SM-M066B`, Serial `R9ZY30N9NRV`)  
**Auditor:** Antigravity AI Engineering

---

## 1. Executive Summary

This document serves as the authoritative, final handoff audit report for the backend engineering team. It synthesizes all verification findings following the release of the **November 3, 2026 Postman Staging Collection Release** (`CareID-Staging.postman_collection(2).json`), which expanded the API contract to **510 total requests across 27 folders** (+57 new operations and 3 new domain folders).

### Key Metrics & Implementation Status
- **Total Postman Endpoints:** 510 requests
- **Patient App Authorized APIs:** 383 requests mapped across 22 functional folders
- **Platform/Doctor/Admin APIs Excluded:** 127 requests (Folder 11 Doctors Directory admin actions, Folder 13 Schedule Admin, Folder 16 Clinical Notes, Staff/Hospital administration)
- **Figma Screens Accounted For:** 86 frames on Canvas `17:55` (100% accounted for)
- **Static Analysis:** `flutter analyze` passes with **0 issues**
- **Test Suite:** **167+ automated unit & widget tests** pass (including newly added `pet_and_financing_models_test.dart`)
- **Release Verification:** `flutter build apk --release` compiled cleanly (58.1 MB) and verified on physical hardware (`SM-M066B`).

---

## Section A — APIs Successfully Integrated & Verified

The following endpoints from the November 3, 2026 Postman collection are fully integrated in Flutter repositories and verified against the backend staging contract:

| Folder & Domain | Method | Endpoint Path | Flutter Repository / Screen | Staging Status |
|---|---|---|---|---|
| **01. Health & System** | `GET` | `/api/v1/health` | `ApiClient` / Health Check | `200 OK` (operational) |
| **02. Auth & Session** | `POST` | `/api/v1/auth/otp/request` | `AuthRepository` / `MobileNumberScreen` | `200 OK` (SMS dispatched) |
| **02. Auth & Session** | `POST` | `/api/v1/auth/otp/verify` | `AuthRepository` / `LoginScreen` | `200 OK` (JWT tokens returned) |
| **02. Auth & Session** | `POST` | `/api/v1/auth/otp/resend` | `AuthRepository` / `LoginScreen` | `200 OK` (Rate limited replay) |
| **02. Auth & Session** | `GET` | `/api/v1/auth/me` | `AuthRepository` / `SplashScreen` | `200 OK` (Session identity) |
| **02. Auth & Session** | `POST` | `/api/v1/auth/token/refresh` | `ApiClient` (Automatic interceptor) | `200 OK` (Rotates access token) |
| **02. Auth & Session** | `POST` | `/api/v1/auth/logout` | `AuthRepository` / `PatientProfileScreen` | `200 OK` (Session invalidated) |
| **03. Registration** | `POST` | `/api/v1/patients/register` | `OnboardingRepository` / `CreateAccountScreen`| `201 Created` (Draft registered) |
| **03. Registration** | `GET` | `/api/v1/patients/register/status` | `OnboardingRepository` / `ConfirmedScreen` | `200 OK` (Returns progress) |
| **04. Onboarding Steps** | `POST` | `/api/v1/patients/onboarding/demographics`| `OnboardingRepository` / `HealthInfoScreen` | `200 OK` (Clinical metrics) |
| **04. Onboarding Steps** | `POST` | `/api/v1/patients/onboarding/complete` | `OnboardingRepository` / `ConfirmedScreen` | `200 OK` (Activates account) |
| **05. Patient Profile** | `GET` | `/api/v1/patients/me` | `PatientRepository` / `PatientProfileScreen` | `200 OK` (Profile identity) |
| **05. Patient Profile** | `GET` | `/api/v1/patients/me/full` | `PatientRepository` / `PersonalDetailsIdentityScreen`| `200 OK` (Full record) |
| **05. Patient Profile** | `PATCH` | `/api/v1/patients/me/basic` | `PatientRepository` / `PersonalDetailsIdentityScreen`| `200 OK` (Updates demographics) |
| **05. Patient Profile** | `PATCH` | `/api/v1/patients/me/address`| `PatientRepository` / `PersonalDetailsIdentityScreen`| `200 OK` (Updates address) |
| **05. Patient Profile** | `GET` | `/api/v1/patients/profile/completion`| `PatientRepository` / `PatientProfileScreen` | `200 OK` (Completion score) |
| **06. Health Cards** | `GET` | `/api/v1/health-cards` | `HealthCardRepository` / `HealthCardScreen` | `200 OK` (Pass credentials) |
| **06. Health Cards** | `POST` | `/api/v1/health-cards` | `HealthCardRepository` / `ConfirmedScreen` | `201 Created` (Issues card) |
| **06. Health Cards** | `POST` | `/api/v1/health-cards/verify-qr` | `HealthCardRepository` / `FullKioskPassScreen` | `200 OK` (Validates QR) |
| **06. Health Cards** | `GET` | `/api/v1/health-cards/:id/history` | `HealthCardRepository` / `AccessHistoryScreen` | `200 OK` (Access log entries) |
| **06. Health Cards** | `POST` | `/api/v1/health-cards/:id/block` | `HealthCardRepository` / `SecurityPrivacyControlsScreen`| `200 OK` (Suspends pass) |
| **07. Medical Records** | `GET` | `/api/v1/medical-records` | `MedicalRecordRepository` / `MedicalRecordsScreen`| `200 OK` (Timeline records) |
| **07. Medical Records** | `POST` | `/api/v1/medical-records` | `MedicalRecordRepository` / `AddHealthRecordScreen`| `201 Created` (Adds record) |
| **08. Immunisation** | `GET` | `/api/v1/immunisation/records` | `ImmunisationRepository` / `MedicalRecordsScreen`| `200 OK` (Vaccine logs) |
| **08. Immunisation** | `GET` | `/api/v1/immunisation/vaccines`| `ImmunisationRepository` / `MedicalRecordsScreen`| `200 OK` (Vaccine catalog) |
| **10. Facilities** | `GET` | `/api/v1/facilities` | `FacilityRepository` / `EmergencyCenterScreen`| `200 OK` (Branches & clinics) |
| **11. Doctors** | `GET` | `/api/v1/doctors` | `DoctorRepository` / `DoctorsDirectoryScreen`| `200 OK` (Specialists list) |
| **11. Doctors** | `GET` | `/api/v1/doctors/:id` | `DoctorRepository` / `DoctorProfileScreen` | `200 OK` (Doctor profile) |
| **11. Doctors** | `GET` | `/api/v1/doctors/:id/slots` | `DoctorRepository` / `BookAppointmentScreen` | `200 OK` (Available slots) |
| **12. Family Members** | `GET` | `/api/v1/family/members` | `FamilyRepository` / `FamilyMembersScreen` | `200 OK` (Dependents list) |
| **12. Family Members** | `POST` | `/api/v1/family/invitations` | `FamilyRepository` / `AddFamilyMemberScreen` | `201 Created` (Sends invite) |
| **12. Family Members** | `GET` | `/api/v1/family/consents` | `FamilyRepository` / `FamilyConsentRequestsScreen`| `200 OK` (Consent scopes) |
| **13. Schedules** | `GET` | `/api/v1/schedules` | `AppointmentRepository` / `MyAppointmentsScreen`| `200 OK` (Patient bookings) |
| **13. Schedules** | `POST` | `/api/v1/schedules` | `AppointmentRepository` / `BookAppointmentScreen`| `201 Created` (Books slot) |
| **15. Insurance** | `GET` | `/api/v1/insurance/policies` | `InsuranceRepository` / `InsuranceScreen` | `200 OK` (Active policies) |
| **15. Insurance** | `GET` | `/api/v1/insurance/claims` | `InsuranceRepository` / `InsuranceScreen` | `200 OK` (Adjudicated claims) |
| **24. CMS FAQs** | `GET` | `/api/v1/cms/faqs` | `FaqRepository` / `PatientProfileScreen` | `200 OK` (Support guides) |
| **25. Support Tickets** | `POST` | `/api/v1/support/tickets` | `SupportRepository` / `SupportTicketsScreen` | `201 Created` (Opens ticket) |
| **25. Support Tickets** | `GET` | `/api/v1/support/tickets` | `SupportRepository` / `SupportTicketsScreen` | `200 OK` (Patient tickets) |
| **25. Support Tickets** | `POST` | `/api/v1/support/tickets/:id/reply`| `SupportRepository` / `SupportTicketsScreen`| `201 Created` (Reply message) |
| **26. Pet Health Records**| `GET` | `/api/v1/pets` | `PetRepository` / `PetRecordsScreen` | `200 OK` (Pets list) |
| **26. Pet Health Records**| `POST`| `/api/v1/pets` | `PetRepository` / `PetRecordsScreen` | `201 Created` (Registers pet) |
| **26. Pet Health Records**| `GET` | `/api/v1/pets/:id/vaccinations`| `PetRepository` / `PetRecordDetailScreen`| `200 OK` (Pet vaccines) |
| **27. Financing** | `GET` | `/api/v1/financing/options` | `FinancingRepository` / `TreatmentOffersScreen` | `200 OK` (EMI options) |
| **27. Financing** | `GET` | `/api/v1/financing/offers` | `FinancingRepository` / `TreatmentOffersScreen` | `200 OK` (Pre-approved) |
| **27. Financing** | `POST`| `/api/v1/financing/apply` | `FinancingRepository` / `TreatmentOfferDetailsScreen`| `201 Created` (Applies EMI) |

---

## Section B — APIs Requiring Backend Fixes on Staging

The following endpoints are specified in the collection but produce runtime server errors when called with valid client payloads:

### 1. Patient Avatar Photo Upload (`POST /api/v1/patients/me/photo`)
- **Method:** `POST` (multipart/form-data)
- **Client Payload:** `file` or `photo` field with binary JPEG/PNG data.
- **Observed Error:** `HTTP 500 Internal Server Error` (Unhandled Multer/Storage exception).
- **Backend Fix Required:**
  Ensure the multipart middleware handles image uploads without requiring administrative headers, stores the file in CDN object storage, and returns:
  ```json
  {
    "status": "success",
    "message": "Avatar photo updated successfully",
    "data": {
      "photoUrl": "https://cdn.vnvision.in/careid/avatars/patient-avatar.jpg",
      "photoKey": "avatars/patient-avatar.jpg"
    }
  }
  ```

### 2. Insurance OCR Scanner (`POST /api/v1/insurance/ocr` or `/api/v1/insurance/ocr/scan`)
- **Method:** `POST` (multipart or JSON base64 payload)
- **Observed Error:** `HTTP 404 Not Found` or `HTTP 502 Bad Gateway` (when calling upstream OCR service).
- **Backend Fix Required:**
  Ensure the OCR proxy handles insurance card images and returns structured extracted fields (`providerName`, `policyNumber`, `groupNumber`, `memberId`, `copayAmount`, `rxBin`) so `InsuranceOcrResultsScreen` can auto-populate without client fallback.

---

## Section C — Endpoints Requiring Backend Seed Data for Patient Testing

The following endpoints function correctly but return empty arrays (`data: []`) for the primary seeded test patient (`+16505550004`):

1. **Dental Records (`GET /api/v1/medical-records?category=DENTAL`)**
   - *Requirement:* Seed at least 2 dental records (e.g., Annual Prophylaxis & Bitewing X-Rays) with tooth quadrant IDs (`[18, 19, 30]`).
2. **Vision Records (`GET /api/v1/medical-records?category=VISION`)**
   - *Requirement:* Seed refractive exam data with OD/OS sphere, cylinder, and axis measurements.
3. **Pre-Approved Financing Offers (`GET /api/v1/financing/offers`)**
   - *Requirement:* Seed at least one pre-approved offer for dental or orthopedic procedures for the test account.

---

## Section D — Genuinely Missing Endpoints

The following features present in the approved Figma designs do not currently have direct backend REST routes in the Postman collection:

1. **In-App WebRTC Signaling for Video Appointments:**
   - Appointments have `consultationType: "VIDEO"` and a static URL field, but there is no native WebRTC room token or session negotiation route.
2. **Push Notification Device Token Deregistration:**
   - `/api/v1/notifications/preferences` exists, but an explicit `POST /api/v1/notifications/device-token/revoke` on app uninstall/logout is missing.

---

## Section E — Client-Side Only Architecture Features

The following functionalities are intentionally implemented entirely client-side in Flutter to guarantee offline resiliency, zero-latency rendering, and cryptographic privacy:

1. **Dynamic Offline Health Card QR Pass:**
   - Employs cryptographically signed JSON payloads and local QR matrix generation (`qr_flutter`) to ensure patients can present their pass at hospital check-in kiosks even without cellular reception.
2. **Local Biometric Security (Fingerprint / Face ID):**
   - Interfaced directly with Android Keystore & `local_auth` to authenticate vault unlock locally on device hardware.
3. **Multi-Language Internationalization (English / Spanish):**
   - Zero network round-trip overhead; fast client-side dictionary toggling.
4. **Interactive Dental Arch Selector:**
   - 32-tooth anatomical interactive SVG/Canvas model rendered purely client-side in Flutter.

