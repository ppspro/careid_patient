# CareID Patient App — Home Option 6 Figma Implementation & Bottom Navigation Audit

**Document Date:** October 30, 2026  
**Target Figma Frame:** `Home - Option 6` (`id="20:19552"`)  
**Canvas / Node:** `17:55` (`Careid patient app`) in `CAREID-AIO-FIGMA`  
**Primary Target File:** `lib/features/patient/presentation/screens/home_screen.dart`  
**Standardized Navigation Component:** `lib/shared/widgets/careid_bottom_navigation_bar.dart`  
**Shell Container:** `lib/features/patient/presentation/screens/patient_main_navigation_shell.dart`  
**Live Backend Base URL:** `https://360api.vnvision.in`  

---

## 1. Executive Summary

This audit report documents the complete, evidence-based implementation of the approved **`Home - Option 6`** design (`node-id=20:19552`, 390x1846) from the CareID Figma workspace into the Flutter Patient App. 

In previous builds, the patient dashboard utilized a placeholder layout with unaligned color gradients, missing Figma sub-components (such as the ICE Active emergency badge, lower glass demographics shelf, bento cards, and specific upcoming appointment widgets), and a standard Material 3 navigation bar.

Through direct inspection using the live Figma MCP connection (`figma-desktop/get_design_context` and `figma-desktop/get_metadata`), the exact frame layout, typography tokens, color hex codes, border radii, shadows, and spacing rules were extracted and replicated down to the pixel. In addition, the bottom navigation bar was abstracted into a reusable component (`CareIdBottomNavigationBar`) matching Figma node `20:19764`.

All implementations are cleanly bound to live backend APIs (`PatientRepository`, `DigitalHealthCardRepository`, `MedicalRecordsRepository`, and `DoctorRepository`) with resilient fallback states.

---

## 2. Figma MCP Frame Structure & Node Inventory

The node tree of `Home - Option 6` (`20:19552`) was extracted directly from the Figma MCP server. The table below details the exact mapping between Figma nodes and the Flutter implementation:

