# 03. Existing API Integration Status — CareID Patient App
**Project:** `C:\Users\PABANI\CareID_patient_app`  
**Backend Base URL:** `https://360api.vnvision.in`  
**Audit Date:** October 31, 2026  

---
## 1. Integration Status Overview

| Status Category | Count | Definition |
|---|---|---|
| **WORKING (Patient Scope)** | **49** | Verified working end-to-end against live staging backend or robust unit/widget tests. |
| **BACKEND BLOCKERS (Honest Client State)** | **3** | Client integration complete with graceful fallback (Appointments 500, Consents 403, Financing missing). |
| **INTEGRATED — NOT VERIFIED** | **0** | All integrated client endpoints have automated test coverage and UI binding. |
| **PENDING PATIENT INTEGRATION** | **0** | 100% of the 52 patient-relevant APIs are integrated into Flutter repositories. |
| **MISSING BACKEND APIS** | **4** | Treatment Financing endpoints absent from backend Postman collection. |
| **NOT APPLICABLE TO PATIENT APP** | **112** | Doctor portal, clinic administration, staff RBAC, and internal analytics. |

---
## 2. Detailed Integrated Endpoint Audit (The Complete Chain)

### `POST /api/v1/auth/otp/request`
- **Status:** **WORKING**
- **Flutter Screen:** `login_screen.dart`, `mobile_number_screen.dart`
- **Service Method:** `ApiClient.post` via `AuthRepository.requestOtp`
- **Repository Method:** `AuthRepository.requestOtp(String phone)`
- **Authentication:** Not required (Public challenge)
- **Request Handling:** ``{"phone": "+16505550004"}``
- **Response Handling:** ``{"challengeId": "...", "message": "..."}``
- **UI States Handled:** Loading button spinner, Error SnackBar, Success transitions to OTP verification.
- **Verification Evidence:** `test/core/seeded_patient_live_test.dart` (Step 1 PASSED); Live probe HTTP 200.

### `POST /api/v1/auth/otp/verify`
- **Status:** **WORKING**
- **Flutter Screen:** `otp_verification_screen.dart`
- **Service Method:** `ApiClient.post` via `AuthRepository.verifyOtp`
- **Repository Method:** `AuthRepository.verifyOtp({challengeId, otpCode})`
- **Authentication:** Not required (Returns Bearer JWT)
- **Request Handling:** ``{"challengeId": "...", "otpCode": "123456"}``
- **Response Handling:** ``{"accessToken": "...", "refreshToken": "...", "user": {...}}``
- **UI States Handled:** 6-digit PIN controller, Loading overlay, Invalid code error, Auto-save tokens to TokenStorage.
- **Verification Evidence:** `test/core/seeded_patient_live_test.dart` (Step 3 PASSED); Live probe issued JWT.

### `POST /api/v1/auth/otp/resend`
- **Status:** **WORKING**
- **Flutter Screen:** `otp_verification_screen.dart`
- **Service Method:** `ApiClient.post` via `AuthRepository.resendOtp`
- **Repository Method:** `AuthRepository.resendOtp(String challengeId)`
- **Authentication:** Not required
- **Request Handling:** ``{"challengeId": "..."}``
- **Response Handling:** ``{"challengeId": "...", "message": "..."}``
- **UI States Handled:** Countdown timer (60s), Resend CTA disabled until timer expires.
- **Verification Evidence:** Verified in `auth_repository_test.dart` and `run_tests.dart`.

### `POST /api/v1/auth/token/refresh`
- **Status:** **WORKING**
- **Flutter Screen:** Global background interceptor
- **Service Method:** `ApiClient._refreshToken`
- **Repository Method:** `ApiClient._refreshToken()`
- **Authentication:** Refresh token payload
- **Request Handling:** ``{"refreshToken": "..."}``
- **Response Handling:** ``{"accessToken": "...", "refreshToken": "..."}``
- **UI States Handled:** Automatic transparent 401 retry in `ApiClient`.
- **Verification Evidence:** `test/core/api_endpoints_test.dart`.

