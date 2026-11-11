# CareID Patient App — Comprehensive Screen Map & Architecture Specification

**Date**: October 29, 2026  
**Reference Figma File**: `CAREID-AIO-FIGMA`  
**Target Canvas**: `Careid patient app` (Node ID: `17:55`)  
**Flutter Workspace**: `C:\Users\PABANI\CareID_patient_app`  
**Backend API**: `https://360api.vnvision.in`  

---

## 1. Executive Summary & Canvas Overview

The CareID Patient App canvas (`17:55`) represents the complete patient-facing experience of the CareID healthcare platform. A complete structural audit of the canvas revealed **87 distinct frames** spanning 8 primary functional domains.

The Flutter application architecture modularly organizes the approved 15 primary screens across:
- **Onboarding & Registration Pipeline** (Steps 1 through 6 + Splash & Gateway)
- **Authentication & Session Restore** (OTP Challenge, Phone Picker, Biometric, Session Guard)
- **Persistent Patient Navigation Shell** (`HomeScreen`, `MedicalRecordsScreen`, `HealthCardScreen`, `InsuranceScreen`, `PatientProfileScreen`)

---

## 2. Master Navigation Flow Map

```
                     ┌────────────────────────────────┐
                     │   SplashScreen (20:25191)      │
                     └───────────────┬────────────────┘
                                     │
                                     ▼
                     ┌────────────────────────────────┐
                     │ WelcomeScreen (20:19794)       │
                     └───────┬────────────────┬───────┘
                             │                │
            "I already have  │                │ "Get Started"
               an account"   ▼                ▼
     ┌─────────────────────────────┐   ┌─────────────────────────────┐
     │ LoginScreen (20:24965)      │   │ CreateAccount (20:30644)    │
     │ - Phone (+1 prefix)         │   │ - Step 1 of 6               │
     │ - Challenge ID dispatch     │   └──────────────┬──────────────┘
     │ - 6-Digit OTP & 60s timer   │                  │
     └──────────────┬──────────────┘                  ▼
                    │                  ┌─────────────────────────────┐
                    │                  │ MobileNumberScreen (20:30756│
                    │                  │ - Step 2 of 6: OTP verify   │
                    │                  └──────────────┬──────────────┘
                    │                                 │
                    │                                 ▼
                    │                  ┌─────────────────────────────┐
                    │                  │ HealthInfoScreen (20:30900) │
                    │                  │ - Step 3 of 6: Vitals/Meds  │
                    │                  └──────────────┬──────────────┘
                    │                                 │
                    │                                 ▼
                    │                  ┌─────────────────────────────┐
                    │                  │ AddInsuranceScreen (20:33068│
                    │                  │ - Step 4 of 6: Policy/Scan  │
                    │                  └──────────────┬──────────────┘
                    │                                 │
                    │                                 ▼
                    │                  ┌─────────────────────────────┐
                    │                  │ PrivacyConsents (20:31164)  │
                    │                  │ - Step 5 of 6: HIPAA / Auth │
                    │                  └──────────────┬──────────────┘
                    │                                 │
                    │                                 ▼
                    │                  ┌─────────────────────────────┐
                    │                  │ ConfirmedScreen (20:31401)  │
                    │                  │ - Step 6 of 6: Card Issued  │
                    │                  └──────────────┬──────────────┘
                    │                                 │
                    │         "Enter CareID"          │
                    └────────────────►┬◄──────────────┘
                                      │
                                      ▼
     ┌──────────────────────────────────────────────────────────────┐
     │         PatientMainNavigationShell (Persistent IndexedStack) │
     ├─────────────┬─────────────┬─────────────┬─────────────┬──────┤
     │ Tab 0       │ Tab 1       │ Tab 2       │ Tab 3       │Tab 4 │
     │ HomeScreen  │ Medical     │ HealthCard  │ Insurance   │Profile
     │ (20:19552)  │ Records     │ Screen      │ Screen      │Screen│
     └─────────────┴─────────────┴─────────────┴─────────────┴──────┘
```

---

## 3. Complete Canvas 17:55 Frame Hierarchy (All 87 Nodes)

