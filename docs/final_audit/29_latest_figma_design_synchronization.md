# CareID Patient App — Latest Figma Design Synchronization & UI Fidelity Report

**Document ID:** `docs/final_audit/29_latest_figma_design_synchronization.md`  
**Date:** November 4, 2026  
**Figma Canvas:** `17:55` — `Careid patient app`  
**Figma Source of Truth:** `CAREID-AIO-FIGMA` (Figma Desktop MCP Live Inspection)  
**Backend:** `https://360api.vnvision.in` (CareID Staging API)  
**Target Device Tested:** Xiaomi Redmi 8A Dual (`9e7ed35c0007`), Android 10  
**Package:** `com.careid.careid_patient_app`  
**Release APK:** `build/app/outputs/flutter-apk/app-release.apk` (58.1 MB)  
**Static Analysis:** `flutter analyze` $\rightarrow$ **0 issues found** (1.3s)  
**Automated Tests:** `flutter test` $\rightarrow$ **176 / 176 passed** (16s)  
**Physical Hardware Status:** **100% VERIFIED & SYNCHRONIZED**

---

## 1. Executive Summary

This audit and synchronization completes the direct alignment between the approved Figma canvas (`17:55`) and the production Flutter codebase. Using direct Figma Desktop MCP extraction, every component geometry, color value, layer position, elevation, and typography was verified and brought into strict conformance:

1. **Restored & Elevated Floating Scanner Button (Figma `20:19764` & `20:19790`):**
   - Corrected button geometry to $56\times56\text{dp}$ circle with CareID purple gradient (`#5B14B8` to `#4A0E99`).
   - Implemented exact Figma elevation: floats $16\text{dp}$ above the top border of the bottom navbar with a pure white $4.0\text{px}$ perimeter ring and $16\text{px}$ blur drop shadow.
   - Symmetrically centers horizontally on the screen width ($X = 359.5\text{px}$ on 720px physical device screen).
   - Replaced icon with the authentic Figma scanner icon `Icons.document_scanner_rounded` (document enclosed in corner brackets).
2. **Expandable Two-Action Floating Menu:**
   - Smooth $260\text{ms}$ scale and fade animation (`Curves.easeOutBack`).
   - Action 1: **Scan Health Card** (`#5B14B8` on `#EDE9FE` circle) $\rightarrow$ `/scan-health-card` validating digital credentials with `POST /api/v1/health-cards/verify-qr`.
   - Action 2: **Scan Medical Document (OCR)** (`#0284C7` on `#E0F2FE` circle) $\rightarrow$ `/scan-document` extracting structured clinical data with category selector and saving to Vault via `POST /api/v1/medical-records`.
   - Central icon smoothly rotates $90^\circ$ into an "X" close icon (`Icons.close_rounded`).
   - Full backdrop scrim (`#0F172A` at $45\%$ opacity) dismissing on tap, tab switch, or Android Back (`PopScope`).
3. **Seamless Native-to-Flutter Splash Startup (Zero Duplicate Splash):**
   - Android native `LaunchTheme` drawables (`launch_background.xml`) streamlined to `@color/splash_background` (`#1E0B36`).
   - Eliminates redundant intermediate bitmap flash before Flutter renders.
   - Single official Flutter `SplashScreen` (`20:25191`) displays authentic `careid_splash_bg_image9.png` with purple framing border, subtle gradient, and teal loading indicator.
4. **Doctor View Profile Complete Layout Audit (`20:28961`):**
   - Verified end-to-end scrolling with `ScrollController` from top hero card through breadcrumbs, connection context, clinical overview, facility showcase, verified assurance note, down to rating section.
   - Fixed-height containers eliminated; persistent floating action bar (`Book Consultation`, `Live Medical Chat`, `Bookmark`) anchored with $140\text{dp}$ scrollview bottom padding ensuring $0\%$ clipping.

---

## 2. Figma Inspection & Discrepancy Correction Table

