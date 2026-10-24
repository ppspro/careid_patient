# CareID Patient App — Screen Map & Specification

## 1. Frame Identification & Flow Context

- **Figma File**: `CAREID-AIO-FIGMA`
- **Figma Canvas Node**: `17:55` (Canvas Name: `Careid patient app`)
- **Phase 1 Screen (Completed)**:
  - **Frame Name**: `Welcome - Option 2`
  - **Figma Node ID**: `20:19794`
  - **Implementation Status**: Completed and Verified in Phase 1.
- **Phase 2 Screen (Completed)**:
  - **Frame Name**: `CareID-Create Account`
  - **Figma Node ID**: `20:30644`
  - **Implementation Status**: Completed and Verified in Phase 2.
- **Phase 3 Screen (Completed)**:
  - **Frame Name**: `Mobile_number`
  - **Figma Node ID**: `20:30756`
  - **Implementation Status**: Completed and Verified in Phase 3.
- **Phase 4 Screen (Completed)**:
  - **Frame Name**: `Health_info`
  - **Figma Node ID**: `20:30900`
  - **Dimensions**: `390 x 2636 pt`
  - **Implementation Status**: Completed and Verified in Phase 4.
- **Phase 5 Screen (Completed)**:
  - **Frame Name**: `Add Insurance Info`
  - **Figma Node ID**: `20:33068`
  - **Dimensions**: `390 x 1034 pt`
  - **Implementation Status**: Completed and Verified in Phase 5.
- **Phase 6 Destination Screen (Next Target)**:
  - **Frame Name**: `Privacy & Consents`
  - **Figma Node ID**: `20:31164`
  - **Dimensions**: `390 x 2549.5 pt`
  - **Implementation Status**: Target for Phase 6 (Step 5 of 6: Consents, HIPAA Authorization & Digital Health Card).

---

## 2. Screen Specification: `Welcome - Option 2` (Node `20:19794`) — Completed (Phase 1)
- **Frame Dimensions**: `390 x 1072 pt`
- **Purpose**: Patient onboarding gateway introducing CareID's clinical vault across medical, dental, vision, and pet records.
- **Actions**: "Get Started" -> Step 1 (`CreateAccountScreen`); "I already have an account" -> Login.

---

## 3. Screen Specification: `CareID-Create Account` (Node `20:30644`) — Completed (Phase 2)
- **Frame Dimensions**: `390 x 911 pt`
- **Purpose**: Step 1 of 6. Validates credentials, initiates `RegistrationContext`, passes control to Step 2.
- **Fields**: Full Name, Mobile Number (+1 prefix), Email, Password, Confirm Password, Terms & Privacy checkbox.

---

## 4. Screen Specification: `Mobile_number` (Node `20:30756`) — Completed (Phase 3)
- **Frame Dimensions**: `390 x 1207 pt`
- **Purpose**: Step 2 of 6. Multi-factor phone verification via 6-digit SMS challenge.
- **Components**:
  - 6 individual OTP input boxes with auto-traversal, backspace support, and paste handling.
  - 60-second countdown timer with resend SMS and call triggers.
  - Masked phone display (`+1 (•••) •••-2671`) with "Change" action.
  - Two-Step Clinical Safeguard reassurance badge.

---

## 5. Screen Specification: `Health_info` (Node `20:30900`) — Completed (Phase 4)

### Purpose
Step 3 of the 6-step Patient Onboarding Journey. Captures the patient's baseline clinical health profile: blood group, physical measurements, medical history, allergies, regular medications, surgeries, and family health history.

### Dimensions & Structure
- **Dimensions**: `390 x 2636 pt`
- **Node ID**: `20:30900`
- **Position**: Direct destination from Step 2 (`MobileNumberScreen`).
- **Background**: `#F4F7FB` (Light clinical slate-blue tone).
- **Surface**: White elevated cards with `#CBD5E1` borders, purple accents (`#8B5CF6`), and responsive keyboard dismiss.

### Implemented Sections & Form Controls
1. **Top Header**:
   - Back arrow navigation returning to Step 2 with preserved context.
   - Centered CareID brand mark.
   - Bilingual language selector (`EN` / `ESP`) with live translation.
2. **Step Progress Indicator (`20:30904`)**:
   - "VERIFICATION STEP" / "PASO DE VERIFICACIÓN" label.
   - "Step 3 of 6" indicator.
   - Progress bar (50.0% filled).
3. **Screen Heading (`20:30913`)**:
   - "Tell us about your health".
   - "Your health history helps Care ID organize your information and provide a more complete health profile."
4. **Verified Identity Summary**:
   - Displays patient's name and verified phone (`+1 (•••) •••-2671 • Verified`).