### 3.1 Onboarding & Registration (8 Frames)
1. **`Splash_Screen`** (`20:25191`): `390 x 884 pt` — Brand clinical splash screen with logo & photoroom artwork.
2. **`Welcome - Option 2`** (`20:19794`): `390 x 1072 pt` — Gateway with 4 service disciplines (Medical, Dental, Vision, Pets).
3. **`CareID-Create Account`** (`20:30644`): `390 x 911 pt` — Step 1 of 6: Basic credentials & registration.
4. **`Health_info`** (`20:30900`): `390 x 2636 pt` — Step 3 of 6: Clinical demographics, blood group chips, vitals.
5. **`Add Insurance Info`** (`20:33068`): `375 x 1179 pt` — Step 4 of 6: Insurance link, OCR camera card capture.
6. **`Privacy &amp; Consents`** (`20:31164`): `390 x 2550 pt` — Step 5 of 6: Required consents, HIPAA release, emergency contact.
7. **`Confirmed_Screen`** (`20:31401`): `390 x 2033 pt` — Step 6 of 6: Digital health card issued, holographic tag, disciplines.
8. **`Security &amp; Privacy Controls`** (`20:24805`): `390 x 1906 pt` — Post-onboarding cryptographic settings & permissions.

### 3.2 Authentication & Security (5 Frames)
9. **`Mobile_number`** (`20:30756`): `390 x 1207 pt` — Step 2 of 6: OTP challenge verification & resend timer.
10. **`Login - Refined Auth Flow v2`** (`20:24965`): `390 x 1020 pt` — Seeded patient login with phone, challenge dispatch, and 6-digit OTP.
11. **`Biometric Setup - Refined Polish`** (`20:25097`): `390 x 972 pt` — Fingerprint/FaceID biometric prompt.
12. **`OTP Verification - Refined States`** (`20:25032`): `390 x 884 pt` — Error, focus, and auto-submit states for OTP.
13. **`Account recovery`** (`20:25143`): `390 x 972 pt` — Account retrieval via verified mobile number.

### 3.3 Core Navigation Shell & Dashboard (6 Frames)
14. **`Home - Option 6`** (`20:19552`): `390 x 1846 pt` — Patient Dashboard, hero credential card, vitals overview, upcoming items.
15. **`Smart Digital Health Card`** (`20:19873`): `390 x 1522 pt` — Full digital health card with verifiable QR code, NFC trigger, Apple Wallet / GPay.
16. **`QR Dashboard`** (`20:22771`): `390 x 1105 pt` — Quick QR presentation dashboard.
17. **`QR Preview`** (`20:23338`): `390 x 1150 pt` — Full-screen QR code scanner preview.
18. **`Notification Center`** (`20:23812`): `390 x 1459 pt` — Notification history and clinical alerts.
19. **`Emergency Center`** (`20:23956`): `390 x 2176 pt` — Emergency dispatch, ICE contacts, medical alert profile.

### 3.4 Health Records & Vault Modules (20 Frames)
20. **`Medical Records`** (`20:31908`): `390 x 1272 pt` — Medical records vault, category filtering, search, timeline.
21. **`Care ID - Health Records Landing (Refined)`** (`20:25209`): `390 x 1386 pt` — Records landing view.
22. **`Dental Records`** (`20:21111`): `390 x 1272 pt` — Dental examinations, procedures, radiographs.
23. **`Care ID - Dental Record Detail`** (`20:25653`): `390 x 1854 pt` — Detailed dental procedure view.
24. **`Vision Records - Timeline &amp; Vault`** (`20:21301` / `20:32423`): `390 x 1272 pt` — Eye exams, refractive measurements.
25. **`Care ID - Vision Record Detail`** (`20:25410` / `20:32573`): `390 x 2030 pt` — Visual acuity details.
26. **`Care ID - Family Records`** (`20:30521`): `390 x 1043 pt` — Consolidated family vault records.
27. **`Shared Medical Records`** (`20:22594`): `390 x 1310 pt` — Delegated records view.
28. **`Upload Medical Record - Refined Flow`** (`20:21451`): `390 x 1642 pt` — Document upload & categorization.
29. **`Scan Reports`** (`20:32268`): `390 x 905 pt` — Camera scanner for clinical reports.
30. **`OCR Processing - Report`** (`20:32321`): `390 x 980 pt` — Extraction progress indicator.
31. **`Review Health Record`** (`20:33367`): `375 x 1101 pt` — Pre-save verification of OCR extracted fields.
32. **`Add Health Record`** (`20:33245`): `375 x 1228 pt` — Manual entry form for records.
33. **`Record Saved Success`** (`20:33470`): `375 x 1012 pt` — Confirmation dialog after record landing.
34. **`Document Viewer`** (`20:32097` / `20:32177` / `20:32816`): `390 x 936 pt` — In-app document and PDF viewer.
35. **`OCR Processing - Insurance Card`** (`20:20415`): `390 x 980 pt` — Card OCR animation.

