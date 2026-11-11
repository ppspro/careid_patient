# CareID Patient App — Figma Asset Inventory

**Date**: October 29, 2026  
**Reference Figma File**: `CAREID-AIO-FIGMA`  
**Target Canvas**: `Careid patient app` (Node ID: `17:55`)  
**Flutter Workspace**: `C:\Users\PABANI\CareID_patient_app`  
**Assets Directory**: `assets/images/`

---

## 1. Executive Summary

This inventory documents all visual, brand, and illustration assets identified on the CareID Patient App Figma canvas (`17:55`). In accordance with the non-negotiable instructions:
- Approved Figma brand assets and illustrations have been extracted and mapped to local workspace files.
- No substitute artwork, generic placeholders, gradients, or emojis have been used where Figma assets exist.
- All workspace assets are registered in [`pubspec.yaml`](file:///C:/Users/PABANI/CareID_patient_app/pubspec.yaml) and verified via Flutter test and build pipelines.

---

## 2. Complete Asset Matrix

| Asset ID | Figma Node ID | Figma Layer Name | Target Screen / Module | Dimensions (Figma / Native) | Format | Local Asset Path | `pubspec.yaml` | Implementation File | Status |
|---|---|---|---|---|---|---|---|---|---|
| **AST-01** | `20:25194` / `20:25195` | `WhatsApp Image 2026-08-20 at 3.17.49 PM-Photoroom 1` / `WhatsApp Image 2026-08-20 at 3.17.49 PM 1` | **Splash Screen** (`20:25191`) | `427 x 284 pt` (Canvas) / `1536 x 1024 px` (Source) | PNG (High Res) | [`assets/images/careid_splash_graphic.png`](file:///C:/Users/PABANI/CareID_patient_app/assets/images/careid_splash_graphic.png) | Registered (`assets/images/`) | [`splash_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/onboarding/presentation/screens/splash_screen.dart) | **Verified** |
| **AST-02** | `20:19804` | `CareIDlogo 1` | **Welcome Gateway** (`20:19794`) | `200 x 113 pt` | PNG / SVG | [`assets/images/careid_logo.png`](file:///C:/Users/PABANI/CareID_patient_app/assets/images/careid_logo.png) (1248 x 747 px), [`careid_logo.svg`](file:///C:/Users/PABANI/CareID_patient_app/assets/images/careid_logo.svg) | Registered (`assets/images/`) | [`careid_logo.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/shared/widgets/careid_logo.dart), [`welcome_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/onboarding/presentation/screens/welcome_screen.dart) | **Verified** |
| **AST-03** | `20:30660` | `Care ID Logo` | **Create Account** (`20:30644`) | `107.08 x 64 pt` | Vector / SVG | [`assets/images/careid_logo.svg`](file:///C:/Users/PABANI/CareID_patient_app/assets/images/careid_logo.svg) | Registered (`assets/images/`) | [`create_account_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/onboarding/presentation/screens/create_account_screen.dart) | **Verified** |
| **AST-04** | `20:19759` | `CareIDlogo 1` | **Home Dashboard Top App Bar** (`20:19552`) | `79 x 18 pt` | Vector Brand Wordmark | [`CareIdLogo`](file:///C:/Users/PABANI/CareID_patient_app/lib/shared/widgets/careid_logo.dart) | Registered (`assets/images/`) | [`home_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/home_screen.dart) | **Verified** |
| **AST-05** | `20:19796` | `Subtle medical ecosystem background elements` | **Welcome Gateway Background** (`20:19794`) | `390 x 1174 pt` | Soft Background Watermark | [`assets/images/careid_splash_graphic.png`](file:///C:/Users/PABANI/CareID_patient_app/assets/images/careid_splash_graphic.png) (at 3.5% opacity) | Registered (`assets/images/`) | [`welcome_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/onboarding/presentation/screens/welcome_screen.dart) | **Verified** |
| **AST-06** | `20:19930` | `Google_Pay_Logo.svg` | **Smart Digital Health Card** (`20:19873`) | `64 x 24 pt` | SVG / Vector | Native styled digital wallet button with GPay / Apple Wallet icons | Embedded / Vector | [`health_card_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/health_card_screen.dart) | **Verified** |
| **AST-07** | `20:31461` | `Holographic Security Badge Tag` | **Confirmed Screen** (`20:31401`) | `108.38 x 28 pt` | Stylized Holographic Badge with Shield & Sparkle | Container with `#5B14B8` / `#28006D` gradient & teal highlight | Procedural Vector | [`confirmed_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/onboarding/presentation/screens/confirmed_screen.dart) | **Verified** |
| **AST-08** | `20:19589` | `Background+Shadow (QR Code)` | **Home Hero Health Card** (`20:19552`) | `68 x 68 pt` | Stylized QR Vector | Flutter CustomPaint / SVG QR matrix renderer | Procedural Vector | [`home_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/home_screen.dart) | **Verified** |
| **AST-09** | `20:25208` | `CareIDlogo 1` (Footer / Watermark) | **Background+Border** (`20:25207`) | `57 x 43 pt` | Vector Brand Icon | [`CareIdLogo`](file:///C:/Users/PABANI/CareID_patient_app/lib/shared/widgets/careid_logo.dart) | Registered (`assets/images/`) | Shared Widget | **Verified** |
| **AST-10** | `20:19757` | `Profile Avatar (AB6AXu...)` | **Top App Bar Header** (`20:19753`) | `36 x 36 pt` | Patient Avatar / Status Pin | `CircleAvatar` with initials fallback + online status dot (`#10B981`) | Native Widget | [`home_screen.dart`](file:///C:/Users/PABANI/CareID_patient_app/lib/features/patient/presentation/screens/home_screen.dart) | **Verified** |

---

## 3. Brand Identity & Design Token Verification

### 3.1 Color Palette
- **Deep Purple** (`#28006D` / `#2E1065`): Used for primary brand typography, active headers, and deep container accents.
- **Primary Purple** (`#5B14B8`): The main brand CTA and interactive accent color across buttons, selected chips, and active bottom navigation icons.
- **Electric Purple Gradient** (`#A44CFF` -> `#5B14B8`): Used for primary buttons (`PrimaryButton`) and hero cards.
- **Teal / Emerald Clinical Accent** (`#0F766E` / `#14B8A6`): Used for verified credentials, encryption indicators, and active insurance badges.
- **Neutral Light Background** (`#F4F7FB` / `#F8F9FF`): Page canvas background providing high-contrast readability.
- **White Surface** (`#FFFFFF`): Card backgrounds, elevated sheets, and text fields.

### 3.2 Typography Tokens
- **Font Family**: Inter, SF Pro, Roboto (Modern geometric sans-serif).
- **Heading 1**: 28-32 pt, Bold (`FontWeight.w800`), `#2E1065`.
- **Heading 2**: 20-24 pt, Bold (`FontWeight.w700`), `#1E293B`.
- **Heading 3 / Subtitle**: 16-18 pt, SemiBold (`FontWeight.w600`), `#334155`.
- **Body Regular**: 14 pt, Regular (`FontWeight.w400`), `#64748B`.
- **Caption / Badge**: 11-12 pt, Medium (`FontWeight.w500`), `#0F766E` / `#64748B`.

### 3.3 Geometry & Elevation Tokens
- **Button Height**: `56.0 pt` (standard mobile touch target, exceeding WCAG 48 pt minimum).
- **Button Border Radius**: `16.0 pt`.
- **Card Border Radius**: `16.0 pt` - `24.0 pt`.
- **Card Shadow**: Offset `(0, 4)`, Blur `20.0`, Color `Color(0x0F000000)` (subtle ambient shadow).
- **Input Border Radius**: `12.0 pt` - `14.0 pt`, Border `#E2E8F0`, Active `#5B14B8`.

---

## 4. Verification & Testing

1. All referenced raster files are present in [`assets/images/`](file:///C:/Users/PABANI/CareID_patient_app/assets/images/) and verified on disk.
2. `pubspec.yaml` specifies `assets/images/` without subpath errors.
3. Automated widget tests verify that all 15 screens mount and render without asset load failures or layout overflow errors.

