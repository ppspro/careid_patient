# CareID Patient App — Remaining Figma Screens Inventory (Canvas `17:55`)

**Project:** `C:\Users\PABANI\CareID_patient_app`  
**Figma File:** `CAREID-AIO-FIGMA`  
**Canvas:** `17:55` — Careid patient app  
**Backend:** `https://360api.vnvision.in`  
**Date of Audit:** October 31, 2026

---

## 1. Canvas Overview & Progress Summary

The `Careid patient app` canvas (`17:55`) contains **89 direct top-level canvas nodes** representing 45 implemented screens/hubs across onboarding, auth, home, health records, family ecosystem, appointments, emergency, notifications, profile, and insurance OCR capture.

### Macro Progress Tracking
- **Total Direct Top-Level Nodes:** 89 (87 screens/frames, 1 standalone vector graphic `20:19551`, 1 text component `20:33523`)
- **Completed Top-Level Screens:** 45 core screens
- **Component / Modal Variants & Duplicates:** 32 frames (e.g. `20:32177`, `20:32816` Document Viewer clones; `20:32423`, `20:32573` Vision clones; dialog frames)
- **Remaining Distinct Screens to Implement:** 12 screens across 3 major clinical journeys

---

## 2. Complete Inventory of All 89 Direct Canvas Nodes

