# CareID Patient App — Next Implementation Batch (Batch 1)

**Batch Focus:** Health Records & Specialized Clinical Detail Screens  
**Figma Canvas:** `17:55` (`Careid patient app`)  
**Figma File:** `CAREID-AIO-FIGMA`  
**Execution Date:** October 31, 2026  
**Status:** In Progress  

---

## 1. Selected Screens for Batch 1

| No. | Screen Name | Figma Reference Node | Frame Dimensions | Target Flutter File | Rationale |
|---|---|---|---|---|---|
| 1 | **Care ID - Vision Record Detail** | `20:25410` & `20:32573` | 390x2030 | `lib/features/patient/presentation/screens/vision_record_detail_screen.dart` | High fidelity clinical detail screen with Retinal Fundus OCT / acuity preview, OD/OS refraction metrics, 4 quick actions, Dr. Sarah Lin provider card, diagnosis card, PDF/JPG attachments, and doctor notes. |
| 2 | **Care ID - Dental Record Detail** | `20:25653` | 390x1854 | `lib/features/patient/presentation/screens/dental_record_detail_screen.dart` | High fidelity dental detail screen with Panoramic tooth arch viewer, 4 quick actions, Dr. Michael Vance provider card, dental diagnosis card, dental X-ray PDF/JPG attachments, and periodontal notes. |
| 3 | **Care ID - Medical Record Detail** | `20:25209` / `20:24484` | 390x1776 | `lib/features/patient/presentation/screens/medical_record_detail_screen.dart` | High fidelity general consultation and laboratory biomarker panel screen with cholesterol, glucose, CBC, 4 quick actions, Dr. Robert Chen provider card, and clinical attachments. |
| 4 | **Pet Care Records** | `20:26073` / `20:30578` | 390x1400 | `lib/features/patient/presentation/screens/pet_records_screen.dart` | Completes the 3rd vault card on `Care ID - Family Records` (`20:30521`), providing pet profile (breed, microchip ID, age, weight), core immunization status, vet history, and filter tabs. |
| 5 | **Care ID - Pet Record Detail** | `20:26229` / `20:30578` | 390x1776 | `lib/features/patient/presentation/screens/pet_record_detail_screen.dart` | Detailed veterinary immunization and exam report with vaccine batch/lot, veterinarian Dr. Amanda Bell DVM, clinic details, clinical exam notes, and downloadable rabies certification. |

---

## 2. Integration & Navigation Updates

1. **`lib/features/patient/presentation/screens/family_records_screen.dart`**:
   - Update Card 3 ("Pet Records") `onContinue` action to navigate directly to `PetRecordsScreen(apiClient: widget.apiClient, language: widget.language)`.
2. **`lib/features/patient/presentation/screens/vision_records_screen.dart`**:
   - Update item tap to navigate directly to `VisionRecordDetailScreen`.
3. **`lib/features/patient/presentation/screens/dental_records_screen.dart`**:
   - Update item tap to navigate directly to `DentalRecordDetailScreen`.
4. **`lib/features/patient/presentation/screens/medical_records_screen.dart`**:
   - Update item tap to navigate directly to `MedicalRecordDetailScreen`.
5. **`lib/features/patient/presentation/screens/record_detail_screen.dart`**:
   - Convert to an intelligent polymorphic router so any legacy or deep link to `RecordDetailScreen` delegates cleanly to the appropriate specialized screen based on `record.category`.

---

## 3. Visual & Functional Specifications

### A. Vision Record Detail (`20:25410` / `20:32573`)
- Top App Bar with back navigation, CareID logo, and patient profile initials avatar.
- Security & Verified Verification Strip:
  - Cyan badge with security lock, "Verified & End-to-End Encrypted", Care ID Reference ID.
- Hero Panoramic OCT Scan Document Card:
  - Fundus OCT scan container with subtle medical gradient scrim, fullscreen expansion button, and Care ID verified tag.
- 4 Quick Action Buttons (2x2 Grid):
  - Download, Share, Print, Export with responsive touch feedback.
- Attending Provider Section:
  - Dr. Sarah Lin, MD, VisionCare Eye Specialists, Optometry & Retinal Diagnostics, Lic. #OD-8896, verified checkmark, direct contact buttons.
