# CareID Patient App — Figma Visual Regression Test Results

**Date of Execution:** October 29, 2026  
**Target Figma Canvas:** `17:55` ("Careid patient app" in `CAREID-AIO-FIGMA`)  
**Standard Mobile Viewport Tested:** 390 x 844 pt (iPhone 13/14/15/16 baseline standard)  
**Test Suite File:** [`test/features/visual_regression/figma_visual_fidelity_test.dart`](file:///C:/Users/PABANI/CareID_patient_app/test/features/visual_regression/figma_visual_fidelity_test.dart)  
**Result:** **15 / 15 Passed (100% Green, 0 Overflows, 0 Unbounded Constraints)**

---

## 1. Executive Summary

A comprehensive automated visual regression test suite was executed against the 15 core patient screens defined in Figma canvas `17:55`. The test suite verifies:
1. Widget tree instantiation without layout exceptions (`RenderFlex` overflows, unbounded height/width).
2. Proper rendering of design-system assets, typography, chips, badges, and brand elements.
3. Responsive flex container behavior at the standard 390 pt viewport width.
4. Correct dual-language localization (English / Spanish) string rendering without clipping.

---

## 2. Visual Regression Pass/Fail Matrix

| # | Screen Name | Figma Frame Node ID | Figma Canvas Dimensions | Status | RenderFlex Overflows | Key Visual Tokens Verified |
|---|-------------|---------------------|-------------------------|--------|----------------------|----------------------------|
| 1 | Splash Screen | `20:25191` | 390 x 884 pt | **PASS** | 0 | `CareIdLogo`, `careid_logo.svg`, "Encrypted Clinical Vault" |
| 2 | Welcome Screen | `20:19794` | 390 x 1072 pt | **PASS** | 0 | 4 Discipline Cards (Medical, Dental, Vision, Pets), "Get Started", "I already have an account" |
| 3 | Create Account (Step 1) | `20:30644` | 390 x 911 pt | **PASS** | 0 | Step 1 progress bar, Full Name, Email, Mobile, Password, Wrap-based login footer |
| 4 | Mobile Number (Step 2) | `20:30756` | 390 x 1207 pt | **PASS** | 0 | Step 2 of 6 indicator, +1 country selector, 6-digit pin input, security badge |
| 5 | Health Info (Step 3) | `20:30900` | 390 x 2636 pt | **PASS** | 0 | Step 3 of 6 indicator, Blood group grid, Height/Weight measurements, Allergy tags, HIPAA footer |
| 6 | Add Insurance (Step 4) | `20:33068` | 375 x 1179 pt | **PASS** | 0 | Step 4 of 6 indicator, OCR scanner mock card, Member ID & Group # fields, "Skip for now" |
| 7 | Privacy & Consents (Step 5) | `20:31164` | 390 x 2550 pt | **PASS** | 0 | Step 5 of 6 indicator, HIPAA authorization toggles, Data rights card, Consent status badge |
| 8 | Confirmed Screen (Step 6) | `20:31401` | 390 x 2033 pt | **PASS** | 0 | Step 6 of 6 indicator, "Your Care ID Vault is ready", Monospaced Care ID pill, Profile strength bar |
| 9 | Login Screen | `20:24965` | 390 x 1020 pt | **PASS** | 0 | Welcome Back header, Mobile number challenge, "Send Verification Code", Wrap create account link |
| 10 | Patient Home Dashboard | `20:19552` | 390 x 1846 pt | **PASS** | 0 | Patient greeting, CareID Health Pass hero card, Quick Actions grid, Clinical Health Summary card |
| 11 | Medical Records Vault | `20:31908` | 390 x 1272 pt | **PASS** | 0 | Vault summary stats, Filter chips ("All Records", "GENERAL", "DENTAL", "VISION"), Record timeline items |
| 12 | Digital Health Card | `20:19873` | 390 x 1522 pt | **PASS** | 0 | Verifiable QR credential, SMART Health Card standards rows (ECDSA secp256r1, SHA-256), Action buttons |
| 13 | Insurance Dashboard | `20:20059` | 390 x 2179 pt | **PASS** | 0 | Insurance platform header, Active coverage policy cards, Claims history, Deductible progress |
| 14 | Family Care Dashboard | `20:21675` | 390 x 1546 pt | **PASS** | 0 | Family & Dependents header, Linked ecosystem member cards, Role permissions badges, Add dependent CTA |
| 15 | Personal Details & Profile | `20:24653` | 390 x 1160 pt | **PASS** | 0 | Personal Information card, Medical Summary section, Security & Emergency contact status |

---

## 3. Layout Anomalies Detected & Remediated

During visual testing, several horizontal `Row` structures overflowed because their text contents or badges lacked flexible bounding constraints on a standard 390 pt mobile viewport. The following precise remedies were applied:

1. **`lib/features/onboarding/presentation/screens/create_account_screen.dart`**
   - Converted fixed `Row` for "Already have an account? Sign In" into a responsive `Wrap` with `WrapAlignment.center`.
   - Converted encryption notice footer `Row` into `Wrap`.
   - Wrapped Step 1 progress title in `Expanded`.

2. **`lib/features/onboarding/presentation/screens/mobile_number_screen.dart`**
   - Wrapped Step 2 of 6 header in `Expanded`.
   - Converted footer help link into `Wrap`.
   - Wrapped verification code header text in `Expanded`.

3. **`lib/features/onboarding/presentation/screens/health_info_screen.dart`**
   - Wrapped Step 3 of 6 header label in `Expanded`.
   - Wrapped Height and Weight measurement column labels in `Expanded`.
   - Replaced fixed `Row` allergy chips with `Flexible(child: Text(allergy.displayTag, overflow: TextOverflow.ellipsis))`.
   - Replaced footer security reassurance `Row` with `Wrap(alignment: WrapAlignment.center)`.

4. **`lib/features/onboarding/presentation/screens/add_insurance_screen.dart`**
   - Wrapped Step 4 of 6 verification step label in `Expanded`.

5. **`lib/features/onboarding/presentation/screens/privacy_consents_screen.dart`**
   - Wrapped Step 5 of 6 header label in `Expanded`.
   - Wrapped Required Consents header in `Expanded`.
   - Wrapped Health Information Consent header in `Expanded`.
   - Wrapped "Your Rights & Data Control" header in `Expanded`.
   - Wrapped "Consent Status" title in `Expanded`.

6. **`lib/features/onboarding/presentation/screens/confirmed_screen.dart`**
   - Wrapped Step 6 of 6 header title in `Expanded`.
   - Wrapped "Care ID Cryptographic Vault Active" text in `Flexible` with `TextOverflow.ellipsis`.
   - Wrapped Digital Credential title row in `Expanded` with `Flexible`.
   - Converted Care ID Monospaced Pill row into responsive `Wrap`.
   - Wrapped "You own your health data" in `Expanded`.
   - Wrapped Profile Strength header in `Expanded` with `Flexible`.
   - Wrapped Share Digital Health Card button row in `Flexible`.

7. **`lib/features/auth/presentation/screens/login_screen.dart`**
   - Converted "Don't have an account? Create Account" `Row` into responsive `Wrap`.

8. **`lib/features/patient/presentation/screens/home_screen.dart`**
   - Wrapped "CareID Health Pass" title in `Expanded` and `Flexible`.
   - Wrapped "CARDHOLDER" name column in `Expanded` with `TextOverflow.ellipsis`.
   - Wrapped "Clinical Health Summary" in `Expanded`.
   - Wrapped "Recent Medical Records" title in `Expanded`.

9. **`lib/features/patient/presentation/screens/health_card_screen.dart`**
   - Wrapped screen title and subtitle column in `Expanded`.
   - Wrapped card top row status chip in `Expanded` and `Flexible`.
   - Redesigned `_buildDetailRow` to use proportional flex (`Expanded(flex: 2)` for labels and `Expanded(flex: 3)` with `TextAlign.end` for values) so multi-line cryptographic standards wrap cleanly without overflowing.

10. **`lib/features/patient/presentation/screens/insurance_screen.dart`**
    - Wrapped header title in `Expanded`.

11. **`lib/features/patient/presentation/screens/family_members_screen.dart`**
    - Wrapped header title in `Expanded`.

12. **`lib/features/patient/presentation/screens/patient_profile_screen.dart`**
    - Wrapped header title and vault profile strength pill in `Expanded`.

13. **`lib/shared/widgets/primary_button.dart`**
    - Wrapped button label text in `Flexible` with `TextOverflow.ellipsis`.

---

## 4. Execution Command & Reproduction

To reproduce this 100% green test run:
```bash
flutter test test/features/visual_regression/figma_visual_fidelity_test.dart
```

