# 01. Patient Screen to Figma Mapping Report

**Project:** `C:\Users\PABANI\CareID_patient_app`  
**Platform:** Flutter Android  
**Design Reference:** CAREID-AIO-FIGMA  
**Figma Canvas:** `17:55` (`Careid patient app`)  
**Audit Date:** November 2, 2026  

---

## 1. Overview & Canvas Inspection

The Patient App canvas (`17:55`) in `CAREID-AIO-FIGMA` contains 104 canvas-level nodes. An audit of each frame against the Flutter client implementation was conducted via the connected Figma MCP server.

This report establishes the single source of truth for screen mapping, component hierarchy, and visual fidelity requirements.

---

## 2. Complete Screen-to-Figma Mapping Table

| No. | Exact Figma Frame Name | Figma Node ID | Dimensions | Flutter Implementation File | Visual Fidelity Status |
|---|---|---|---|---|---|
| **1** | **Profile & Settings Hub** | `20:24204` | 390 × 2002 | `lib/features/patient/presentation/screens/patient_profile_screen.dart` | **Target — In Progress** |
| **2** | **Family Member List** | `20:21825` | 390 × 1430 | `lib/features/patient/presentation/screens/family_members_screen.dart` | **Target — Step 3** |
| **3** | **Family Dashboard** | `20:21675` | 390 × 1545.5 | `lib/features/patient/presentation/screens/family_dashboard_screen.dart` | **Target — Step 4** |
| **4** | **Care ID - Appointment Confirmation** | `20:29208` | 390 × 1464.5 | `lib/features/patient/presentation/screens/appointment_confirmation_screen.dart` | **Target — Step 5** |
| 5 | `Shared Health Card - Dependent View` | `20:22459` | 390 × 1062.5 | `lib/features/patient/presentation/screens/family_member_profile_screen.dart` | Requires Alignment |
| 6 | `Home - Option 6` | `20:19552` | 390 × 1846 | `lib/features/patient/presentation/screens/home_screen.dart` | Implemented |
| 7 | `Smart Digital Health Card` | `20:19873` | 390 × 1522 | `lib/features/patient/presentation/screens/health_card_screen.dart` | Implemented |
| 8 | `Insurance Dashboard` | `20:20059` | 390 × 2179 | `lib/features/patient/presentation/screens/insurance_screen.dart` | Implemented |
| 9 | `Care ID - Health Records Landing` | `20:25209` | 390 × 1386 | `lib/features/patient/presentation/screens/medical_records_screen.dart` | Implemented |
| 10 | `Medical Records` | `20:31908` | 390 × 1272 | `lib/features/patient/presentation/screens/medical_records_screen.dart` | Implemented |
| 11 | `Care ID - Family Records` | `20:30521` | 390 × 1043 | `lib/features/patient/presentation/screens/family_records_screen.dart` | Implemented |
| 12 | `Personal Details & Identity` | `20:24653` | 390 × 1160 | `lib/features/patient/presentation/screens/personal_details_identity_screen.dart` | Implemented |
| 13 | `Security & Privacy Controls` | `20:24805` | 390 × 1906 | `lib/features/patient/presentation/screens/security_privacy_controls_screen.dart` | Implemented |
| 14 | `Medical Information Summary` | `20:24484` | 390 × 1550.75 | `lib/features/patient/presentation/screens/medical_info_summary_screen.dart` | Implemented |
| 15 | `Access History` | `20:23450` | 390 × 1290 | `lib/features/patient/presentation/screens/access_history_screen.dart` | Implemented |
| 16 | `Emergency Center` | `20:23956` | 390 × 2175.6 | `lib/features/patient/presentation/screens/emergency_center_screen.dart` | Implemented |
| 17 | `Medication Reminder Detail` | `20:24101` | 390 × 862 | `lib/features/patient/presentation/screens/medication_reminder_detail_screen.dart` | Implemented |
| 18 | `Doctors` | `20:28020` | 390 × 1810 | `lib/features/patient/presentation/screens/doctors_directory_screen.dart` | Implemented |
| 19 | `Doctor Profile` | `20:28961` | 390 × 2244 | `lib/features/patient/presentation/screens/doctor_profile_screen.dart` | Implemented |
| 20 | `Care ID - Book Appointment (Date & Time)` | `20:28312` | 390 × 1362 | `lib/features/patient/presentation/screens/book_appointment_screen.dart` | Implemented |
| 21 | `Care ID - Book Appointment (Type Selection)` | `20:28764` | 390 × 1458 | `lib/features/patient/presentation/screens/book_appointment_screen.dart` | Implemented |
| 22 | `Care ID - Review Appointment` | `20:28595` | 390 × 1181.7 | `lib/features/patient/presentation/screens/book_appointment_screen.dart` | Implemented |
| 23 | `Care ID - Appointment Details` | `20:29399` | 390 × 2063 | `lib/features/patient/presentation/screens/appointment_details_screen.dart` | Implemented |
| 24 | `Care ID - My Appointments` | `20:29664` | 390 × 1174 | `lib/features/patient/presentation/screens/my_appointments_screen.dart` | Implemented |
| 25 | `Care ID - Reschedule Appointment` | `20:30086` | 390 × 1540 | `lib/features/patient/presentation/screens/reschedule_appointment_screen.dart` | Implemented |
| 26 | `Care ID - Cancel Appointment Dialog` | `20:30384` | 390 × 886 | `lib/features/patient/presentation/screens/appointment_details_screen.dart` | Implemented |
| 27 | `Dental Records` | `20:21111` | 390 × 1272 | `lib/features/patient/presentation/screens/dental_records_screen.dart` | Implemented |
| 28 | `Vision Records - Timeline & Vault` | `20:21301` | 390 × 1272 | `lib/features/patient/presentation/screens/vision_records_screen.dart` | Implemented |
| 29 | `Full Kiosk Pass` | `20:32906` | 375 × 1145 | `lib/features/patient/presentation/screens/full_kiosk_pass_screen.dart` | Implemented |
| 30 | `Notification Center` | `20:23812` | 390 × 1459 | `lib/features/patient/presentation/screens/notification_center_screen.dart` | Implemented |
| 31 | `Live_chat_messeges` | `20:31689` | 390 × 1117 | `lib/features/patient/presentation/screens/live_chat_screen.dart` | Implemented |
| 32 | `Welcome - Option 2` | `20:19794` | 390 × 1072 | `lib/features/onboarding/presentation/screens/welcome_screen.dart` | Implemented |
| 33 | `CareID-Create Account` | `20:30644` | 390 × 911 | `lib/features/onboarding/presentation/screens/create_account_screen.dart` | Implemented |
| 34 | `Mobile_number` | `20:30756` | 390 × 1207 | `lib/features/onboarding/presentation/screens/mobile_number_screen.dart` | Implemented |
| 35 | `Health_info` | `20:30900` | 390 × 2636 | `lib/features/onboarding/presentation/screens/health_info_screen.dart` | Implemented |
| 36 | `Privacy & Consents` | `20:31164` | 390 × 2549.5 | `lib/features/onboarding/presentation/screens/privacy_consents_screen.dart` | Implemented |
| 37 | `Confirmed_Screen` | `20:31401` | 390 × 2033 | `lib/features/onboarding/presentation/screens/confirmed_screen.dart` | Implemented |
| 38 | `Splash_Screen` | `20:25191` | 390 × 884 | `lib/features/onboarding/presentation/screens/splash_screen.dart` | Implemented |
| 39 | `Add Insurance Info` | `20:33068` | 375 × 1178.8 | `lib/features/onboarding/presentation/screens/add_insurance_screen.dart` | Implemented |
| 40 | `Login - Refined Auth Flow v2` | `20:24965` | 390 × 1020 | `lib/features/auth/presentation/screens/login_screen.dart` | Implemented |
| 41 | `OTP Verification - Refined States` | `20:25032` | 390 × 884 | `lib/features/auth/presentation/screens/login_screen.dart` | Implemented |