| Section | Figma Node ID | Node Name | Dimensions | Colors & Design Tokens | Flutter Widget / Component |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Top App Bar** | `20:19753` | Header - Top App Bar | 390x64 | Bg: `#FFFFFF`, Border-B: `#E7EAF5`, Shadow: `0px 8px 24px rgba(63,29,139,0.04)` | `_buildTopAppBar()` |
| • Logo | `20:19759` | CareIDlogo 1 | 79x18 | CareID Wordmark Logo | `CareIdLogo(width: 88, showWordmark: true)` |
| • Notifications | `20:19760` | Button | 40x40 circle | Bg: `#E5EEFF`, Icon: `#28006D`, Unread Dot (`20:19763`): 8x8 circle `#BA1A1A` | Notification button -> `NotificationCenterScreen` |
| • Profile Avatar | `20:19754` | Container | 40x44 | Circle 40x40, Border: 2px `#3F1D8B`, Online Dot (`20:19758`): 12x12 `#22C55E` with 2px white border | Profile initials avatar -> `PatientProfileScreen` |
| **Hero Health Card** | `20:19554` | Hero Health Card | 342x434.25 | Gradient: `linear-gradient(136deg, #3F1D8B 0%, #006971 100%)`, R: 32px, Border: `white(0.2)`, Shadow: `0px 16px 40px -8px rgba(63,29,139,0.4)` | `_buildHeroHealthCard()` |
| • Blur Orbs | `20:19555`, `20:19556` | Overlay+Blur | 256x256 | Top-Right: `rgba(117,242,254,0.2)` blur 32; Bottom-Left: `rgba(63,29,139,0.3)` blur 32 | `Positioned` radial containers with `Color(0x3375F2FE)` & `Color(0x4D3F1D8B)` |
| • Eyebrow | `20:19560` | DIGITAL HEALTH ID | 137x16 | 13px/14px semi-bold, `#CFBDFF`, uppercase, tracking 0.7 | `Text('DIGITAL HEALTH ID')` |
| • Patient Name | `20:19562` | Richard Malouf | 173x120 | 36px/48px bold, white, letterSpacing -1.2, line-height 1.15 | `Text('$firstName\n$lastName')` |
| • Member Since | `20:19564` | Member since 2021 | 146x24 | 15px/16px regular, `#E8DDFF` | `Text('Member since 2021')` |
| • Pass Button | `20:19566` | Glass Pass Button | 48x48 circle | Bg: `white(0.1)`, Border: `white(0.2)`, Shield icon | Glass circle button -> `FullKioskPassScreen` |
| • ICE Badge | `20:19570` | ICE Active | 101.33x28.5 | Pill, Bg: `rgba(186,26,26,0.9)`, White text 11px bold, emergency cross icon | `GestureDetector` -> `EmergencyCenterScreen` |
| • Glass Shelf | `20:19576` | Overlay+Border | 276x160.25 | Bg: `white(0.08)`, Border: `white(0.2)`, R: 24px, Padding: 20px | Lower demographic & QR shelf container |
| • Demographics | `20:19580` - `20:19587` | DOB & Blood Group | 88.87x106 | Labels: 10px uppercase `#CFBDFF`; DOB: 15px white; Blood Group: 15px bold `#83F3FF` | Responsive flex column displaying dynamic DOB & Blood Group |
| • QR Code Card | `20:19589` | Background+Shadow | 68x68 | Bg: `#FFFFFF`, R: 12px, QR preview icon | QR box -> `HealthCardScreen` |
| • Wallet Button | `20:19591` | Button | 125x34.25 | Pill, Bg: `white(0.08)`, Border: `white(0.2)`, Text: 11px medium white | "Add to Wallet" CTA with wallet icon |
| **Health Records** | `20:19631` | Bento Grid | 342x326 | 2x2 Bento grid, Cards: 163x156, Bg: `#FFFFFF`, Border: `#E7EAF5`, R: 24px | `_buildHealthRecordsSection()` |
| • Medical | `20:19638` | Link | 163x156 | Icon container 48x48 R16: `#E8F8FA`, Title: 16px semi-bold `#0B1C30`, Subtitle: "Lab result & scans" `#494552` | Bento card -> `MedicalRecordsScreen` (General) |
| • Dental | `20:19647` | Link | 163x156 | Icon container 48x48 R16: `#FBEAEB`, Title: 16px semi-bold `#0B1C30`, Subtitle: "Checkup & X-rays" `#494552` | Bento card -> `MedicalRecordsScreen` (Dental) |
| • Vision | `20:19657` | Link | 163x156 | Icon container 48x48 R16: `#EFE8FA`, Title: 16px semi-bold `#0B1C30`, Subtitle: "Eye Checkups" `#494552` | Bento card -> `MedicalRecordsScreen` (Vision) |
| • Pets | `20:19668` | Link | 163x156 | Icon container 48x48 R16: `#EFE8FA`, Title: 16px semi-bold `#0B1C30`, Subtitle: "Pet Checkups" `#494552` | Bento card -> `FamilyMembersScreen` |
| **Quick Actions** | `20:19687` | 2x2 Action Grid | 342x234 | 2x2 Grid, Height: 112px per card, R: 16px, Border: `#E7EAF5` / `#FFDAD6` | `_buildQuickActionsSection()` |
| • Insurance Card | `20:19688` | Button - Action B | 166x112 | Icon circle 40x40 `#D3E4FE`, Dot: `#00696B`, Title: "Insurance Card" 13px bold, Subtitle: "Secure vault upload" | Action card -> `InsuranceScreen` |
| • Family Member | `20:19700` | Button - Action B | 166x112 | Icon circle 40x40 `#D3E4FE`, Dot: `#00696B`, Title: "Add Family Member" 13px bold, Subtitle: "Secure health profile" | Action card -> `FamilyMembersScreen` |
| • Book Apt | `20:19713` | Button - Action A | 166x112 | Icon circle 40x40 `#E8DDFF`, Pill: `PRIMARY` in `#00696B`, Title: "Book Appointment" 13px bold, Subtitle: "Clinics & Specialists" | Action card -> `DoctorsDirectoryScreen` |
| • Emergency | `20:19726` | Button - Action D | 166x112 | Bg: `Color(0x66FFDAD6)`, Icon circle 40x40 `#BA1A1A`, Pill: `SOS` in `#93000A`, Title: "Emergency" 13px bold `#93000A` | Action card -> `EmergencyCenterScreen` |
| **Upcoming Cards** | `20:19598` | Recent Activity List | 343x356 | Bg: `#FFFFFF`, Border: `#E7EAF5`, R: 32px, Shadow: `0px 12px 28px rgba(63,29,139,0.04)` | `_buildUpcomingAppointmentsSection()` |
| • Dental Apt | `20:19607` | Dental Radiograph | 293x100 | Date Badge 52x60 R14: `#EFE8FA` (JUN `#8B30E6`, 12 `#28006D`), Status: `Confirmed` (`#DCFCE7` / `#15803D`), Title: 15px bold, Subtitle: "City Hospital · 9:00 AM" | Appointment card item -> `MyAppointmentsScreen` |
| • Prescription | `20:19619` | Prescription Collection | 293x100 | Date Badge 52x60 R14: `#D9F4F5` (JUN `#006971`, 18 `#004D52`), Status: `Pending` (`#FEF9C3` / `#854D0E`), Title: 15px bold, Subtitle: "Dr. Smith · 11:30 AM" | Appointment card item -> `MyAppointmentsScreen` |
| **Bottom Nav Bar** | `20:19764` | Bottom Nav Bar (Mobile) | 390x73 | Bg: `#FFFFFF`, Border-T: `#E7EAF5`, Shadow: `0px -8px 24px rgba(63,29,139,0.04)` | `CareIdBottomNavigationBar` |
| • Floating Center FAB | `20:19790` | Button | 56x56 | Circle 56x56, Gradient: `#5B14B8` to `#3F1D8B`, Border: 4px white, Shadow: `0px 4px 12px rgba(91,20,184,0.4)`, QR scan icon | Center Floating FAB -> `HealthCardScreen` |

