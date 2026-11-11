# CareID Patient App — Physical Device Verification & Release Installation Report

**Project:** `C:\Users\PABANI\CareID_patient_app`  
**Physical Target Device:** Xiaomi Redmi 8A Dual (`9e7ed35c0007`)  
**OS:** Android  
**Date:** October 31, 2026  
**Status:** INSTALLED & VERIFIED  

---

## 1. Build Verification

- **Command:** `flutter build apk --release`
- **Exit Code:** `0` (Success)
- **Compilation Time:** 49.8 seconds
- **Generated Release APK Path:** `C:\Users\PABANI\CareID_patient_app\build\app\outputs\flutter-apk\app-release.apk`
- **Generated File Size:** **58.2 MB** (`61,029,480 bytes`)

---

## 2. Physical Device Connection & ADB Status

- **Command:** `adb devices -l`
- **Output:**
  ```text
  List of devices attached
  9e7ed35c0007           device product:olivewood model:Redmi_8A_Dual device:olivewood transport_id:7
  ```
- **Device Hardware Model:** Xiaomi Redmi 8A Dual (`olivewood`)

---

## 3. Installation Execution

- **Command:** `adb -s 9e7ed35c0007 install -r build\app\outputs\flutter-apk\app-release.apk`
- **Output:**
  ```text
  Performing Streamed Install
  Success
  ```
- **Installation Result:** **SUCCESS**

---

## 4. App Launch & Runtime Verification

- **Launch Command:** `adb -s 9e7ed35c0007 shell am start -n com.careid.careid_patient_app/com.careid.careid_patient_app.MainActivity`
- **Output:**
  ```text
  Starting: Intent { cmp=com.careid.careid_patient_app/.MainActivity }
  ```
- **Screenshot Capture:** Pulled to `artifacts/device-qa/careid_verified_screen.png`.
- **Logcat Inspection:** `adb logcat -d -t 150 *:E` confirmed **0 startup crashes** and **0 Flutter runtime exceptions**.
- **Visual Checks on Physical Device:**
  1. Bottom navigation bar active tab uses the approved `#00BFA5` aqua highlight.
  2. Profile & Settings header renders centered title, left-aligned logo/back button, and right-aligned settings/language buttons with balanced spacing.
  3. Logo rendering preserves natural `4.64:1` aspect ratio without distortion or clipping.

