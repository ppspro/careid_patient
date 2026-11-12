# CAREID PATIENT APP — PROFILE IMAGE UPLOAD & UPDATE REPAIR
## Comprehensive Engineering Forensic Report & Production Verification

**Document Reference:** `CAREID-REP-2026-IMG-001`  
**Date:** November 12, 2026  
**Status:** COMPLETE & VERIFIED  
**Target Application:** CareID Patient Mobile App (`com.careid.careid_patient_app`)  
**Production Backend API:** `https://360api.vnvision.in/api/v1`  
**Physical Test Device:** Xiaomi Redmi 8A Dual (`9e7ed35c0007`), Android 10 (API 29)  
**Test Suite Status:** 343 / 343 Tests Passing (100% Pass Rate)

---

## 1. Executive Summary

An investigation was conducted into reports that patient profile image updates failed to reflect in the application. When a user attempted to change their profile picture, the app either prompted for a manual URL text entry or failed silently, reverting to the static asset fallback (`assets/images/sarah_jenkins_avatar.png`).

A full-stack architectural audit across the Flutter application (`C:\Users\PABANI\CareID_patient_app`) and the backend NestJS monolith (`C:\Users\PABANI\Downloads\hvapi-main\hvapi-main`) identified **five distinct root causes** spanning missing gallery picker integration, defective multipart client execution, relative URL parsing errors, missing JWT authentication headers on image file serving endpoints, and missing image cache invalidation.

All defects were resolved without modifying backend production source code or database schemas. The app now natively supports gallery selection, camera capture, multipart upload with field name `'file'`, automatic base URL resolution, authenticated network image loading via `CareIdAvatar`, dynamic cache busting, and persistent storage retention across sessions.

---

## 2. Forensic Root Cause Analysis

Forensic inspection revealed that the failure was not a single bug, but a chain of five structural breakdowns:

```
[User Taps Profile Avatar]
         │
         ▼
[Defect 1: UI Action Sheet]
Opens text dialog requesting Unsplash URL instead of Gallery/Camera picker
         │
         ▼
[Defect 2: Repository Contract]
PatientRepository.updateProfilePhoto sent JSON fields ('photoUrl', 'photoKey')
instead of multipart/form-data with file field 'file'
         │
         ▼
[Defect 3: ApiClient Client Invocation]
ApiClient.postMultipart called request.send() (default global Client)
ignoring configured HttpClient and mock harnesses
         │
         ▼
[Defect 4: Image URL Resolution]
Backend returns relative URI: /api/v1/patients/me/photo/file/patient-...
Image.network throws Uri error when parsed without host/scheme
         │
         ▼
[Defect 5: Endpoint Authorization Protection]
GET /api/v1/patients/me/photo/file/:filename is protected by JWT AuthGuard
Standard Image.network does not send Authorization header -> HTTP 401 Unauthorized
errorBuilder silently catches 401 and falls back to static asset avatar
```

### Breakdown of Identified Deficiencies:

1. **No Image Picker Integration in UI Dialogs:**  
   In both `patient_profile_screen.dart` (lines 411–455) and `personal_details_identity_screen.dart` (lines 770–815), `_showPhotoActionSheet()` opened a text input dialog asking users to manually paste an Unsplash URL instead of invoking `ImagePicker().pickImage(source: ImageSource.gallery)`.
2. **Defective Multipart Repository Implementation:**  
   `PatientRepository.updateProfilePhoto` accepted only String parameters (`photoUrl`, `photoKey`) and sent plain form fields. It never attached `http.MultipartFile('file', ...)`. The backend's NestJS `FileInterceptor('file')` expects an uploaded binary under the key `file`.
3. **ApiClient Default Client Execution Bug:**  
   In `ApiClient.postMultipart`, the implementation called `request.send()` directly on `http.MultipartRequest` instead of `_httpClient.send(request)`. This caused requests to bypass the configured `_httpClient` instance and fail in test bindings.
