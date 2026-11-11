# CareID Patient App — Live Figma Screen & Component Inventory

**Source Figma File:** `CAREID-AIO-FIGMA`  
**Source Canvas Node:** `17:55` (`Careid patient app`)  
**Retrieved Via:** Figma MCP `figma-desktop/get_metadata`  
**Audit Date:** October 31, 2026  
**Total Direct Canvas Nodes:** 104  

---

## 1. Top-Level Patient App Screens & Dialogs

| No. | Exact Figma screen name | Node ID | Dimensions | Flutter implementation | Current status |
|---|---|---|---|---|---|
| 1 | `Invitation Sent` | `20:19138` | 390x1143 | `lib/features/patient/presentation/screens/invitation_sent_screen.dart` | **Implemented** |
| 2 | `Add Family Member — Review` | `20:19238` | 390x1521 | `lib/features/patient/presentation/screens/add_family_member_screen.dart` | **Implemented** |
| 3 | `Add Family Member — Access` | `20:19424` | 390x1400 | `lib/features/patient/presentation/screens/add_family_member_screen.dart` | **Implemented** |
| 5 | `Home - Option 6` | `20:19552` | 390x1846 | `lib/features/patient/presentation/screens/home_screen.dart` | **Completed** |
| 6 | `Welcome - Option 2` | `20:19794` | 390x1072 | `lib/features/onboarding/presentation/screens/welcome_screen.dart` | **Completed** |
| 7 | `Smart Digital Health Card` | `20:19873` | 390x1522 | `lib/features/patient/presentation/screens/health_card_screen.dart` | **Completed** |
| 8 | `Insurance Dashboard` | `20:20059` | 390x2179 | `lib/features/patient/presentation/screens/insurance_screen.dart` | **Completed** |
| 9 | `Insurance Card - Camera Capture` | `20:20258` | 390x905 | `lib/features/onboarding/presentation/screens/add_insurance_screen.dart` | **Implemented** |
| 10 | `Add Insurance - Select Method` | `20:20311` | 390x1539 | `lib/features/onboarding/presentation/screens/add_insurance_screen.dart` | **Implemented** |
| 11 | `OCR Processing - Insurance Card` | `20:20415` | 390x980 | `lib/features/onboarding/presentation/screens/add_insurance_screen.dart` | **Implemented** |
| 12 | `OCR Extraction Results` | `20:20517` | 390x2134.5 | `lib/features/onboarding/presentation/screens/add_insurance_screen.dart` | **Implemented** |
| 13 | `Manual Review & Edit` | `20:20723` | 390x1234.5799560546875 | `lib/features/onboarding/presentation/screens/add_insurance_screen.dart` | **Implemented** |
| 14 | `Insurance Card Details` | `20:20890` | 390x1384.75 | `lib/features/onboarding/presentation/screens/add_insurance_screen.dart` | **Implemented** |
| 15 | `Html → Body` | `20:21019` | 390x1135 | `lib/features/patient/presentation/screens/claim_details_screen.dart` | **Implemented** |
| 16 | `Dental Records` | `20:21111` | 390x1272 | `lib/features/patient/presentation/screens/dental_records_screen.dart` | **Implemented** |
| 17 | `Vision Records - Timeline & Vault` | `20:21301` | 390x1272 | `lib/features/patient/presentation/screens/vision_records_screen.dart` | **Implemented** |
| 18 | `Upload Medical Record - Refined Flow` | `20:21451` | 390x1642 | `lib/features/patient/presentation/screens/add_health_record_screen.dart` | **Partially Implemented** |
| 19 | `Family Dashboard` | `20:21675` | 390x1545.5 | `lib/features/patient/presentation/screens/family_members_screen.dart` | **Partially Implemented** |
| 20 | `Family Member List` | `20:21825` | 390x1430 | `lib/features/patient/presentation/screens/family_members_screen.dart` | **Implemented** |
| 21 | `Add Family Member - Form` | `20:22023` | 390x1418 | `lib/features/patient/presentation/screens/add_family_member_screen.dart` | **Implemented** |
| 22 | `Family Consent & Requests` | `20:22157` | 390x1175 | `lib/features/patient/presentation/screens/family_members_screen.dart` | **Partially Implemented** |
| 23 | `Member Permissions & Sharing` | `20:22307` | 390x1125 | `lib/features/patient/presentation/screens/family_members_screen.dart` | **Partially Implemented** |
| 24 | `Shared Health Card - Dependent View` | `20:22459` | 390x1062.5 | `lib/features/patient/presentation/screens/health_card_screen.dart` | **Partially Implemented** |
| 25 | `Shared Medical Records` | `20:22594` | 390x1310 | `lib/features/patient/presentation/screens/family_records_screen.dart` | **Partially Implemented** |
| 26 | `QR Dashboard` | `20:22771` | 390x1105 | `lib/features/patient/presentation/screens/health_card_screen.dart` | **Partially Implemented** |
| 27 | `Share Options` | `20:23195` | 390x2204.833251953125 | `lib/features/patient/presentation/screens/health_card_screen.dart` | **Partially Implemented** |
| 28 | `QR Preview` | `20:23338` | 390x1150 | `lib/features/patient/presentation/screens/health_card_screen.dart` | **Partially Implemented** |
| 29 | `Access History` | `20:23450` | 390x1290 | `lib/features/patient/presentation/screens/access_history_screen.dart` | **Implemented** |
| 30 | `Manage Shared Access` | `20:23597` | 390x1282 | `lib/features/patient/presentation/screens/access_history_screen.dart` | **Partially Implemented** |
| 31 | `Access Verification` | `20:23745` | 390x1324 | `lib/features/patient/presentation/screens/health_card_screen.dart` | **Partially Implemented** |
| 32 | `Notification Center` | `20:23812` | 390x1459 | `lib/features/patient/presentation/screens/notification_center_screen.dart` | **Implemented** |
| 33 | `Emergency Center` | `20:23956` | 390x2175.64013671875 | `lib/features/patient/presentation/screens/emergency_center_screen.dart` | **Implemented** |
| 34 | `Medication Reminder Detail` | `20:24101` | 390x862 | `lib/features/patient/presentation/screens/medication_reminder_detail_screen.dart` | **Implemented** |
| 35 | `Profile & Settings Hub` | `20:24204` | 390x2002 | `lib/features/patient/presentation/screens/patient_profile_screen.dart` | **Implemented** |
| 36 | `Medical Information Summary` | `20:24484` | 390x1550.75 | `lib/features/patient/presentation/screens/patient_profile_screen.dart` | **Implemented** |
| 37 | `Personal Details & Identity` | `20:24653` | 390x1160 | `lib/features/patient/presentation/screens/patient_profile_screen.dart` | **Implemented** |
| 38 | `Security & Privacy Controls` | `20:24805` | 390x1906 | `lib/features/patient/presentation/screens/security_privacy_controls_screen.dart` | **Implemented** |
| 39 | `Login - Refined Auth Flow v2` | `20:24965` | 390x1020 | `lib/features/auth/presentation/screens/login_screen.dart` | **Completed** |
| 40 | `OTP Verification - Refined States` | `20:25032` | 390x884 | `lib/features/auth/presentation/screens/login_screen.dart` | **Completed** |
| 41 | `Biometric Setup - Refined Polish` | `20:25097` | 390x972 | `Not Mapped` | **Not Implemented** |
| 42 | `Account recovery` | `20:25143` | 390x972 | `Not Mapped` | **Not Implemented** |
| 45 | `Splash_Screen` | `20:25191` | 390x884 | `lib/features/onboarding/presentation/screens/splash_screen.dart` | **Completed** |
| 59 | `Care ID - Health Records Landing (Refined)` | `20:25209` | 390x1386 | `lib/features/patient/presentation/screens/medical_records_screen.dart` | **Completed** |
| 60 | `Care ID - Vision Record Detail` | `20:25410` | 390x2030 | `Not Mapped` | **Not Implemented** |
| 61 | `Care ID - Dental Record Detail` | `20:25653` | 390x1854 | `Not Mapped` | **Not Implemented** |
| 62 | `Care ID - Insurance & Financing Hub` | `20:25895` | 390x2453 | `Not Mapped` | **Not Implemented** |
| 63 | `Care ID - Insurance Status (Uninsured)` | `20:26187` | 390x1743 | `Not Mapped` | **Not Implemented** |
| 64 | `Care ID - Treatment Offers` | `20:26404` | 390x2134.43505859375 | `Not Mapped` | **Not Implemented** |
| 65 | `Care ID - Financing Option Details` | `20:26692` | 390x1637.8800048828125 | `Not Mapped` | **Not Implemented** |
| 66 | `Care ID - Treatment Offer Details` | `20:26922` | 390x1843.3800048828125 | `Not Mapped` | **Not Implemented** |
| 67 | `Care ID - Offer Accepted Confirmation` | `20:27176` | 390x1685.5 | `Not Mapped` | **Not Implemented** |
| 68 | `Care ID - Cash Discount Options` | `20:27380` | 390x2010 | `Not Mapped` | **Not Implemented** |
| 69 | `Care ID - Offer Rejected Confirmation` | `20:27613` | 390x1451.1300048828125 | `Not Mapped` | **Not Implemented** |
| 70 | `Care ID - Offer Status & History` | `20:27768` | 408x1443.5 | `Not Mapped` | **Not Implemented** |
| 71 | `Doctors` | `20:28020` | 390x1810.18994140625 | `lib/features/patient/presentation/screens/doctors_directory_screen.dart` | **Implemented** |
| 72 | `Care ID - Book Appointment (Date & Time)` | `20:28312` | 390x1362 | `lib/features/patient/presentation/screens/book_appointment_screen.dart` | **Partially Implemented** |
| 73 | `Care ID - Review Appointment` | `20:28595` | 390x1181.75 | `lib/features/patient/presentation/screens/book_appointment_screen.dart` | **Partially Implemented** |
| 74 | `Care ID - Book Appointment (Type Selection)` | `20:28764` | 390x1458 | `lib/features/patient/presentation/screens/book_appointment_screen.dart` | **Partially Implemented** |
| 75 | `Doctor Profile` | `20:28961` | 390x2244 | `lib/features/patient/presentation/screens/doctor_profile_screen.dart` | **Implemented** |
| 76 | `Care ID - Appointment Confirmation` | `20:29208` | 390x1464.5 | `lib/features/patient/presentation/screens/book_appointment_screen.dart` | **Partially Implemented** |
| 77 | `Care ID - Appointment Details` | `20:29399` | 390x2063 | `lib/features/patient/presentation/screens/appointment_details_screen.dart` | **Implemented** |
| 78 | `Care ID - My Appointments (Upcoming, Completed, Cancelled)` | `20:29664` | 390x1174 | `lib/features/patient/presentation/screens/my_appointments_screen.dart` | **Implemented** |
| 79 | `Care ID - Appointment Details & Actions` | `20:29860` | 390x1706 | `lib/features/patient/presentation/screens/appointment_details_screen.dart` | **Implemented** |
| 80 | `Care ID - Reschedule Appointment (Date & Time)` | `20:30086` | 390x1540 | `lib/features/patient/presentation/screens/reschedule_appointment_screen.dart` | **Implemented** |
| 81 | `Care ID - Cancel Appointment Confirmation Dialog` | `20:30384` | 390x886 | `lib/features/patient/presentation/screens/appointment_details_screen.dart` | **Implemented** |
| 82 | `Care ID - Family Records` | `20:30521` | 390x1043 | `lib/features/patient/presentation/screens/family_records_screen.dart` | **Completed** |
| 83 | `CareID-Create Account` | `20:30644` | 390x911 | `lib/features/onboarding/presentation/screens/create_account_screen.dart` | **Completed** |
| 84 | `Mobile_number` | `20:30756` | 390x1207 | `lib/features/onboarding/presentation/screens/mobile_number_screen.dart` | **Completed** |
| 85 | `Health_info` | `20:30900` | 390x2636 | `lib/features/onboarding/presentation/screens/health_info_screen.dart` | **Completed** |
| 86 | `Privacy & Consents` | `20:31164` | 390x2549.5 | `lib/features/onboarding/presentation/screens/privacy_consents_screen.dart` | **Completed** |
| 87 | `Confirmed_Screen` | `20:31401` | 390x2033 | `lib/features/onboarding/presentation/screens/confirmed_screen.dart` | **Completed** |
| 88 | `Live_chat_messeges` | `20:31689` | 390x1117 | `lib/features/patient/presentation/screens/live_chat_screen.dart` | **Implemented** |
| 89 | `Medical Records` | `20:31908` | 390x1272 | `lib/features/patient/presentation/screens/medical_records_screen.dart` | **Completed** |
| 90 | `Document Viewer` | `20:32097` | 390x936 | `lib/features/patient/presentation/screens/document_viewer_screen.dart` | **Implemented** |
| 91 | `Document Viewer` | `20:32177` | 390x936 | `lib/features/patient/presentation/screens/document_viewer_screen.dart` | **Implemented** |
| 93 | `Scan Reports` | `20:32268` | 390x905 | `lib/features/patient/presentation/screens/add_health_record_screen.dart` | **Partially Implemented** |
| 94 | `OCR Processing - Report` | `20:32321` | 390x980 | `lib/features/patient/presentation/screens/add_health_record_screen.dart` | **Partially Implemented** |
| 95 | `Vision Records - Timeline & Vault` | `20:32423` | 390x1272 | `lib/features/patient/presentation/screens/vision_records_screen.dart` | **Implemented** |
| 96 | `Care ID - Vision Record Detail` | `20:32573` | 390x2030 | `lib/features/patient/presentation/screens/record_detail_screen.dart` | **Partially Implemented** |
| 97 | `Document Viewer` | `20:32816` | 390x936 | `lib/features/patient/presentation/screens/document_viewer_screen.dart` | **Implemented** |
| 98 | `Full Kiosk Pass` | `20:32906` | 375x1145 | `lib/features/patient/presentation/screens/full_kiosk_pass_screen.dart` | **Completed** |
| 99 | `Add Insurance Info` | `20:33068` | 375x1178.780029296875 | `lib/features/onboarding/presentation/screens/add_insurance_screen.dart` | **Completed** |
| 100 | `Care ID payment options` | `20:33152` | 390x844 | `lib/features/patient/presentation/screens/payment_options_screen.dart` | **Implemented** |
| 101 | `Add Health Record` | `20:33245` | 375x1228 | `lib/features/patient/presentation/screens/add_health_record_screen.dart` | **Partially Implemented** |
| 102 | `Review Health Record` | `20:33367` | 375x1101 | `lib/features/patient/presentation/screens/add_health_record_screen.dart` | **Partially Implemented** |
| 103 | `Record Saved Success` | `20:33470` | 375x1012.5 | `lib/features/patient/presentation/screens/add_health_record_screen.dart` | **Partially Implemented** |

