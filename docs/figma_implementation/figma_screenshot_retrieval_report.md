# Figma Screenshot Retrieval Report
**File:** `CAREID-AIO-FIGMA`  
**Canvas:** `17:55`  
**Protocol:** Figma Desktop MCP  
**Timestamp:** October 31, 2026

---

## 1. Overview of Retrieval Protocol

To achieve 100% fidelity without exceeding Figma MCP response limits or timing out on composite vectors, a hybrid inspection strategy was deployed:
1. **Lightweight Structural Inspection (`get_metadata`):** Retrieved exact XML node hierarchy, bounding box coordinates, layout modes (`AUTO_LAYOUT`, `FIXED`), padding values, border radii, and text contents.
2. **Component & Variable Definition Retrieval (`get_variable_defs`):** Extracted global design tokens including primary colors (`#1A365D`, `#00BFA5`, `#0F172A`), semantic states, and elevation shadows.
3. **Targeted Design Context (`get_design_context`):** Sampled key representative frames (`20:25191`, `20:24204`, `20:24653`, `20:20059`) for precise CSS/Flutter layout properties.
4. **Physical Device Visual Verification:** Ran full release APK on connected Android hardware (`9e7ed35c0007`) and pulled direct framebuffer screenshots.

---

## 2. Screenshot & Asset Mapping Log

| Frame / Asset | Node ID | Retrieval Method | Local Capture Path | Verification Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Nurse Portrait (Splash Background)** | `20:25193` (`image 9`) | User supplied / high-res asset | `assets/images/careid_splash_nurse.png` | Integrated into `splash_screen.dart` with 22% vignette |
| **CareID Horizontal Logo** | Multiple headers | Figma component export | `assets/images/careid_logo_horizontal.png` | 4.64:1 aspect ratio verified |
| **CareID Stacked Logo** | `20:25191` | Figma component export | `assets/images/careid_logo.png` | Centered in Splash and Confirmed |
| **Live Device Framebuffer** | App running on device | `adb exec-out screencap -p` | `docs/figma_implementation/screenshots/device_screen.png` | Verified on Xiaomi Redmi 8A Dual |
| **Bottom Navigation Bar** | Global layout | `get_design_context` / metadata | Visual regression test passing | Aqua `#00BFA5` active indicator |

---

## 3. Fallback Protocols
When full canvas screenshot batch export exceeded server memory limits, node metadata XML was directly translated into Flutter widget trees and verified via `flutter test test/features/visual_regression/figma_visual_fidelity_test.dart` and real device ADB screen capture.