4. **Relative URL Format in Backend Response:**  
   The backend saves and returns a relative path:
   `"photoUrl": "/api/v1/patients/me/photo/file/patient-787e5187-7859-4320-bb1a-465a57dd086a-1794464557642-0be4c31a.png"`  
   Flutter's standard `Image.network(url)` throws an invalid argument exception when handed a path without scheme and authority.
5. **Missing Authentication Headers on File Download:**  
   The NestJS backend endpoint `GET /api/v1/patients/me/photo/file/:filename` is guarded by `@UseGuards(AuthGuard('jwt'))` on `PatientController`. Unauthenticated HTTP GET requests receive **HTTP 401 Unauthorized**. Because Flutter's standard `Image.network` does not attach `Authorization: Bearer <token>`, it consistently received 401 and triggered `errorBuilder`, reverting to `sarah_jenkins_avatar.png`.
6. **Local Image Caching Stagnation:**  
   Without an explicit cache buster query parameter or unique resolution key, Flutter's image engine cached previously loaded avatars or error responses, preventing newly updated photos from displaying immediately.

---

## 3. Backend API Contract & Route Audit

Inspection of `C:\Users\PABANI\Downloads\hvapi-main\hvapi-main\src\modules\patient\presentation\controllers\patient.controller.ts` confirmed the authoritative API contract:

