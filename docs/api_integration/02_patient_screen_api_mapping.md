# 02. CareID Patient App — Screen-to-API Mapping Matrix

**Document Date:** November 3, 2026  
**Postman Collection Reference:** `CareID-Staging.postman_collection(2).json` (November 3, 2026 Release)  
**Figma Canvas Reference:** `CAREID-AIO-FIGMA` (Canvas `17:55` — `Careid patient app`)  
**Backend Target:** `https://360api.vnvision.in`  

---

## 1. Complete Screen-to-API Matrix

| # | Figma Screen Name | Node ID | Flutter Screen File | Primary API Endpoints | HTTP Method | CRUD Operation | Integration Status |
|---|---|---|---|---|:---:|:---:|---|
| 1 | **Splash_Screen** | `20:25191` | `splash_screen.dart` | `/api/v1/auth/me` | `GET` | Read (Session Check) | Integrated & Verified |
| 2 | **Welcome - Option 2** | `20:19794` | `welcome_screen.dart` | `/api/v1/health` | `GET` | Read (Connectivity) | Integrated & Verified |
| 3 | **CareID-Create Account** | `20:30644` | `create_account_screen.dart` | `/api/v1/patients/register` | `POST` | Create (Draft Registration) | Integrated & Verified |
| 4 | **Mobile_number** | `20:30756` | `mobile_number_screen.dart` | `/api/v1/auth/otp/request` | `POST` | Create (Send OTP Challenge) | Integrated & Verified |
| 5 | **Login - Refined Auth Flow** | `20:24965` | `login_screen.dart` | `/api/v1/auth/otp/request` | `POST` | Create (Send OTP Challenge) | Integrated & Verified |
| 6 | **OTP Verification** | `20:25032` | `login_screen.dart` | `/api/v1/auth/otp/verify, /api/v1/auth/otp/resend` | `POST` | Create (Verify Session Token) | Integrated & Verified |
| 7 | **Health_info** | `20:30900` | `health_info_screen.dart` | `/api/v1/patients/health-info` | `POST` | Create (Clinical Demographics) | Integrated & Verified |
| 8 | **Add Insurance Info** | `20:33068` | `add_insurance_screen.dart` | `/api/v1/insurance/policies` | `POST` | Create (Link Policy) | Integrated & Verified |
| 9 | **Privacy & Consents** | `20:31164` | `privacy_consents_screen.dart` | `/api/v1/patients/consents` | `POST` | Create (HIPAA Consent) | Integrated & Verified |
| 10 | **Confirmed_Screen** | `20:31401` | `confirmed_screen.dart` | `/api/v1/health-cards` | `POST` | Create (Issue Health Pass) | Integrated & Verified |
| 11 | **Biometric Setup** | `20:25097` | `biometric_setup_screen.dart` | `Local Hardware Keystore` | `LOCAL` | Local Enrollment | Frontend-Only Verified |
| 12 | **Account Recovery** | `20:25143` | `account_recovery_screen.dart` | `/api/v1/auth/recovery` | `POST` | Create (Recovery Lookup) | Integrated & Verified |
| 13 | **Home - Option 6** | `20:19552` | `home_screen.dart` | `/api/v1/patients/me, /api/v1/health-cards, /api/v1/medical-records` | `GET` | Read (Dashboard Aggregation) | Integrated & Verified |
| 14 | **Smart Digital Health Card** | `20:19873` | `health_card_screen.dart` | `/api/v1/health-cards` | `GET` | Read (Active Card & QR) | Integrated & Verified |
| 15 | **Full Kiosk Pass** | `20:32906` | `full_kiosk_pass_screen.dart` | `/api/v1/health-cards/verify-qr` | `POST` | Read/Verify (Hospital Check-in) | Integrated & Verified |
| 16 | **QR Dashboard** | `20:22771` | `qr_dashboard_screen.dart` | `/api/v1/health-cards` | `GET` | Read (QR Sharing Mode) | Integrated & Verified |
| 17 | **Share Options** | `20:23195` | `share_options_screen.dart` | `/api/v1/health-cards/share` | `POST` | Create (Temporary Token) | Integrated & Verified |
| 18 | **QR Preview** | `20:23338` | `qr_preview_screen.dart` | `/api/v1/health-cards/qr` | `GET` | Read (Dynamic QR) | Integrated & Verified |
| 19 | **Access History** | `20:23450` | `access_history_screen.dart` | `/api/v1/health-cards/:id/history` | `GET` | Read (Check-in Audit Logs) | Integrated & Verified |
| 20 | **Manage Shared Access** | `20:23597` | `manage_shared_access_screen.dart` | `/api/v1/health-cards/:id/block, :id/unblock` | `POST` | Update/Delete (Revoke Access) | Integrated & Verified |
| 21 | **Medical Records** | `20:31908` | `medical_records_screen.dart` | `/api/v1/medical-records, /api/v1/vaccines, /api/v1/immunisations` | `GET` | Read (Records & Vaccine Stream) | Integrated & Verified |
| 22 | **Care ID - Health Records Landing** | `20:25209` | `medical_records_screen.dart` | `/api/v1/medical-records` | `GET` | Read (Discipline Vaults) | Integrated & Verified |
| 23 | **Add Health Record** | `20:33245` | `add_health_record_screen.dart` | `/api/v1/medical-records` | `POST` | Create (Clinical Record Entry) | Integrated & Verified |
| 24 | **Review Health Record** | `20:33367` | `add_health_record_screen.dart` | `/api/v1/medical-records` | `POST` | Create (Final Submission) | Integrated & Verified |
| 25 | **Record Saved Success** | `20:33470` | `add_health_record_screen.dart` | `Navigation / State Feedback` | `LOCAL` | State Feedback | Frontend-Only Verified |
| 26 | **Document Viewer (General)** | `20:32097` | `document_viewer_screen.dart` | `/api/v1/medical-records/:id/attachment` | `GET` | Read (Binary Stream/URL) | Integrated & Verified |
| 27 | **Document Viewer (Lab)** | `20:32177` | `document_viewer_screen.dart` | `/api/v1/medical-records/:id/attachment` | `GET` | Read (Lab Report File) | Integrated & Verified |
| 28 | **Document Viewer (Rx)** | `20:32816` | `document_viewer_screen.dart` | `/api/v1/medical-records/:id/attachment` | `GET` | Read (Prescription File) | Integrated & Verified |
| 29 | **Dental Records** | `20:21111` | `dental_records_screen.dart` | `/api/v1/medical-records?category=DENTAL` | `GET` | Read (Dental Vault) | Integrated & Verified |
| 30 | **Dental Record Detail** | `20:25653` | `dental_record_detail_screen.dart` | `/api/v1/medical-records/:id` | `GET` | Read (Procedure & Odontogram) | Integrated & Verified |
| 31 | **Vision Records** | `20:21301` | `vision_records_screen.dart` | `/api/v1/medical-records?category=VISION` | `GET` | Read (Optical Vault) | Integrated & Verified |
| 32 | **Vision Record Detail** | `20:25410` | `vision_record_detail_screen.dart` | `/api/v1/medical-records/:id` | `GET` | Read (Acuity & Lenses) | Integrated & Verified |
| 33 | **Pet Health Records** | `20:26073` | `pet_records_screen.dart` | `/api/v1/pets` | `GET/POST` | Read/Create (Pet Vault) | Ready for New Endpoint Integration |
| 34 | **Pet Record Details** | `20:26229` | `pet_record_detail_screen.dart` | `/api/v1/pets/:id, /api/v1/pets/:id/vaccinations` | `GET/POST` | Read/Create (Pet Details) | Ready for New Endpoint Integration |
| 35 | **Family Dashboard** | `20:21675` | `family_dashboard_screen.dart` | `/api/v1/family/dashboard, /api/v1/family/members` | `GET` | Read (Family Ecosystem) | Integrated & Verified |
| 36 | **Family Member List** | `20:21825` | `family_members_screen.dart` | `/api/v1/family/members` | `GET` | Read (Dependents List) | Integrated & Verified |
| 37 | **Add Family Member** | `20:22023` | `add_family_member_screen.dart` | `/api/v1/family/invitations` | `POST` | Create (Dispatch Invitation) | Integrated & Verified |
| 38 | **Invitation Sent** | `20:19138` | `invitation_sent_screen.dart` | `/api/v1/family/invitations` | `GET` | Read (Pending Invites) | Integrated & Verified |
| 39 | **Family Consent & Requests** | `20:22157` | `family_consent_requests_screen.dart` | `/api/v1/family/consents` | `GET` | Read (Consent Grants) | Integrated & Verified |
| 40 | **Member Permissions & Sharing** | `20:22307` | `member_permissions_sharing_screen.dart` | `/api/v1/family/consents/:id` | `PATCH` | Update (Discipline Scopes) | Integrated & Verified |
| 41 | **Shared Health Card** | `20:22459` | `dependent_health_card_screen.dart` | `/api/v1/family/members` | `GET` | Read (Dependent Card & QR) | Integrated & Verified |
| 42 | **Shared Medical Records** | `20:22594` | `shared_medical_records_screen.dart` | `/api/v1/family/records` | `GET` | Read (Filtered Shared Vault) | Integrated & Verified |
| 43 | **Family Records Vault** | `20:30521` | `family_records_screen.dart` | `/api/v1/medical-records, /api/v1/family/members` | `GET` | Read (Family Hub) | Integrated & Verified |
| 44 | **Doctors Directory** | `20:28020` | `doctors_directory_screen.dart` | `/api/v1/doctors` | `GET` | Read (Physician Search) | Integrated & Verified |
| 45 | **Doctor Profile** | `20:28961` | `doctor_profile_screen.dart` | `/api/v1/doctors/:id` | `GET` | Read (Specialist Credentials) | Integrated & Verified |
| 46 | **Book Appointment (Slots)** | `20:28312` | `book_appointment_screen.dart` | `/api/v1/doctors/:id/slots` | `GET` | Read (Available Shifts) | Integrated & Verified |
| 47 | **Book Appointment (Review)** | `20:28595` | `book_appointment_screen.dart` | `/api/v1/schedules` | `POST` | Create (Confirm Booking) | Integrated & Verified |
| 48 | **Appointment Confirmation** | `20:29208` | `appointment_confirmation_screen.dart` | `/api/v1/schedules` | `POST` | Create (Issue Care Pass) | Integrated & Verified |
| 49 | **My Appointments** | `20:29664` | `my_appointments_screen.dart` | `/api/v1/schedules` | `GET` | Read (Upcoming & Past) | Integrated & Verified |
| 50 | **Appointment Details** | `20:29399` | `appointment_details_screen.dart` | `/api/v1/schedules/:id` | `GET` | Read (Facility & Pass) | Integrated & Verified |
| 51 | **Reschedule Appointment** | `20:30086` | `reschedule_appointment_screen.dart` | `/api/v1/schedules/:id` | `PUT` | Update (Date/Time Slot) | Integrated & Verified |
| 52 | **Cancel Appointment** | `20:30384` | `appointment_details_screen.dart` | `/api/v1/schedules/:id` | `DELETE` | Delete (Cancel Booking) | Integrated & Verified |
| 53 | **Live Chat Messages** | `20:31689` | `live_chat_screen.dart` | `/api/v1/support/tickets/:id/replies` | `GET/POST` | Read/Create (Messages) | Integrated & Verified |
| 54 | **Insurance Dashboard** | `20:20059` | `insurance_screen.dart` | `/api/v1/insurance/policies, /api/v1/insurance/claims` | `GET` | Read (Policies & Claims) | Integrated & Verified |
| 55 | **Insurance Card Camera Capture** | `20:20258` | `insurance_card_camera_screen.dart` | `Camera Platform Channel` | `LOCAL` | Local Image Capture | Frontend-Only Verified |
| 56 | **OCR Processing** | `20:20415` | `insurance_ocr_processing_screen.dart` | `/api/v1/insurance/ocr` | `POST` | Create (OCR Scan Submission) | Ready for New Endpoint Integration |
| 57 | **OCR Extraction Results** | `20:20517` | `insurance_ocr_results_screen.dart` | `/api/v1/insurance/ocr/:id, /api/v1/insurance/policies` | `GET/POST` | Read/Create (Policy Link) | Ready for New Endpoint Integration |
| 58 | **Insurance Card Details** | `20:20890` | `insurance_card_details_screen.dart` | `/api/v1/insurance/policies/:id` | `GET` | Read (Benefits Breakdown) | Integrated & Verified |
| 59 | **Insurance QR Screen** | `20:21019` | `insurance_qr_screen.dart` | `/api/v1/insurance/policies/:id` | `GET` | Read (Carrier QR Verification) | Integrated & Verified |
| 60 | **Treatment Offers** | `20:26404` | `treatment_offers_screen.dart` | `/api/v1/financing/options, /api/v1/financing/offers` | `GET` | Read (Financing Plans) | Ready for New Endpoint Integration |
| 61 | **Treatment Offer Details** | `20:26922` | `treatment_offer_details_screen.dart` | `/api/v1/financing/apply` | `POST` | Create (Application) | Ready for New Endpoint Integration |
| 62 | **Offer Status & History** | `20:27768` | `treatment_offers_screen.dart` | `/api/v1/financing/applications` | `GET` | Read (Financing Contracts) | Ready for New Endpoint Integration |
| 63 | **Payment Options** | `20:33152` | `payment_options_screen.dart` | `/api/v1/financing/options` | `GET` | Read (Copay Splits) | Integrated & Verified |
| 64 | **Notification Center** | `20:23812` | `notification_center_screen.dart` | `/api/v1/notifications, /api/v1/notifications/:id/read` | `GET/PUT` | Read/Update (Alert Feed) | Integrated & Verified |
| 65 | **Emergency Center** | `20:23956` | `emergency_center_screen.dart` | `/api/v1/facilities, /api/v1/emergency/contacts` | `GET` | Read (ER & Urgent Care) | Integrated & Verified |
| 66 | **Patient Profile & Hub** | `20:24204` | `patient_profile_screen.dart` | `/api/v1/patients/me, /api/v1/auth/logout` | `GET/POST` | Read/Revoke (Profile Hub) | Integrated & Verified |
| 67 | **Personal Details & Identity** | `20:24653` | `personal_details_identity_screen.dart` | `/api/v1/patients/me/full, /api/v1/patients/me/basic, /api/v1/patients/me/address, /api/v1/patients/me/photo` | `GET/PATCH/POST` | Read/Update (Demographics & Photo) | Integrated & Verified |
| 68 | **Security & Privacy Controls** | `20:24805` | `security_privacy_controls_screen.dart` | `/api/v1/security/sessions, /api/v1/health-cards/:id/block` | `GET/POST` | Read/Update (Security Toggles) | Integrated & Verified |
| 69 | **Help & Support Tickets** | `20:24204-H` | `patient_profile_screen.dart` | `/api/v1/support/tickets, /api/v1/support/tickets/:id/reply` | `GET/POST` | Read/Create (Support Helpdesk) | Ready for New Endpoint Integration |

---

## 2. Integration Architecture Highlights

1. **Zero Mock Endpoints:** Every integrated endpoint binds directly to `CareID-Staging.postman_collection(2).json`.
2. **Removed Insurance Recommendation Navigation:** Aligned strictly with Phase 4 guidelines — no recommendation screens or entry points exist.
3. **Bottom Navigation Standard:** Exactly 4 tabs (Home, Records, Doctor, Profile) with center floating QR scan action. No separate Health Card tab.
4. **Full CRUD Support:** Verified GET, POST, PUT, PATCH, and DELETE operations across Patient Profiles, Appointments, Health Cards, Family Invitations, and Records.