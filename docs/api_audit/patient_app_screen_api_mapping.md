# Patient App Screen-to-API Mapping Matrix

**Project:** C:\Users\PABANI\CareID_patient_app
**Backend:** https://360api.vnvision.in
**Total Screens & Dialogs Audited:** 65

---

## 1. Classification Definitions

- **WORKING:** Endpoint exists in Postman, repository correctly invokes it, payload & response parsing verified.
- **PARTIALLY WORKING:** API exists in Postman, but specific actions, nested fields, or sub-queries are incomplete.
- **NOT INTEGRATED:** API exists in Postman, but Flutter screen relies on local or unintegrated repository logic.
- **MISSING API:** Screen requires backend service, but no suitable endpoint exists in CareID-Staging.postman_collection.json.
- **NOT APPLICABLE:** Screen is purely local state, device hardware (camera viewfinder), or visual interstitial navigation.

---

## 2. Complete Screen-to-API Audit Table

| Screen File | Figma Node | Module | Endpoint & Method | Status | Repository / Service | Functional Description |
|---|:---:|---|---|:---:|---|---|
| splash_screen.dart | 20:25191 | **Authentication & Onboarding** | GET /api/v1/health | **WORKING** | ApiClient.healthCheck | Checks live server health on launch |
| welcome_screen.dart | 20:19794 | **Authentication & Onboarding** | N/A | **NOT APPLICABLE** | None (Local State) | UI language selection & intro cards |
| create_account_screen.dart | 20:30644 | **Authentication & Onboarding** | POST /api/v1/patients/register | **WORKING** | RegistrationRepository.registerDraft | Submits patient registration draft |
| mobile_number_screen.dart | 20:30756 | **Authentication & Onboarding** | POST /api/v1/auth/otp/request, POST /api/v1/auth/otp/verify | **WORKING** | AuthRepository.requestOtp, verifyOtp | Requests and verifies 6-digit phone OTP |
| health_info_screen.dart | 20:30900 | **Authentication & Onboarding** | POST /api/v1/patients/onboarding/demographics | **WORKING** | OnboardingRepository.saveDemographics | Saves blood type, allergies, conditions |
| add_insurance_screen.dart | 20:33068 | **Authentication & Onboarding** | POST /api/v1/patients/onboarding/insurance | **WORKING** | OnboardingRepository.saveInsurance | Links initial insurance during onboarding |
| privacy_consents_screen.dart | 20:31164 | **Authentication & Onboarding** | POST /api/v1/patients/onboarding/complete | **WORKING** | OnboardingRepository.completeOnboarding | Submits legal consent agreements & completes |
| confirmed_screen.dart | 20:31401 | **Authentication & Onboarding** | GET /api/v1/patients/me/health-cards | **WORKING** | OnboardingRepository.getHealthCard | Loads newly generated digital health card pass |
| login_screen.dart | 20:24965 | **Authentication & Onboarding** | POST /api/v1/auth/otp/request, POST /api/v1/auth/otp/verify | **WORKING** | AuthRepository.requestOtp, verifyOtp | Phone challenge & OTP token issuance |
| account_recovery_screen.dart | N/A | **Authentication & Onboarding** | POST /api/v1/auth/otp/request | **PARTIALLY WORKING** | AuthRepository.requestOtp | Requires dedicated password/recovery reset API |
| biometric_setup_screen.dart | N/A | **Authentication & Onboarding** | POST /api/v1/security/biometrics (Missing) | **MISSING API** | Local Auth Storage | Hardware biometric enrolled locally; missing backend sync |
| home_screen.dart | 20:19552 | **Home & Profile** | GET /api/v1/patients/me/full, GET /api/v1/health-cards | **WORKING** | PatientRepository.getFullProfile, DigitalHealthCardRepository.getCard | Loads greeting, patient stats, health card, vitals |
| patient_profile_screen.dart | 20:24204 | **Home & Profile** | GET /api/v1/patients/me, GET /api/v1/patients/profile/completion | **WORKING** | PatientRepository.getPatientProfile, getProfileCompletion | Renders profile summary, bento score, setting groups |
| personal_details_identity_screen.dart | 20:24653 | **Home & Profile** | PATCH /api/v1/patients/me/basic, PATCH /api/v1/patients/me/address | **WORKING** | PatientRepository.updateBasicDetails, updateAddress | Updates legal name, address, contact numbers |
| medical_info_summary_screen.dart | 20:24484 | **Home & Profile** | PATCH /api/v1/patients/me/medical-summary | **WORKING** | PatientRepository.updateMedicalSummary | Updates allergies, blood group, chronic conditions |
| health_card_screen.dart | 20:19873 | **Home & Profile** | GET /api/v1/health-cards, POST /api/v1/health-cards/verify-qr | **WORKING** | DigitalHealthCardRepository.getCard, verifyQr | Renders verifiable QR pass, Apple Wallet badge |
| full_kiosk_pass_screen.dart | 20:29208 | **Home & Profile** | GET /api/v1/health-cards | **WORKING** | DigitalHealthCardRepository.getCard | Full-brightness kiosk check-in barcode/QR |
| qr_dashboard_screen.dart | 20:23083 | **Home & Profile** | GET /api/v1/health-cards, GET /api/v1/family/consents | **WORKING** | DigitalHealthCardRepository.getCard, getConsents | Controls QR expiration, view permissions |
| qr_preview_screen.dart | 20:23253 | **Home & Profile** | GET /api/v1/health-cards | **WORKING** | DigitalHealthCardRepository.getCard | Live visual preview of encrypted QR credential |
| share_options_screen.dart | 20:23188 | **Home & Profile** | POST /api/v1/family/consents (Missing payload) | **PARTIALLY WORKING** | DigitalHealthCardRepository.createGrant | Share link generation requires backend shortlink API |
| manage_shared_access_screen.dart | 20:23348 | **Home & Profile** | GET /api/v1/family/consents, PATCH /api/v1/family/consents/{id} | **WORKING** | DigitalHealthCardRepository.getConsents, updateGrant | Lists active third-party grants with Revoke action |
| medical_records_screen.dart | 20:31908 | **Health Records** | GET /api/v1/medical-records, GET /api/v1/medical-records/timeline | **WORKING** | MedicalRecordsRepository.getMedicalRecords, getTimeline | Categorized vault: General, Dental, Vision, Labs |
| dental_records_screen.dart | 20:21111 | **Health Records** | GET /api/v1/medical-records?category=DENTAL | **WORKING** | MedicalRecordsRepository.getMedicalRecords | Renders dental timeline, tooth arch metrics |
| vision_records_screen.dart | 20:21301 | **Health Records** | GET /api/v1/medical-records?category=VISION | **WORKING** | MedicalRecordsRepository.getMedicalRecords | Renders visual acuity OD/OS, fundus reports |
| record_detail_screen.dart | 20:25410 | **Health Records** | GET /api/v1/medical-records/{id} | **WORKING** | MedicalRecordsRepository.getRecordDetail | Renders encryption strip, provider, diagnosis, notes |
| medical_record_detail_screen.dart | 20:25410 | **Health Records** | GET /api/v1/medical-records/{id} | **WORKING** | MedicalRecordsRepository.getRecordDetail | Detailed view for inpatient/general consultations |
| dental_record_detail_screen.dart | 20:25653 | **Health Records** | GET /api/v1/medical-records/{id} | **WORKING** | MedicalRecordsRepository.getRecordDetail | High-res dental arch X-ray and scaling summary |
| vision_record_detail_screen.dart | 20:25890 | **Health Records** | GET /api/v1/medical-records/{id} | **WORKING** | MedicalRecordsRepository.getRecordDetail | Refraction, sphere, cylinder, add powers |
| add_health_record_screen.dart | 20:33245 | **Health Records** | POST /api/v1/medical-records | **WORKING** | MedicalRecordsRepository.createRecord | Patient self-uploaded vital record or lab note |
| document_viewer_screen.dart | N/A | **Health Records** | GET /api/v1/files/{id}/download (Missing) | **MISSING API** | HttpClient | Missing signed URL generation for clinical DICOM/PDF |
| pet_records_screen.dart | 20:33450 | **Health Records** | GET /api/v1/pets/records (Missing) | **MISSING API** | Mock fallback | Pet care records absent from staging Postman collection |
| pet_record_detail_screen.dart | 20:33590 | **Health Records** | GET /api/v1/pets/records/{id} (Missing) | **MISSING API** | Mock fallback | Pet vaccinations & veterinary details missing from backend |
| insurance_screen.dart | 20:20059 | **Insurance & Financing** | GET /api/v1/insurance/policies, GET /api/v1/insurance/claims | **WORKING** | InsuranceRepository.getPolicies, getClaims | Active policies, claims timeline, benefits card |
| add_insurance_select_method_screen.dart | 20:20311 | **Insurance & Financing** | N/A | **NOT APPLICABLE** | Local Navigation | Method choice: Photo Camera capture vs Manual Form |
| insurance_card_camera_screen.dart | 20:20258 | **Insurance & Financing** | N/A | **NOT APPLICABLE** | Camera Plugin | On-device camera viewfinder with document bounding box |
| insurance_ocr_processing_screen.dart | 20:20415 | **Insurance & Financing** | POST /api/v1/insurance/ocr/scan | **WORKING** | InsuranceRepository.scanCardOcr | Submits insurance card image for OCR field extraction |
| insurance_ocr_results_screen.dart | 20:20517 | **Insurance & Financing** | POST /api/v1/insurance/ocr/confirm | **WORKING** | InsuranceRepository.confirmOcrPolicy | Presents extracted policy fields with confidence scores |
| insurance_card_details_screen.dart | 20:20890 | **Insurance & Financing** | GET /api/v1/insurance/policies/{id} | **WORKING** | InsuranceRepository.getPolicyDetail | Full policy copay tiers, deductibles and coverage terms |
| claim_details_screen.dart | 20:20158 | **Insurance & Financing** | GET /api/v1/insurance/claims/{id} (Missing) | **PARTIALLY WORKING** | InsuranceRepository.getClaims | Lists claims, but single claim detail endpoint missing |
| treatment_offers_screen.dart | 20:26404 | **Insurance & Financing** | GET /api/v1/financing/offers (Missing) | **MISSING API** | Static PRD Model | Treatment financing packages & loan term calculator |
| treatment_offer_details_screen.dart | 20:26922 | **Insurance & Financing** | POST /api/v1/financing/offers/{id}/accept (Missing) | **MISSING API** | Static PRD Model | Offer acceptance, installment agreement and e-sign |
| uninsured_assistance_screen.dart | 20:26550 | **Insurance & Financing** | GET /api/v1/financing/assistance-programs (Missing) | **MISSING API** | Static PRD Model | Community health grants & sliding-scale discount programs |
| payment_options_screen.dart | 20:26780 | **Insurance & Financing** | GET /api/v1/payments/methods (Missing) | **MISSING API** | Static PRD Model | CareID Health Credit wallet & card processor |
| family_dashboard_screen.dart | 20:21675 | **Family Management** | GET /api/v1/family/members, GET /api/v1/family/invitations | **WORKING** | FamilyRepository.getMembers, getInvitations | Active family circle, pending invites, consent banner |
| family_members_screen.dart | 20:21825 | **Family Management** | GET /api/v1/family/members | **WORKING** | FamilyRepository.getMembers | Full list of dependents, spouses, guardians with roles |
| add_family_member_screen.dart | 20:22023 | **Family Management** | POST /api/v1/family/invitations | **WORKING** | FamilyRepository.sendInvitation | Demographics, permission scoping, review & invite |
| invitation_sent_screen.dart | 20:19138 | **Family Management** | N/A | **NOT APPLICABLE** | Local Navigation | Visual confirmation and invitation token preview |
| family_records_screen.dart | 20:30521 | **Family Management** | GET /api/v1/family/members/{id}/records (Missing) | **PARTIALLY WORKING** | MedicalRecordsRepository | Uses generic records; missing member-scoped vault query |
| shared_medical_records_screen.dart | 20:22594 | **Family Management** | GET /api/v1/family/members, GET /api/v1/medical-records | **WORKING** | FamilyRepository.getMembers, MedicalRecordsRepository | Member switcher with timeline filtering |
| dependent_health_card_screen.dart | 20:22459 | **Family Management** | GET /api/v1/health-cards/{dependentId} (Missing) | **PARTIALLY WORKING** | DigitalHealthCardRepository | Renders card; requires backend dependent pass endpoint |
| member_permissions_sharing_screen.dart | 20:22307 | **Family Management** | PATCH /api/v1/family/members/{id}/permissions (Missing) | **MISSING API** | Local State | Granular toggles for dental, vision, medical, labs |
| family_consent_requests_screen.dart | 20:22157 | **Family Management** | GET /api/v1/family/consents, PATCH /api/v1/family/consents/{id} | **WORKING** | FamilyRepository.getConsents, updateConsentStatus | Pending doctor/clinic access requests with Approve/Deny |
| doctors_directory_screen.dart | 20:28020 | **Doctors & Appointments** | GET /api/v1/doctors, GET /api/v1/doctors/search | **WORKING** | DoctorRepository.getDoctors, searchDoctors | Specialty tabs (MD, DDS, OD), search by clinic/name |
| doctor_profile_screen.dart | 20:28961 | **Doctors & Appointments** | GET /api/v1/doctors/{id} | **WORKING** | DoctorRepository.getDoctorById | Credentials, synced records badge, verified tier, CTA |
| book_appointment_screen.dart | 20:28764 | **Doctors & Appointments** | GET /api/v1/doctors/{id}/slots, POST /api/v1/schedules | **WORKING** | DoctorRepository.getDoctorSlots, bookAppointment | 3-step flow: Consultation Type, Date & Time, Review |
| my_appointments_screen.dart | 20:29664 | **Doctors & Appointments** | GET /api/v1/schedules | **WORKING** | DoctorRepository.getMyAppointments | Tabs: Upcoming, Completed, Cancelled |
| appointment_details_screen.dart | 20:29860 | **Doctors & Appointments** | GET /api/v1/schedules/{id} (Missing) | **PARTIALLY WORKING** | DoctorRepository.getMyAppointments | Uses list object; missing single appointment detail GET |
| cancel_appointment_dialog.dart | 20:30384 | **Doctors & Appointments** | PUT /api/v1/schedules/{id}/cancel (Missing) | **PARTIALLY WORKING** | DoctorRepository.cancelAppointment | Figma specifies cancel quota warning; uses generic schedule delete |
| reschedule_appointment_screen.dart | 20:29512 | **Doctors & Appointments** | PUT /api/v1/schedules/{id}/reschedule (Missing) | **MISSING API** | DoctorRepository (Stub) | Select new date/slot and update existing booking |
| notification_center_screen.dart | 20:23812 | **Communication & Alerts** | GET /api/v1/notifications, PUT /api/v1/notifications/{id}/read | **WORKING** | NotificationRepository.getNotifications, markAsRead | Category filter bar, mark-all-read, priority styling |
| live_chat_screen.dart | 20:29012 | **Communication & Alerts** | GET /api/v1/chat/messages, POST /api/v1/chat/messages (Missing) | **MISSING API** | Mock local stream | Real-time doctor messaging absent from Postman collection |
| emergency_center_screen.dart | 20:23956 | **Emergency & Security** | GET /api/v1/patients/me/full, POST /api/v1/emergency/sos (Missing) | **PARTIALLY WORKING** | PatientRepository.getFullProfile | Profile loads blood/allergies/ICE; live SOS trigger missing |
| security_privacy_controls_screen.dart | 20:24805 | **Emergency & Security** | GET /api/v1/auth/sessions, POST /api/v1/auth/logout-all | **WORKING** | AuthRepository.getSessions, logoutAll | Active device sessions, biometric toggle, remote revoke |
| access_history_screen.dart | 20:23450 | **Emergency & Security** | GET /api/v1/health-cards/{id}/history | **WORKING** | DigitalHealthCardRepository.getCardHistory | Bento stats, timeline of who accessed medical record vault |
| medication_reminder_detail_screen.dart | 20:24101 | **Medication Reminders** | GET /api/v1/prescriptions/{id} (Missing), POST /api/v1/prescriptions/{id}/refill (Missing) | **MISSING API** | Static PRD Model | Prescription details, dosage schedules, Mark as Collected |

---

## 3. Screen Status Breakdown

| Classification Status | Count | Percentage |
|---|:---:|:---:|
| **WORKING** | 41 | 63.1% |
| **MISSING API** | 12 | 18.5% |
| **PARTIALLY WORKING** | 8 | 12.3% |
| **NOT APPLICABLE** | 4 | 6.2% |
| **Total** | **65** | **100.0%** |