### 3.5 Family Care & Sharing Ecosystem (9 Frames)
36. **`Family Dashboard`** (`20:21675`): `390 x 1546 pt` — Family member management, dependents, invitation status.
37. **`Family Member List`** (`20:21825`): `390 x 1430 pt` — Detailed list of linked family members.
38. **`Add Family Member - Form`** (`20:22023`): `390 x 1418 pt` — Personal information form for dependent/guardian.
39. **`Add Family Member — Access`** (`20:19424`): `390 x 1400 pt` — Permission selection (read-only, full access, emergency only).
40. **`Add Family Member — Review`** (`20:19238`): `390 x 1521 pt` — Final confirmation before dispatching invitation.
41. **`Invitation Sent`** (`20:19138`): `390 x 1143 pt` — Success state with expiration countdown.
42. **`Family Consent &amp; Requests`** (`20:22157`): `390 x 1175 pt` — Mutual consent authorization hub.
43. **`Member Permissions &amp; Sharing`** (`20:22307`): `390 x 1125 pt` — Granular access control list.
44. **`Shared Health Card - Dependent View`** (`20:22459`): `390 x 1062 pt` — Dependent card presentation.

### 3.6 Appointments & Clinical Care (13 Frames)
45. **`Doctors`** (`20:28020`): `390 x 1810 pt` — Search and browse verified clinical practitioners.
46. **`Doctor Profile`** (`20:28961`): `390 x 2244 pt` — Physician credentials, ratings, specialties.
47. **`Care ID - Book Appointment (Type Selection)`** (`20:28764`): `390 x 1458 pt` — In-person vs Telehealth selection.
48. **`Care ID - Book Appointment (Date &amp; Time)`** (`20:28312`): `390 x 1362 pt` — Calendar picker & available slot selector.
49. **`Care ID - Review Appointment`** (`20:28595`): `390 x 1182 pt` — Pre-confirmation review.
50. **`Care ID - Appointment Confirmation`** (`20:29208`): `390 x 1464 pt` — Confirmed booking with calendar link.
51. **`Care ID - Appointment Details`** (`20:29399`): `390 x 2063 pt` — Clinic location, pre-visit instructions.
52. **`Care ID - My Appointments`** (`20:29664`): `390 x 1174 pt` — Tabs for Upcoming, Completed, and Cancelled.
53. **`Care ID - Appointment Details &amp; Actions`** (`20:29860`): `390 x 1706 pt` — Check-in, reschedule, cancel triggers.
54. **`Care ID - Reschedule Appointment`** (`20:30086`): `390 x 1540 pt` — Rescheduling date picker.
55. **`Care ID - Cancel Appointment Dialog`** (`20:30384`): `390 x 886 pt` — Cancellation reason confirmation.
56. **`Full Kiosk Pass`** (`20:32906`): `375 x 1145 pt` — Self-service kiosk barcode for fast clinic check-in.
57. **`Live_chat_messeges`** (`20:31689`): `390 x 1117 pt` — Real-time messaging with clinic care team.

