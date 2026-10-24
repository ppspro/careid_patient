# CareID Patient Mobile App — Phase 1

CareID Patient Mobile Application initialized from Figma designs (`CAREID-AIO-FIGMA`, node `17-55`) and integrated with the CareID backend API (`https://360api.vnvision.in`).

---

## 1. Phase 1 Overview

- **Target Figma Canvas**: `Careid patient app` (Node ID: `17:55`)
- **First Screen Implemented**: `Welcome - Option 2` (Node ID: `20:19794`)
- **Screen Dimensions**: 390 x 1072 pt (Mobile responsive viewport)
- **Framework**: Flutter / Dart
- **Backend API**: `https://360api.vnvision.in` (Verified OpenAPI 3.0.0 & live health check)

---

## 2. Project Architecture

The project follows a clean, feature-first modular architecture separating UI presentation, domain models, network contracts, and design tokens:

```
CareID_patient_app/
├── analysis_options.yaml           # Linting and static analysis configuration
├── pubspec.yaml                    # Flutter project specification & dependencies
├── assets/
│   └── images/
│       └── careid_logo.svg         # Official CareID vector logo with healthcare icons
├── lib/
│   ├── main.dart                   # Application entry point
│   ├── app.dart                    # Root MaterialApp and theme binding
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart     # Environment config, base URL (https://360api.vnvision.in)
│   │   ├── constants/
│   │   │   ├── api_endpoints.dart  # Verified API routes matching backend OpenAPI spec
│   │   │   └── app_strings.dart    # User-facing strings (English and Spanish)
│   │   ├── network/
│   │   │   ├── api_client.dart     # Central HTTP client (timeouts, auth headers, error handling)
│   │   │   └── api_result.dart     # Functional Result type (ApiSuccess / ApiFailure)
│   │   ├── storage/
│   │   │   └── token_storage.dart  # Secure token storage contract & implementation
│   │   └── theme/
│   │       ├── app_colors.dart     # Figma color tokens (Purples, Teals, Slates, Badges)
│   │       ├── app_spacing.dart    # Padding, border radii, card and button shadows
│   │       ├── app_theme.dart      # Material 3 ThemeData definition
│   │       └── app_typography.dart # Font styles, sizes, and line-heights matching Figma
│   ├── shared/
│   │   └── widgets/
│   │       ├── careid_logo.dart    # CareID cloud & wordmark custom painter widget
│   │       ├── language_toggle.dart# Interactive 'EN / ESP' pill selector
│   │       ├── primary_button.dart # Vibrant purple gradient CTA button ("Get Started →")
│   │       ├── secondary_button.dart# Outlined teal button ("I already have an account")
│   │       └── service_feature_card.dart # Medical, Dental, Vision, Pets category cards
│   └── features/
│       ├── auth/
│       │   └── data/models/
│       │       ├── auth_tokens.dart # Access/refresh token models
│       │       └── patient_registration.dart # RegisterPatientResponseDto model
│       └── onboarding/
│           └── presentation/screens/
│               ├── welcome_screen.dart # Phase 1 First Screen (Figma 20:19794)
│               └── create_account_screen.dart # Step 1 Registration (Figma 20:30644)
└── test/
    ├── run_tests.dart              # Standalone automated verification test runner
    └── core/
        ├── api_endpoints_test.dart # Endpoint validation suite
        ├── api_health_integration_test.dart # Live backend connectivity test
        ├── api_result_test.dart    # Result pattern matching suite
        └── models_test.dart        # DTO deserialization suite
```

---

## 3. Figma Design Inspection (Node 17:55 & 20:19794)

| Property | Figma Specification | Implementation |
|---|---|---|
| **Canvas** | `Careid patient app` (17:55) | Root Page in Figma |
| **Frame Name** | `Welcome - Option 2` (20:19794) | `WelcomeScreen` (`welcome_screen.dart`) |
| **Dimensions** | 390 x 1072 pt | Fluid Safe Area, `BoxConstraints(maxWidth: 440)` |
| **Screen Background**| `#F4F7FB` | `AppColors.background` |
| **Card Container** | `#FFFFFF`, Radius: 24, Ambient Shadow | `AppColors.surface`, `AppSpacing.cardShadow` |
| **Branding Logo** | CareID Cloud with 5 healthcare icons | `CareIdLogo` (`careid_logo.dart`) |
| **Header Title** | "Your Health All In One Place" (28pt, w800, `#2E1065`) | `AppTypography.heading1` |
| **Subtitle** | "Securely store and share your verifiable health records..." | `AppTypography.subtitle` |
| **Service Cards** | Medical, Dental, Vision, Pets | `ServiceFeatureCard` (`service_feature_card.dart`) |
| **Primary CTA** | "Get Started →" (Purple Gradient, Pill) | `PrimaryButton` (`primary_button.dart`) |
| **Secondary CTA**| "I already have an account" (Teal Border, White Bg) | `SecondaryButton` (`secondary_button.dart`) |
| **Language Toggle**| "EN" / "ESP" Pill Switcher | `LanguageToggle` (`language_toggle.dart`) |

---

## 4. Backend API Verification (`https://360api.vnvision.in`)

The backend API was inspected via its live OpenAPI 3.0 specification at `https://360api.vnvision.in/docs`.

### Live Health Check
- **Endpoint**: `GET /api/v1/health`
- **Verified Status**: `200 OK`
- **Response**:
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Operation executed successfully",
  "data": {
    "status": "ok",
    "timestamp": "2026-10-24T09:23:52.134Z",
    "service": "HVAPI Backend"
  }
}
```

### Key Verified Endpoints for Onboarding & Auth
- `POST /api/v1/patients/register` — Step 1: Initialize Patient Draft Registration
- `GET /api/v1/patients/register/status` — Check Draft Registration Progress Status
- `POST /api/v1/auth/otp/request` — Request Phone OTP
- `POST /api/v1/auth/otp/verify` — Verify Phone OTP & Login (returns JWT tokens)
- `POST /api/v1/patients/onboarding/demographics` — Step 2: Patient Demographic Registration
- `POST /api/v1/patients/onboarding/emergency-contact` — Step 3: Save Emergency Contact
- `POST /api/v1/patients/onboarding/insurance` — Step 4: Primary/Secondary Insurance Link
- `POST /api/v1/patients/onboarding/health-card` — Step 5: Initialize Secure Digital Health Card
- `POST /api/v1/patients/onboarding/complete` — Step 6: Finalize Onboarding Registration

---

## 5. Verification Commands

### Formatter
```powershell
dart format .
```

### Automated Test Suite
```powershell
dart run test/run_tests.dart
```

---

## 6. Recommended Next Frame for Phase 2

- **Next Frame Name**: `CareID-Create Account` (Node ID: `20:30644`)
- **Dimensions**: 390 x 911 pt
- **Description**: Step 1 Patient Registration Form collecting Full Name, Mobile Number, Email, Password, and Consent. Connected to `POST /api/v1/patients/register`.
- **Subsequent Frame**: `Mobile_number` (Node ID: `20:30756`), Step 2: Mobile Phone Verification (6-digit OTP).
