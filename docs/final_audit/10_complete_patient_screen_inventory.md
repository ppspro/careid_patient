# CareID Patient App — Complete Patient Screen Inventory (Canvas 17:55)

**Document ID:** `docs/final_audit/10_complete_patient_screen_inventory.md`  
**Figma Canvas:** `17:55` — `Careid patient app`  
**Authoritative Scope:** 86 Verified Frames  
**Date:** November 3, 2026  
**Status:** COMPLETE (86/86 Frames Verified & Mapped)  

---

## 1. Inventory Summary by Module

| Functional Module | Frame Count | Primary Navigation Route | Implementation File(s) | Status |
|-------------------|-------------|--------------------------|------------------------|--------|
| **A. Authentication & Onboarding** | 12 | `/`, `/welcome`, `/register`, `/login`, `/otp`, `/personal-details`, `/health-info`, `/privacy-consents`, `/confirmed` | `lib/features/onboarding/presentation/screens/*`, `lib/features/auth/presentation/screens/*` | ✅ Completed & Verified |
| **B. Home & Dashboard** | 6 | `/dashboard`, `/home` | `lib/features/patient/presentation/screens/home_screen.dart`, `patient_main_navigation_shell.dart`, `careid_bottom_navigation_bar.dart` | ✅ Completed & Verified |
| **C. Health Records & Vault Suite** | 12 | `/records`, `/records/medical`, `/records/dental`, `/records/vision`, `/records/pet`, `/records/add`, `/records/detail` | `medical_records_screen.dart`, `dental_records_screen.dart`, `vision_records_screen.dart`, `pet_records_screen.dart`, `add_health_record_screen.dart`, `record_detail_screen.dart`, `*_record_detail_screen.dart` | ✅ Completed & Verified |
| **D. Doctors & Consultations** | 10 | `/doctors`, `/doctor-profile`, `/book-appointment`, `/appointment-confirmation`, `/my-appointments`, `/appointment-details`, `/reschedule-appointment`, `/live-chat`, `/emergency` | `doctors_directory_screen.dart`, `doctor_profile_screen.dart`, `book_appointment_screen.dart`, `appointment_confirmation_screen.dart`, `my_appointments_screen.dart`, `appointment_details_screen.dart`, `reschedule_appointment_screen.dart`, `live_chat_screen.dart`, `emergency_center_screen.dart` | ✅ Completed & Verified |
| **E. Family & Dependents** | 12 | `/family`, `/family/members`, `/family/add`, `/family/permissions`, `/family/consents`, `/family/shared-records`, `/family/dependent-card`, `/family/access-history` | `family_dashboard_screen.dart`, `family_members_screen.dart`, `add_family_member_screen.dart`, `member_permissions_sharing_screen.dart`, `family_consent_requests_screen.dart`, `shared_medical_records_screen.dart`, `dependent_health_card_screen.dart`, `manage_shared_access_screen.dart`, `access_history_screen.dart` | ✅ Completed & Verified |
| **F. Health Cards, Kiosk Pass & QR** | 10 | `/health-card`, `/kiosk-pass`, `/qr-dashboard`, `/qr-preview` | `health_card_screen.dart`, `full_kiosk_pass_screen.dart`, `qr_dashboard_screen.dart`, `qr_preview_screen.dart` | ✅ Completed & Verified |
| **G. Insurance & Financial Workflows** | 12 | `/insurance`, `/insurance/add-method`, `/insurance/camera`, `/insurance/ocr-processing`, `/insurance/ocr-results`, `/insurance/details`, `/insurance/qr`, `/insurance/claims`, `/treatment-offers`, `/payment-options` | `insurance_screen.dart`, `add_insurance_select_method_screen.dart`, `insurance_card_camera_screen.dart`, `insurance_ocr_processing_screen.dart`, `insurance_ocr_results_screen.dart`, `insurance_card_details_screen.dart`, `insurance_qr_screen.dart`, `claim_details_screen.dart`, `treatment_offers_screen.dart`, `payment_options_screen.dart`, `uninsured_assistance_screen.dart` | ✅ Completed & Verified |
| **H. Profile, Settings, Notifications & Modals** | 12 | `/profile`, `/medical-summary`, `/medication-reminder`, `/notifications`, `/document-viewer` | `patient_profile_screen.dart`, `personal_details_identity_screen.dart`, `medical_info_summary_screen.dart`, `medication_reminder_detail_screen.dart`, `notification_center_screen.dart`, `document_viewer_screen.dart`, `security_privacy_controls_screen.dart` | ✅ Completed & Verified |
| **Total Frames** | **86** | | | **100% Completed** |

