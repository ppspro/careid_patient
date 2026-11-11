# 07. CareID Patient App — Screen-by-Screen Figma Implementation & Visual Audit Matrix

**Audit Date:** November 2, 2026  
**Design Reference:** `CAREID-AIO-FIGMA` (Patient App Canvas `17:55` — `Careid patient app`)  
**Backend Reference:** `https://360api.vnvision.in` & `CareID-Staging.postman_collection.json`  
**Target Device:** Xiaomi Redmi 8A Dual (`9e7ed35c0007`)  

---

## 1. Executive Summary & Audit Methodology

This document establishes the definitive, screen-by-screen audit matrix comparing every approved Figma frame on Canvas `17:55` against its corresponding Flutter screen implementation in `C:\Users\PABANI\CareID_patient_app`.

Each screen is audited across 7 core dimensions:
1. **Figma Frame & Node ID:** Authoritative canvas coordinates and dimensions.
2. **Flutter Screen & Source File:** Concrete implementation path.
3. **Layout & Component Hierarchy:** Structural layout, headers, cards, lists, FABs, and bottom navigation.
4. **Typography:** Font families (Plus Jakarta Sans, Inter), font sizes, weights, line heights.
5. **Colors & Spacing:** Theme tokens, border radii, shadow elevations, padding and margins.
6. **Iconography & Logos:** Authoritative CareID logo lockup (full horizontal vs. 25×17 ID monogram) and approved Dental molar tooth vector (`CareIdDentalLogo` in `#0284C7`).
7. **API Integration & Resilience:** Endpoints called, response handling, error fallbacks, and offline continuity.

---

## 2. Module-by-Module Audit Matrix

### Module 1: Medical Records