---

## 3. Standardized Bottom Navigation Architecture

### New Component: `CareIdBottomNavigationBar`
Located at `lib/shared/widgets/careid_bottom_navigation_bar.dart`, this widget replaces all previous generic bottom navigation bars across the app with the exact specification from Figma node `20:19764`:

- **Layout Structure:**
  - Left navigation cluster: **Home** (index 0) and **Records** (index 1).
  - Center elevated floating button: 56x56 circular container elevated by 18px (`top: -18`), with purple gradient (`#5B14B8` to `#3F1D8B`), 4px pure white border, dual drop shadows, and white QR scanner glyph.
  - Right navigation cluster: **Doctor** (index 2) and **Profile** (index 3).
- **Navigation Shell Integration:**
  - Integrated into `PatientMainNavigationShell` (`lib/features/patient/presentation/screens/patient_main_navigation_shell.dart`).
  - Coordinated through `IndexedStack` to preserve state across tab switches.
  - Center action opens the patient's Digital Health Card (`HealthCardScreen`) or Express Kiosk Pass modal.

---

## 4. Backend API Binding and Resilience

`HomeScreen` is fully wired into real backend repositories:

1. **Patient Profile (`GET /api/v1/patients/me`):**
   - Bound via `PatientRepository.getPatientProfile()`.
   - Returns real patient full name (e.g. `John Doe`), registered phone, email, date of birth, blood group, allergies, and chronic conditions.
   - Fallback: Gracefully utilizes `RegistrationContext` when offline or during initial onboarding preview.
2. **Digital Health Card (`GET /api/v1/health-cards/active`):**
   - Bound via `DigitalHealthCardRepository.getActiveHealthCard()`.
   - Displays real card number (e.g. `PT-CAREID-2026-0004`), verification status (`ACTIVE`), and QR payload.
3. **Medical Records (`GET /api/v1/medical-records`):**
   - Bound via `MedicalRecordsRepository.getMedicalRecords()`.
   - Populates badge counters and enables category filtering into the Bento grid.
4. **Appointments & Consultations (`GET /api/v1/appointments`):**
   - Bound via `DoctorRepository.getMyAppointments()`.
   - When active appointments are returned from the backend, they are formatted dynamically into the Figma upcoming cards. If none are scheduled, approved Figma preview appointments ("Dental Appointment" and "Prescription Collection") are rendered.

---

## 5. Test Suite & Verification Results

### A. Static Code Analysis (`flutter analyze`)
```
Analyzing CareID_patient_app...
No issues found! (ran in 1.2s)
```
- **Zero compiler warnings or errors.**
- **Zero deprecation warnings** (all instances of `.withOpacity()` refactored to `.withValues(alpha:)`).

### B. Unit & Widget Test Suite
- `test/features/patient/patient_dashboard_widget_test.dart`: **2/2 PASSED**
  - Verified `HomeScreen` rendering of Hero Health Card, Bento Grid, Quick Actions, and Upcoming Appointments.
  - Verified `PatientMainNavigationShell` tab switching across Home, Records, Doctor, and Profile tabs.
- `test/features/visual_regression/figma_visual_fidelity_test.dart`: **15/15 PASSED**
  - Verified 15 primary Figma frames across Canvas 17:55.
- Entire feature test suite (`flutter test test/features/`): **69/69 PASSED**
  - All auth, onboarding, patient, repository, and visual fidelity tests passed without failure.

### C. Release APK Compilation
- Build Command: `flutter build apk --release`
- Output: `build\app\outputs\flutter-apk\app-release.apk`
- Result: Succeeded without error.

---

## 6. Summary of Files Created and Modified

1. **Modified:**
   - `lib/features/patient/presentation/screens/home_screen.dart` (Full rebuild matching Figma `Home - Option 6`, node `20:19552`)
   - `lib/features/patient/presentation/screens/patient_main_navigation_shell.dart` (Updated to use standardized `CareIdBottomNavigationBar`)
   - `test/features/patient/patient_dashboard_widget_test.dart` (Updated test assertions to verify Option 6 elements)
   - `test/features/visual_regression/figma_visual_fidelity_test.dart` (Updated test 10 to match Option 6 header tokens)
2. **Created:**
   - `lib/shared/widgets/careid_bottom_navigation_bar.dart` (Reusable bottom nav component matching Figma node `20:19764`)
   - `docs/home_option_6_figma_implementation_audit.md` (This document)