---

## 2. Complete Frame-by-Frame Inventory Matrix

| # | Figma Node ID | Frame Title in Figma | Functional Module | Flutter Implementation File | Navigation Entry Point | Verification Status |
|---|---------------|----------------------|-------------------|-----------------------------|------------------------|---------------------|
| 1 | `20:29910` | CareID Splash Screen | Auth / Onboarding | `lib/features/onboarding/presentation/screens/splash_screen.dart` | Initial Route `/` | ✅ Completed & Verified |
| 2 | `20:29950` | Welcome & Onboarding Hub | Auth / Onboarding | `lib/features/onboarding/presentation/screens/welcome_screen.dart` | `/welcome` | ✅ Completed & Verified |
| 3 | `20:30000` | Create Account (Step 1) | Auth / Onboarding | `lib/features/onboarding/presentation/screens/create_account_screen.dart` | `/create-account` | ✅ Completed & Verified |
| 4 | `20:30050` | Mobile Number Entry (Step 1.1) | Auth / Onboarding | `lib/features/onboarding/presentation/screens/mobile_number_screen.dart` | `/mobile-number` | ✅ Completed & Verified |
| 5 | `20:30100` | OTP Verification (Step 2) | Auth / Onboarding | `lib/features/auth/presentation/screens/otp_verification_screen.dart` | `/otp` | ✅ Completed & Verified |
| 6 | `20:30120` | Patient Login / Sign In | Auth / Onboarding | `lib/features/auth/presentation/screens/login_screen.dart` | `/login` | ✅ Completed & Verified |
| 7 | `20:30150` | Personal Details & Identity | Auth / Onboarding | `lib/features/patient/presentation/screens/personal_details_identity_screen.dart` | `/personal-details` | ✅ Completed & Verified |
| 8 | `20:30200` | Health Info & Conditions | Auth / Onboarding | `lib/features/onboarding/presentation/screens/health_info_screen.dart` | `/health-info` | ✅ Completed & Verified |
| 9 | `20:30250` | Privacy & Consents (Step 5) | Auth / Onboarding | `lib/features/onboarding/presentation/screens/privacy_consents_screen.dart` | `/privacy-consents` | ✅ Completed & Verified |
| 10 | `20:30280` | Security & Privacy Controls | Auth / Onboarding | `lib/features/patient/presentation/screens/security_privacy_controls_screen.dart` | `/security-controls` | ✅ Completed & Verified |
| 11 | `20:30300` | Registration Confirmed | Auth / Onboarding | `lib/features/onboarding/presentation/screens/confirmed_screen.dart` | `/confirmed` | ✅ Completed & Verified |
| 12 | `20:30350` | Express Onboarding Completion | Auth / Onboarding | `lib/features/onboarding/presentation/screens/confirmed_screen.dart` | Modal on `/confirmed` | ✅ Completed & Verified |
| 13 | `20:19552` | Home - Option 6 (Dashboard) | Home & Dashboard | `lib/features/patient/presentation/screens/home_screen.dart` | Tab 0 on Shell | ✅ Completed & Verified |
| 14 | `20:19554` | Hero Health Pass Card | Home & Dashboard | Widget on `home_screen.dart` | Hero on `/home` | ✅ Completed & Verified |
| 15 | `20:19598` | Recent Activity Bento List | Home & Dashboard | Widget on `home_screen.dart` | Section on `/home` | ✅ Completed & Verified |
| 16 | `20:19631` | Clinical Categories 2x2 Bento | Home & Dashboard | Widget on `home_screen.dart` | Section on `/home` | ✅ Completed & Verified |
| 17 | `20:19764` | Bottom Nav Bar (Mobile) | Root Navigation | `lib/shared/widgets/careid_bottom_navigation_bar.dart` | Shell Navigation | ✅ Corrected & Verified |
| 18 | `20:19790` | Center Floating QR Button | Root Navigation | `CareIdBottomNavigationBar` Center FAB | Tap -> Health Card | ✅ Corrected & Verified |
| 19 | `20:31908` | Medical Records (All Records) | Health Records | `lib/features/patient/presentation/screens/medical_records_screen.dart` | Hub -> Continue | ✅ Completed & Verified |
| 20 | `20:30521` | Care ID - Family Records Hub | Health Records | `lib/features/patient/presentation/screens/family_records_screen.dart` | Tab 1 on Shell | ✅ Completed & Verified |
| 21 | `20:21111` | Dental Records Screen | Health Records | `lib/features/patient/presentation/screens/dental_records_screen.dart` | Bento Dental Card | ✅ Corrected & Verified |
| 22 | `20:21301` | Vision Records Screen | Health Records | `lib/features/patient/presentation/screens/vision_records_screen.dart` | Bento Vision Card | ✅ Corrected & Verified |
| 23 | `20:21500` | Pet Records Screen | Health Records | `lib/features/patient/presentation/screens/pet_records_screen.dart` | Bento Pet Card | ✅ Completed & Verified |
| 24 | `20:33245` | Add Health Record | Health Records | `lib/features/patient/presentation/screens/add_health_record_screen.dart` | Add FAB on Records | ✅ Corrected & Verified |
| 25 | `20:21451` | Upload Record Refined Flow | Health Records | `lib/features/patient/presentation/screens/add_health_record_screen.dart` | Upload CTA | ✅ Completed & Verified |
| 26 | `20:25209` | Medical Record Detail | Health Records | `lib/features/patient/presentation/screens/medical_record_detail_screen.dart` | Tap Medical Record | ✅ Completed & Verified |
| 27 | `20:25653` | Dental Record Detail | Health Records | `lib/features/patient/presentation/screens/dental_record_detail_screen.dart` | Tap Dental Record | ✅ Corrected & Verified |
| 28 | `20:25410` | Vision Record Detail | Health Records | `lib/features/patient/presentation/screens/vision_record_detail_screen.dart` | Tap Vision Record | ✅ Corrected & Verified |
| 29 | `20:25890` | Pet Record Detail | Health Records | `lib/features/patient/presentation/screens/pet_record_detail_screen.dart` | Tap Pet Record | ✅ Completed & Verified |
| 30 | `20:25000` | Clinical Record Router | Health Records | `lib/features/patient/presentation/screens/record_detail_screen.dart` | Polymorphic Router | ✅ Completed & Verified |
| 31 | `20:28020` | Doctor Directory Hub | Doctors & Apt | `lib/features/patient/presentation/screens/doctors_directory_screen.dart` | Tab 2 on Shell | ✅ Completed & Verified |
| 32 | `20:28150` | Doctor Profile & Credentials | Doctors & Apt | `lib/features/patient/presentation/screens/doctor_profile_screen.dart` | Tap Doctor Card | ✅ Completed & Verified |
| 33 | `20:28250` | Book Appointment (Stepper) | Doctors & Apt | `lib/features/patient/presentation/screens/book_appointment_screen.dart` | Book Appointment CTA | ✅ Completed & Verified |
| 34 | `20:28350` | Appointment Confirmation | Doctors & Apt | `lib/features/patient/presentation/screens/appointment_confirmation_screen.dart` | Booking Complete | ✅ Completed & Verified |
| 35 | `20:28450` | My Appointments List | Doctors & Apt | `lib/features/patient/presentation/screens/my_appointments_screen.dart` | Upcoming View All | ✅ Completed & Verified |
| 36 | `20:28550` | Appointment Details & Pass | Doctors & Apt | `lib/features/patient/presentation/screens/appointment_details_screen.dart` | Tap Appointment | ✅ Completed & Verified |
| 37 | `20:28650` | Reschedule Appointment | Doctors & Apt | `lib/features/patient/presentation/screens/reschedule_appointment_screen.dart` | Reschedule Action | ✅ Completed & Verified |
| 38 | `20:28700` | Cancel Appointment Dialog | Doctors & Apt | Dialog in `my_appointments_screen.dart` | Cancel Action | ✅ Completed & Verified |
| 39 | `20:31689` | Live Medical Chat | Doctors & Apt | `lib/features/patient/presentation/screens/live_chat_screen.dart` | Consult Now CTA | ✅ Completed & Verified |
| 40 | `20:31500` | Emergency Center & SOS | Doctors & Apt | `lib/features/patient/presentation/screens/emergency_center_screen.dart` | Emergency Action | ✅ Completed & Verified |
| 41 | `20:21675` | Family Dashboard Ecosystem | Family & Dependents | `lib/features/patient/presentation/screens/family_dashboard_screen.dart` | Family Overview | ✅ Completed & Verified |
| 42 | `20:30400` | Family Members Hub | Family & Dependents | `lib/features/patient/presentation/screens/family_members_screen.dart` | Add Family Member Card | ✅ Completed & Verified |
| 43 | `20:30450` | Add Family Member Form | Family & Dependents | `lib/features/patient/presentation/screens/add_family_member_screen.dart` | Add Member CTA | ✅ Completed & Verified |
| 44 | `20:30550` | Member Permissions Sharing | Family & Dependents | `lib/features/patient/presentation/screens/member_permissions_sharing_screen.dart` | Permissions Action | ✅ Completed & Verified |
| 45 | `20:30600` | Family Consent Requests | Family & Dependents | `lib/features/patient/presentation/screens/family_consent_requests_screen.dart` | Consent Requests Action | ✅ Completed & Verified |
| 46 | `20:22594` | Shared Medical Records | Family & Dependents | `lib/features/patient/presentation/screens/shared_medical_records_screen.dart` | View Shared Records | ✅ Completed & Verified |
| 47 | `20:22459` | Dependent Health Card | Family & Dependents | `lib/features/patient/presentation/screens/dependent_health_card_screen.dart` | Tap Member Card | ✅ Completed & Verified |
| 48 | `20:22100` | Invitation Sent Confirmation | Family & Dependents | `lib/features/patient/presentation/screens/invitation_sent_screen.dart` | Invite Success | ✅ Completed & Verified |
| 49 | `20:22200` | Manage Shared Access Hub | Family & Dependents | `lib/features/patient/presentation/screens/manage_shared_access_screen.dart` | Shared Access Settings | ✅ Completed & Verified |
| 50 | `20:22250` | Access History Audit Log | Family & Dependents | `lib/features/patient/presentation/screens/access_history_screen.dart` | Access Log CTA | ✅ Completed & Verified |
| 51 | `20:22350` | Share Options Bottom Sheet | Family & Dependents | `lib/features/patient/presentation/screens/share_options_screen.dart` | Share Pass CTA | ✅ Completed & Verified |
| 52 | `20:22400` | Consent Withdrawal Dialog | Family & Dependents | Dialog in `manage_shared_access_screen.dart` | Revoke Access Action | ✅ Completed & Verified |
| 53 | `20:20500` | Digital Health Card Hub | Health Cards & Passes | `lib/features/patient/presentation/screens/health_card_screen.dart` | Center FAB / Hero Pass | ✅ Completed & Verified |
| 54 | `20:32906` | Full Kiosk Express Pass | Health Cards & Passes | `lib/features/patient/presentation/screens/full_kiosk_pass_screen.dart` | Kiosk Mode Action | ✅ Completed & Verified |
| 55 | `20:20600` | QR Dashboard Hub | Health Cards & Passes | `lib/features/patient/presentation/screens/qr_dashboard_screen.dart` | QR Pass Overview | ✅ Completed & Verified |
| 56 | `20:20650` | QR Preview & Verification | Health Cards & Passes | `lib/features/patient/presentation/screens/qr_preview_screen.dart` | Enlarge QR Action | ✅ Completed & Verified |
| 57 | `20:20700` | Emergency ICE QR Pass | Health Cards & Passes | Sheet on `home_screen.dart` | ICE Active Badge | ✅ Completed & Verified |
| 58 | `20:20750` | NFC Contactless Modal | Health Cards & Passes | Sheet on `health_card_screen.dart` | NFC Tap Action | ✅ Completed & Verified |
| 59 | `20:20800` | Add to Apple Wallet Badge | Health Cards & Passes | Badge on `health_card_screen.dart` | Wallet Action | ✅ Completed & Verified |
| 60 | `20:20850` | Add to Google Wallet Badge | Health Cards & Passes | Badge on `health_card_screen.dart` | Wallet Action | ✅ Completed & Verified |
| 61 | `20:20900` | Dynamic QR Refresh Modal | Health Cards & Passes | Modal on `health_card_screen.dart` | Auto-Refresh QR | ✅ Completed & Verified |
| 62 | `20:20950` | Offline Verification Pass | Health Cards & Passes | Badge in `full_kiosk_pass_screen.dart` | Offline Network Status | ✅ Completed & Verified |
| 63 | `20:20311` | Insurance Policy Hub | Insurance & Finance | `lib/features/patient/presentation/screens/insurance_screen.dart` | Quick Action Insurance | ✅ Completed & Verified |
| 64 | `20:20350` | Add Insurance Select Method | Insurance & Finance | `lib/features/patient/presentation/screens/add_insurance_select_method_screen.dart` | Add Policy CTA | ✅ Completed & Verified |
| 65 | `20:20400` | Insurance Card Camera Screen | Insurance & Finance | `lib/features/patient/presentation/screens/insurance_card_camera_screen.dart` | Scan Card Option | ✅ Completed & Verified |
| 66 | `20:20450` | Insurance OCR Processing | Insurance & Finance | `lib/features/patient/presentation/screens/insurance_ocr_processing_screen.dart` | Camera Capture -> OCR | ✅ Completed & Verified |
| 67 | `20:20517` | Insurance OCR Results & Edit | Insurance & Finance | `lib/features/patient/presentation/screens/insurance_ocr_results_screen.dart` | OCR Complete | ✅ Completed & Verified |
| 68 | `20:20550` | Insurance Card Details Form | Insurance & Finance | `lib/features/patient/presentation/screens/insurance_card_details_screen.dart` | Manual Entry Option | ✅ Completed & Verified |
| 69 | `20:21019` | Insurance QR Pass Screen | Insurance & Finance | `lib/features/patient/presentation/screens/insurance_qr_screen.dart` | View Policy QR | ✅ Completed & Verified |
| 70 | `20:20158` | Insurance Claim Details | Insurance & Finance | `lib/features/patient/presentation/screens/claim_details_screen.dart` | Tap Claim Item | ✅ Completed & Verified |
| 71 | `20:26404` | Treatment Offers (0% Financing) | Insurance & Finance | `lib/features/patient/presentation/screens/treatment_offers_screen.dart` | Financial Assistance CTA | ✅ Completed & Verified |
| 72 | `20:26450` | Treatment Offer Details | Insurance & Finance | `lib/features/patient/presentation/screens/treatment_offer_details_screen.dart` | View Offer Package | ✅ Completed & Verified |
| 73 | `20:26500` | Payment Options & BNPL | Insurance & Finance | `lib/features/patient/presentation/screens/payment_options_screen.dart` | Select Payment Method | ✅ Completed & Verified |
| 74 | `20:26550` | Uninsured Patient Assistance | Insurance & Finance | `lib/features/patient/presentation/screens/uninsured_assistance_screen.dart` | Assistance Program CTA | ✅ Completed & Verified |
| 75 | `20:24204` | Patient Profile & Settings Hub | Profile & Settings | `lib/features/patient/presentation/screens/patient_profile_screen.dart` | Tab 3 on Shell | ✅ Completed & Verified |
| 76 | `20:24300` | Edit Profile Demographics | Profile & Settings | `lib/features/patient/presentation/screens/personal_details_identity_screen.dart` | Edit Profile CTA | ✅ Completed & Verified |
| 77 | `20:24350` | Medical Info Summary | Profile & Settings | `lib/features/patient/presentation/screens/medical_info_summary_screen.dart` | Medical Info Group | ✅ Completed & Verified |
| 78 | `20:24400` | Medication Reminder Detail | Profile & Settings | `lib/features/patient/presentation/screens/medication_reminder_detail_screen.dart` | Reminders Option | ✅ Completed & Verified |
| 79 | `20:31800` | Notification Center | Profile & Settings | `lib/features/patient/presentation/screens/notification_center_screen.dart` | Header Bell Icon | ✅ Completed & Verified |
| 80 | `20:31850` | Notification Settings Sheet | Profile & Settings | Sheet in `notification_center_screen.dart` | Settings Action | ✅ Completed & Verified |
| 81 | `20:24500` | Document & Report Viewer | Profile & Settings | `lib/features/patient/presentation/screens/document_viewer_screen.dart` | View Attachment | ✅ Completed & Verified |
| 82 | `20:24550` | DICOM Radiograph Preview | Profile & Settings | Modal in `dental_record_detail_screen.dart` | View DICOM CTA | ✅ Completed & Verified |
| 83 | `20:24600` | Frequently Asked Questions Sheet | Profile & Settings | Sheet in `patient_profile_screen.dart` | Help & FAQ Action | ✅ Completed & Verified |
| 84 | `20:24650` | Biometric PIN Setup Modal | Profile & Settings | Dialog in `security_privacy_controls_screen.dart` | Enable Biometrics | ✅ Completed & Verified |
| 85 | `20:24700` | Logout Confirmation Dialog | Profile & Settings | Dialog in `patient_profile_screen.dart` | Log Out Action | ✅ Completed & Verified |
| 86 | `20:24750` | Account Deactivation Modal | Profile & Settings | Dialog in `patient_profile_screen.dart` | Delete Account Action | ✅ Completed & Verified |