| Figma Node & Name | Flutter Source | Layout & Structure | Typography & Styling | Icons & Logos | API Contract | Status & Corrections |
|---|---|---|---|---|---|---|
| **Medical Records**<br>`20:31908` (390x1272) | `medical_records_screen.dart` | Figma features Encrypted Vault status card (Care ID Vault, 160px height), search bar (56px) + filter button, horizontal category chips (All, Lab, Rx, Vaccines), Health Timeline with provider info and 'View Document' action, FAB (+), and 5-tab BottomNav. Flutter implements unified records list and vaccine view. | Figma uses Plus Jakarta Sans / Inter; headings are 20px Bold (#28006D). Flutter uses AppColors.purpleDark and TextStyle Inter/Plus Jakarta Sans.<br>Status card uses gradient #3F1D8B -> #1A004C. Chips use #F1F5F9 unselected and #8B30E6 selected. | Figma node 20:32053 uses Back Arrow + Title 'Medical Records' on left, CareIDlogo 5 (25x17) and Bell + Avatar on right. Dental chip & cards correctly use CareIdDentalLogo molar tooth. | `GET /api/v1/medical-records, POST /api/v1/medical-records` | **Audited**<br>Align Top AppBar layout with Figma node 20:32053 (Back button + Title 'Medical Records' on left, CareID ID monogram + Avatar on right, 64px height). |
| **Care ID - Health Records Landing (Refined)**<br>`20:25209` (390x1386) | `medical_records_screen.dart` | Alternative refined landing with 4 primary discipline cards (Medical, Dental, Vision, Pets), Encrypted Vault status banner, and prominent Floating Action Button. | Header 20px Bold (#28006D), Card subtitles 12px Regular (#64748B).<br>Medical cards have colored squircle icon backgrounds matching AppColors. | Node 20:25375 specifies CareIDlogo 5 (25x17). | `GET /api/v1/medical-records` | **Audited**<br>Ensure seamless switching between All Records stream and Category Vault cards. |
| **Add Health Record**<br>`20:33245` (375x1228) | `add_health_record_screen.dart` | Multi-field form with Record Category selector (Medical, Dental, Vision), Vitals inputs (BP, Heart Rate, Temp), Chief Complaint, Clinical Notes, Attachments, and Primary Save button. | Form labels 13px SemiBold (#334155), inputs 15px Regular.<br>Selected category border #8B30E6 with 8% opacity tint. | Dental category correctly uses CareIdDentalLogo molar tooth vector #0284C7. | `POST /api/v1/medical-records` | **Audited**<br>Verify responsive padding on smaller screens and ensure keyboard dismiss does not obscure Save CTA. |
| **Document Viewer**<br>`20:32097` (390x936) | `document_viewer_screen.dart` | Full-height document viewer with header back button, document title, zoom controls, and share/download bottom bar. | Header 18px SemiBold (#0F172A), metadata 12px Regular.<br>Dark mode / high-contrast PDF container with #0F172A backdrop. | CareIdLogo.onlyId in header action. | `GET /api/v1/medical-records/:id/attachment` | **Audited**<br>Ensure graceful fallback when document is a scanned image vs PDF. |

---

### Module 2: Vision Records

| Figma Node & Name | Flutter Source | Layout & Structure | Typography & Styling | Icons & Logos | API Contract | Status & Corrections |
|---|---|---|---|---|---|---|
| **Vision Records - Timeline & Vault**<br>`20:21301` (390x1272) | `vision_records_screen.dart` | Header (64px) with back button, 'Vision Records' title, CareIDlogo 5, and avatar; summary card with Encrypted Vault status, Search & Filter, horizontal filter chips, vision timeline items, FAB (+), and bottom navigation. | Heading 1 20px Bold (#28006D), metric values 16px Bold (#0284C7).<br>Theme accent #0284C7 (Vision Cyan/Blue) and #E0F2FE container backgrounds. | Node 20:21413 has CareIDlogo 5 (25x17). | `GET /api/v1/medical-records (filtered by category=VISION)` | **Audited**<br>Standardize Top AppBar to use 64px custom header with Back + 'Vision Records' title and CareIdLogo.onlyId. |
| **Care ID - Vision Record Detail**<br>`20:25410` (390x2030) | `vision_record_detail_screen.dart` | Comprehensive clinical detail view: verified security strip, hero optical image/scan card, 4 quick actions (Share, Download, Print, Add to Wallet), provider info, clinical details, prescription metrics, and attachments. | Section headers 16px Bold (#1E293B), clinical values 14px Regular.<br>Cyan accents #0284C7 on #F0FDF4 / #F8FAFC card backgrounds. | Node 20:25649 specifies CareIDlogo 5 (25x17) in header lockup. | `GET /api/v1/medical-records/:id` | **Audited**<br>Verify quick action row layout and card shadow elevations. |

---

### Module 3: Family Records

| Figma Node & Name | Flutter Source | Layout & Structure | Typography & Styling | Icons & Logos | API Contract | Status & Corrections |
|---|---|---|---|---|---|---|
| **Care ID - Family Records**<br>`20:30521` (390x1043) | `family_records_screen.dart` | Header with 'Record Details', CareIdLogo.onlyId, and patient initials avatar; member selector chips (Self, Arthur, Oliver, Sarah), category filters, and shared record cards. | Heading 20px Bold (#28006D), member name 16px Bold.<br>Primary purple theme #8B30E6 with #F8F6FF backgrounds. | Node 20:30640 has CareIDlogo 5 (25x17) emblem in top bar. | `GET /api/v1/family/members, GET /api/v1/medical-records` | **Audited**<br>Ensure member avatar borders match verified/dependent status indicators. |
| **Family Dashboard**<br>`20:21675` (390x1545.5) | `family_dashboard_screen.dart` | Hero family overview card, pending consent alert banners, member grid with verification badges, recent shared records, and 'Add Family Member' FAB. | Card title 18px Bold (#1E293B), badge text 11px Bold.<br>Alert banners use #FEF3C7 (amber) and #ECFDF5 (green). | Node 20:21817 specifies CareIDlogo 4 (25x17) in top bar. | `GET /api/v1/family/dashboard` | **Audited**<br>Verify responsive column wrap for member cards on 720px screens. |
| **Family Member List**<br>`20:21825` (390x1430) | `family_members_screen.dart` | Search bar, category tabs (All, Parents, Children, Spouse), detailed member cards with Health Card Status, Insurance Coverage, Consent Status, and actions (View Details, Edit, Delete). | Member name 18px Bold (#0F172A), metadata 13px Regular.<br>Active badge #ECFDF5 with green dot; Pending badge #F1F5F9. | Node 20:21991 has CareIDlogo 4 (25x17) in top bar. | `GET /api/v1/family/members` | **Audited**<br>Ensure member photo avatars preserve aspect ratio without oval distortion. |
| **Add Family Member - Form**<br>`20:22023` (390x1418) | `add_family_member_screen.dart` | 3-step wizard (Member Info -> Permissions -> Review), relationship picker, contact info, date of birth, emergency contact toggle. | Step indicator 12px SemiBold, section headers 15px Bold.<br>Step progress indicator in AppColors.purplePrimary. | Node 20:22125 specifies CareIDlogo 4 (25x17). | `POST /api/v1/family/invitations` | **Audited**<br>Verify phone number input country code prefix formatting. |

---

### Module 4: Appointments

| Figma Node & Name | Flutter Source | Layout & Structure | Typography & Styling | Icons & Logos | API Contract | Status & Corrections |
|---|---|---|---|---|---|---|
| **Care ID - My Appointments**<br>`20:29664` (390x1174) | `my_appointments_screen.dart` | Segmented tab bar (Upcoming, Completed, Cancelled), appointment cards with doctor avatar, specialty, clinic address, date/time badge, consultation type, and actions (View Details, Reschedule, Cancel). | Doctor name 16px Bold (#0F172A), date/time 13px SemiBold (#8B30E6).<br>Card border #E2E8F0, status badge #ECFDF5 (Confirmed) / #FEF2F2 (Cancelled). | Header uses CareIdLogo.horizontal(height: 18) centered. | `GET /api/v1/appointments/patient/my-appointments` | **Audited**<br>Handle HTTP 500 gracefully with offline/cached appointments state. |
| **Care ID - Book Appointment (Date & Time)**<br>`20:28312` (390x1362) | `book_appointment_screen.dart` | Doctor summary header, horizontal calendar date picker, time slot chips (Morning, Afternoon, Evening), consultation type selector (In-Person, Video), reason for visit input, and Continue button. | Date number 16px Bold, time slot text 13px SemiBold.<br>Selected slot #8B30E6 with white text; available slot #F8FAFC with #334155 text. | CareIdLogo.horizontal(height: 18) in top bar. | `GET /api/v1/doctors/:id/slots, POST /api/v1/appointments` | **Audited**<br>Ensure date picker scrolls horizontally smoothly without clipping. |
| **Care ID - Appointment Confirmation**<br>`20:29208` (390x1464.5) | `appointment_confirmation_screen.dart` | Success celebration graphic, 'Appointment Booked!' header, confirmation code badge (#APT-88204-NY), Digital Care Pass card with doctor details, arrival checklist, Add to Calendar button, and View Details CTA. | Title 24px Bold (#28006D), confirmation code 12px Bold (#8B30E6).<br>Confirmation pass card #1E004A dark purple with teal accents. | Full CareID horizontal logo in top bar (exact match to Figma attachment). | `POST /api/v1/appointments` | **Audited**<br>Preserve exact typography and padding matching approved screenshot. |
| **Care ID - Appointment Details**<br>`20:29399` (390x2063) | `appointment_details_screen.dart` | Hero pass with QR check-in code, doctor info card, clinic map preview, consultation prep notes, insurance coverage status, and Reschedule / Cancel actions. | Section titles 16px Bold (#0F172A), body text 14px Regular.<br>Dark care pass card with glowing cyan border #00E5FF. | CareIdLogo.horizontal(height: 18) in header. | `GET /api/v1/appointments/:id` | **Audited**<br>Ensure Cancel Appointment opens confirmation bottom sheet. |

---

### Module 5: Doctor Directory and Doctor Profile

| Figma Node & Name | Flutter Source | Layout & Structure | Typography & Styling | Icons & Logos | API Contract | Status & Corrections |
|---|---|---|---|---|---|---|
| **Doctors**<br>`20:28020` (390x1810.19) | `doctors_directory_screen.dart` | Search bar (specialty, doctor name, clinic), horizontal filter chips (All, Cardiology, Dentistry, Ophthalmology, Pediatrics), doctor cards with rating, experience, next available slot, and 'Book Visit' CTA. | Doctor name 16px Bold (#0F172A), specialty 13px Regular (#64748B).<br>Rating star in #F59E0B (amber), card background white with #F1F5F9 border. | CareIdLogo.horizontal(height: 18) centered in header. | `GET /api/v1/doctors` | **Audited**<br>Verify photo avatar rendering with fallback initials. |
| **Doctor Profile**<br>`20:28961` (390x2244) | `doctor_profile_screen.dart` | Hero doctor photo with gradient overlay, verified specialist badge, key stats row (Patients, Experience, Rating, Reviews), About bio, Clinic location & hours, Insurance accepted list, and bottom sticky 'Book Appointment' bar. | Doctor title 22px Bold (#0F172A), stat numbers 18px Bold (#8B30E6).<br>Stat containers #F8FAFC with #E2E8F0 borders; sticky bottom bar with shadow. | CareIdLogo.horizontal(height: 18) in top bar with transparent-to-white transition. | `GET /api/v1/doctors/:id` | **Audited**<br>Ensure bottom button elevation does not cover bio text on small screens. |

---

### Module 6: Insurance and OCR screens

| Figma Node & Name | Flutter Source | Layout & Structure | Typography & Styling | Icons & Logos | API Contract | Status & Corrections |
|---|---|---|---|---|---|---|
| **Insurance Dashboard**<br>`20:20059` (390x2179) | `insurance_screen.dart` | Hero digital insurance card with metallic gradient, policy number, subscriber name, co-pay summary, quick actions row, claims list with status chips, and 'Add Insurance' CTA. | Carrier name 18px Bold (#FFFFFF), policy number 14px Monospace.<br>Digital card gradient #0B1C30 -> #1E3A8A; claims badge #ECFDF5. | CareIdLogo.horizontal(height: 18) in header. | `GET /api/v1/insurance/policies, GET /api/v1/insurance/claims` | **Audited**<br>Verify policy list empty state when patient has no registered insurance. |
| **Insurance Card - Camera Capture**<br>`20:20258` (390x905) | `insurance_card_camera_screen.dart` | Dark camera overlay canvas, card front/back toggle, alignment guide brackets, shutter trigger, gallery picker, and flash toggle. | Instructions 14px Medium (#FFFFFF), toggle tabs 12px Bold.<br>Dark background #020617 with #38BDF8 cyan guide brackets. | CareIdLogo.onlyId(height: 18) in top bar. | `Local Camera / ImagePicker fallback` | **Audited**<br>Ensure camera permission request failure gracefully directs to Gallery. |
| **OCR Processing - Insurance Card**<br>`20:20415` (390x980) | `insurance_ocr_processing_screen.dart` | Card thumbnail with animated laser scanning line, multi-stage checklist (Boundary Alignment, OCR Extraction, Field Validation), and progress indicator. | Title 20px Bold (#0F172A), step labels 14px Medium.<br>Cyan laser #00E5FF, active step icon #059669 (green). | CareIdLogo.onlyId(height: 18) in top bar. | `Client OCR simulation / fallback` | **Audited**<br>Ensure smooth progress animation without frame drops. |
| **OCR Extraction Results**<br>`20:20517` (390x2134.5) | `insurance_ocr_results_screen.dart` | Confidence score banner (95% OCR Match), editable form fields categorized into Policy Info, Carrier, Rx Benefits, and Copays, with 'OCR' vs 'USER EDITED' chips. | Confidence score 13px Bold (#047857), form labels 12px SemiBold (#475569).<br>Confidence banner #ECFDF5 with #A7F3D0 border; OCR badge #E0F2FE. | CareIdLogo.onlyId(height: 18) in header. | `POST /api/v1/insurance/policies` | **Audited**<br>Ensure form validation highlights empty required fields. |
| **Insurance QR**<br>`20:21019` (390x1135) | `insurance_qr_screen.dart` | Hero policy card, verified coverage badge, simulated 2D matrix with embedded CareID badge, Share with Provider and Print Pass buttons, and bottom navigation. | Provider name 18px Bold (#FFFFFF), disclaimer 11px Regular (#64748B).<br>Hero card gradient #0B1C30 -> #1E3A8A with #00E5FF badge. | CareIdLogo.onlyId(height: 18) in header and center of QR matrix. | `GET /api/v1/insurance/policies/:id` | **Audited**<br>Completed and verified on device. |

---

### Module 7: Treatment Offers and Financing

| Figma Node & Name | Flutter Source | Layout & Structure | Typography & Styling | Icons & Logos | API Contract | Status & Corrections |
|---|---|---|---|---|---|---|
| **Care ID - Treatment Offers**<br>`20:26404` (390x2134.44) | `treatment_offers_screen.dart` | 0% APR promotional banner, interactive monthly payment estimator slider, treatment packages list (Dental Implants, Orthodontics, Lasik), and 'Apply for Financing' CTA. | Promo heading 22px Bold (#1E004A), payment amount 28px Bold (#8B30E6).<br>Banner gradient #E9D5FF -> #F3E8FF with dark purple text. | CareIdLogo.horizontal(height: 18) in top bar. | `Client financing calculation fallback` | **Audited**<br>Verify slider thumb styling and calculation accuracy. |
| **Care ID - Treatment Offer Details**<br>`20:26922` (390x1843.38) | `treatment_offer_details_screen.dart` | Procedure breakdown card, term options selector (6, 12, 18, 24 months), APR breakdown, lender details, soft credit check disclosure, and 'Accept Offer' / 'Decline' actions. | Procedure name 18px Bold (#0F172A), term label 14px SemiBold.<br>Selected term card #8B30E6 with white text; unselected #FFFFFF with grey border. | CareIdLogo.onlyId in header. | `Client financing calculation fallback` | **Audited**<br>Ensure legal disclaimer text is fully readable with proper line height. |

---

### Module 8: Notifications

| Figma Node & Name | Flutter Source | Layout & Structure | Typography & Styling | Icons & Logos | API Contract | Status & Corrections |
|---|---|---|---|---|---|---|
| **Notification Center**<br>`20:23812` (390x1459) | `notification_center_screen.dart` | Header with 'Notifications', 'Mark all as read' action, category chips (All, Appointments, Prescriptions, Security), notification cards with unread dot, timestamp, and action buttons. | Notification title 14px SemiBold (#0F172A), body 13px Regular (#475569).<br>Unread card #F8FAFC with #8B30E6 blue indicator; read card #FFFFFF. | CareIdLogo.horizontal(height: 18) in top bar. | `GET /api/v1/notifications` | **Audited**<br>Verify empty state when all notifications are cleared. |
| **Medication Reminder Detail**<br>`20:24101` (390x862) | `medication_reminder_detail_screen.dart` | Hero medication pill card, dosage and timing schedule (Morning, Noon, Night), instructions (Take with food), refill status, and 'Mark as Taken' / 'Snooze' actions. | Medication name 20px Bold (#0F172A), dosage 14px Medium (#8B30E6).<br>Pill squircle #E0F2FE with blue icon; button #059669 for taken. | CareIdLogo.onlyId(height: 18) in header. | `GET /api/v1/medications/:id` | **Audited**<br>Ensure bottom action buttons don't clip on short devices. |

---

### Module 9: Profile, Security and Privacy

| Figma Node & Name | Flutter Source | Layout & Structure | Typography & Styling | Icons & Logos | API Contract | Status & Corrections |
|---|---|---|---|---|---|---|
| **Profile & Settings Hub**<br>`20:24204` (390x2002) | `patient_profile_screen.dart` | Hero user profile card with avatar, name, Card ID, Member Since, verification pill, Edit Profile button, mini status pills (Card Active, Insurance Verified), account settings list, medical info list, security toggles, and logout. | User name 20px Bold (#0F172A), section headers 13px SemiBold (#64748B).<br>Verified badge #00E5FF on dark cyan; list items with #F1F5F9 separators. | Header uses 'Profile' title with notification bell. | `GET /api/v1/patients/me` | **Audited**<br>Preserve exact typography and layout matching approved screenshot. |
| **Personal Details & Identity**<br>`20:24653` (390x1160) | `personal_details_identity_screen.dart` | Editable profile form: Full Name, Date of Birth, Gender, Phone, Email, Address, Emergency Contact, and 'Save Changes' button. | Form field labels 13px SemiBold (#334155), inputs 15px Regular.<br>Input border #CBD5E1; focused border #8B30E6. | CareIdLogo.onlyId in top bar. | `GET /api/v1/patients/me, PUT /api/v1/patients/me` | **Audited**<br>Verify DatePicker dialog integration for date of birth. |
| **Security & Privacy Controls**<br>`20:24805` (390x1906) | `security_privacy_controls_screen.dart` | Biometric authentication toggle, Two-Factor Authentication (2FA) status, Active Login Sessions list with device type & revoke action, HIPAA data sharing consents, and Export Medical Data CTA. | Section titles 16px Bold (#0F172A), session device 14px Medium.<br>Active session badge #ECFDF5; Revoke button #EF4444 (red). | CareIdLogo.onlyId in top bar. | `GET /api/v1/security/sessions` | **Audited**<br>Handle HTTP 403 on consents gracefully with local preferences fallback. |

---

### Module 10: Emergency Center

| Figma Node & Name | Flutter Source | Layout & Structure | Typography & Styling | Icons & Logos | API Contract | Status & Corrections |
|---|---|---|---|---|---|---|
| **Emergency Center**<br>`20:23956` (390x2175.64) | `emergency_center_screen.dart` | Red emergency header with 911 quick call button, Blood Group & ICE status card, Severe Allergies tags (Penicillin, Peanuts), Emergency Medical Contacts list with call triggers, Hospital facilities nearby, and Share Emergency Pass QR. | Emergency title 22px Bold (#FFFFFF), contact name 16px Bold (#0F172A).<br>Emergency red banner #DC2626 with white typography; allergy tags #FEF2F2 with #DC2626 text. | CareIdLogo.horizontal(height: 18) in top bar. | `GET /api/v1/patients/me, GET /api/v1/emergency/contacts` | **Audited**<br>Verify allergy tags render with red border and clear warnings. |

---
