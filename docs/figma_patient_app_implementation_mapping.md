# CareID Patient App — Figma Implementation Mapping

**Project:** `C:\Users\PABANI\CareID_patient_app`  
**Figma File:** `CAREID-AIO-FIGMA`  
**Canvas:** `17:55` (`Careid patient app`)  
**Backend Base URL:** `https://360api.vnvision.in`  
**Date:** October 31, 2026  

---

## 1. Onboarding Screen Journey (8 Core Steps)

| Figma Page | Screen / Frame Name | Figma Node ID | Dimensions | Existing Flutter Screen / Widget | Current Status | Required Changes / Figma Fidelity Alignment |
|---|---|---|---|---|---|---|
| Careid patient app (`17:55`) | **Splash_Screen** | `20:25191` | `390 × 884` | `lib/features/onboarding/presentation/screens/splash_screen.dart` | Implemented | Uses `careid_splash_graphic.png` background (`image 9`) and hero illustration (`20:25194`). Verify transition timing to Welcome. |
| Careid patient app (`17:55`) | **Welcome - Option 2** | `20:19794` | `390 × 1072` | `lib/features/onboarding/presentation/screens/welcome_screen.dart` | Implemented | 4 feature cards grid (Digital Card, Medical Records, Insurance, Family & Pet Care), hero typography ("Your Health All In One Place"), CareID horizontal logo. |
| Careid patient app (`17:55`) | **CareID-Create Account** | `20:30644` | `390 × 911` | `lib/features/onboarding/presentation/screens/create_account_screen.dart` | Implemented | Step 1 of 6. Form fields for Full Name, Mobile Number, Email Address, Password with prefix icons, validation and CareID branding. |
| Careid patient app (`17:55`) | **Mobile_number** | `20:30756` | `390 × 1207` | `lib/features/onboarding/presentation/screens/mobile_number_screen.dart` | Implemented | Step 2 of 6. Top branding bar, 6-digit OTP code cells, resend timer, simulated/live SMS challenge via Auth API. |
| Careid patient app (`17:55`) | **Health_info** | `20:30900` | `390 × 2636` | `lib/features/onboarding/presentation/screens/health_info_screen.dart` | Implemented | Step 3 of 6. Top branding bar, Blood group selectors (A+, B+, O+, AB+, etc.), Known allergies chips, chronic conditions, emergency contacts. |
| Careid patient app (`17:55`) | **Add Insurance Info** | `20:33068` | `375 × 1178.78` | `lib/features/onboarding/presentation/screens/add_insurance_screen.dart` | Implemented | Step 4 of 6. Language switcher (EN/ESP), "Scan Insurance Card" camera trigger, Insurance Provider, Member ID, Group Number, Skip button. |
| Careid patient app (`17:55`) | **Privacy & Consents** | `20:31164` | `390 × 2549.5` | `lib/features/onboarding/presentation/screens/privacy_consents_screen.dart` | Implemented | Step 5 of 6. Top branding bar, Terms of Service, HIPAA Authorization, Emergency Data Sharing consent toggles, Accept & Continue button. |
| Careid patient app (`17:55`) | **Confirmed_Screen** | `20:31401` | `390 × 2033` | `lib/features/onboarding/presentation/screens/confirmed_screen.dart` | Implemented | Step 6 of 6. Top branding bar, Success badge ("Registration Complete"), preview of active Digital Health Card with QR and CareID number, "Go to Dashboard" CTA. |

---

## 2. Family Management Journey