| # | Figma Node ID | Screen / Frame Name | Dimensions | Implementation Status | Dart File Reference | API Dependency | Notes / Functionality |
|---|---|---|---|---|---|---|---|
| 1 | `20:19138` | Invitation Sent | 390 × 1143 | ✅ Completed (Batch 2) | `invitation_sent_screen.dart` | `POST /api/v1/family/invitations` | Member invitation confirmation pass |
| 2 | `20:19238` | Add Family Member — Review | 390 × 1521 | ✅ Completed (Batch 2) | `add_family_member_screen.dart` | `POST /api/v1/family/members` | Step 3 review & confirm invite |
| 3 | `20:19424` | Add Family Member — Access | 390 × 1400 | ✅ Completed (Batch 2) | `add_family_member_screen.dart` | `POST /api/v1/family/members` | Step 2 permission scope picker |
| 4 | `20:19551` | Union (Stroke) | 228 × 228 | ℹ️ Canvas Graphic | N/A | None | Vector background artwork |
| 5 | `20:19552` | Home - Option 6 | 390 × 1846 | ✅ Completed | `home_screen.dart` | `GET /api/v1/patients/me` | Core patient home dashboard |
| 6 | `20:19794` | Welcome - Option 2 | 390 × 1072 | ✅ Completed | `welcome_screen.dart` | N/A | Onboarding intro carousel |
| 7 | `20:19873` | Smart Digital Health Card | 390 × 1522 | ✅ Completed | `health_card_screen.dart` | `GET /api/v1/health-cards` | Digital card, QR & wallet passes |
| 8 | `20:20059` | Insurance Dashboard | 390 × 2179 | ✅ Completed | `insurance_screen.dart` | `GET /api/v1/insurance/policies` | Coverage policies & claims hub |
| 9 | `20:20258` | Insurance Card - Camera Capture | 390 × 905 | ✅ Completed (Batch 6) | `insurance_card_camera_screen.dart` | Camera / fallback | Viewfinder, guide brackets, shutter |
| 10 | `20:20311` | Add Insurance - Select Method | 390 × 1539 | ✅ Completed (Batch 6) | `add_insurance_select_method_screen.dart` | Ingestion routing | Camera vs gallery selection bento |
| 11 | `20:20415` | OCR Processing - Insurance Card | 390 × 980 | ✅ Completed (Batch 6) | `insurance_ocr_processing_screen.dart` | `POST /api/v1/insurance/ocr/scan` | Laser scanner bar, 3-step pipeline |
| 12 | `20:20517` | OCR Extraction Results | 390 × 2134.5 | ✅ Completed (Batch 6) | `insurance_ocr_results_screen.dart` | `POST /api/v1/insurance/ocr/confirm` | 95% match, USER EDITED distinction |
| 13 | `20:20723` | Manual Review & Edit | 390 × 1234.6 | ℹ️ Variant Component | Integrated in `20:20517` | None | Direct field editing bento |
| 14 | `20:20890` | Insurance Card Details | 390 × 1384.75 | ✅ Completed (Batch 6) | `insurance_card_details_screen.dart` | `POST /api/v1/insurance/policies/:id/verify` | Hologram card pass, verify coverage |
| 15 | `20:21019` | Html → Body | 390 × 1135 | ℹ️ Web Container | N/A | None | Web view layout component |
| 16 | `20:21111` | Dental Records | 390 × 1272 | ✅ Completed (Batch 1) | `dental_records_screen.dart` | `GET /api/v1/medical-records` | Dental timeline & history |
| 17 | `20:21301` | Vision Records - Timeline & Vault | 390 × 1272 | ✅ Completed (Batch 1) | `vision_records_screen.dart` | `GET /api/v1/medical-records` | Vision timeline & vault |
| 18 | `20:21451` | Upload Medical Record - Refined Flow | 390 × 1642 | ⏳ **Remaining** | None | `POST /api/v1/medical-records` | Multi-step record upload & tagger |
| 19 | `20:21675` | Family Dashboard | 390 × 1545.5 | ✅ Completed (Batch 2) | `family_dashboard_screen.dart` | `GET /api/v1/family/members` | Ecosystem hero & member cards |
| 20 | `20:21825` | Family Member List | 390 × 1430 | ✅ Completed (Batch 2) | `family_members_screen.dart` | `GET /api/v1/family/members` | Searchable member list & filters |
| 21 | `20:22023` | Add Family Member - Form | 390 × 1418 | ✅ Completed (Batch 2) | `add_family_member_screen.dart` | Form validation | Step 1 member basic details |
| 22 | `20:22157` | Family Consent & Requests | 390 × 1175 | ⏳ **Remaining** | None | `GET/POST /api/v1/family/consents` | Pending authorization requests |
| 23 | `20:22307` | Member Permissions & Sharing | 390 × 1125 | ⏳ **Remaining** | None | `PATCH /api/v1/family/members/:id` | Read/write clinical records access |
| 24 | `20:22459` | Shared Health Card - Dependent View | 390 × 1062.5 | ⏳ **Remaining** | None | `GET /api/v1/health-cards` | Dependent digital card with guardian seal |
| 25 | `20:22594` | Shared Medical Records | 390 × 1310 | ⏳ **Remaining** | None | `GET /api/v1/medical-records` | Filtered clinical records for family |
| 26 | `20:22771` | QR Dashboard | 390 × 1105 | ⏳ **Remaining** | None | `GET /api/v1/health-cards/verify-qr` | QR Code sharing & quick scan hub |
| 27 | `20:23195` | Share Options | 390 × 2204.83 | ⏳ **Remaining** | None | `POST /api/v1/health-cards/share` | Time-limited & granular record scopes |
| 28 | `20:23338` | QR Preview | 390 × 1150 | ⏳ **Remaining** | None | Dynamic token / QR | Fullscreen high-contrast clinical QR |
| 29 | `20:23450` | Access History | 390 × 1290 | ✅ Completed (Batch 4) | `access_history_screen.dart` | Dynamic audit ready | Access history & audit log hub |
| 30 | `20:23597` | Manage Shared Access | 390 × 1282 | ⏳ **Remaining** | None | `GET /api/v1/family/consents` | Revoke & manage active shares |
| 31 | `20:23745` | Access Verification | 390 × 1324 | ⏳ **Remaining** | None | `POST /api/v1/health-cards/verify-qr` | Doctor verification scanner & confirmation |
| 32 | `20:23812` | Notification Center | 390 × 1459 | ✅ Completed (Batch 4) | `notification_center_screen.dart` | `GET /api/v1/notifications` | Notification alerts & filters |
| 33 | `20:23956` | Emergency Center | 390 × 2175.64 | ✅ Completed (Batch 4) | `emergency_center_screen.dart` | `GET /api/v1/patients/me` | SOS trigger & offline Medical ID |
| 34 | `20:24101` | Medication Reminder Detail | 390 × 862 | ✅ Completed (Batch 5) | `medication_reminder_detail_screen.dart` | Notification context | Pill reminder, dosage, pharmacy |
| 35 | `20:24204` | Profile & Settings Hub | 390 × 2002 | ✅ Completed (Batch 5) | `patient_profile_screen.dart` | `GET /api/v1/patients/me` | Account, health summary, settings |
| 36 | `20:24484` | Medical Information Summary | 390 × 1550.75 | ✅ Completed (Batch 5) | `medical_info_summary_screen.dart` | `PATCH /api/v1/patients/me/medical-summary` | Allergies, conditions, vitals |
| 37 | `20:24653` | Personal Details & Identity | 390 × 1160 | ✅ Completed (Batch 5) | `personal_details_identity_screen.dart` | `PATCH /api/v1/patients/me/basic` | Profile demographics & ID |
| 38 | `20:24805` | Security & Privacy Controls | 390 × 1906 | ✅ Completed (Batch 4) | `security_privacy_controls_screen.dart` | `GET /api/v1/auth/sessions` | Biometric, session audit, PIN |
| 39 | `20:24965` | Login - Refined Auth Flow v2 | 390 × 1020 | ✅ Completed | `login_screen.dart` | `POST /api/v1/auth/otp/request` | Welcome back phone login |
| 40 | `20:25032` | OTP Verification - Refined States | 390 × 884 | ✅ Completed | `otp_screen.dart` | `POST /api/v1/auth/otp/verify` | 6-digit OTP code input |
| 41 | `20:25097` | Biometric Setup - Refined Polish | 390 × 972 | ✅ Completed | `biometric_setup_screen.dart` | Local auth | Fingerprint/Face biometric prompt |
| 42 | `20:25143` | Account recovery | 390 × 972 | ✅ Completed | `account_recovery_screen.dart` | Auth recovery | Passcode & email reset |
| 43 | `20:25191` | Splash_Screen | 390 × 884 | ✅ Completed | `splash_screen.dart` | Auth init | Logo animation & session check |
| 44 | `20:25207` | Background+Border | 65 × 55 | ℹ️ Component Badge | N/A | None | Icon container frame |
| 45 | `20:25209` | Care ID - Health Records Landing | 390 × 1386 | ✅ Completed (Batch 1) | `health_records_screen.dart` | `GET /api/v1/medical-records` | Category tabs & records list |
| 46 | `20:25410` | Care ID - Vision Record Detail | 390 × 2030 | ✅ Completed (Batch 1) | `vision_record_detail_screen.dart` | `GET /api/v1/medical-records/:id` | Sphere, cylinder, prescription |
| 47 | `20:25653` | Care ID - Dental Record Detail | 390 × 1854 | ✅ Completed (Batch 1) | `dental_record_detail_screen.dart` | `GET /api/v1/medical-records/:id` | Odontogram & dental notes |
| 48 | `20:25895` | Care ID - Insurance & Financing Hub | 390 × 2453 | ✅ Completed | `insurance_screen.dart` | `GET /api/v1/insurance/policies` | Full financial & policy hub |
| 49 | `20:26187` | Care ID - Insurance Status (Uninsured) | 390 × 1743 | ✅ Completed | `uninsured_assistance_screen.dart` | Sliding scale / assistance | Financial counseling & programs |
| 50 | `20:26404` | Care ID - Treatment Offers | 390 × 2134.44 | ✅ Completed | `treatment_offers_screen.dart` | Treatment discounts | 0% APR financing packages |
| 51 | `20:26692` | Care ID - Financing Option Details | 390 × 1637.88 | ✅ Completed | `financing_option_details_screen.dart` | Payment schedules | Monthly loan breakdown |
| 52 | `20:26922` | Care ID - Treatment Offer Details | 390 × 1843.38 | ✅ Completed | `treatment_offer_details_screen.dart` | Offer quotes | Procedure cost breakdown |
| 53 | `20:27176` | Care ID - Offer Accepted Confirmation | 390 × 1685.5 | ✅ Completed | `offer_confirmation_dialog.dart` | Offer acceptance | Agreement & booking trigger |
| 54 | `20:27380` | Care ID - Cash Discount Options | 390 × 2010 | ✅ Completed | `cash_discount_options_screen.dart` | Prompt payment | Cash discount calculations |
| 55 | `20:27613` | Care ID - Offer Rejected Confirmation | 390 × 1451.13 | ✅ Completed | `offer_rejection_dialog.dart` | Offer rejection | Alternative care pathways |
| 56 | `20:27768` | Care ID - Offer Status & History | 408 × 1443.5 | ✅ Completed | `offer_status_history_screen.dart` | Offer audit | Historical offers timeline |
| 57 | `20:28020` | Doctors | 390 × 1810.19 | ✅ Completed (Batch 3) | `doctors_directory_screen.dart` | `GET /api/v1/doctors` | Specialties, ratings, search |
| 58 | `20:28312` | Care ID - Book Appointment (Date & Time) | 390 × 1362 | ✅ Completed (Batch 3) | `book_appointment_screen.dart` | Doctor slots | Calendar & time slot picker |
| 59 | `20:28595` | Care ID - Review Appointment | 390 × 1181.75 | ✅ Completed (Batch 3) | `book_appointment_screen.dart` | Step 3 review | Booking verification |
| 60 | `20:28764` | Care ID - Book Appointment (Type) | 390 × 1458 | ✅ Completed (Batch 3) | `book_appointment_screen.dart` | Step 1 selection | In-person vs video visit |
| 61 | `20:28961` | Doctor Profile | 390 × 2244 | ✅ Completed (Batch 3) | `doctor_profile_screen.dart` | `GET /api/v1/doctors/:id` | Credentials, bio, reviews |
| 62 | `20:29208` | Care ID - Appointment Confirmation | 390 × 1464.5 | ✅ Completed (Batch 3) | `book_appointment_screen.dart` | Booking result | Success badge & pass link |
| 63 | `20:29399` | Care ID - Appointment Details | 390 × 2063 | ✅ Completed (Batch 3) | `appointment_details_screen.dart` | `GET /api/v1/appointments/:id` | Full visit details & directions |
| 64 | `20:29664` | Care ID - My Appointments | 390 × 1174 | ✅ Completed (Batch 3) | `my_appointments_screen.dart` | `GET /api/v1/schedules` | Upcoming, Completed, Cancelled |
| 65 | `20:29860` | Care ID - Appointment Details & Actions | 390 × 1706 | ✅ Completed (Batch 3) | `appointment_details_screen.dart` | `GET /api/v1/appointments/:id` | Kiosk QR, reschedule, cancel |
| 66 | `20:30086` | Care ID - Reschedule Appointment | 390 × 1540 | ✅ Completed | `reschedule_appointment_screen.dart` | Slot update | Re-select date & slot |
| 67 | `20:30384` | Care ID - Cancel Appointment Dialog | 390 × 886 | ✅ Completed | `cancel_appointment_dialog.dart` | Cancellation API | Cancellation reason dialog |
| 68 | `20:30521` | Care ID - Family Records | 390 × 1043 | ✅ Completed | `family_records_screen.dart` | Family clinical list | Vault view for dependents |
| 69 | `20:30644` | CareID-Create Account | 390 × 911 | ✅ Completed | `create_account_screen.dart` | `POST /api/v1/patients/register` | Step 1 name & email |
| 70 | `20:30756` | Mobile_number | 390 × 1207 | ✅ Completed | `mobile_number_screen.dart` | Phone OTP request | Step 2 phone number input |
| 71 | `20:30900` | Health_info | 390 × 2636 | ✅ Completed | `health_info_screen.dart` | Clinical profile | Step 3 blood group & allergies |
| 72 | `20:31164` | Privacy & Consents | 390 × 2549.5 | ✅ Completed | `privacy_consents_screen.dart` | Consents API | Step 5 HIPAA & disclosures |
| 73 | `20:31401` | Confirmed_Screen | 390 × 2033 | ✅ Completed | `confirmed_screen.dart` | Completion badge | Step 6 digital pass summary |
| 74 | `20:31689` | Live_chat_messeges | 390 × 1117 | ✅ Completed | `live_chat_screen.dart` | Support chat | Helpdesk messaging channel |
| 75 | `20:31908` | Medical Records | 390 × 1272 | ✅ Completed | `medical_records_screen.dart` | `GET /api/v1/medical-records` | General records repository |
| 76 | `20:32097` | Document Viewer | 390 × 936 | ✅ Completed | `document_viewer_screen.dart` | File rendering | PDF & image viewer |
| 77 | `20:32177` | Document Viewer (Duplicate) | 390 × 936 | ℹ️ Duplicate | N/A | None | Duplicate of 20:32097 |
| 78 | `20:32268` | Scan Reports | 390 × 905 | ⏳ **Remaining** | None | Camera / OCR | Camera report document scanner |
| 79 | `20:32321` | OCR Processing - Report | 390 × 980 | ⏳ **Remaining** | None | Lab OCR API | Document extraction pipeline |
| 80 | `20:32423` | Vision Records - Timeline (Duplicate) | 390 × 1272 | ℹ️ Duplicate | N/A | None | Duplicate of 20:21301 |
| 81 | `20:32573` | Vision Record Detail (Duplicate) | 390 × 2030 | ℹ️ Duplicate | N/A | None | Duplicate of 20:25410 |
| 82 | `20:32816` | Document Viewer (Duplicate) | 390 × 936 | ℹ️ Duplicate | N/A | None | Duplicate of 20:32097 |
| 83 | `20:32906` | Full Kiosk Pass | 375 × 1145 | ✅ Completed | `full_kiosk_pass_screen.dart` | Check-in token | Fullscreen QR check-in |
| 84 | `20:33068` | Add Insurance Info | 375 × 1178.78 | ✅ Completed | `add_insurance_screen.dart` | Onboarding insurance | Onboarding step 4 |
| 85 | `20:33152` | Care ID payment options | 390 × 844 | ✅ Completed | `payment_options_screen.dart` | Payment gateways | Card & billing management |
| 86 | `20:33245` | Add Health Record | 375 × 1228 | ✅ Completed | `add_health_record_screen.dart` | Record submission | Manual record entry |
| 87 | `20:33367` | Review Health Record | 375 × 1101 | ✅ Completed | `add_health_record_screen.dart` | Form review | Record confirmation |
| 88 | `20:33470` | Record Saved Success | 375 × 1012.5 | ✅ Completed | `add_health_record_screen.dart` | Save confirmation | Record success banner |
| 89 | `20:33523` | Provider not registered? | 390 × 36 | ℹ️ Banner Text | N/A | None | Inline CTA link banner |

