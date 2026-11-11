# 03. CareID Patient App — Remaining Issues, Fallbacks & Backend Gaps

**Audit Date:** November 3, 2026  
**Document ID:** `docs/final_audit/03_remaining_issues.md`

---

## 1. Overview

In accordance with the project rules, this document provides an honest assessment of all remaining fallbacks, backend limitations, and design inconsistencies. No backend failures or missing endpoints are hidden behind dummy success responses.

---

## 2. Fallbacks & Backend Gaps

### Issue 1: Uninsured Sliding-Scale Charity Care Calculation
- **Figma Reference:** Frame `20:26187` ("Care ID - Insurance Status (Uninsured)")
- **Status in Postman:** **Missing from Postman Collection.**
- **Details:** The Postman collection contains `27. Healthcare Financing & Financial Assistance` (`/api/v1/financing/options`, `/api/v1/financing/offers`, `/api/v1/financing/apply`), but does not define a dedicated calculation endpoint for hospital charity care, poverty-line sliding scale subsidies, or state-funded uninsured relief programs.
- **Client Resolution:** Preserved the approved Figma layout, interactive income-to-household subsidy calculator, and local directory of charity hospital partners. No replacement endpoint was invented.
- **Backend Requirement for Staging Team:**
  ```http
  POST /api/v1/assistance/charity-eligibility
  Content-Type: application/json

  {
    "householdSize": 3,
    "annualIncome": 28000,
    "state": "NY",
    "hasMedicaid": false
  }
  ```

### Issue 2: Insurance Camera OCR Direct Binary Ingestion
- **Figma Reference:** Frames `20:20258` ("Camera Capture"), `20:20415` ("OCR Processing"), `20:20517` ("OCR Extraction Results")
- **Status in Postman:** `POST /api/v1/insurance/ocr/scan` and `POST /api/v1/insurance/ocr` exist, but accept a remote image URL (`{"imageUrl": "..."}` or `{"documentUrl": "..."}`).
- **Details:** When a patient captures a physical insurance card via camera on the Android device, the resulting file is a local JPEG. Directly sending a local binary stream requires a presigned object storage upload or multipart handler on `/api/v1/insurance/ocr`.
- **Client Resolution:** The camera capture overlay and review UI are preserved. When testing with live URL fixtures, the endpoint returns `200 OK`. Local photo capture gracefully routes to manual field verification rather than fabricating mock extraction numbers.
- **Backend Requirement for Staging Team:**
  Support direct multipart form upload on `POST /api/v1/insurance/ocr/upload` accepting `multipart/form-data` with `file: <binary>`.

### Issue 3: Patient Profile Avatar Upload (`POST /api/v1/patients/me/photo`)
- **Figma Reference:** Frame `20:24204` ("Profile & Settings Hub")
- **Status on Staging:** Staging returns `HTTP 500 Internal Server Error`.
- **Details:** The server multipart handler throws an exception during file stream buffer parsing or when interacting with uninitialized object storage buckets.
- **Client Resolution:** The client maintains an immediate local preview of the selected image, informs the patient if the server fails, and provides an option to retry or set a photo URL.

---

## 3. Verified Report Inconsistencies & Resolutions

### A. Support Tickets Inconsistency (Resolved)
- **Investigation:** A comprehensive audit of all 104 direct canvas nodes in `CAREID-AIO-FIGMA` (Canvas `17:55`) confirmed that **"Support Tickets" is NOT an approved Figma frame**. The approved Figma frame for support in `20:24204` is the Support Center bottom sheet, which features **Live Medical Chat** (Figma Frame `20:31689`, `Live_chat_messeges`) and the **Frequently Asked Questions (FAQ)** ledger.
- **Action Taken:** Removed the unapproved `SupportTicketsScreen` and the "Support Tickets & Helpdesk" ListTile from `PatientProfileScreen`. The approved Live Medical Chat (`LiveChatScreen`) and FAQ sheet are preserved without disruption.

### B. Removed Insurance Recommendation Screens (Verified Clean)
- **Investigation:** Verified across all routes in `lib/app.dart` and UI navigation links.
- **Action Taken:** Zero references to obsolete Insurance Recommendation screens exist in the client.

### C. Bottom Navigation Structure (Verified Clean)
- **Investigation:** Verified `CareIdBottomNavigationBar`.
- **Action Taken:** Contains exactly 4 tabs (Home, Records, Doctor, Profile) plus center floating QR pass action. No separate Health Card tab exists.