### 3.7 Insurance, Financing & Treatment Offers (14 Frames)
58. **`Insurance Dashboard`** (`20:20059`): `390 x 2179 pt` — Active policy cards, claims status, coverage breakdown.
59. **`Add Insurance - Select Method`** (`20:20311`): `390 x 1539 pt` — Choice between photo OCR, provider login, or manual entry.
60. **`Insurance Card - Camera Capture`** (`20:20258`): `390 x 905 pt` — Camera overlay for card front and back.
61. **`Insurance Card Details`** (`20:20890`): `390 x 1385 pt` — Copay, coinsurance, deductible progress bars.
62. **`Care ID - Insurance &amp; Financing Hub`** (`20:25895`): `390 x 2453 pt` — Financial solutions portal.
63. **`Care ID - Insurance Status (Uninsured)`** (`20:26187`): `390 x 1743 pt` — Self-pay guidance and discount enrollments.
64. **`Care ID payment options`** (`20:33152`): `390 x 844 pt` — Split payments, CareCredit, HSA/FSA cards.
65. **`Care ID - Treatment Offers`** (`20:26404`): `390 x 2134 pt` — Proposed dental/vision treatment packages.
66. **`Care ID - Financing Option Details`** (`20:26692`): `390 x 1638 pt` — APR, term, and monthly payment calculator.
67. **`Care ID - Treatment Offer Details`** (`20:26922`): `390 x 1843 pt` — Line item breakdown of clinical procedures.
68. **`Care ID - Offer Accepted Confirmation`** (`20:27176`): `390 x 1686 pt` — Cryptographically signed plan acceptance.
69. **`Care ID - Cash Discount Options`** (`20:27380`): `390 x 2010 pt` — Prompt payment cash discounts.
70. **`Care ID - Offer Rejected Confirmation`** (`20:27613`): `390 x 1451 pt` — Feedback dialog on offer decline.
71. **`Care ID - Offer Status &amp; History`** (`20:27768`): `408 x 1444 pt` — Historical archive of treatment proposals.

### 3.8 Profile, Identity & Settings Hub (3 Frames)
72. **`Profile &amp; Settings Hub`** (`20:24204`): `390 x 2002 pt` — Master patient preferences, languages, linked accounts.
73. **`Medical Information Summary`** (`20:24484`): `390 x 1551 pt` — High-level summary of allergies, chronic conditions, surgeries.
74. **`Personal Details &amp; Identity`** (`20:24653`): `390 x 1160 pt` — Patient demographics, address, emergency contact, DOB.

### 3.9 Access & Verification Modals (9 Frames)
75. **`Share Options`** (`20:23195`): `390 x 2205 pt` — Modal sheet with QR share, link share, one-time passcode.
76. **`Access History`** (`20:23450`): `390 x 1290 pt` — Audit log of healthcare providers who viewed records.
77. **`Manage Shared Access`** (`20:23597`): `390 x 1282 pt` — Revoke or modify existing access grants.
78. **`Access Verification`** (`20:23745`): `390 x 1324 pt` — Dual-factor verification for high-security record releases.
79. **`Medication Reminder Detail`** (`20:24101`): `390 x 862 pt` — Prescription dosage schedule & adherence tracker.
80. **`OCR Extraction Results`** (`20:20517`): `390 x 2134 pt` — Confidence score breakdown for scanned fields.
81. **`Manual Review &amp; Edit`** (`20:20723`): `390 x 1235 pt` — Field correction interface before saving.
82. **`Html → Body`** (`20:21019`): `390 x 1135 pt` — Clinical report markup renderer.
83. **`Background+Border`** (`20:25207`): `65 x 55 pt` — Shared decorative token container.

---

## 4. Primary Implemented Screen Specifications (15 Core Modules)