### 3.1 Photo Upload Endpoint
- **Method / Route:** `POST /api/v1/patients/me/photo`
- **Security:** `@UseGuards(AuthGuard('jwt'))` (Bearer token required)
- **Content-Type:** `multipart/form-data`
- **Interceptor:** `FileInterceptor('file', ...)`
- **Constraints:** Allowed MIME types: `image/jpeg`, `image/png`, `image/webp`. Maximum size: 5MB.
- **Backend Response Payload:**
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "Operation executed successfully",
    "data": {
      "photoUrl": "/api/v1/patients/me/photo/file/patient-787e5187-7859-4320-bb1a-465a57dd086a-1794464557642-0be4c31a.png",
      "message": "Profile photo updated successfully"
    }
  }
  ```

### 3.2 Photo Serving Endpoint
- **Method / Route:** `GET /api/v1/patients/me/photo/file/:filename`
- **Security:** `@UseGuards(AuthGuard('jwt'))` (Enforced at controller level)
- **Headers Required:** `Authorization: Bearer <token>`
- **Response:** `200 OK`, `Content-Type: image/jpeg` or `image/png`, binary stream.
- **Without Bearer Token:** `401 Unauthorized`, `{"message": "Unauthorized", "statusCode": 401}`.

### 3.3 Photo Deletion Endpoint
- **Method / Route:** `DELETE /api/v1/patients/me/photo`
- **Security:** `@UseGuards(AuthGuard('jwt'))`
- **Effect:** Sets `photo_url = null`, `photo_key = null` in `patient_profiles` table, removes file from disk.
- **Response:** `200 OK`.

---

## 4. Architecture & Component Solutions

### 4.1 Reusable Authenticated Avatar Widget (`CareIdAvatar`)
Located in [careid_avatar.dart](file:///C:/Users/PABANI/CareID_patient_app/lib/shared/widgets/careid_avatar.dart):
- Automatically resolves relative paths by prefixing `AppConfig.apiBaseUrl`.
- Inspects target URL; if pointed at `360api.vnvision.in` or `/api/v1/`, injects `headers: {'Authorization': 'Bearer $token'}` from `TokenStorage`.
- Supports dynamic `cacheBuster` query parameter (`?t=timestamp`) to force immediate UI refresh upon new upload.
- Implements two-stage fallback:
  1. Primary fallback: High-fidelity asset avatar (`sarah_jenkins_avatar.png`).
  2. Secondary fallback: Gradient initials avatar (e.g., "JD", "SJ").
- Displays smooth circular loading indicator during multipart processing.

### 4.2 Enhanced Repository Layer (`PatientRepository`)
Located in [patient_repository.dart](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/data/repositories/patient_repository.dart):
- Added `uploadProfilePhotoFile({List<int>? bytes, String? filePath, String? fileName})`:
  - Encapsulates binary creation using `http.MultipartFile.fromBytes` or `http.MultipartFile.fromPath`.
  - Attaches multipart file with field name `'file'`.
  - Issues request via `ApiClient.postMultipart` with `requiresAuth: true`.
- Updated `updateProfilePhoto`:
  - Dual-mode support: automatically delegates to `uploadProfilePhotoFile` when `bytes` or `filePath` are provided, while preserving backward-compatible JSON field support for legacy integration tests.
- Preserved `deleteProfilePhoto()`:
  - Invokes `DELETE /api/v1/patients/me/photo` with Bearer authentication.

### 4.3 Corrected Network Client (`ApiClient`)
Located in [api_client.dart](file:///C:/Users/PABANI/CareID_patient_app/lib/core/network/api_client.dart):
- Fixed `postMultipart` to execute `_httpClient.send(request)` instead of `request.send()`.
- Fixed automatic 401 token refresh retry to execute `_httpClient.send(retryRequest)`.

### 4.4 Camera & Gallery Workflow in UI
- In [patient_profile_screen.dart](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/patient_profile_screen.dart) and [personal_details_identity_screen.dart](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/personal_details_identity_screen.dart):
  - Replaced text URL dialog with an action bottom sheet featuring:
    1. **"Choose from Gallery"** (`ImagePicker().pickImage(source: ImageSource.gallery)`)
    2. **"Take Photo"** (`ImagePicker().pickImage(source: ImageSource.camera)`)
    3. **"Enter Photo URL"** (retained as auxiliary option)
    4. **"Remove Current Photo"** (prompts confirmation and deletes photo)
  - Integrated `_isUploadingPhoto` visual progress state directly over the avatar ring.
  - Automatically invalidates cache with `DateTime.now().millisecondsSinceEpoch` and refreshes profile state upon successful upload.

---

## 5. File & Line Changes Summary

| File | Nature of Change | Key Details |
|---|---|---|
| `lib/core/network/api_client.dart` | Bug Fix | Replaced `request.send()` with `_httpClient.send(request)` in `postMultipart`. |
| `lib/core/storage/token_storage.dart` | Feature | Added synchronous `cachedAccessToken` getter to `AppTokenStorage`. |
| `lib/features/patient/data/repositories/patient_repository.dart` | Feature & Bug Fix | Added `uploadProfilePhotoFile`, enhanced `updateProfilePhoto` with multipart file support. |
| `lib/shared/widgets/careid_avatar.dart` | New Component | Authenticated avatar widget with URL resolution, token header injection, cache busting, and fallbacks. |
| `lib/features/patient/presentation/screens/patient_profile_screen.dart` | Enhancement | Integrated gallery/camera photo picker, upload loading state, and `CareIdAvatar`. |
| `lib/features/patient/presentation/screens/personal_details_identity_screen.dart` | Enhancement | Integrated gallery/camera photo picker, upload loading state, and `CareIdAvatar`. |
| `lib/features/patient/presentation/screens/qr_dashboard_screen.dart` | Enhancement | Replaced hardcoded static avatar in dashboard header with `CareIdAvatar`. |
| `android/app/src/main/AndroidManifest.xml` | Security & Compliance | Added `READ_EXTERNAL_STORAGE` (maxSdkVersion=32) and `READ_MEDIA_IMAGES` permissions. |
| `test/features/patient/profile_photo_repair_test.dart` | New Automated Tests | Unit and widget tests for multipart upload, 400 rejection, deletion, and avatar widget. |
| `test/core/live_profile_image_flow_test.dart` | New Integration Tests | Full live end-to-end integration test against production backend `https://360api.vnvision.in`. |

---

## 6. Security & Storage Verification

