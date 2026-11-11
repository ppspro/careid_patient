# CareID Patient App — Central Floating QR Button & Expandable Action Menu Implementation Report

**Document ID:** `docs/final_audit/28_floating_qr_action_menu_implementation.md`  
**Date:** November 4, 2026  
**Figma Canvas:** `17:55` — `Careid patient app`  
**Figma Reference Frames:**  
- `20:19764`: Bottom Nav Bar (Mobile)  
- `20:19790`: Floating Action Button (Elevated Central CareID QR Trigger)  
- `20:19873` / `20:22771`: Digital Health Card QR Verification  
- `20:32268` / `20:32321`: Document Scanner & OCR Intake  
**Backend:** `https://360api.vnvision.in` (CareID Staging API)  
**Connected Physical Device:** Xiaomi Redmi 8A Dual (`9e7ed35c0007`), Android 10  
**Package:** `com.careid.careid_patient_app`  
**Release APK:** `build/app/outputs/flutter-apk/app-release.apk` (58.5 MB)  
**Verification Status:** **100% VERIFIED ON PHYSICAL HARDWARE**

---

## 1. Executive Summary & Root Cause Analysis

### The Issue
Previous iterations showed an empty 72px dead gap in the bottom navigation bar between the "Records" and "Doctor" items. This occurred because a placeholder gap was erroneously inserted in place of the floating center button.

### The Solution
1. **Restored the Central Floating QR Button:** Reinstated the elevated circular button (`52x52`) matching Figma `20:19790`, featuring a rich purple gradient (`#5B14B8` to `#3F1D8B`), a 3.5px white border, and a 12px blur drop shadow.
2. **Expandable Floating Action Menu:** Tapping the center button smoothly reveals two floating action bubbles with scale and fade animations:
   - **Action 1: Scan Health Card** (Figma `20:19873` / `20:22771`) — Opens the camera QR scanner for real-time verification of CareID credentials against `POST /api/v1/health-cards/verify-qr`.
   - **Action 2: Scan Medical Document (OCR)** (Figma `20:32268` / `20:32321`) — Opens medical document camera/gallery OCR intake, extracting structured fields (Diagnosis, Facility, Physician, Care Plan) and saving directly to the CareID Vault via `POST /api/v1/medical-records`.
3. **Intuitive Dismissal & UX Mechanics:**
   - Animated rotation of the central icon from QR scanner (`Icons.qr_code_scanner_rounded`) to close (`Icons.close_rounded`).
   - Semi-transparent scrim backdrop (`#0F172A` with 45% opacity) that dismisses the menu on tap.
   - Android hardware/gesture Back button dismisses the menu via `PopScope(canPop: !_isMenuExpanded)`.
   - Switching any of the 4 primary tabs (Home, Records, Doctor, Profile) immediately collapses the menu.

---

## 2. Modified & Created Files

| File | Type | Purpose |
|---|---|---|
| `lib/shared/widgets/careid_bottom_navigation_bar.dart` | Modified | Restored central floating button, added `isMenuExpanded`, `showCenterButton`, animated rotation & gradient |
| `lib/features/patient/presentation/screens/patient_main_navigation_shell.dart` | Modified | Integrated `AnimationController`, backdrop scrim, floating action bubbles, back navigation, route transitions |
| `lib/features/patient/presentation/screens/scan_health_card_qr_screen.dart` | Created | Camera QR viewfinder, laser animation, live credential verification against `/api/v1/health-cards/verify-qr` |
| `lib/features/patient/presentation/screens/scan_medical_document_ocr_screen.dart` | Created | Document camera/gallery OCR intake, category selection, editable fields, direct vault creation via `/api/v1/medical-records` |
| `lib/app.dart` | Modified | Registered named routes `/scan-health-card`, `/scan-document`, and `/dashboard-qr-menu` |
| `test/features/patient/floating_qr_expandable_menu_widget_test.dart` | Created | Automated widget tests validating button presence, menu expansion, bubble taps, and backdrop dismissal |

---

## 3. Physical Hardware QA & Screen Captures

| Verification View | Description | Status |
|---|---|---|
| **Collapsed Navbar with Central Floating QR** | Elevated purple QR button centered symmetrically between Records and Doctor | **VERIFIED** |
| **Expanded Action Menu** | Two action bubbles ("Scan Health Card" and "Scan Medical Document (OCR)") above dim scrim | **VERIFIED** |
| **Scan Health Card Screen** | Full-screen HUD scanner with laser scanning bar and live credential validation | **VERIFIED** |
| **Scan Medical Document (OCR) Screen** | Camera & gallery OCR intake with categorized field extraction and Vault sync | **VERIFIED** |

---

## 4. Verification Suite Results

```bash
# 1. Static Analysis
flutter analyze
# Result: No issues found! (ran in 1.3s)

# 2. Automated Test Suite
flutter test
# Result: 00:17 +176: All tests passed!

# 3. Production Release Build
flutter build apk --release
# Result: Built build/app/outputs/flutter-apk/app-release.apk (58.5MB in 57.5s)

# 4. Device Installation
adb -s 9e7ed35c0007 install -r build/app/outputs/flutter-apk/app-release.apk
# Result: Performing Streamed Install -> Success
```

