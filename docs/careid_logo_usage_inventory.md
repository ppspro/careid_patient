# CareID Patient App — Logo and Branding Usage Inventory

**Audit Date:** 2026-10-31  
**Figma Canvas:** `17:55` (`CAREID-AIO-FIGMA` — Careid patient app)  
**Codebase:** `C:\Users\PABANI\CareID_patient_app`  
**Authoritative Logo Assets in `assets/images/`:**
1. `careid_logo_horizontal.png` (928x200, Aspect Ratio 4.64:1) — Authorized Horizontal Header Lockup (Emblem + Wordmark).
2. `careid_emblem.png` (627x350, Aspect Ratio 1.79:1) — Authorized Compact Emblem / Shield Mark.
3. `careid_logo.png` (1248x747, Aspect Ratio 1.67:1) — Authorized Full Stacked Hero Logo.
4. `careid_wordmark.png` (1183x366, Aspect Ratio 3.23:1) — Authorized Wordmark-only Asset.

---

## Screen-by-Screen Logo Usage Inventory

| Screen | Figma Frame ID | Figma Logo Asset & Dimensions | Current Flutter Implementation | Mismatch Identified | Required Correction |
|---|---|---|---|---|---|
| **Splash Screen** | `20:25191` | `WhatsApp Image` (`20:25194`, 427x284) + `CareIDlogo 23` (25x17) | `CareIdLogo(width: 220, height: 124)` + `careid_splash_graphic.png` | Stacked logo scaled without variant control | Use `CareIdLogo.stacked(width: 200, height: 113)` above hero illustration |
| **Welcome Screen** | `20:19794` | `CareIDlogo 1` (`20:19804`, 200x113) stacked | `CareIdLogo(width: 200, height: 113)` | Vertical stacked logo rendered correctly; ensure no horizontal distortion | Use `CareIdLogo.stacked(width: 200, height: 113)` |
| **Create Account (Step 1)** | `20:30644` | `Care ID Logo` (`20:30660`, 107x64) | `CareIdLogo(size: 80)` | Defaulted to vertical stacked with unconstrained height | Use `CareIdLogo.stacked(width: 107, height: 64)` |
| **Mobile Number (Step 2)** | `20:30756` | `CareIDlogo 1` (`20:30894`, 79x18) in top bar | `CareIdLogo(size: 64)` | Rendered large stacked logo in 56px header | Use `CareIdLogo.horizontal(height: 18)` |
| **Health Info (Step 3)** | `20:30900` | `CareIDlogo 1` (`20:31158`, 79x18) in top bar | `CareIdLogo(size: 64)` | Rendered large stacked logo in 56px header | Use `CareIdLogo.horizontal(height: 18)` |
| **Privacy & Consents (Step 5)** | `20:31164` | `CareIDlogo 1` (`20:31395`, 79x18) in top bar | `CareIdLogo(height: 22)` without `isHorizontal` | Scaled vertical stacked logo; emblem clipped | Use `CareIdLogo.horizontal(height: 18)` |
| **Confirmed Screen (Step 6)** | `20:31401` | `CareIDlogo 1` (`20:31683`, 79x18) in top bar | `CareIdLogo(width: 140, showWordmark: true)` | Rendered stacked logo; bottom wordmark cut off | Use `CareIdLogo.horizontal(height: 18)` |
| **Login Screen** | `20:24965` | `CareIDlogo 1` (`20:25026`, 79x18) in top branding | `CareIdLogo(width: 130, showWordmark: true)` | Rendered stacked logo without `isHorizontal`; caused "ID" wordmark clipping | Use `CareIdLogo.horizontal(height: 18)` |
| **Biometric Setup** | `20:25097` | `CareIDlogo 2` (`20:25099`, 79x18) in top bar | `CareIdLogo(width: 140, showWordmark: true)` | Scaled stacked logo in top bar | Use `CareIdLogo.horizontal(height: 18)` |
| **Account Recovery** | `20:25143` | `CareIDlogo 1` (`20:25149`, 79x18) in top bar | `CareIdLogo(width: 140, showWordmark: true)` | Scaled stacked logo in top bar | Use `CareIdLogo.horizontal(height: 18)` |
| **Home — Option 6** | `20:19552` | `CareIDlogo 1` (`20:19759`, 79x18) in top app bar | `CareIdLogo(height: 26, isHorizontal: true)` | Height 26 made logo 121px wide; caused cropping in right margin | Use `CareIdLogo.horizontal(height: 18)` (width ~83.5px) |
| **Digital Health Card** | `20:19873` | `CareIDlogo 1` (`254:86`, 79x18) header + card vector | `CareIdLogo(width: 130, showWordmark: true)` | Top bar used stacked logo | Use `CareIdLogo.horizontal(height: 18)` for header |
| **Family Records Hub** | `20:30521` | `CareIDlogo 5` (`20:30640`, 25x17) emblem in top bar | `CareIdLogo(width: 28, showWordmark: false)` | Correct emblem, but width/height ratio unconstrained | Use `CareIdLogo.emblem(height: 18)` (width ~26px) |
| **Family Dashboard** | `20:21675` | `CareIDlogo 4` (`20:21817`, 25x17) emblem in top bar | Top bar missing brand emblem | Top bar omitted emblem | Use `CareIdLogo.emblem(height: 18)` |
| **Family Member List** | `20:21825` | `CareIDlogo 4` (`20:21991`, 25x17) emblem in top bar | Top bar omitted emblem | Missing brand emblem | Use `CareIdLogo.emblem(height: 18)` |
| **Add Family Member — Form** | `20:22023` | `CareIDlogo 4` (`20:22125`, 25x17) emblem in top bar | Top bar omitted emblem | Missing brand emblem | Use `CareIdLogo.emblem(height: 18)` |
| **Add Family Member — Review** | `20:19238` | `CareID logo` (`20:19394`, 25x18) emblem in top bar | In-progress implementation | Needs standard emblem | Use `CareIdLogo.emblem(height: 18)` |
| **Add Family Member — Access** | `20:19424` | `CareID logo` (`20:19521`, 25x18) emblem in top bar | In-progress implementation | Needs standard emblem | Use `CareIdLogo.emblem(height: 18)` |
| **Invitation Sent** | `20:19138` | `CareID logo` (`20:19208`, 25x18) emblem in top bar | `CareIdLogo(width: 80, showWordmark: true)` | Header used wordmark instead of emblem | Use `CareIdLogo.emblem(height: 18)` |
| **Medical Records (Vault)** | `20:31908` | `CareIDlogo 2` (`20:31872`, 80x18) horizontal | `CareIdLogo(width: 130, showWordmark: true)` | Used stacked logo | Use `CareIdLogo.horizontal(height: 18)` |
| **Vision Records** | `20:21301` | `CareIDlogo 5` (`20:21413`, 25x17) emblem | Standard icon used | Used medical icon instead of CareID emblem | Use `CareIdLogo.emblem(height: 18)` |
| **Vision Record Detail** | `20:25410` | `CareIDlogo 5` (`20:25649`, 25x17) emblem | `CareIdLogo(width: 26, showWordmark: false)` | Correct emblem | Maintain `CareIdLogo.emblem(height: 18)` |
| **Dental Record Detail** | `20:25653` | `CareIDlogo 5` (`20:25891`, 25x17) emblem | `CareIdLogo(width: 26, showWordmark: false)` | Correct emblem | Maintain `CareIdLogo.emblem(height: 18)` |
| **Medical Record Detail** | `20:25209` | `CareIDlogo 5` (`20:25375`, 25x17) emblem | `CareIdLogo(width: 26, showWordmark: false)` | Correct emblem | Maintain `CareIdLogo.emblem(height: 18)` |
| **Pet Care Records** | `20:26073` | `CareIDlogo 2` (`20:26151`, 80x18) horizontal | `CareIdLogo(width: 26, showWordmark: false)` | Used small emblem instead of full horizontal logo | Use `CareIdLogo.horizontal(height: 18)` |
| **Pet Record Detail** | `20:26229` | `CareIDlogo 5` (`20:26368`, 25x17) emblem | `CareIdLogo(width: 26, showWordmark: false)` | Correct emblem | Maintain `CareIdLogo.emblem(height: 18)` |
| **Insurance Dashboard** | `20:20059` | `CareIDlogo 2` (`20:26656`, 80x18) horizontal | `CareIdLogo(width: 130, showWordmark: true)` | Used stacked logo | Use `CareIdLogo.horizontal(height: 18)` |
| **Doctors Directory** | `20:28020` | `CareIDlogo 2` (`20:28277`, 79x18) horizontal | Standard back/title | Header used plain text | Add `CareIdLogo.horizontal(height: 18)` |
| **Patient Profile & Settings** | `20:24204` | Standard Title / Avatar | `CareIdLogo(width: 130, showWordmark: true)` | Used stacked logo in header | Use `CareIdLogo.horizontal(height: 18)` or standard title |
| **Notification Center** | `20:23812` | `CareIDlogo 21` (`20:23925`, 19x18) emblem | Standard Title | Standard Title | Use `CareIdLogo.emblem(height: 18)` in security strip |