- Clinical Details Section:
  - Record Type ("Vision Record"), Examination Date, Next Follow-up, Primary Diagnosis ("H35.31 - Non-exudative age-related macular screening & routine funduscopy"), Refraction OD/OS table.
- Attachments Section:
  - Retinal_Scan_HighRes_OCT.pdf, Fundus_Color_Composite.jpg with download and view actions.
- Patient Notes Card:
  - Attending physician clinical observations, recommendations, and timestamp.

### B. Dental Record Detail (`20:25653`)
- Top App Bar matching vision detail.
- Security & Verified Verification Strip with Care ID ID: CR-7721-D.
- Hero Panoramic X-Ray Document Card:
  - Dental panoramic arch viewer, fullscreen expansion, verified tag, and timestamp.
- 4 Quick Action Buttons (2x2 Grid):
  - Download, Share, Print, Export.
- Attending Provider Section:
  - Dr. Michael Vance, DDS, Dental Care Specialists, Dentist & Orthodontist, Lic. #OD-7721.
- Clinical Details Section:
  - Record Type ("Dental Record"), Examination Date, Next Cleaning Due, Primary Diagnosis ("Routine Dental Examination & Cleaning D0120/D1110"), Tooth Arch status.
- Attachments Section:
  - Dental X-Ray Observations.pdf, Dental X-Ray.jpg.
- Patient Notes Card:
  - Exact quote from Figma: *"Routine panoramic X-ray taken for annual check-up. No significant abnormalities noted in the jaw structure or tooth alignment. Patient advised to continue regular flossing."*

### C. Medical Record Detail (`20:25209` / `20:24484`)
- Top App Bar matching design system.
- Security & Verified Verification Strip with Care ID ID: CR-5582-M.
- Hero Diagnostic Summary Card with lab biomarker overview.
- 4 Quick Action Buttons (2x2 Grid).
- Attending Provider Section:
  - Dr. Robert Chen, MD, Internal Medicine & Diagnostics, Lic. #MD-4421.
- Clinical Biomarkers Panel:
  - Total Cholesterol (185 mg/dL - Normal), HDL (54 mg/dL), LDL (108 mg/dL), Fasting Glucose (92 mg/dL), Blood Pressure (118/76 mmHg).
- Attachments Section:
  - Comprehensive_Metabolic_Panel.pdf, Clinical_Summary.pdf.
- Doctor Notes Card with preventive recommendations.

### D. Pet Care Records (`20:26073` / `20:30578`)
- Pet Profile Header Card:
  - Pet Name ("Max"), Species & Breed ("Golden Retriever • Canine"), Age ("3 Years"), Weight ("68 lbs"), Microchip ID ("985141002345678"), CareID Pet Passport QR badge.
- Security & Synchronization Strip:
  - "Care ID Pet Health Passport • Synced with VCA Animal Hospital".
- Filter Tabs:
  - "All Records", "Vaccinations", "Vet Visits", "Medications", "Lab Tests".
- Timeline Record Cards:
  - Rabies & Core Annual Booster (Current, Expires Sep 2024).
  - Dental Scaling & Oral Health Exam.
  - Heartworm & Flea/Tick Prevention (Heartgard Plus).
- Add Record Action & Tap-to-Detail Navigation.

### E. Pet Record Detail (`20:26229`)
- Top App Bar with back navigation and CareID brand header.
- Animal Health Verification Strip.
- Pet Overview & Veterinary Clinic Card (Dr. Amanda Bell, DVM, Metropolitan Veterinary Hospital).
- 4 Quick Actions.
- Clinical Immunization Details (Vaccine Batch DEF-2023-RAB-9912, Dosage 1.0 mL Subcutaneous, Expiration Date).
- Full Veterinary Clinical Notes.
- Downloadable Certificate Attachments.

---

## 4. Verification Plan
- `flutter analyze`: 0 warnings, 0 errors.
- Unit/Widget Tests: Add dedicated tests verifying rendering, data binding, and button interactions for all 5 screens.
- `flutter test`: 100% pass rate.
- APK Build: `flutter build apk --release`.
- Device Installation: Install on physical test device `9e7ed35c0007` via ADB.
- Verification Screencap: Capture screenshot from physical device and verify visual correctness.

