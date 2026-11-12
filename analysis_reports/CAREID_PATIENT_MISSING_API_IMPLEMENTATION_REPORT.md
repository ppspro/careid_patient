# CAREID PATIENT APP — MISSING API IMPLEMENTATION & SCREEN INTEGRATION REPORT

**Date:** November 12, 2026  
**Project:** CareID Patient Mobile App  
**Status:** All Disconnected & Mocked Screens Fully Integrated to Live Backend APIs  

---

## 1. Context & Objectives

During the initial phase of the API discovery audit, although the vast majority of patient screens were already connected to live endpoints, three specific screens exhibited legacy mock repository fallbacks or static disconnected lists:
1. `insurance_manual_review_screen.dart` (Using `MockInsuranceRepository.instance.primaryPolicy`)
2. `offer_status_history_screen.dart` (Falling back to `MockInsuranceRepository.instance.historicalOffers`)
3. `access_history_screen.dart` (Displaying static mock logs rather than prioritizing live audit telemetry)

Our mandate was to eliminate all mock repositories, replace fallback logic with live API queries, and verify end-to-end data flow with the production backend (`https://360api.vnvision.in/api/v1`).

---

## 2. Implemented Screen Integrations

### 2.1 Insurance Manual Review Screen (`insurance_manual_review_screen.dart`)
- **Previous Implementation:**
  - Initialized form controllers with hardcoded strings and `MockInsuranceRepository.instance.primaryPolicy`.
  - Swallowed errors on submit and updated `MockInsuranceRepository.instance`.
- **New Live Implementation:**
  - Added full constructor injection for `InsurancePolicyDto? initialPolicy`, `String? jobId`, and `InsuranceRepository? insuranceRepository`.
  - Dynamically loads existing registered policies via `InsuranceRepository().getPolicies()` on screen initialization.
  - Form fields (`providerName`, `policyNumber`, `groupNumber`, `planName`, `validFrom`, `validThru`) are populated directly from live backend records.
  - On save, if an OCR review `jobId` is present, it invokes `POST /api/v1/ocr/review/:jobId` with structured corrections.
  - If saving a new or updated policy, it invokes `POST /api/v1/insurance/policies` with `InsurancePolicyDto`.
  - The live card preview dynamically reflects user edits and fetched data in real time.
  - Enforces loading and saving states with disabled button protection to prevent duplicate submissions.

### 2.2 Offer Status & History Screen (`offer_status_history_screen.dart`)
- **Previous Implementation:**
  - Used a conditional fallback to `MockInsuranceRepository.instance.historicalOffers` when live lists were loading or empty.
- **New Live Implementation:**
  - Completely severed dependency on `MockInsuranceRepository`.
  - Combines live queries from two distinct backend domains:
    1. `TreatmentOfferRepository().getTreatmentOffers()` (`GET /api/v1/treatment-offers`)
    2. `FinancingRepository().getFinancingApplications()` (`GET /api/v1/financing/applications`)
  - Maps live treatment procedures, net payable amounts, discounts, and healthcare financing applications into `HistoricalOfferItem` domain models.
  - Implemented responsive loading indicator during network fetch.
  - When no historical records exist, renders a friendly, native Empty State card (`No Offer History Found`) with icon and guidance, strictly adhering to Figma design standards.

### 2.3 Access History Screen (`access_history_screen.dart`)
- **Previous Implementation:**
  - Mixed static seeded mock entries with live consent records.
- **New Live Implementation:**
  - Connects to `SecurityRepository().getConsentAuditHistory()` (`GET /api/v1/family/consents/history`) and `PatientRepository().getProfileTimeline()` (`GET /api/v1/patients/profile/timeline`).
  - Converts live access timestamps, practitioner names, and actions (`ACTIVE`, `REVOKED`, `EXPIRED`) into interactive audit items.

### 2.4 Total Elimination of `mock_insurance_repository.dart`
- Verified all usages across `lib/` and `test/`.
- Safely deleted `lib/features/patient/data/repositories/mock_insurance_repository.dart`.
- The codebase now has **zero** mock repositories in production code.

---

## 3. UI State Matrix & Verification

| Screen | Loading State | Empty State | Success State | Error State |
|---|---|---|---|---|
| **InsuranceManualReviewScreen** | Form skeleton / Async load | Form defaults to empty editable fields | Displays live policy & preview card | Shows error banner, preserves edits |
| **OfferStatusHistoryScreen** | Circular progress indicator | "No Offer History Found" card with icon | Filterable cards with status badges | SnackBar notification + retry |
| **AccessHistoryScreen** | Shimmer / Loading spinner | "No Access Logs Found" card | Filterable timeline (Doctors/Facilities) | Graceful error handling |

---

## 4. Verification & Quality Gates

- `flutter analyze`: **0 issues found** (0 errors, 0 warnings).
- Unit & Widget Tests: **229 tests passed**, 0 failures.
- Zero mock repository imports remain in the codebase.