| # | Screen Name | Node ID | Dimensions | Flutter Implementation | Route / Placement |
|---|---|---|---|---|---|
| 1 | **Splash Screen** | `20:25191` | `390 x 884 pt` | [`splash_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/onboarding/presentation/screens/splash_screen.dart) | Initial Route (`/`) |
| 2 | **Welcome Screen** | `20:19794` | `390 x 1072 pt` | [`welcome_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/onboarding/presentation/screens/welcome_screen.dart) | `/welcome` |
| 3 | **Create Account** | `20:30644` | `390 x 911 pt` | [`create_account_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/onboarding/presentation/screens/create_account_screen.dart) | `/create-account` (Step 1) |
| 4 | **Mobile Number / OTP** | `20:30756` | `390 x 1207 pt` | [`mobile_number_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/onboarding/presentation/screens/mobile_number_screen.dart) | Step 2 of 6 |
| 5 | **Health Info** | `20:30900` | `390 x 2636 pt` | [`health_info_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/onboarding/presentation/screens/health_info_screen.dart) | Step 3 of 6 |
| 6 | **Add Insurance** | `20:33068` | `375 x 1179 pt` | [`add_insurance_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/onboarding/presentation/screens/add_insurance_screen.dart) | Step 4 of 6 |
| 7 | **Privacy & Consents** | `20:31164` | `390 x 2550 pt` | [`privacy_consents_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/onboarding/presentation/screens/privacy_consents_screen.dart) | Step 5 of 6 |
| 8 | **Confirmed Screen** | `20:31401` | `390 x 2033 pt` | [`confirmed_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/onboarding/presentation/screens/confirmed_screen.dart) | Step 6 of 6 |
| 9 | **Login Screen** | `20:24965` | `390 x 1020 pt` | [`login_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/auth/presentation/screens/login_screen.dart) | `/login` |
| 10 | **Patient Home** | `20:19552` | `390 x 1846 pt` | [`home_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/home_screen.dart) | Nav Shell Tab 0 (`/home`, `/dashboard`) |
| 11 | **Medical Records** | `20:31908` | `390 x 1272 pt` | [`medical_records_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/medical_records_screen.dart) | Nav Shell Tab 1 (`/records`) |
| 12 | **Digital Health Card** | `20:19873` | `390 x 1522 pt` | [`health_card_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/health_card_screen.dart) | Nav Shell Tab 2 (`/health-card`) |
| 13 | **Insurance & Claims** | `20:20059` | `390 x 2179 pt` | [`insurance_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/insurance_screen.dart) | Nav Shell Tab 3 (`/insurance`) |
| 14 | **Family Dashboard** | `20:21675` | `390 x 1546 pt` | [`family_members_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/family_members_screen.dart) | Quick Action / Sub-route |
| 15 | **Personal Details & Profile**| `20:24653` | `390 x 1160 pt` | [`patient_profile_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/patient_profile_screen.dart) | Nav Shell Tab 4 (`/profile`) |
| 16 | **Doctors Directory** | `20:28020` | `390 x 1810 pt` | [`doctors_directory_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/doctors_directory_screen.dart) | Home Quick Action / Search |
| 17 | **Doctor Profile** | `20:28961` | `390 x 2244 pt` | [`doctor_profile_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/doctor_profile_screen.dart) | From Doctors Directory |
| 18 | **Book Appointment** | `20:28764` | `390 x 1458 pt` | [`book_appointment_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/book_appointment_screen.dart) | Multi-step Booking Flow |
| 19 | **My Appointments** | `20:29664` | `390 x 1174 pt` | [`my_appointments_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/my_appointments_screen.dart) | Home Banner "View All" |
| 20 | **Appointment Details** | `20:29860` | `390 x 1706 pt` | [`appointment_details_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/appointment_details_screen.dart) | From Appointments List |
| 21 | **Dental Records Vault** | `20:21111` | `390 x 1272 pt` | [`dental_records_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/dental_records_screen.dart) | Medical Records Vault Chip |
| 22 | **Vision Records Vault** | `20:21301` | `390 x 1272 pt` | [`vision_records_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/vision_records_screen.dart) | Medical Records Vault Chip |
| 23 | **Clinical Record Detail** | `20:25410` | `390 x 2030 pt` | [`record_detail_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/record_detail_screen.dart) | From Any Record Card |
| 24 | **Add Health Record** | `20:33245` | `375 x 1228 pt` | [`add_health_record_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/add_health_record_screen.dart) | Medical Records Floating Action |
| 25 | **Notification Center** | `20:23812` | `390 x 1459 pt` | [`notification_center_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/notification_center_screen.dart) | Home AppBar Bell Icon |
| 26 | **Emergency Center** | `20:23956` | `390 x 2176 pt` | [`emergency_center_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/emergency_center_screen.dart) | Home Quick Action SOS |
| 27 | **Add Family Member** | `20:22023` | `390 x 1418 pt` | [`add_family_member_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/add_family_member_screen.dart) | Family Dashboard Action |
| 28 | **Treatment Offers** | `20:26404` | `390 x 2134 pt` | [`treatment_offers_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/treatment_offers_screen.dart) | Insurance Financing Banner |
| 29 | **Claim Details** | `20:20158` | `390 x 1450 pt` | [`claim_details_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/claim_details_screen.dart) | Insurance Claims Card Tap |