| Figma Page | Screen / Frame Name | Figma Node ID | Dimensions | Existing Flutter Screen / Widget | Current Status | Required Changes / Figma Fidelity Alignment |
|---|---|---|---|---|---|---|
| Careid patient app (`17:55`) | **Family Dashboard** | `20:21675` | `390 × 1545.5` | `lib/features/patient/presentation/screens/family_dashboard_screen.dart` | Implemented | 64px AppBar with `CareIdLogo.horizontal(height: 18)`, Family ecosystem hero card, Member preview list, Quick actions (Add Member, Manage Consents, Shared Records). |
| Careid patient app (`17:55`) | **Family Member List** | `20:21825` | `390 × 1430` | `lib/features/patient/presentation/screens/family_members_screen.dart` | Implemented | Search bar, relationship category filter chips (All, Spouse, Children, Parents, Dependents), member cards with status badges and menu. |
| Careid patient app (`17:55`) | **Member Permissions & Sharing** | `20:22307` | `390 × 1125` | `lib/features/patient/presentation/screens/member_permissions_sharing_screen.dart` | Implementation Needed | 64px AppBar, Member Header with avatar & relationship, 4 permission toggles (Medical, Dental, Vision, Records), Expiry Settings, Save Button. |
| Careid patient app (`17:55`) | **Shared Health Card - Dependent View** | `20:22459` | `390 × 1062.5` | `lib/features/patient/presentation/screens/dependent_health_card_screen.dart` | Implementation Needed | 64px AppBar, Apple Wallet-inspired physical health card preview for dependent, Blood group, DOB, Emergency QR, quick stat pills. |
| Careid patient app (`17:55`) | **Shared Medical Records** | `20:22594` | `390 × 1310` | `lib/features/patient/presentation/screens/shared_medical_records_screen.dart` | Implementation Needed | 64px AppBar, Member Switcher carousel, category search & filters, medical history timeline for authorized dependent records. |
| Careid patient app (`17:55`) | **Family Consent & Requests** | `20:22157` | `390 × 1175` | `lib/features/patient/presentation/screens/family_consent_requests_screen.dart` | Implementation Needed | 64px AppBar, 3-tab request system (Pending, Approved, Expired), Bento style request cards with Approve/Decline actions grounded in `/api/v1/family/consents`. |
| Careid patient app (`17:55`) | **Add Family Member - Form** | `20:22023` | `390 × 1418` | `lib/features/patient/presentation/screens/add_family_member_screen.dart` | Implemented | Step 1 of 3: Member Demographics, Full Name, Relationship dropdown, DOB, Gender, Contact Information. |
| Careid patient app (`17:55`) | **Add Family Member — Access** | `20:19424` | `390 × 1400` | `lib/features/patient/presentation/screens/add_family_member_screen.dart` | Implemented | Step 2 of 3: Access Level scoping (Full, Limited, Emergency-Only), expiration period selector. |
| Careid patient app (`17:55`) | **Add Family Member — Review** | `20:19238` | `390 × 1521` | `lib/features/patient/presentation/screens/add_family_member_screen.dart` | Implemented | Step 3 of 3: Summary review card, consent confirmation checkbox, Send Invitation CTA. |
| Careid patient app (`17:55`) | **Invitation Sent** | `20:19138` | `390 × 1143` | `lib/features/patient/presentation/screens/invitation_sent_screen.dart` | Implemented | Success hero badge, invitation code pass, next steps checklist (SMS delivered, accept link, active status). |

---

## 3. Core Clinical & Patient Identity Screens

| Figma Page | Screen / Frame Name | Figma Node ID | Dimensions | Existing Flutter Screen / Widget | Current Status |
|---|---|---|---|---|---|
| Careid patient app (`17:55`) | **Home - Option 6** | `20:19552` | `390 × 1846` | `lib/features/patient/presentation/screens/patient_dashboard_screen.dart` | Implemented & Verified |
| Careid patient app (`17:55`) | **Smart Digital Health Card** | `20:19873` | `390 × 1522` | `lib/features/patient/presentation/screens/health_card_screen.dart` | Implemented & Verified |
| Careid patient app (`17:55`) | **Insurance Dashboard** | `20:20059` | `390 × 2179` | `lib/features/patient/presentation/screens/insurance_screen.dart` | Implemented & Verified |
| Careid patient app (`17:55`) | **Care ID - Health Records Landing** | `20:25209` | `390 × 1386` | `lib/features/patient/presentation/screens/medical_records_screen.dart` | Implemented & Verified |
| Careid patient app (`17:55`) | **QR Dashboard** | `20:22771` | `390 × 1105` | `lib/features/patient/presentation/screens/qr_dashboard_screen.dart` | Implemented & Verified |
| Careid patient app (`17:55`) | **Share Options** | `20:23195` | `390 × 2204.83` | `lib/features/patient/presentation/screens/share_options_screen.dart` | Implemented & Verified |
| Careid patient app (`17:55`) | **QR Preview** | `20:23338` | `390 × 1150` | `lib/features/patient/presentation/screens/qr_preview_screen.dart` | Implemented & Verified |
| Careid patient app (`17:55`) | **Manage Shared Access** | `20:23597` | `390 × 1282` | `lib/features/patient/presentation/screens/manage_shared_access_screen.dart` | Implemented & Verified |
| Careid patient app (`17:55`) | **Notification Center** | `20:23812` | `390 × 1459` | `lib/features/patient/presentation/screens/notification_center_screen.dart` | Implemented & Verified |
| Careid patient app (`17:55`) | **Emergency Center** | `20:23956` | `390 × 2175.64` | `lib/features/patient/presentation/screens/emergency_center_screen.dart` | Implemented & Verified |
| Careid patient app (`17:55`) | **Profile & Settings Hub** | `20:24204` | `390 × 2002` | `lib/features/patient/presentation/screens/patient_profile_screen.dart` | Implemented & Verified |