---

## 2. Reusable Components, Illustrations & Decorative Vectors

| No. | Element Name | Node ID | Dimensions | Type | Notes |
|---|---|---|---|---|---|
| 4 | `Union (Stroke)` | `20:19551` | 228x228 | `vector` | Canvas Vector / Graphic / Label |
| 43 | `CareIDlogo 4` | `20:25189` | 25x17 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 44 | `CareIDlogo 9` | `20:25190` | 79x18 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 46 | `WhatsApp Image 2026-08-20 at 3.17.49 PM 1` | `20:25195` | 1536x1024 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 47 | `CareIDlogo 23` | `20:25196` | 25x17 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 48 | `CareIDlogo 25` | `20:25197` | 25x17 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 49 | `CareIDlogo 26` | `20:25198` | 25x17 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 50 | `CareIDlogo 27` | `20:25199` | 25x17 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 51 | `CareIDlogo 21` | `20:25200` | 25x17 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 52 | `CareIDlogo 28` | `20:25201` | 25x17 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 53 | `CareIDlogo 29` | `20:25202` | 25x17 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 54 | `CareIDlogo 30` | `20:25203` | 25x17 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 55 | `CareIDlogo 31` | `20:25204` | 25x17 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 56 | `CareIDlogo 32` | `20:25205` | 25x17 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 57 | `CareIDlogo 33` | `20:25206` | 25x17 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 58 | `Background+Border` | `20:25207` | 65x55 | `frame` | Canvas Vector / Graphic / Label |
| 92 | `Image` | `20:32267` | 356x266.5 | `rounded-rectangle` | Canvas Vector / Graphic / Label |
| 104 | `Provider not registered?  Click here to invite your provider to CareID` | `20:33523` | 390x36 | `text` | Canvas Vector / Graphic / Label |