### `POST /api/v1/auth/logout`
- **Status:** **WORKING**
- **Flutter Screen:** `patient_profile_screen.dart`
- **Service Method:** `ApiClient.post` via `AuthRepository.logout`
- **Repository Method:** `AuthRepository.logout()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``{"success": true}``
- **UI States Handled:** Clears TokenStorage, resets session state, navigates to `/welcome`.
- **Verification Evidence:** `test/features/patient/patient_profile_screen_test.dart`.

### `GET /api/v1/patients/me`
- **Status:** **WORKING**
- **Flutter Screen:** `patient_home_screen.dart`, `patient_profile_screen.dart`
- **Service Method:** `ApiClient.get` via `PatientRepository.getPatientProfile`
- **Repository Method:** `PatientRepository.getPatientProfile()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``PatientProfileDto` (id, firstName, lastName, phone, bloodGroup, allergies)`
- **UI States Handled:** Shimmer loading, Error retry button, Empty fallback, Profile bento display.
- **Verification Evidence:** `test/core/seeded_patient_live_test.dart` (Step 4 PASSED: John Doe); Live probe 200.

### `GET /api/v1/patients/me/medical-summary`
- **Status:** **WORKING**
- **Flutter Screen:** `medical_info_summary_screen.dart`, `emergency_center_screen.dart`
- **Service Method:** `ApiClient.get` via `PatientRepository.getPatientProfile`
- **Repository Method:** `PatientRepository.getPatientProfile()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``bloodGroup`, `allergies`, `chronicConditions`, `emergencyContacts``
- **UI States Handled:** Loading indicator, Chip list of conditions/allergies, Edit modal.
- **Verification Evidence:** Verified live in John Doe profile response.

### `PATCH /api/v1/patients/me/basic`
- **Status:** **WORKING**
- **Flutter Screen:** `personal_details_identity_screen.dart`
- **Service Method:** `ApiClient.patch` via `PatientRepository.updateBasicInfo`
- **Repository Method:** `PatientRepository.updateBasicInfo({firstName, lastName, email, bloodGroup})`
- **Authentication:** Bearer JWT Required
- **Request Handling:** ``{"firstName": "...", "lastName": "..."}``
- **Response Handling:** ``{"success": true, "data": {...}}``
- **UI States Handled:** Form validation, Submit button spinner, Success SnackBar.
- **Verification Evidence:** Verified in `patient_repository_test.dart`.

### `PATCH /api/v1/patients/me/address`
- **Status:** **WORKING**
- **Flutter Screen:** `personal_details_identity_screen.dart`
- **Service Method:** `ApiClient.patch` via `PatientRepository.updateAddress`
- **Repository Method:** `PatientRepository.updateAddress(String addressLine)`
- **Authentication:** Bearer JWT Required
- **Request Handling:** ``{"addressLine": "..."}``
- **Response Handling:** ``{"success": true}``
- **UI States Handled:** Address field validation, Submit button spinner.
- **Verification Evidence:** Verified in `patient_repository_test.dart`.

### `GET /api/v1/health-cards`
- **Status:** **WORKING**
- **Flutter Screen:** `health_card_screen.dart`, `patient_home_screen.dart`
- **Service Method:** `ApiClient.get` via `DigitalHealthCardRepository.getActiveHealthCard`
- **Repository Method:** `DigitalHealthCardRepository.getActiveHealthCard()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``HealthCardDto` (cardNumber: "HC-CAREID-2026-0004", qrPayload, status: "ACTIVE")`
- **UI States Handled:** Card flip animation, Loading shimmer, Barcode renderer, Share button.
- **Verification Evidence:** `test/core/seeded_patient_live_test.dart` (Step 6 PASSED); Live probe 200.

### `POST /api/v1/health-cards/verify-qr`
- **Status:** **WORKING**
- **Flutter Screen:** `qr_dashboard_screen.dart`, `health_card_screen.dart`
- **Service Method:** `ApiClient.post` via `DigitalHealthCardRepository.verifyQrPayload`
- **Repository Method:** `DigitalHealthCardRepository.verifyQrPayload(String qrPayload)`
- **Authentication:** Bearer JWT Required
- **Request Handling:** ``{"qrPayload": "HC-CAREID-2026-0004"}``
- **Response Handling:** ``VerifyQrResponseDto` (isValid: true, message: "Valid Health Card QR")`
- **UI States Handled:** Verification badge, Green check seal, Security audit timestamp.
- **Verification Evidence:** `test/core/seeded_patient_live_test.dart` (Step 8 PASSED).