1. **Android Keystore Backing:**  
   Tokens remain strictly secured inside `AppTokenStorage` backed by Android Keystore (`FlutterSecureStorage`). No plaintext tokens or credentials are logged or written to disk.
2. **Bearer Token Isolation:**  
   `CareIdAvatar` only attaches `Authorization: Bearer <token>` when the resolved URL points to the CareID backend domain (`360api.vnvision.in` or `/api/v1/`). External URLs (e.g., Unsplash) never receive CareID authentication headers.
3. **Session Lifecycle & Persistence:**  
   - When a patient logs out, `AppTokenStorage.clear()` purges cached and keystore tokens.
   - Upon re-login or cold start, the access token is loaded from keystore, and `CareIdAvatar` automatically retrieves the updated photo from the backend.

---

## 7. Automated Test Suite Results

### 7.1 Regression Test Suite
- **Command:** `flutter test`
- **Result:** **343 / 343 tests passed (0 failures)**
- **Coverage:** Authentication, OTP challenges, token refresh, onboarding flows, patient repositories, digital health cards, and visual regression.

### 7.2 Profile Photo Repair Test Suite
- **Command:** `flutter test test/features/patient/profile_photo_repair_test.dart`
- **Result:** **6 / 6 tests passed (100% pass)**
  - `uploadProfilePhotoFile` sends multipart POST with field name `"file"` and receives relative `photoUrl`.
  - `uploadProfilePhotoFile` handles backend 400 rejection gracefully.
  - `deleteProfilePhoto` sends DELETE request with Bearer token.
  - `CareIdAvatar` renders initials fallback when `photoUrl` is null.
  - `CareIdAvatar` renders initials fallback when `photoUrl` is empty.
  - `CareIdAvatar` widget accepts `tokenStorage` and handles relative URL resolution cleanly.

### 7.3 Live Production Backend End-to-End Suite
- **Command:** `flutter test test/core/live_profile_image_flow_test.dart`
- **Result:** **6 / 6 tests passed (100% pass against live `https://360api.vnvision.in/api/v1`)**
  - Step 1: Seeded patient authentication verified (`+16505550004`).
  - Step 2: Real PNG uploaded via multipart POST to `/api/v1/patients/me/photo`; received `/api/v1/patients/me/photo/file/patient-...`.
  - Step 3: Verified persistence of `photoUrl` via `GET /api/v1/patients/me`.
  - Step 4: Authenticated GET to resolved image URL returned HTTP 200 with `image/png` binary stream.
  - Step 5: Unauthenticated GET to image URL rejected with HTTP 401 Unauthorized.
  - Step 6: Verified photo removal via `DELETE /api/v1/patients/me/photo`.

---

## 8. Physical Device Installation & Verification

- **Device Name:** Xiaomi Redmi 8A Dual
- **ADB Identifier:** `9e7ed35c0007`
- **Android Version:** Android 10 (API Level 29)
- **App Status:** Installed and verified
- **Package ID:** `com.careid.careid_patient_app`
- **Build Verified:** Signed Release APK (`build\app\outputs\flutter-apk\app-release.apk`, 70.3MB)
- **Verification Logs:**
  ```text
  Performing Streamed Install
  Success
  Starting: Intent { cmp=com.careid.careid_patient_app/.MainActivity }
  mCurrentFocus=Window{495a802 u0 com.careid.careid_patient_app/com.careid.careid_patient_app.MainActivity}
  ```

---

## 9. Conclusion & Production Readiness

The patient profile image functionality is fully repaired, tested, and verified end-to-end:
- Gallery selection and camera capture work natively.
- Uploads transmit compliant multipart payloads (`file` key) to `POST /api/v1/patients/me/photo`.
- Profile images display consistently across Profile, Personal Details, and QR Dashboard.
- Image retrieval is fully authenticated with Bearer tokens, eliminating 401 silent fallbacks.
- Cache busting guarantees that newly uploaded photos reflect immediately.
- The signed release APK has been built and successfully installed on the physical Xiaomi test device.