5. **Section 1: Basic Health Information (`20:30919`)**:
   - Blood Group: 8 standard blood group chips (`A+`, `A-`, `B+`, `B-`, `AB+`, `AB-`, `O+`, `O-`) + full-width `Unknown / Not sure`. Active purple fill (`#8B5CF6`).
   - Height Card (`20:30948`): Toggle (`cm` / `ft`), number input field (default `175`), unit indicator.
   - Weight Card (`20:30968`): Toggle (`kg` / `lb`), number input field (default `70`), unit indicator.
6. **Section 2: Medical History (`20:30988`)**:
   - Subtitle: "Select anything that applies to you."
   - Multi-select chips: `Diabetes`, `High Blood Pressure`, `Heart Condition`, `Asthma`, `Kidney Condition`, `Liver Condition`, `Thyroid Condition`, `Cancer`, `High Cholesterol`.
   - Exclusive toggle: `None of these` (clears all selections).
   - Dynamic input: `Other` (opens inline text field for custom conditions).
7. **Section 3: Allergies (`20:31022`)**:
   - Badge pill: `1 Recorded` / `0 Recorded`.
   - Category toggle: `No known allergies` (exclusive).
   - Active allergy tags with delete icon (`Penicillin (Mild rash)`).
   - Action: `+ Add another allergy` opening interactive modal sheet (Allergy Name, Symptoms/Reaction, Category: Medication/Food/Environmental/Other).
8. **Section 4: Current Medications (`20:31057`)**:
   - Active Medication Cards list: Medicine name (`Atorvastatin 20mg`), dosage & timing subtitle (`1 tablet daily • Evening`), with Delete button.
   - Action: `+ Add Medication` opening interactive modal sheet (Name, Dosage, Timing).
   - Checkbox: "I do not take any medications regularly".
9. **Section 5: Previous Surgeries or Major Procedures (`20:31091`)**:
   - Documented procedure cards with year and remove action.
   - Action: `+ Add Procedure` opening interactive modal sheet (Procedure name, approximate year).
   - Checkbox: "I have no previous surgeries or major procedures".
10. **Section 6: Family Health History (`20:31108`)**:
    - Multi-select chips: `Heart Disease`, `Diabetes`, `High Blood Pressure`, `Cancer`, `Stroke`, `None known` (exclusive), `Other` (inline text input).
11. **Section 7: Optional Document Notice (`20:31131`)**:
    - "Already have health documents? Add past medical documents later directly from your Care ID Vault. Document upload is not required right now."
12. **Inline Server Error & Telemetry Card**:
    - Displays real server response (e.g. `401 Unauthorized` due to unmigrated backend or session) without faking navigation. Preserves all entered data.
13. **Actions & Navigation (`20:31140`)**:
    - Primary CTA: "Save & Continue" gradient button with arrow icon. Shows spinner during save. Validates, updates `RegistrationContext`, calls `OnboardingRepository.submitHealthInformation`, and transitions to Step 4.
    - Secondary CTA: "Skip for now" button. Allows skipping optional health details and proceeding directly to Step 4.
    - Trust Note: "You can complete or revise your health history later from your Care ID Vault."
    - Security Note: "Your health information is encrypted and securely stored in your Care ID Vault."

---

## 6. Screen Specification: `Add Insurance Info` (Node `20:33068`) — Completed (Phase 5)

### Purpose
Step 4 of the 6-step Patient Onboarding Journey. Connects the patient's primary health insurance policy (Provider name, Member ID, Group number) or allows deferring insurance entry via "I'll do this later" to advance onboarding.

### Dimensions & Structure
- **Dimensions**: `390 x 1034 pt` (viewport responsive, scrollable)
- **Node ID**: `20:33068`
- **Position**: Direct destination from Step 3 (`HealthInfoScreen`).
- **Background**: `#F8F9FF` (Soft blue-tinted clinical background).
- **Surface**: White elevated cards with `#DCE9FF` borders, deep purple accent `#5B14B8`, and responsive keyboard handling.

### Implemented Sections & UI Components
1. **Top Header (`20:33069`)**:
   - Navigation back button with preserved context.
   - CareID brand mark (`CareIdLogo`).
   - Bilingual language pill (`EN` in `#5B14B8` / `ESP` in `#414754`).
2. **Step Progress Indicator (`20:33079` - `20:33087`)**:
   - "VERIFICATION STEP" / "PASO DE VERIFICACIÓN" in teal `#00696B` (12px, font-semibold, letter-spacing 0.6px).
   - "Step 4 of 6" indicator (`#494552`, 12px).
   - Linear progress bar: `#DCE9FF` background track, filled 66.6% (4 of 6) in deep indigo `#28006D`.