---

## 3. Detailed Component Hierarchy for the 4 Reference Screens

### 3.1 Patient Profile (`20:24204`) — Reference Image 1
- **Top App Bar:**
  - Back arrow `<` on left.
  - Centered title `Profile` in deep purple (`#2E006A`).
  - Notification action bell on right.
- **Profile Identity Card (White rounded card, 358 × 274):**
  - Circular avatar (112 × 112) with cyan outer border ring (`#00E5FF` / `#22D3EE`).
  - Overlapping teal verification badge pill `VERIFIED` with checkmark icon at the bottom of the avatar.
  - Centered patient name: `Sarah Jenkins` (22sp bold, `#0F172A`).
  - Centered info badge row: `HV-360-9928` pill + `Member Since Jan 2024` text.
  - Pill button: `[ ✏ Edit Profile ]` in deep solid purple (`#2E006A`), white text.
- **Horizontal Status Cards:**
  - Card 1: `Card / Active` on mint/cyan surface (`#E0F7FA`), teal credit card icon.
  - Card 2: `Insurance / Verified` on lavender surface (`#EDE9FE`), purple shield icon.
- **Grouped Settings Containers (White rounded cards, subtle border & shadow):**
  - **Account Settings:** Personal Information (`Name, Address, Date of Birth`), Email & Phone (`Manage your contact details`).
  - **Medical Information:** Health Profiles (`Conditions, Allergies, Medications`), Insurance Details (`Policy 44829 - Primary Health`).
  - **Security:** Biometric Login (`Use FaceID or Fingerprint` + toggle switch), Change PIN, Active Sessions (`2 active on Mobile & Web`).
  - **Privacy:** Consent & Permissions (`Who can view your data`), Data Sharing (`External app connections`).
  - **Application:** Version (`v3.4.2 (Production)`), Terms & Privacy Policy, Support Center (`24/7 dedicated medical help`).
  - **Account Actions:** Logout (red icon & label), Delete Account (`Irreversibly erase all medical data`, red icon & label).