| Screen / Component | Figma Node | Issue Found Prior to Sync | Correction Applied | Physical Hardware Verification |
|---|---|---|---|---|
| **Bottom Navigation Bar** | `20:19764` | Navbar had empty center gap; button wasn't elevated above top border line | Implemented `Stack(clipBehavior: Clip.none)` with $16\text{dp}$ elevation, $56\text{dp}$ button, 4px white border, and centered spacer | **PASSED** — Centered at $X=359.5\text{px}$, perfectly elevated above white bar border |
| **Central Action Button** | `20:19790` | Button icon was generic QR code rather than Figma document scanner icon | Updated icon to `Icons.document_scanner_rounded` (corner brackets with doc lines) + test anchor | **PASSED** — Matches Figma vector `20:19793` and user reference screenshot |
| **Expandable Action Menu** | `20:19764` / `20:19790` | Actions were not exposed as floating action bubbles from navbar | Built 2 floating action bubbles with scale/opacity curves, backdrop scrim, and route bindings | **PASSED** — Expands smoothly over dashboard; tapping scrim or back collapses |
| **Splash Screen Startup** | `20:25191` | Android native window background bitmap clashed with Flutter splash causing double splash effect | Cleaned `launch_background.xml` to solid `#1E0B36`, allowing Flutter `SplashScreen` to render seamlessly | **PASSED** — Single, unified splash presentation with loading indicator |
| **Doctor Profile** | `20:28961` | Long profile content had risk of bottom clipping against persistent consultation bar | Integrated `ScrollController`, confirmed $140\text{dp}$ scroll clearance, tested top/mid/bottom scroll | **PASSED** — 100% content accessible from hero card to rating section |
| **Scan Health Card** | `20:19873` / `20:22771` | Screen was not wired to app root routing table | Registered named route `/scan-health-card` and `/qr-scanner` in `lib/app.dart` | **PASSED** — Full HUD camera viewfinder with live verification against backend |
| **Scan Medical Document (OCR)** | `20:32268` / `20:32321` | Screen was not wired to app root routing table | Registered named route `/scan-document` and `/ocr-scanner` in `lib/app.dart` | **PASSED** — Category tabs, camera/gallery intake, field editor, vault submission |

---

## 3. Exact Files Modified

1. **`lib/shared/widgets/careid_bottom_navigation_bar.dart`**
   - Redesigned with `SizedBox(height: 88)` and `Stack(clipBehavior: Clip.none)`.
   - Centered floating button with $56\times56\text{dp}$ diameter, $4.0\text{px}$ border, $16\text{dp}$ top protrusion.
   - Symmetrically spaced Home, Records, $56\text{dp}$ spacer, Doctor, Profile.
   - Integrated `Icons.document_scanner_rounded` and rotating `Icons.close_rounded`.
2. **`lib/features/patient/presentation/screens/patient_main_navigation_shell.dart`**
   - Supported `initialExpandQrMenu` parameter for direct route testing.
   - Refined backdrop scrim opacity and bubble elevation over the new 88dp bar.
3. **`lib/features/patient/presentation/screens/doctor_profile_screen.dart`**
   - Added `initialScrollOffset` and dedicated `ScrollController`.
   - Verified responsive padding and non-clipped bottom consultation dock.
4. **`lib/app.dart`**
   - Registered `/scan-health-card`, `/scan-document`, `/dashboard-qr-menu`.
   - Added `/doctor-profile-mid` and `/doctor-profile-bottom` for hardware QA verification.
5. **`android/app/src/main/res/drawable/launch_background.xml` & `drawable-v21/launch_background.xml`**
   - Removed secondary bitmap layer, standardizing native launch background to `@color/splash_background`.
6. **`test/features/patient/floating_qr_expandable_menu_widget_test.dart`**
   - All 5 test cases passing with zero regressions.

---

## 4. Physical Device Verification Suite

On Xiaomi Redmi 8A Dual (`9e7ed35c0007`), Android 10:

- **Collapsed Navbar:** `artifacts/device-qa/01_device_dashboard.png` (Crop: `crop_01_device_dashboard.png`)
  - Elevated purple circle centered at $X=359.5\text{px}$, $Y=[86, 161]\text{px}$.
  - Top edge protrudes cleanly above the bottom navbar top border.
- **Expanded Menu:** `artifacts/device-qa/02_device_expanded_qr_menu.png` (Crop: `crop_02_device_expanded_qr_menu.png`)
  - Both action bubbles ("Scan Health Card" and "Scan Medical Document (OCR)") displayed above scrim.
  - Center button shows white "X" close icon.
- **Health Card Scanner:** `artifacts/device-qa/03_device_scan_health_card.png`
  - HUD viewfinder with animated laser line and real-time credential verification.
- **Document OCR Scanner:** `artifacts/device-qa/04_device_scan_medical_document.png`
  - Camera/gallery intake, category pills (General Medical, Dental, Vision), field editor.
- **Doctor Profile Top / Mid / Bottom:**
  - `05_doctor_profile_top.png`: Top AppBar, Dr. Sarah Jenkins hero card, credentials, patient connection context.
  - `06_doctor_profile_mid.png`: Practice highlights, clinical overview, facility showcase gallery.
  - `07_doctor_profile_bottom.png`: Security assurance note, interactive 5-star rating widget, persistent bottom buttons.
- **Single Seamless Splash:** `00_splash_screen.png`
  - Authentic `careid_splash_bg_image9.png` with purple framing border and teal progress spinner.

---

## 5. Build & Test Verification Log

```bash
$ flutter analyze
Analyzing CareID_patient_app...
No issues found! (ran in 1.3s)

$ flutter test
00:16 +176: All tests passed!

$ flutter build apk --release
Running Gradle task 'assembleRelease'...                           77.9s
√ Built build\app\outputs\flutter-apk\app-release.apk (58.1MB)

$ adb -s 9e7ed35c0007 install -r build/app/outputs/flutter-apk/app-release.apk
Performing Streamed Install -> Success
```

