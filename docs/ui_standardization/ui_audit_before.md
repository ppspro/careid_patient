# CareID Patient App — UI Audit Before Standardization

**Project:** `C:\Users\PABANI\CareID_patient_app`  
**Figma Canvas:** `17:55` (`Careid patient app`)  
**Date:** October 31, 2026  

---

## 1. Executive Summary

A comprehensive visual consistency audit was performed across all 65 Patient App screens, widgets, and dialogs before applying standardization changes.

While functional coverage and API connections were in place, significant visual discrepancies existed across:
1. **Bottom Navigation Tab Highlight Colour:** The selected tab highlight utilized an unapproved purple tint (`Color(0x1F5B14B8)` pill and `Color(0xFF5B14B8)` icon) instead of the approved active aqua/teal token specified in the Figma design system (`#00BFA5`).
2. **Page Header Inconsistencies:** Screen headers varied widely across three competing implementations: custom container rows with differing heights (56px, 64px, 72px), Material 3 standard `AppBar`, and arbitrary `PreferredSize` blocks with mismatched back button paddings and logo placements.
3. **Profile & Settings Header Imbalance:** `patient_profile_screen.dart` lacked a proper right-aligned Settings action, had misaligned language toggles, and did not reflect the Figma frame `20:24204` / `20:24443` top navigation structure.
4. **Logo Asset Inconsistencies:** Multiple screens used isolated emblems (`CareIdLogo.emblem`) in top bars where the full horizontal brand mark (`CareIdLogo.horizontal`) was required by Figma, or lacked proper constrained aspect ratios.

---

## 2. Inconsistencies & Defects by Category

### A. Bottom Navigation Active State (`CareIdBottomNavigationBar`)
- **Figma Reference:** Nodes `20:19764` ("Bottom Nav Bar (Mobile)"), `20:24622`, `20:30432`.
- **Existing Implementation Defect:** Selected tab icon and pill container used CareID brand purple (`0xFF5B14B8`).
- **Approved Design Token:** Figma design system specifies `#00BFA5` (Aqua/Teal) for the selected tab indicator and active label.

### B. Header Height & Alignment Discrepancies
- **Figma Reference:** 64px fixed height top navigation bar with safe-area padding, 18px horizontal CareID logo (`careid_logo_horizontal.png`, natural ratio 4.64:1), and standardized iOS-style chevron back icon (`Icons.arrow_back_ios_new_rounded`, 18-20px).
- **Existing Implementation Defect:**
  - 17 screens used standard M3 `AppBar` (56px) without consistent logo placement.
  - 30 screens rendered headers as body children without safe-area alignment.
  - Several screens rendered an emblem logo (`CareIdLogo.emblem`) on the right action bar instead of functional controls.

### C. Profile and Settings Hub (`patient_profile_screen.dart`)
- **Figma Reference:** Frame `20:24204` ("Profile & Settings Hub") / Node `20:24443` ("Header - Top AppBar").
- **Existing Implementation Defect:**
  - Left-aligned title with no dedicated Settings icon button.
  - Inconsistent spacing when back navigation was toggled.
  - No direct quick access to security & privacy controls from the top app bar.

### D. Logo Asset Usage
- **Figma Reference:** `assets/images/careid_logo_horizontal.png`.
- **Existing Implementation Defect:** `reschedule_appointment_screen.dart`, `invitation_sent_screen.dart`, and `family_dashboard_screen.dart` used partial emblem crops instead of the standardized horizontal logo.