- **Bottom Navigation Bar:**
  - Home, Records, Floating center QR scanner (56 × 56 purple circle), Doctor, Profile (highlighted with active cyan pill overlay).

### 3.2 Family Management — Member List (`20:21825`) — Reference Image 2
- **Header:** Back arrow, `Family Management` title, CareID emblem, notification bell, user avatar circle.
- **Search & Filters:** Search field `Search family members...` + Filter chips (`All`, `Parents`, `Children`, `Spouse`).
- **Member Cards:** Member photo, full name, relationship & age (`Father • 68 Years`), `Verified` badge, 3 status pills (`Health Card Status: ● Active`, `Insurance: Global Care Plus`, `Consent Status: Full Access`), action row (`View Details` purple button, pencil edit icon button, red trash delete button).
- **Floating Action Button:** Circular teal add-user button (`+👤`).
- **Bottom Navigation Bar.**

### 3.3 Family Management — Overview (`20:21675`) — Reference Image 3 / Overview
- **Header:** Back arrow, `Family Member` or `Family Dashboard` with avatar and notification bell.
- **Family Ecosystem Bento Card:** Deep purple gradient card with ecosystem metrics, pending consent alert card (`02 Pending Consent Requests`).
- **Dependent Shared Card (`20:22459`):** Premium Care card for `Benjamin Harrison`, blood group `O- Positive (O+)`, DOB `12 May 2018`, allergies `PENICILLIN`, `PEANUTS`, QR code.
- **Insurance Card:** `BlueCross Platinum Plus`, `ACTIVE Exp: 12/2025`.
- **Action Buttons:** `Share with Provider` (purple pill) and `Download Health PDF` (teal outlined pill).
- **Bento Stats:** `Immunizations (12 Up-to-date)` and `Prescriptions (2 Active Refills)`.

### 3.4 Appointment Confirmation (`20:29208`) — Reference Image 4
- **Top Bar:** Back arrow, CareID logo, notification bell.
- **Status Sub-bar:** `APPOINTMENT STATUS` with teal checkmark and `X` close button.
- **Hero Success Block:** Purple circular checkmark badge with sparkles, `Appointment Booked!`, subtitle, `# CONFIRMATION #APT-88204-NY` badge.
- **Digital Care Pass Card:** Dark purple header with `● ACTIVE` pill, Doctor photo, `Dr. Sarah Jenkins, MD`, `Department of Cardiology`, Date & Time pills, Location block, `In-Person Consultation (45 Min)` badge.
- **Arrival & Next Steps Guide:** Step 1 `Digital Pass Created`, Step 2 `Fast Arrival Registration`, Step 3 `Device Calendar` with `+ Add to Calendar` button.
- **Action Buttons:** `View Appointment Details ->` (purple solid button), `Return to Home` (lavender outlined button).
- **Bottom Navigation Bar:** Doctor tab highlighted.

---

## 4. Shared Components Specification

| Component | Standard Specifications from Approved Figma Frames |
|---|---|
| **Page App Bar** | Height 64dp, white/subtle background, 40×40 back button, centered page title (18-20sp bold, `#0F172A` / `#2E006A`), 40×40 trailing action (bell / close). |
| **Section Headings** | 14-16sp bold `#475569` or `#334155`, uppercase or title case, 16dp top margin, 8dp bottom margin. |
| **Settings Tile Group** | White card (`#FFFFFF`), borderRadius 16-20dp, border `#F1F5F9`, 1dp divider lines `#F1F5F9`, 76dp row height, leading colored icon in 36×36 container, 15sp title `#0F172A`, 12sp subtitle `#64748B`, trailing chevron. |
| **Primary Button** | 44-52dp height, `#5B14B8` or `#2E006A`, borderRadius 12-24dp (pill or rounded rect), 14-15sp bold white text. |
| **Secondary Button** | 44-52dp height, white or `#F3F4F6` background, border `#00BFA5` or `#E2E8F0`, 14-15sp bold text. |
| **Bottom Navigation** | 75dp height, 5 items (Home, Records, Floating 56×56 QR button, Doctor/Family, Profile), cyan/teal highlight pill on active tab (`#A5F3FC` / `#00BFA5`). |

---
*Report generated for CareID Patient App UI Audit.*