3. **Screen Heading (`20:33088` - `20:33093`)**:
   - "Add your insurance" in `#0B1C30` (28px bold, letter-spacing -0.7px).
   - "Adding your insurance now helps speed up your first visit. You can also skip this and add it later." (`#494552`, 16px).
4. **Card 1: Scan Insurance Card (`20:33095` - `20:33106`)**:
   - White card with `#DCE9FF` border, rounded 16px, padding 20px, drop-shadow `0px 1px 1px rgba(0,0,0,0.05)`.
   - 56x56 circular icon badge in `#EFF4FF` with camera/scanner icon `#3F1D8B`.
   - Title: "Scan Insurance Card" (`#0B1C30`, 18px semibold).
   - Subtitle: "Quickly capture your card details" (`#767676`, 14px).
   - Button: "Open Camera" (`#EFF4FF` background, `#3F1D8B` text, 16px semibold, rounded 12px).
   - Interactive camera/scan modal sheet with viewfinder simulation, card capture, and automatic pre-fill of Provider, Member ID, and Group Number.
5. **Card 2: Insurance Details Form (`20:33107` - `20:33134`)**:
   - White card with rounded 12px, drop-shadow `0px 1px 1px rgba(0,0,0,0.05)`.
   - Section header: Shield icon + "Insurance Details" (`#0B1C30`, 16px semibold).
   - Field 1: "Insurance Provider" (`#0B1C30`, 14px medium), input background `#EFF4FF`, hint "Enter provider name" (`#767676`, 16px).
   - Field 2: "Member ID" (`#0B1C30`, 14px medium), input background `#EFF4FF`, hint "Enter member ID" (`#767676`, 16px).
   - Field 3: "Group Number (Optional)" (`#0B1C30`, 14px medium), input background `#EFF4FF`, hint "Enter group number" (`#767676`, 16px).
6. **Inline Diagnostic Error Banner**:
   - Real-time display of backend errors (401 unauthenticated / database blocker) with retry and dismiss options, ensuring user input is never lost.
7. **Action Buttons (`20:33135` - `20:33145`)**:
   - Primary: "Save & Continue" gradient button (`from-[#A44CFF] to-[#5B14B8]`, rounded 9999px, height 52px, 16px bold white text + arrow icon) with loading indicator and duplicate-tap protection.
   - Secondary: "I'll do this later" underlined link (`#494552`, 14px medium) advancing to Step 5 with `isInsuranceSkipped = true`.
8. **Vault Security Trust Badge (`20:33146` - `20:33151`)**:
   - Rounded 8px badge in `#E5EEFF` with lock icon.
   - "Your insurance data is encrypted and stored in your private Care ID Vault." (`#494552`, 11px).

---

## 7. Next Target Screen: `Privacy & Consents` (Node `20:31164`) — Step 5 of 6 (Phase 6)
- **Frame Name**: `Privacy & Consents`
- **Figma Node ID**: `20:31164`
- **Dimensions**: `390 x 2549.5 pt`
- **Purpose**: Step 5 of 6. Patient privacy consent disclosures, HIPAA authorization, digital health card options, and data sharing controls.
- **Required Backend APIs**:
  - `POST /api/v1/patients/onboarding/health-card`
  - `POST /api/v1/family/consents`
  - `GET /api/v1/cms/policies`

---

## 8. Complete Onboarding Journey Map

```
[Splash_Screen (20:25191)]
          │
          ▼
[Welcome - Option 2 (20:19794)]  ◄─── (Phase 1 Entry Gateway — COMPLETED)
          │
          ├───► "I already have an account" ───► [Login (20:24965)]
          │
          └───► "Get Started"
                    │
                    ▼
          [CareID-Create Account (20:30644)] (Step 1 — COMPLETED IN PHASE 2)
                    │
                    ▼
          [Mobile_number (20:30756)] (Step 2: 6-Digit OTP — COMPLETED IN PHASE 3)
                    │
                    ▼
          [Health_info (20:30900)] (Step 3: Tell us about your health — COMPLETED IN PHASE 4)
                    │
                    ▼
          [Add Insurance Info (20:33068)] (Step 4: Primary Insurance — COMPLETED IN PHASE 5)
                    │
                    ▼
          [Privacy & Consents (20:31164)] (Step 5: Consents & Health Card — PHASE 6 TARGET)
                    │
                    ▼
          [Confirmed_Screen (20:31401)] (Step 6: Registration Complete)
                    │
                    ▼
          [Home - Option 6 (20:19552)] (Patient Main Dashboard)
```
