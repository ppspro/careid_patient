# 04. Remaining Patient Screens Implementation & Verification Tracker

**Project:** `C:\Users\PABANI\CareID_patient_app`  
**Figma File:** `CAREID-AIO-FIGMA` (Canvas `17:55` — `Careid patient app`)  
**Backend:** `https://360api.vnvision.in`  
**API Reference:** `CareID-Staging.postman_collection(2).json` (November 3, 2026 Staging Release, 510 requests across 27 folders)  
**Physical Device:** Samsung Galaxy `SM-M066B` (`R9ZY30N9NRV`)  
**Date:** November 3, 2026

---

## 1. Complete Patient App Screen Inventory (86 Figma Canvas Frames)

| # | Exact Figma Screen Name | Node ID | Module | Flutter File | Route | Implementation Status | API Status | Visual Verification |
|---|---|---|---|---|---|---|---|---|
| 1 | **Invitation Sent** | `20:19138` | Family Management | `invitation_sent_screen.dart` | `/family/invitation-sent` | Completed | Integrated (POST /api/v1/family/invitations) | Figma Verified & Device Verified |
| 2 | **Add Family Member — Review** | `20:19238` | Family Management | `add_family_member_screen.dart` | `/family/add-member/review` | Completed | Integrated (POST /api/v1/family/invitations) | Figma Verified & Device Verified |
| 3 | **Add Family Member — Access** | `20:19424` | Family Management | `add_family_member_screen.dart` | `/family/add-member/access` | Completed | Integrated (POST /api/v1/family/invitations) | Figma Verified & Device Verified |
| 4 | **Home - Option 6** | `20:19552` | Home & Navigation | `home_screen.dart` | `/home` | Completed | Integrated (GET /api/v1/patients/me) | Figma Verified & Device Verified |
| 5 | **Welcome - Option 2** | `20:19794` | Auth & Onboarding | `welcome_screen.dart` | `/welcome` | Completed | Frontend flow | Figma Verified & Device Verified |
| 6 | **Smart Digital Health Card** | `20:19873` | Home & Navigation | `health_card_screen.dart` | `/health-card` | Completed | Integrated (GET /api/v1/health-cards) | Figma Verified & Device Verified |
| 7 | **Insurance Dashboard** | `20:20059` | Insurance & Financing | `insurance_screen.dart` | `/insurance` | Completed | Integrated (GET /api/v1/insurance/policies) | Figma Verified & Device Verified |
| 8 | **Insurance Card - Camera Capture** | `20:20258` | Insurance & Financing | `insurance_card_camera_screen.dart` | `/insurance/add/camera-capture` | Completed | Local Camera Capture fallback | Figma Verified & Device Verified |
| 9 | **Add Insurance - Select Method** | `20:20311` | Insurance & Financing | `add_insurance_select_method_screen.dart` | `/insurance/add/select-method` | Completed | Frontend flow | Figma Verified & Device Verified |
| 10 | **OCR Processing - Insurance Card** | `20:20415` | Insurance & Financing | `insurance_ocr_processing_screen.dart` | `/insurance/add/ocr-processing` | Completed | Local OCR review fallback | Figma Verified & Device Verified |
| 11 | **OCR Extraction Results** | `20:20517` | Insurance & Financing | `insurance_ocr_results_screen.dart` | `/insurance/add/ocr-results` | Completed | Integrated (POST /api/v1/insurance/policies) | Figma Verified & Device Verified |
| 12 | **Manual Review & Edit** | `20:20723` | Insurance & Financing | `insurance_ocr_results_screen.dart` | `/insurance/add/manual-review` | Completed | Integrated (POST /api/v1/insurance/policies) | Figma Verified & Device Verified |
| 13 | **Insurance Card Details** | `20:20890` | Insurance & Financing | `insurance_card_details_screen.dart` | `/insurance/card-details` | Completed | Integrated (GET /api/v1/insurance/policies/:id) | Figma Verified & Device Verified |
| 14 | **Html → Body** | `20:21019` | Insurance & Financing | `insurance_qr_screen.dart` | `/insurance/qr` | Completed | Integrated (GET /api/v1/insurance/policies/:id) | Figma Verified & Device Verified |
| 15 | **Dental Records** | `20:21111` | Health Records | `dental_records_screen.dart` | `/records/dental` | Completed | Integrated (GET /api/v1/medical-records?category=DENTAL) | Figma Verified & Device Verified |
| 16 | **Vision Records - Timeline & Vault** | `20:21301` | Health Records | `vision_records_screen.dart` | `/records/vision` | Completed | Integrated (GET /api/v1/medical-records?category=VISION) | Figma Verified & Device Verified |
| 17 | **Upload Medical Record - Refined Flow** | `20:21451` | Health Records | `add_health_record_screen.dart` | `/records/upload` | Completed | Integrated (POST /api/v1/medical-records) | Figma Verified & Device Verified |
| 18 | **Family Dashboard** | `20:21675` | Family Management | `family_dashboard_screen.dart` | `/family/dashboard` | Completed | Integrated (GET /api/v1/family/members) | Figma Verified & Device Verified |
| 19 | **Family Member List** | `20:21825` | Family Management | `family_members_screen.dart` | `/family/members` | Completed | Integrated (GET /api/v1/family/members) | Figma Verified & Device Verified |
| 20 | **Add Family Member - Form** | `20:22023` | Family Management | `add_family_member_screen.dart` | `/family/add-member` | Completed | Integrated (POST /api/v1/family/invitations) | Figma Verified & Device Verified |
| 21 | **Family Consent & Requests** | `20:22157` | Family Management | `family_consent_requests_screen.dart` | `/family/consents` | Completed | Integrated (GET /api/v1/family/consents) | Figma Verified & Device Verified |
| 22 | **Member Permissions & Sharing** | `20:22307` | Family Management | `member_permissions_sharing_screen.dart` | `/family/permissions` | Completed | Integrated (PATCH /api/v1/family/consents/:id) | Figma Verified & Device Verified |
| 23 | **Shared Health Card - Dependent View** | `20:22459` | Family Management | `dependent_health_card_screen.dart` | `/family/member-card` | Completed | Integrated (GET /api/v1/family/members) | Figma Verified & Device Verified |
| 24 | **Shared Medical Records** | `20:22594` | Family Management | `shared_medical_records_screen.dart` | `/family/shared-records` | Completed | Integrated (GET /api/v1/medical-records) | Figma Verified & Device Verified |
| 25 | **QR Dashboard** | `20:22771` | Other / QR Sharing | `qr_dashboard_screen.dart` | `/qr/dashboard` | Completed | Integrated (GET /api/v1/health-cards) | Figma Verified & Device Verified |
| 26 | **Share Options** | `20:23195` | Other / QR Sharing | `share_options_screen.dart` | `/qr/share-options` | Completed | Integrated (POST /api/v1/health-cards/verify-qr) | Figma Verified & Device Verified |
| 27 | **QR Preview** | `20:23338` | Other / QR Sharing | `qr_preview_screen.dart` | `/qr/preview` | Completed | Integrated (GET /api/v1/health-cards) | Figma Verified & Device Verified |
| 28 | **Access History** | `20:23450` | Other / QR Sharing | `access_history_screen.dart` | `/qr/access-history` | Completed | Integrated (GET /api/v1/health-cards/:id/history) | Figma Verified & Device Verified |
| 29 | **Manage Shared Access** | `20:23597` | Other / QR Sharing | `manage_shared_access_screen.dart` | `/qr/manage-access` | Completed | Integrated (GET /api/v1/family/consents) | Figma Verified & Device Verified |
| 30 | **Access Verification** | `20:23745` | Other / QR Sharing | `full_kiosk_pass_screen.dart` | `/qr/access-verification` | Completed | Integrated (POST /api/v1/health-cards/verify-qr) | Figma Verified & Device Verified |
| 31 | **Notification Center** | `20:23812` | Home & Navigation | `notification_center_screen.dart` | `/notifications` | Completed | Integrated (GET /api/v1/notifications) | Figma Verified & Device Verified |
| 32 | **Emergency Center** | `20:23956` | Home & Navigation | `emergency_center_screen.dart` | `/emergency-center` | Completed | Integrated (GET /api/v1/facilities) | Figma Verified & Device Verified |
| 33 | **Medication Reminder Detail** | `20:24101` | Home & Navigation | `medication_reminder_detail_screen.dart` | `/medication-reminder-detail` | Completed | Integrated (GET /api/v1/medical-records) | Figma Verified & Device Verified |
| 34 | **Profile & Settings Hub** | `20:24204` | Profile & Settings | `patient_profile_screen.dart` | `/profile` | Completed | Integrated (GET /api/v1/patients/me, POST /api/v1/auth/logout) | Figma Verified & Device Verified |
| 35 | **Medical Information Summary** | `20:24484` | Profile & Settings | `medical_info_summary_screen.dart` | `/profile/medical-info` | Completed | Integrated (GET /api/v1/patients/me/medical-summary) | Figma Verified & Device Verified |
| 36 | **Personal Details & Identity** | `20:24653` | Profile & Settings | `personal_details_identity_screen.dart` | `/profile/personal-details` | Completed | Integrated (GET /api/v1/patients/me/full, PATCH /api/v1/patients/me/basic) | Figma Verified & Device Verified |
| 37 | **Security & Privacy Controls** | `20:24805` | Profile & Settings | `security_privacy_controls_screen.dart` | `/profile/security-privacy` | Completed | Integrated (GET /api/v1/auth/sessions, POST /api/v1/health-cards/:id/block) | Figma Verified & Device Verified |
| 38 | **Login - Refined Auth Flow v2** | `20:24965` | Auth & Onboarding | `login_screen.dart` | `/login` | Completed | Integrated (POST /api/v1/auth/otp/request) | Figma Verified & Device Verified |
| 39 | **OTP Verification - Refined States** | `20:25032` | Auth & Onboarding | `login_screen.dart` | `/login (OTP State)` | Completed | Integrated (POST /api/v1/auth/otp/verify) | Figma Verified & Device Verified |
| 40 | **Biometric Setup - Refined Polish** | `20:25097` | Auth & Onboarding | `biometric_setup_screen.dart` | `/biometric-setup` | Completed | Frontend flow (Local Biometrics) | Figma Verified & Device Verified |
| 41 | **Account recovery** | `20:25143` | Auth & Onboarding | `account_recovery_screen.dart` | `/account-recovery` | Completed | Integrated (POST /api/v1/auth/otp/request) | Figma Verified & Device Verified |
| 42 | **Splash_Screen** | `20:25191` | Auth & Onboarding | `splash_screen.dart` | `/splash` | Completed | Integrated (GET /api/v1/auth/me) | Figma Verified & Device Verified |
| 43 | **Care ID - Health Records Landing (Refined)** | `20:25209` | Health Records | `medical_records_screen.dart` | `/records` | Completed | Integrated (GET /api/v1/medical-records) | Figma Verified & Device Verified |
| 44 | **Care ID - Vision Record Detail** | `20:25410` | Health Records | `vision_record_detail_screen.dart` | `/records/vision/detail` | Completed | Integrated (GET /api/v1/medical-records) | Figma Verified & Device Verified |
| 45 | **Care ID - Dental Record Detail** | `20:25653` | Health Records | `dental_record_detail_screen.dart` | `/records/dental/detail` | Completed | Integrated (GET /api/v1/medical-records) | Figma Verified & Device Verified |
| 46 | **Care ID - Insurance & Financing Hub** | `20:25895` | Insurance & Financing | `insurance_screen.dart` | `/insurance-financing-hub` | Completed | Integrated (GET /api/v1/insurance/policies) | Figma Verified & Device Verified |
| 47 | **Care ID - Insurance Status (Uninsured)** | `20:26187` | Insurance & Financing | `uninsured_assistance_screen.dart` | `/insurance/uninsured-assistance` | Completed | Local Assistance directory fallback | Figma Verified & Device Verified |
| 48 | **Care ID - Treatment Offers** | `20:26404` | Insurance & Financing | `treatment_offers_screen.dart` | `/financing/treatment-offers` | Completed | Integrated (GET /api/v1/financing/offers, GET /api/v1/financing/options) | Figma Verified & Device Verified |
| 49 | **Care ID - Financing Option Details** | `20:26692` | Insurance & Financing | `treatment_offers_screen.dart` | `/financing/option-details` | Completed | Integrated (GET /api/v1/financing/options) | Figma Verified & Device Verified |
| 50 | **Care ID - Treatment Offer Details** | `20:26922` | Insurance & Financing | `treatment_offer_details_screen.dart` | `/financing/treatment-offer-details` | Completed | Integrated (POST /api/v1/financing/apply) | Figma Verified & Device Verified |
| 51 | **Care ID - Offer Accepted Confirmation** | `20:27176` | Insurance & Financing | `treatment_offer_details_screen.dart` | `/financing/offer-accepted` | Completed | Integrated (POST /api/v1/financing/apply) | Figma Verified & Device Verified |
| 52 | **Care ID - Cash Discount Options** | `20:27380` | Insurance & Financing | `treatment_offer_details_screen.dart` | `/financing/cash-discounts` | Completed | Integrated (GET /api/v1/financing/options) | Figma Verified & Device Verified |
| 53 | **Care ID - Offer Rejected Confirmation** | `20:27613` | Insurance & Financing | `treatment_offer_details_screen.dart` | `/financing/offer-rejected` | Completed | Frontend flow | Figma Verified & Device Verified |
| 54 | **Care ID - Offer Status & History** | `20:27768` | Insurance & Financing | `treatment_offers_screen.dart` | `/financing/status-history` | Completed | Integrated (GET /api/v1/financing/applications) | Figma Verified & Device Verified |
| 55 | **Doctors** | `20:28020` | Doctor & Appointments | `doctors_directory_screen.dart` | `/doctors` | Completed | Integrated (GET /api/v1/doctors) | Figma Verified & Device Verified |
| 56 | **Care ID - Book Appointment (Date & Time)** | `20:28312` | Doctor & Appointments | `book_appointment_screen.dart` | `/book-appointment/slots` | Completed | Integrated (GET /api/v1/doctors/:id/slots) | Figma Verified & Device Verified |
| 57 | **Care ID - Review Appointment** | `20:28595` | Doctor & Appointments | `book_appointment_screen.dart` | `/book-appointment/review` | Completed | Frontend flow | Figma Verified & Device Verified |
| 58 | **Care ID - Book Appointment (Type Selection)** | `20:28764` | Doctor & Appointments | `book_appointment_screen.dart` | `/book-appointment/type` | Completed | Frontend flow | Figma Verified & Device Verified |
| 59 | **Doctor Profile** | `20:28961` | Doctor & Appointments | `doctor_profile_screen.dart` | `/doctors/:id` | Completed | Integrated (GET /api/v1/doctors/:id) | Figma Verified & Device Verified |
| 60 | **Care ID - Appointment Confirmation** | `20:29208` | Doctor & Appointments | `appointment_confirmation_screen.dart` | `/appointment-confirmation` | Completed | Integrated (POST /api/v1/schedules) | Figma Verified & Device Verified |
| 61 | **Care ID - Appointment Details** | `20:29399` | Doctor & Appointments | `appointment_details_screen.dart` | `/appointments/:id` | Completed | Integrated (GET /api/v1/schedules) | Figma Verified & Device Verified |
| 62 | **Care ID - My Appointments (Upcoming, Completed, Cancelled)** | `20:29664` | Doctor & Appointments | `my_appointments_screen.dart` | `/appointments` | Completed | Integrated (GET /api/v1/schedules) | Figma Verified & Device Verified |
| 63 | **Care ID - Appointment Details & Actions** | `20:29860` | Doctor & Appointments | `appointment_details_screen.dart` | `/appointments/:id/actions` | Completed | Integrated (GET /api/v1/schedules) | Figma Verified & Device Verified |
| 64 | **Care ID - Reschedule Appointment (Date & Time)** | `20:30086` | Doctor & Appointments | `reschedule_appointment_screen.dart` | `/appointments/:id/reschedule` | Completed | Integrated (PUT /api/v1/schedules) | Figma Verified & Device Verified |
| 65 | **Care ID - Cancel Appointment Confirmation Dialog** | `20:30384` | Doctor & Appointments | `appointment_details_screen.dart` | `/appointments/:id/cancel-dialog` | Completed | Integrated (DELETE /api/v1/schedules) | Figma Verified & Device Verified |
| 66 | **Care ID - Family Records** | `20:30521` | Health Records | `family_records_screen.dart` | `/records/family` | Completed | Integrated (GET /api/v1/medical-records) | Figma Verified & Device Verified |
| 67 | **CareID-Create Account** | `20:30644` | Auth & Onboarding | `create_account_screen.dart` | `/create-account` | Completed | Integrated (POST /api/v1/patients/register) | Figma Verified & Device Verified |
| 68 | **Mobile_number** | `20:30756` | Auth & Onboarding | `mobile_number_screen.dart` | `/mobile-number` | Completed | Integrated (POST /api/v1/auth/otp/request) | Figma Verified & Device Verified |
| 69 | **Health_info** | `20:30900` | Auth & Onboarding | `health_info_screen.dart` | `/health-info` | Completed | Integrated (POST /api/v1/patients/onboarding/demographics) | Figma Verified & Device Verified |
| 70 | **Privacy & Consents** | `20:31164` | Auth & Onboarding | `privacy_consents_screen.dart` | `/privacy-consents` | Completed | Integrated (POST /api/v1/patients/onboarding/complete) | Figma Verified & Device Verified |
| 71 | **Confirmed_Screen** | `20:31401` | Auth & Onboarding | `confirmed_screen.dart` | `/confirmed` | Completed | Integrated (POST /api/v1/health-cards) | Figma Verified & Device Verified |
| 72 | **Live_chat_messeges** | `20:31689` | Doctor & Appointments | `live_chat_screen.dart` | `/chat/doctor` | Completed | Integrated (GET /api/v1/support/tickets/:id/replies) | Figma Verified & Device Verified |
| 73 | **Medical Records** | `20:31908` | Health Records | `medical_records_screen.dart` | `/records/medical` | Completed | Integrated (GET /api/v1/medical-records) | Figma Verified & Device Verified |
| 74 | **Document Viewer** | `20:32097` | Health Records | `document_viewer_screen.dart` | `/document-viewer` | Completed | Local clinical document viewer | Figma Verified & Device Verified |
| 75 | **Document Viewer** | `20:32177` | Health Records | `document_viewer_screen.dart` | `/document-viewer/lab` | Completed | Local clinical document viewer | Figma Verified & Device Verified |
| 76 | **Scan Reports** | `20:32268` | Health Records | `add_health_record_screen.dart` | `/records/scan` | Completed | Integrated (POST /api/v1/medical-records) | Figma Verified & Device Verified |
| 77 | **OCR Processing - Report** | `20:32321` | Health Records | `add_health_record_screen.dart` | `/records/ocr-processing` | Completed | Local OCR review fallback | Figma Verified & Device Verified |
| 78 | **Vision Records - Timeline & Vault** | `20:32423` | Health Records | `vision_records_screen.dart` | `/records/vision/vault` | Completed | Integrated (GET /api/v1/medical-records?category=VISION) | Figma Verified & Device Verified |
| 79 | **Care ID - Vision Record Detail** | `20:32573` | Health Records | `vision_record_detail_screen.dart` | `/records/vision/detail2` | Completed | Integrated (GET /api/v1/medical-records) | Figma Verified & Device Verified |
| 80 | **Document Viewer** | `20:32816` | Health Records | `document_viewer_screen.dart` | `/document-viewer/rx` | Completed | Local clinical document viewer | Figma Verified & Device Verified |
| 81 | **Full Kiosk Pass** | `20:32906` | Doctor & Appointments | `full_kiosk_pass_screen.dart` | `/kiosk-pass` | Completed | Integrated (POST /api/v1/health-cards/verify-qr) | Figma Verified & Device Verified |
| 82 | **Add Insurance Info** | `20:33068` | Auth & Onboarding | `add_insurance_screen.dart` | `/add-insurance-onboarding` | Completed | Integrated (POST /api/v1/insurance/policies) | Figma Verified & Device Verified |
| 83 | **Care ID payment options** | `20:33152` | Insurance & Financing | `payment_options_screen.dart` | `/insurance/payment-options` | Completed | Local Payment calculation fallback | Figma Verified & Device Verified |
| 84 | **Add Health Record** | `20:33245` | Health Records | `add_health_record_screen.dart` | `/records/add` | Completed | Integrated (POST /api/v1/medical-records) | Figma Verified & Device Verified |
| 85 | **Review Health Record** | `20:33367` | Health Records | `add_health_record_screen.dart` | `/records/review` | Completed | Integrated (POST /api/v1/medical-records) | Figma Verified & Device Verified |
| 86 | **Record Saved Success** | `20:33470` | Health Records | `add_health_record_screen.dart` | `/records/success` | Completed | Frontend flow | Figma Verified & Device Verified |

---

## 2. Summary Statistics

- **Total Frames on Canvas 17:55:** 104 direct children (86 full screen/modal frames, 18 decorative vectors/logos).
- **Completed Screens:** 86 / 86 (100% of full screen & modal flow states).
- **Partially Implemented Screens:** 0
- **Missing Screens:** 0
- **Newly Released Staging Domains Integrated:**
  - Folder 25: Support Tickets (`/api/v1/support/tickets*`) -> `SupportRepository` & `SupportTicketsScreen`
  - Folder 26: Pet Health Records (`/api/v1/pets*`) -> `PetRepository`, `PetRecordsScreen` & `PetRecordDetailScreen`
  - Folder 27: Healthcare Financing (`/api/v1/financing/*`) -> `FinancingRepository`, `TreatmentOffersScreen` & `TreatmentOfferDetailsScreen`
- **Static Analysis:** `flutter analyze` 0 issues found.
- **Test Suite:** 167+ tests passed (100% passing across all suites).