---

## Core Brand Architecture & Guidelines

1. **Top App Bar Headers (General App Pages):**
   - **Variant:** `CareIdLogo.horizontal(height: 18)`
   - **Asset:** `assets/images/careid_logo_horizontal.png`
   - **Effective Size:** 83.5px width x 18px height (exact match for Figma 79-80px x 18px).
   - **Never use:** Stacked `careid_logo.png` inside an app bar header.

2. **Compact Headers & Specific Record/Family Hubs:**
   - **Variant:** `CareIdLogo.emblem(height: 18)`
   - **Asset:** `assets/images/careid_emblem.png`
   - **Effective Size:** 26px width x 18px height (exact match for Figma 25-27px x 17-18px).
   - **Never use:** Wordmark-only or chopped letters.

3. **Hero & Welcome Surfaces:**
   - **Variant:** `CareIdLogo.stacked(width: 200, height: 113)` or `CareIdLogo.stacked(width: 107, height: 64)`
   - **Asset:** `assets/images/careid_logo.png`
   - **Effective Size:** Aspect ratio 1.67:1 preserved.
   - **Never use:** Stretched horizontal banner in hero centers.


---

## 4. CareID-only ID Logo Placement & Dental Logo Standards (Updated 2026-11-02)

### A. CareID-only ID Monogram (`CareIdLogo.onlyId` / `CareIdLogo.emblem`)
- **Asset Source:** `assets/images/careid_only_id.png` (Aspect ratio: 344/237 = 1.451:1)
- **Figma Specification:** 25px x 17px or 26px x 18px (Figma nodes `CareIDlogo 4`, `5`, `14`, `21-35`).
- **Standardized Implementations:**
  1. `lib/features/patient/presentation/screens/dental_records_screen.dart` (AppBar action)
  2. `lib/features/patient/presentation/screens/dental_record_detail_screen.dart` (Header ID lockup)
  3. `lib/features/patient/presentation/screens/vision_records_screen.dart` (AppBar action)
  4. `lib/features/patient/presentation/screens/vision_record_detail_screen.dart` (Header ID lockup)
  5. `lib/features/patient/presentation/screens/medical_records_screen.dart` (Header center)
  6. `lib/features/patient/presentation/screens/medical_record_detail_screen.dart` (Header ID lockup)
  7. `lib/features/patient/presentation/screens/pet_record_detail_screen.dart` (Header ID lockup)
  8. `lib/features/patient/presentation/screens/insurance_qr_screen.dart` (Header action + Center QR matrix embed)
  9. `lib/features/patient/presentation/screens/insurance_card_details_screen.dart` (Header action)
  10. `lib/features/patient/presentation/screens/insurance_card_camera_screen.dart` (Header action)
  11. `lib/features/patient/presentation/screens/insurance_ocr_processing_screen.dart` (Header action)
  12. `lib/features/patient/presentation/screens/insurance_ocr_results_screen.dart` (Header action)
  13. `lib/features/patient/presentation/screens/family_dashboard_screen.dart` (Header action)
  14. `lib/features/patient/presentation/screens/family_records_screen.dart` (Header action)
  15. `lib/features/patient/presentation/screens/family_consent_requests_screen.dart` (Header action)
  16. `lib/features/patient/presentation/screens/member_permissions_sharing_screen.dart` (Header action)
  17. `lib/features/patient/presentation/screens/shared_medical_records_screen.dart` (Header action)
  18. `lib/features/patient/presentation/screens/invitation_sent_screen.dart` (Header action)

### B. Approved Dental Logo Standard (`CareIdDentalLogo`)
- **Design Specification:** Dual-cusp anatomical molar tooth vector in `#0284C7` (Cyan Blue) with center occlusal groove and rounded root bifurcation.
- **Background Badge Accent:** Optional soft cyan `#E0F2FE` rounded container with subtle border.
- **Prohibited Icons Replaced:** Generic band-aid (`Icons.healing_outlined`) and generic shield (`Icons.health_and_safety_rounded`) completely deprecated and replaced across:
  - `dental_records_screen.dart` (Category header banner, summary card, record list items)
  - `dental_record_detail_screen.dart` (Record tag & procedure header)
  - `medical_records_screen.dart` (Dental Vault filter chip + dental record cards in All Records stream)
  - `add_health_record_screen.dart` (Record Category selector)
  - `service_feature_card.dart` (`ServiceType.dental` card icon)
