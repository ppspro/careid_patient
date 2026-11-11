# CareID Patient App — Comprehensive Visual Consistency Audit

**Audit Date:** 2026-10-31  
**Figma Canvas:** `17:55` (`CAREID-AIO-FIGMA` — Careid patient app)  
**Workspace:** `C:\Users\PABANI\CareID_patient_app`  
**Physical Test Device:** `9e7ed35c0007` (Android)

---

## 1. Executive Summary

This visual consistency audit examines the CareID Patient App Flutter implementation against the approved Figma designs across all 87 frames of Canvas `17:55`. The audit evaluated 16 visual dimensions:
1. Logo and Branding Architecture
2. Header Layout & Top App Bar Specifications
3. Navigation Bars & Selected States
4. Typography, Font Weights & Text Hierarchies
5. Colors & Gradient Tokens
6. Icons & Illustrations
7. Image Assets & Proportions
8. Card Dimensions, Shadows & Corner Radii
9. Spacing, Margins & Padding Consistency
10. Buttons, CTA Heights & Interactive States
11. Form Controls, TextFields & Focus Rings
12. Bottom Sheets, Dialogs & Modals
13. Scrolling Physics & Viewport Containment
14. Safe Area Insets & Edge-to-Edge Behavior
15. Responsive Constraints & Overflow Prevention
16. State Fidelity: Loading Skeletons, Empty Vaults & Error Recovery

---

## 2. Comprehensive Findings & Inconsistency Matrix

### A. Logo & Branding Inconsistencies (High Priority)
- **Problem:** `careid_logo.png` (a vertical stacked logo, ratio 1.67:1) was being invoked inside 56px and 64px top headers with arbitrary widths (`width: 130` or `size: 64`). Because no `height` or `isHorizontal: true` was passed, the image container forced vertical scaling, resulting in cropped wordmarks (showing only "CareID" or "ID") or compressed emblems.
- **Figma Source of Truth:**
  - Standard headers use `CareIDlogo 1` / `CareIDlogo 2` with exact dimensions `79x18` or `80x18` (Horizontal lockup: emblem on left, wordmark on right).
  - Discipline detail and family hubs use `CareIDlogo 4` / `CareIDlogo 5` with dimensions `25x17` or `25x18` (Compact emblem only).
  - Hero onboarding surfaces use `CareIDlogo 1` (`200x113` or `107x64`, vertical stacked).
- **Remediation:** Refactor `CareIdLogo` to expose named constructors: `CareIdLogo.horizontal({double height = 18})`, `CareIdLogo.emblem({double height = 18})`, and `CareIdLogo.stacked({double? width, double? height})`.

### B. Top App Bar & Header Layout
- **Inconsistency:** Header heights varied between `56`, `60`, and `64` across different screens. Back-button icons varied between `Icons.arrow_back` and `Icons.arrow_back_ios_new_rounded`.
- **Figma Source of Truth:**
  - Standard top app bar frame height across all canvas screens is **64px** (`y=0` to `y=64`, width `390`).
  - Leading navigation uses an iOS-style rounded back chevron (`Icons.arrow_back_ios_new_rounded`, 20px, `#28006D`).
  - Center or leading brand element uses the 18px horizontal logo or compact emblem.
  - Trailing action contains either a language selector, a notification badge, or an add action button.

### C. Bottom Navigation Bar & Selected States
- **Inconsistency:** Previous builds had bottom navigation items with inconsistent label sizing and unselected tinting.
- **Figma Source of Truth:**
  - Frame `20:19764` (`Bottom Nav Bar (Mobile)`): 73px height, white background, `#E7ECF6` top border.
  - 4 Navigation Items: **Home** (icon: home), **Records** (icon: folder/records), **Doctors** (icon: medical personnel), **Profile** (icon: user).
  - Active item: `#5B14B8` deep violet with 12px bold font and subtle pill indicator.
  - Inactive item: `#94A3B8` slate with 12px medium font.

### D. Card Dimensions, Corner Radii & Shadows
- **Inconsistency:** Some cards used `BorderRadius.circular(12)` while others used `16` or `20`.
- **Figma Source of Truth:**
  - Primary Bento Hero Cards (Health Card, Insurance Hero, Vault Summary): **BorderRadius: 20px**, border: 1px `#E2E8F0`, shadow: `BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))`.
  - Secondary List Cards (Medical Record Card, Doctor Card, Appointment Card): **BorderRadius: 16px**, border: 1px `#E7ECF6`, shadow: `BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2))`.
  - Filter Chips / Pills: **BorderRadius: 9999px** (fully rounded pill).

### E. Typography & Color Palette
- **Figma Source of Truth Tokens:**
  - **Primary Brand Purple:** `#28006D` (Deep Indigo) / `#5B14B8` (Vibrant Violet).
  - **Background Scaffold:** `#F8F9FE` / `#F8FAFC`.
  - **Surface White:** `#FFFFFF`.
  - **Border Gray:** `#E7ECF6` / `#E2E8F0`.
  - **Text Primary:** `#0F172A` (Slate 900) / `#28006D`.
  - **Text Secondary:** `#64748B` (Slate 500).
  - **Success Green:** `#10B981` (Emerald).
  - **Warning Amber:** `#F59E0B`.
  - **Dental Discipline:** `#0284C7` (Sky Blue) & `#E0F2FE`.
  - **Vision Discipline:** `#6366F1` (Indigo) & `#EEF2FF`.

---

## 3. Remediation Plan

1. **Phase 2 (Logo Refactoring):**
   - Update `lib/shared/widgets/careid_logo.dart` to support named constructors: `.horizontal()`, `.emblem()`, and `.stacked()`.
   - Update `HomeScreen`, `LoginScreen`, `ConfirmedScreen`, `PrivacyConsentsScreen`, `MobileNumberScreen`, `HealthInfoScreen`, and other screens to use the exact matching variant.
2. **Phase 3 (Header & Navigation Normalization):**
   - Standardize all app bars to 64px height with `#28006D` icons and consistent typography.
3. **Phase 4 (Family Sharing & Dependent Management Implementation):**
   - Implement the 6 planned Figma screens:
     1. `Family Member List` (`20:21825`)
     2. `Family Dashboard` (`20:21675`)
     3. `Add Family Member — Form` (`20:22023`)
     4. `Add Family Member — Review` (`20:19238`)
     5. `Add Family Member — Access` (`20:19424`)
     6. `Invitation Sent` (`20:19138`)