---

## 3. Remaining Unimplemented Screens by Journey Cluster

### Cluster A: QR Code Clinical Sharing, Granular Access & Verification Hub
1. **`20:22771` — QR Dashboard** (390 × 1105): Primary sharing management hub for generating time-limited QR codes, emergency offline access tokens, and clinical access passes.
2. **`20:23195` — Share Options** (390 × 2204.83): Comprehensive configuration screen for selecting specific record scopes (Vitals, Lab Results, Prescriptions, Immunizations), validity duration (15 min, 1 hour, 24 hours, single-use), and access passcode protection.
3. **`20:23338` — QR Preview** (390 × 1150): High-contrast, maximum-brightness full-screen clinical QR presentation screen with countdown expiration timer and security seal.
4. **`20:23597` — Manage Shared Access** (390 × 1282): Management dashboard for viewing active doctor/clinic shares, revoking permissions in real-time, and reviewing expired tokens.
5. **`20:23745` — Access Verification** (390 × 1324): Clinical scanning & handshake verification screen displaying doctor credentials, timestamp, and audit logging.

### Cluster B: Family Consents, Dependent Sharing & Delegated Access
6. **`20:22157` — Family Consent & Requests** (390 × 1175): Pending consent approvals and incoming delegation requests between family guardians.
7. **`20:22307` — Member Permissions & Sharing** (390 × 1125): Granular read/write toggle screen for family member record sharing.
8. **`20:22459` — Shared Health Card - Dependent View** (390 × 1062.5): Digital health card specialized for minors/dependents with guardian authorization badges.
9. **`20:22594` — Shared Medical Records** (390 × 1310): Filtered timeline of medical records shared across linked family accounts.

### Cluster C: Medical Document & Lab Report OCR Ingestion
10. **`20:21451` — Upload Medical Record - Refined Flow** (390 × 1642): Clinical document uploader with file type selectors, date tagging, and provider attribution.
11. **`20:32268` — Scan Reports** (390 × 905): Camera capture screen for multi-page lab reports and clinical paper summaries.
12. **`20:32321` — OCR Processing - Report** (390 × 980): Diagnostic report OCR analyzer extracting lab biomarkers, reference ranges, and test dates.

