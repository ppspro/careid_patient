# CareID Patient App — Batch 6: Insurance Ingestion & OCR Card Capture Report

**Project:** `C:\Users\PABANI\CareID_patient_app`  
**Figma File:** `CAREID-AIO-FIGMA`  
**Canvas:** `17:55` — Careid patient app  
**Backend:** `https://360api.vnvision.in`  
**API Reference:** `CareID-Staging.postman_collection.json` (Section 19: Insurance Platform & Claims)  
**Connected Physical Device:** Xiaomi Redmi 8A (`9e7ed35c0007`)  
**Date:** October 31, 2026

---

## 1. Executive Summary

Batch 6 completes the end-to-end Insurance Ingestion and OCR Card Capture journey for the CareID Patient App. The 5 Figma screens have been built and verified with pixel-perfect visual fidelity, full bento architecture, bi-directional English/Spanish localization, responsive overflow-safe layouts, and strict zero-invention API integration with the live backend at `https://360api.vnvision.in`.

### Completed Figma Screens in Batch 6

| # | Screen Name | Figma Node ID | Dimensions | Dart Implementation File | Status |
|---|-------------|---------------|------------|--------------------------|--------|
| 1 | Add Insurance – Select Method | `20:20311` | 390 × 1539 | `lib/features/patient/presentation/screens/add_insurance_select_method_screen.dart` | ✅ Complete |
| 2 | Insurance Card – Camera Capture | `20:20258` | 390 × 905 | `lib/features/patient/presentation/screens/insurance_card_camera_screen.dart` | ✅ Complete |
| 3 | OCR Processing – Insurance Card | `20:20415` | 390 × 980 | `lib/features/patient/presentation/screens/insurance_ocr_processing_screen.dart` | ✅ Complete |
| 4 | OCR Extraction Results & Policy Verification | `20:20517` | 390 × 2134.5 | `lib/features/patient/presentation/screens/insurance_ocr_results_screen.dart` | ✅ Complete |
| 5 | Insurance Card Details | `20:20890` | 390 × 1384.75 | `lib/features/patient/presentation/screens/insurance_card_details_screen.dart` | ✅ Complete |

---

## 2. Ingestion Journey & UX Architecture

The 5 screens form a seamless single user journey for digitizing and managing health insurance cards:

```
[Insurance Screen]
      │
      ▼ (Tap FAB "+ Add Policy" or "Scan Card")
[1. Select Method Screen] (20:20311)
      │
      ├───────────────────────────────┐
      ▼ (Live Camera Scan)            ▼ (Upload from Gallery)
[2. Camera Capture Screen] (20:20258)  └─► Pick image file
      │                                       │
      └───────────────────────┬───────────────┘
                              ▼
        [3. OCR Processing Screen] (20:20415)
          • Animated laser scanner bar
          • 3-stage validation checklist
          • POST /api/v1/insurance/ocr/scan
                              │
                              ▼
        [4. OCR Results & Verification] (20:20517)
          • 95% Confidence Match banner
          • Captured card thumbnail preview
          • Bento field groups (Carrier, Member ID, RxBIN, Copays)
          • "USER EDITED" vs "OCR" badge tracking
          • POST /api/v1/insurance/ocr/confirm
                              │
                              ▼
        [5. Insurance Card Details] (20:20890)
          • High-fidelity digital insurance pass card
          • Masked/unmasked policy toggle
          • Quick actions (Verify, Share Pass, Download PDF, Claim)
          • Financials & Rx routing bento grid
          • POST /api/v1/insurance/policies/:id/verify
```

---

## 3. Screen Specifications & Implementation Details

### Screen 1: Add Insurance – Select Method (`20:20311`)
- **Header:** 64px PreferredSize AppBar with back navigation and `CareIdLogo.horizontal(height: 18)`.
- **Instructional Hero:** Centered medical badge with deep teal hue (`#0F766E`), bold headline, and explanatory subtitle.
- **Selection Bento Cards:**
  - Option 1: **Live Camera Scan** (Recommended pill badge, `#5B14B8` accent, auto edge detection description).
  - Option 2: **Upload from Gallery** (Photo library icon, `#0F766E` accent, selects existing phone images).
- **OCR Features Highlights:** Grid highlighting instant text recognition, offline card caching, and automatic network eligibility check.
- **Security Footer:** `HIPAA Compliant • 256-bit Encrypted Ledger` assurance badge.

### Screen 2: Insurance Card – Camera Capture (`20:20258`)
- **Viewfinder Canvas:** Immersive dark backdrop (`#020617`) simulating camera preview feed.
- **Front / Back Segment Selector:** Pill toggle allowing patients to switch between card front and back capture.
- **Edge Detection Guide:** Centered card cutout overlay with 4 rounded corner guide brackets in emerald/teal (`#0F766E`).
- **Floating Guidance Tip:** "Align card within the guide brackets" with info badge.
- **Controls Bar:** Flashlight toggle (`#FACC15`), 74×74 circular shutter button with inner white indicator, and direct gallery picker shortcut.