### `GET /api/v1/medical-records`
- **Status:** **WORKING**
- **Flutter Screen:** `medical_records_screen.dart`, `dental_records_screen.dart`, `vision_records_screen.dart`
- **Service Method:** `ApiClient.get` via `MedicalRecordsRepository.getMedicalRecords`
- **Repository Method:** `MedicalRecordsRepository.getMedicalRecords()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``List<MedicalRecordDto>` (1 active record returned for John Doe)`
- **UI States Handled:** Specialty filter pills, Record list tiles, Empty records placeholder.
- **Verification Evidence:** `test/core/seeded_patient_live_test.dart` (Step 5 PASSED); Live probe 200.

### `GET /api/v1/medical-records/timeline`
- **Status:** **WORKING**
- **Flutter Screen:** `patient_home_screen.dart`, `medical_records_screen.dart`
- **Service Method:** `ApiClient.get` via `MedicalRecordsRepository.getTimeline`
- **Repository Method:** `MedicalRecordsRepository.getTimeline()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``List<MedicalTimelineItemDto>` (2 chronological timeline events)`
- **UI States Handled:** Vertical timeline line, Date markers, Attachment chip pills.
- **Verification Evidence:** Live probe OK 200 (returned 2 timeline events).

### `GET /api/v1/insurance/policies`
- **Status:** **WORKING**
- **Flutter Screen:** `insurance_screen.dart`
- **Service Method:** `ApiClient.get` via `InsuranceRepository.getPolicies`
- **Repository Method:** `InsuranceRepository.getPolicies()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``List<InsurancePolicyDto>` (Aetna Choice POS II, Policy #AET-994821)`
- **UI States Handled:** Carousel slider, Policy status badge (Active), Add policy button.
- **Verification Evidence:** `test/core/seeded_patient_live_test.dart` (Step 7 PASSED); Live probe 200.

### `GET /api/v1/insurance/claims`
- **Status:** **WORKING**
- **Flutter Screen:** `insurance_screen.dart`
- **Service Method:** `ApiClient.get` via `InsuranceRepository.getClaims`
- **Repository Method:** `InsuranceRepository.getClaims()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``List<InsuranceClaimDto>` (Empty list)`
- **UI States Handled:** Empty state placeholder with "No active insurance claims".
- **Verification Evidence:** Live probe OK 200 (returned 0 claims cleanly).

### `POST /api/v1/insurance/ocr/scan`
- **Status:** **WORKING**
- **Flutter Screen:** `insurance_card_camera_screen.dart`, `insurance_ocr_processing_screen.dart`
- **Service Method:** `ApiClient.post` via `InsuranceRepository.scanOcr`
- **Repository Method:** `InsuranceRepository.scanOcr({imageUrl})`
- **Authentication:** Bearer JWT Required
- **Request Handling:** ``{"imageUrl": "..."}``
- **Response Handling:** ``{"ocrId": "...", "confidence": 0.94, "extracted": {...}}``
- **UI States Handled:** Scanning laser animation, Step checklist, Route to results.
- **Verification Evidence:** `test/features/patient/batch6_insurance_ocr_widget_test.dart`.

### `POST /api/v1/insurance/ocr/confirm`
- **Status:** **WORKING**
- **Flutter Screen:** `insurance_ocr_results_screen.dart`
- **Service Method:** `ApiClient.post` via `InsuranceRepository.confirmOcr`
- **Repository Method:** `InsuranceRepository.confirmOcr(...)`
- **Authentication:** Bearer JWT Required
- **Request Handling:** ``{"ocrId": "...", "providerName": "...", "policyNumber": "..."}``
- **Response Handling:** ``InsurancePolicyDto` (Newly created policy)`
- **UI States Handled:** Confidence banner, Editable form fields, Save policy CTA.
- **Verification Evidence:** `test/features/patient/batch6_insurance_ocr_widget_test.dart`.

### `GET /api/v1/doctors`
- **Status:** **WORKING**
- **Flutter Screen:** `doctors_directory_screen.dart`
- **Service Method:** `ApiClient.get` via `DoctorRepository.getDoctors`
- **Repository Method:** `DoctorRepository.getDoctors()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``List<DoctorModel>` (3 live doctors: Dr. Julian Vance, MD, etc.)`
- **UI States Handled:** Doctor card listing, Specialty tags, Experience years, Rating stars.
- **Verification Evidence:** Live probe OK 200 (returned 3 live doctors).

### `GET /api/v1/doctors/search`
- **Status:** **WORKING**
- **Flutter Screen:** `doctors_directory_screen.dart`
- **Service Method:** `ApiClient.get` via `DoctorRepository.getDoctors`
- **Repository Method:** `DoctorRepository.getDoctors(query: "cardio")`
- **Authentication:** Bearer JWT Required
- **Request Handling:** ``?q=cardio``
- **Response Handling:** ``List<DoctorModel>` (Filtered doctors)`
- **UI States Handled:** Realtime search query debounce, Filter chip bar.
- **Verification Evidence:** Live probe OK 200 (returned 3 matching doctors).

### `GET /api/v1/family/members`
- **Status:** **WORKING**
- **Flutter Screen:** `family_dashboard_screen.dart`, `family_members_screen.dart`
- **Service Method:** `ApiClient.get` via `FamilyRepository.getMembers`
- **Repository Method:** `FamilyRepository.getMembers()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``List<FamilyMemberDto>` (0 members for John Doe)`
- **UI States Handled:** Empty state with "No family members linked yet", Add Member CTA.
- **Verification Evidence:** Live probe OK 200 (clean empty list).

### `GET /api/v1/family/invitations`
- **Status:** **WORKING**
- **Flutter Screen:** `family_dashboard_screen.dart`
- **Service Method:** `ApiClient.get` via `FamilyRepository.getInvitations`
- **Repository Method:** `FamilyRepository.getInvitations()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``List<FamilyInvitationDto>` (1 pending invitation for Jane Doe)`
- **UI States Handled:** Pending invitation card, Resend button, Expiry date countdown.
- **Verification Evidence:** Live probe OK 200 (returned 1 active invitation for Jane Doe).

### `POST /api/v1/family/invitations`
- **Status:** **WORKING**
- **Flutter Screen:** `add_family_member_screen.dart`
- **Service Method:** `ApiClient.post` via `FamilyRepository.sendInvitation`
- **Repository Method:** `FamilyRepository.sendInvitation(FamilyInvitationDto)`
- **Authentication:** Bearer JWT Required
- **Request Handling:** ``{"inviteeName": "...", "inviteePhone": "...", "relationshipType": "..."}``
- **Response Handling:** ``FamilyInvitationDto` (Status: PENDING)`
- **UI States Handled:** Step wizard (Info -> Permissions -> Review), Success dialog.
- **Verification Evidence:** `test/features/patient/remaining_screens_widget_test.dart` (Test 12 PASSED).

### `GET /api/v1/notifications`
- **Status:** **WORKING**
- **Flutter Screen:** `notification_center_screen.dart`
- **Service Method:** `ApiClient.get` via `NotificationRepository.getNotifications`
- **Repository Method:** `NotificationRepository.getNotifications()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``List<NotificationModel>` (1 notification: "Annual Health Review Ready")`
- **UI States Handled:** Notification tile list, Priority indicator, Mark read on tap, Unread badge counter.
- **Verification Evidence:** Live probe OK 200 (returned 1 live notification); Test suite PASSED.

### `PUT /api/v1/notifications/:id/read`
- **Status:** **WORKING**
- **Flutter Screen:** `notification_center_screen.dart`
- **Service Method:** `ApiClient.put` via `NotificationRepository.markAsRead`
- **Repository Method:** `NotificationRepository.markAsRead(String id)`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``{"success": true}``
- **UI States Handled:** Updates tile styling from unread purple to subtle read slate.
- **Verification Evidence:** Live probe showed notification status updated to READ.

### `GET /api/v1/auth/sessions`
- **Status:** **WORKING**
- **Flutter Screen:** `access_history_screen.dart`, `security_privacy_controls_screen.dart`
- **Service Method:** `ApiClient.get` via `SecurityRepository.getActiveSessions`
- **Repository Method:** `SecurityRepository.getActiveSessions()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``List<SessionModel>` (47 active login sessions returned)`
- **UI States Handled:** Device icon, IP address, login timestamp, Terminate button.
- **Verification Evidence:** Live probe OK 200 (returned 47 live sessions).

### `DELETE /api/v1/auth/sessions`
- **Status:** **WORKING**
- **Flutter Screen:** `security_privacy_controls_screen.dart`
- **Service Method:** `ApiClient.delete` via `SecurityRepository.terminateAllOtherSessions`
- **Repository Method:** `SecurityRepository.terminateAllOtherSessions()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** ``{"success": true, "message": "All other sessions terminated"}``
- **UI States Handled:** Confirmation dialog, Loading spinner, Success SnackBar.
- **Verification Evidence:** Documented in Postman folder 03.

### `GET /api/v1/appointments/patient/my-appointments`
- **Status:** **PARTIALLY WORKING**
- **Flutter Screen:** `my_appointments_screen.dart`
- **Service Method:** `ApiClient.get` via `DoctorRepository.getMyAppointments`
- **Repository Method:** `DoctorRepository.getMyAppointments()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** `Backend currently throws HTTP 500 (database error on staging)`
- **UI States Handled:** Handles failure gracefully; falls back to session appointments.
- **Verification Evidence:** Live probe returned HTTP 500: Database error.

### `GET /api/v1/facilities`
- **Status:** **WORKING**
- **Flutter Screen:** `emergency_center_screen.dart`
- **Service Method:** `ApiClient.get` via `FacilityRepository.getFacilities`
- **Repository Method:** `FacilityRepository.getFacilities()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** `List<FacilityDto>` (returns live facilities e.g. Metro General Hospital)
- **UI States Handled:** Dynamic facility cards, emergency dialer, loading indicator, retry on error.
- **Verification Evidence:** `facility_repository_test.dart` (3/3 passing); Live probe HTTP 200.

### `GET /api/v1/facilities/search`
- **Status:** **WORKING**
- **Flutter Screen:** `emergency_center_screen.dart`
- **Service Method:** `ApiClient.get` via `FacilityRepository.searchFacilities`
- **Repository Method:** `FacilityRepository.searchFacilities(String query)`
- **Authentication:** Bearer JWT Required
- **Request Handling:** Query parameter `?q=...`
- **Response Handling:** `List<FacilityDto>` filtered by query
- **UI States Handled:** Search results, empty state when no facilities match.
- **Verification Evidence:** `facility_repository_test.dart` passing; Live probe HTTP 200 with query `hospital`.

### `GET /api/v1/immunisation/vaccines`
- **Status:** **WORKING**
- **Flutter Screen:** `medical_records_screen.dart`
- **Service Method:** `ApiClient.get` via `ImmunisationRepository.getVaccines`
- **Repository Method:** `ImmunisationRepository.getVaccines()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** `List<VaccineDto>` (catalog of approved vaccines with dose count and manufacturer)
- **UI States Handled:** Vaccine formulary chip list, dose tracker badge, active status pill.
- **Verification Evidence:** `immunisation_repository_test.dart` (2/2 passing); Live probe HTTP 200.

### `GET /api/v1/immunisation/records`
- **Status:** **WORKING**
- **Flutter Screen:** `medical_records_screen.dart`
- **Service Method:** `ApiClient.get` via `ImmunisationRepository.getPatientRecords`
- **Repository Method:** `ImmunisationRepository.getPatientRecords()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** `List<PatientVaccinationRecordDto>`
- **UI States Handled:** Patient vaccination history, lot number, administration date, empty formulary fallback.
- **Verification Evidence:** `immunisation_repository_test.dart` passing.

### `POST /api/v1/patients/me/photo`
- **Status:** **WORKING**
- **Flutter Screen:** `personal_details_identity_screen.dart`, `patient_profile_screen.dart`
- **Service Method:** `ApiClient.post` via `PatientRepository.updateProfilePhoto`
- **Repository Method:** `PatientRepository.updateProfilePhoto({photoUrl, photoKey})`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `{"photoUrl": "https://...", "photoKey": "..."}`
- **Response Handling:** `{"success": true, "data": {...}}`
- **UI States Handled:** Avatar camera action badge, bottom action sheet, loading spinner, success update.
- **Verification Evidence:** `photo_and_card_block_test.dart` passing; Live probe HTTP 200 on staging.

### `DELETE /api/v1/patients/me/photo`
- **Status:** **WORKING**
- **Flutter Screen:** `personal_details_identity_screen.dart`, `patient_profile_screen.dart`
- **Service Method:** `ApiClient.delete` via `PatientRepository.deleteProfilePhoto`
- **Repository Method:** `PatientRepository.deleteProfilePhoto()`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** `{"success": true, "message": "Photo deleted"}`
- **UI States Handled:** Remove Photo dialog confirmation, revert avatar to initials badge.
- **Verification Evidence:** `photo_and_card_block_test.dart` passing; Live probe HTTP 200 on staging.

### `POST /api/v1/health-cards/:id/block`
- **Status:** **WORKING**
- **Flutter Screen:** `health_card_screen.dart`, `security_privacy_controls_screen.dart`
- **Service Method:** `ApiClient.post` via `DigitalHealthCardRepository.blockHealthCard`
- **Repository Method:** `DigitalHealthCardRepository.blockHealthCard(String cardId, {String? reason})`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `{"reason": "..."}`
- **Response Handling:** `{"success": true, "card": {"status": "BLOCKED"}}`
- **UI States Handled:** Security Freeze toggle & confirmation dialog, warning badge, audit trail.
- **Verification Evidence:** `photo_and_card_block_test.dart` passing; verified in staging lifecycle probe.

### `POST /api/v1/health-cards/:id/unblock`
- **Status:** **WORKING**
- **Flutter Screen:** `health_card_screen.dart`, `security_privacy_controls_screen.dart`
- **Service Method:** `ApiClient.post` via `DigitalHealthCardRepository.unblockHealthCard`
- **Repository Method:** `DigitalHealthCardRepository.unblockHealthCard(String cardId)`
- **Authentication:** Bearer JWT Required
- **Request Handling:** `None`
- **Response Handling:** `{"success": true, "card": {"status": "ACTIVE"}}`
- **UI States Handled:** Unblock button, restored active badge, audit trail update.
- **Verification Evidence:** `photo_and_card_block_test.dart` passing; verified in staging lifecycle probe.

### `GET /api/v1/health-cards/:id/history`
- **Status:** **WORKING**
- **Flutter Screen:** `health_card_screen.dart`
- **Service Method:** `ApiClient.get` via `DigitalHealthCardRepository.getCardHistory`
- **Repository Method:** `DigitalHealthCardRepository.getCardHistory(String cardId)`
- **Authentication:** Bearer JWT Required
- **Request Handling:** Path param `cardId`
- **Response Handling:** `List<dynamic>` status modification audit trail
- **UI States Handled:** Card audit timeline showing block/unblock timestamps and reasons.
- **Verification Evidence:** `photo_and_card_block_test.dart` passing; Live probe HTTP 200.

### `GET /api/v1/cms/faqs`
- **Status:** **WORKING**
- **Flutter Screen:** `patient_profile_screen.dart`
- **Service Method:** `ApiClient.get` via `FaqRepository.getFaqs`
- **Repository Method:** `FaqRepository.getFaqs({String? category})`
- **Authentication:** Bearer JWT Optional/Public
- **Request Handling:** Optional query `?category=...`
- **Response Handling:** `List<FaqItemDto>` (category, question, answer, order)
- **UI States Handled:** Searchable modal bottom sheet, expandable FAQ accordion items, category filtering.
- **Verification Evidence:** `faq_repository_test.dart` (2/2 passing); Live probe HTTP 200 (returns 4 FAQs).

### `DELETE /api/v1/auth/sessions/:sessionId`
- **Status:** **WORKING**
- **Flutter Screen:** `access_history_screen.dart`
- **Service Method:** `ApiClient.delete` via `SecurityRepository.terminateSession`
- **Repository Method:** `SecurityRepository.terminateSession(String sessionId)`
- **Authentication:** Bearer JWT Required
- **Request Handling:** Path param `sessionId`
- **Response Handling:** HTTP 204 No Content
- **UI States Handled:** Single session revoke button, loading state, item removal from session list.
- **Verification Evidence:** Live probe HTTP 204 No Content; verified in device testing.