### Screen 3: OCR Processing – Insurance Card (`20:20415`)
- **Header:** 64px PreferredSize AppBar with `CareIdLogo.horizontal(height: 18)`.
- **Status Typography:** "Analyzing Insurance Card" with animated subtitle.
- **Laser Scanner Visual:** Dark container with card preview and animated glowing laser bar (`#14B8A6` / `#2DD4BF`) traversing vertically across the card face.
- **3-Stage Pipeline Checklist:**
  1. Boundary & Contour Alignment
  2. Optical Character Recognition (OCR)
  3. Field Extraction & Validation
- **Backend Trigger:** Submits card image payload to `POST /api/v1/insurance/ocr/scan` and automatically advances upon completion.

### Screen 4: OCR Extraction Results & Policy Verification (`20:20517`)
- **Header:** 64px PreferredSize AppBar with `CareIdLogo.horizontal(height: 18)`.
- **Confidence Badge:** "95% OCR Match • Please Verify" banner with emerald verification icon.
- **Card Thumbnail Preview:** Captured front card image with quick "Retake" button.
- **Bento Field Groups:**
  - Policy & Member Info: Carrier Name, Plan Type, Member/Policy ID, Group Number, Electronic Payer ID, Cardholder Name.
  - Prescription (Rx) Benefits: RxBIN, RxPCN, RxGroup.
  - Copays & Deductible: Primary Copay ($25), Specialist Copay ($50), Annual Deductible ($1,500), Out-of-Pocket Max ($4,500).
- **Human Modification Tracking:** Every field begins with `OCR` badge. As soon as the user modifies any field, its badge immediately turns purple with `USER EDITED`, ensuring transparent distinction between machine reading and human correction.
- **Actions:** "Confirm & Save Policy" (calls `POST /api/v1/insurance/ocr/confirm`) and "Retake Card Photo".

### Screen 5: Insurance Card Details (`20:20890`)
- **Header:** 64px PreferredSize AppBar with `CareIdLogo.horizontal(height: 18)`.
- **Digital Health Card Pass:**
  - Deep Navy to Teal gradient container (`#0F172A` → `#1E293B` → `#0F766E`) with ambient glow circles.
  - Golden NFC chip illustration and holographic shield security emblem.
  - Carrier brand name, plan tier, cardholder name.
  - Masked policy number (`•••• •••• •••• 1903`) with interactive eye icon to toggle full unmasked ID.
  - "ACTIVE" verified badge in emerald green.
- **Quick Action Bento:**
  - **Verify Coverage:** Calls `POST /api/v1/insurance/policies/:id/verify` with real-time feedback.
  - **Share Pass:** Exports digital insurance pass.
  - **Download PDF:** Downloads official policy verification summary.
  - **New Claim:** Quick entrypoint for filing claims.
- **Details Bento Grid:** Coverage summary, Copays & Deductible breakdown ($25 primary, $50 specialist, $250 ER), and Rx routing details.
- **Member Hotline Banner:** 1-800-555-0199 contact card.

---

## 4. API Endpoints & Zero-Invention Integrity

All interactions strictly use existing backend endpoints documented in `CareID-Staging.postman_collection.json`:

| Action | HTTP Method | Endpoint | Payload / Behavior |
|--------|-------------|----------|--------------------|
| Scan Card Image | `POST` | `/api/v1/insurance/ocr/scan` | `{"imageUrl": "..."}` → returns `ocrId`, `confidence`, `extractedData` |
| Confirm Policy | `POST` | `/api/v1/insurance/ocr/confirm` | `{"ocrId": "...", "providerName": "...", "policyNumber": "...", "groupNumber": "..."}` |
| Get All Policies | `GET` | `/api/v1/insurance/policies` | Authenticated request returning user policies |
| Get Policy By ID | `GET` | `/api/v1/insurance/policies/:id` | Returns full policy details |
| Verify Coverage | `POST` | `/api/v1/insurance/policies/:id/verify` | Authenticated live eligibility check |

---

## 5. Verification & Test Results

### 1. Automated Widget Test Suite
- **File:** `test/features/patient/batch6_insurance_ocr_widget_test.dart`
- **Results:**
  - `AddInsuranceSelectMethodScreen (20:20311)`: ✅ Passed
  - `InsuranceCardCameraScreen (20:20258)`: ✅ Passed
  - `InsuranceOcrProcessingScreen (20:20415)`: ✅ Passed
  - `InsuranceOcrResultsScreen (20:20517)`: ✅ Passed
  - `InsuranceCardDetailsScreen (20:20890)`: ✅ Passed
- **Batch 2–6 Combined Suite:** 37 targeted tests all passed (100%).

### 2. Static Analysis
- `flutter analyze`: **0 issues found** across entire project.

