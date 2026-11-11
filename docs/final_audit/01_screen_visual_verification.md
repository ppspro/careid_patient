# 01. CareID Patient App — Complete Screen Visual Verification

**Audit Date:** November 3, 2026  
**Figma Canvas:** `CAREID-AIO-FIGMA` (Canvas `17:55` — `Careid patient app`)  
**Target Hardware:** Samsung Galaxy `SM-M066B` (`R9ZY30N9NRV`, Android 14)  
**Document ID:** `docs/final_audit/01_screen_visual_verification.md`

---

## 1. Verification Methodology

Every frame on Figma canvas `17:55` was audited against its corresponding Flutter implementation. Each screen was verified for:
1. **Layout & Dimensions:** Mobile canvas baseline 390×844 / 375×812 matching safe area margins, card padding, and vertical rhythm.
2. **Typography & Styling:** Plus Jakarta Sans font family, explicit font weights (`w400`, `w600`, `w700`, `w800`), font sizes (9.5px badges to 28px hero titles), and letter spacing.
3. **Colors, Gradients & Shadows:** Primary Purple (`#2E006A` / `#5B14B8`), Cyan Accent (`#00E5FF` / `#56F5F8`), Sky Blue Dental Molar (`#0284C7`), dark teal badge pill (`#00838F`), neutral slate backgrounds (`#F8F9FE` / `#F8FAFC`).
4. **Component Hierarchy:** Navigation bars, headers, floating elevated action button (QR scanner), bottom tab bars, bento cards, buttons, tabs, forms, and dialogs.
5. **Brand Logo Assets:** `CareIdLogo` horizontal lockup, `CareIdLogo.onlyId` (25×17) for sub-vault headers, and approved `CareIdDentalLogo` molar vector.

---

## 2. Screen-by-Screen Visual Verification Matrix (86 Frames)

| # | Figma Frame Name | Node ID | Flutter Implementation | Visual Verification Status | Layout, Typography & Styling Notes |
|---|---|---|---|---|---|
| 1 | **Splash_Screen** | `20:25191` | `lib/features/onboarding/presentation/screens/splash_screen.dart` | **Verified** | Unified launch background (`careid_splash_bg_image9.png` on `#1E0B36`). Centered logo, AES-256 trust badges, zero white flash or redundant nurse overlays. |
| 2 | **Welcome - Option 2** | `20:19794` | `lib/features/onboarding/presentation/screens/welcome_screen.dart` | **Verified** | 4 discipline cards (Medical, Dental, Vision, Pets), language toggle, "Get Started" and "I already have an account" CTAs. |
| 3 | **CareID-Create Account** | `20:30644` | `lib/features/onboarding/presentation/screens/create_account_screen.dart` | **Verified** | Step 1 of 6 onboarding wizard, legal name, email, password, terms checkbox. |
| 4 | **Mobile_number** | `20:30756` | `lib/features/onboarding/presentation/screens/mobile_number_screen.dart` | **Verified** | Step 2 of 6 OTP phone dispatch form, country picker pill, verification helper text. |
| 5 | **Health_info** | `20:30900` | `lib/features/onboarding/presentation/screens/health_info_screen.dart` | **Verified** | Step 3 of 6 clinical demographics, blood group selector chips, known allergies, chronic conditions. |
| 6 | **Add Insurance Info** | `20:33068` | `lib/features/onboarding/presentation/screens/add_insurance_screen.dart` | **Verified** | Step 4 of 6 insurance carrier linking, card scanner trigger button, policy manual entry fields. |
| 7 | **Privacy & Consents** | `20:31164` | `lib/features/onboarding/presentation/screens/privacy_consents_screen.dart` | **Verified** | Step 5 of 6 HIPAA and clinical vault data disclosure switches, authorization signature toggle. |
| 8 | **Confirmed_Screen** | `20:31401` | `lib/features/onboarding/presentation/screens/confirmed_screen.dart` | **Verified** | Step 6 of 6 registration success celebration, digital ID card reveal, dashboard entry button. |
| 9 | **Login - Refined Auth Flow v2** | `20:24965` | `lib/features/auth/presentation/screens/login_screen.dart` | **Verified** | Phone challenge authentication input, social login options, header logo lockup. |
| 10 | **OTP Verification - Refined States** | `20:25032` | `lib/features/auth/presentation/screens/login_screen.dart` | **Verified** | 6-cell PIN input field, countdown replay timer, resend OTP trigger. |
| 11 | **Biometric Setup - Refined Polish** | `20:25097` | `lib/features/auth/presentation/screens/biometric_setup_screen.dart` | **Verified** | Fingerprint/FaceID enrollment graphic, system BiometricPrompt bridge, skip button. |
| 12 | **Account recovery** | `20:25143` | `lib/features/auth/presentation/screens/account_recovery_screen.dart` | **Verified** | Phone and email vault recovery form, identity challenge steps. |
| 13 | **Home - Option 6** | `20:19552` | `lib/features/patient/presentation/screens/home_screen.dart` | **Verified** | Hero health pass with ICE badge, Medical/Dental/Vision/Pet bento grid, CareIdDentalLogo (`#0284C7`), 4-tab bottom navigation with floating center scanner. |
| 14 | **Smart Digital Health Card** | `20:19873` | `lib/features/patient/presentation/screens/health_card_screen.dart` | **Verified** | Apple Wallet inspired deep purple card, high-contrast QR credential, blood group, allergies, Add to Google Wallet CTA. |
| 15 | **Medical Records** | `20:31908` | `lib/features/patient/presentation/screens/medical_records_screen.dart` | **Verified** | 64px header (Back + Title + CareIdLogo.onlyId + LanguageToggle), horizontal category chips, clinical timeline, flex overflow fixed. |
| 16 | **Care ID - Health Records Landing** | `20:25209` | `lib/features/patient/presentation/screens/medical_records_screen.dart` | **Verified** | Multi-discipline landing hub with summary metrics across all clinical domains. |
| 17 | **Add Health Record** | `20:33245` | `lib/features/patient/presentation/screens/add_health_record_screen.dart` | **Verified** | Clinical entry form with vital signs, doctor name, clinic, notes, attachment upload. |
| 18 | **Review Health Record** | `20:33367` | `lib/features/patient/presentation/screens/add_health_record_screen.dart` | **Verified** | Pre-save verification review showing recorded vitals and document preview. |
| 19 | **Record Saved Success** | `20:33470` | `lib/features/patient/presentation/screens/add_health_record_screen.dart` | **Verified** | Checkmark animation, "Record Added to Vault" card, return to records button. |
| 20 | **Document Viewer (General)** | `20:32097` | `lib/features/patient/presentation/screens/document_viewer_screen.dart` | **Verified** | High-resolution PDF/image preview, zoom/pan controls, download and share buttons. |
| 21 | **Document Viewer (Lab)** | `20:32177` | `lib/features/patient/presentation/screens/document_viewer_screen.dart` | **Verified** | Pathology and lab report viewer with reference range highlighting. |
| 22 | **Document Viewer (Rx)** | `20:32816` | `lib/features/patient/presentation/screens/document_viewer_screen.dart` | **Verified** | Prescription viewer with dosage, refills remaining, prescriber signature. |
| 23 | **Scan Reports** | `20:32268` | `lib/features/patient/presentation/screens/add_health_record_screen.dart` | **Verified** | Camera viewfinder framing guide for physical paper report scanning. |
| 24 | **OCR Processing - Report** | `20:32321` | `lib/features/patient/presentation/screens/add_health_record_screen.dart` | **Verified** | Shimmer progress indicator with status steps during clinical document parsing. |
| 25 | **Dental Records** | `20:21111` | `lib/features/patient/presentation/screens/dental_records_screen.dart` | **Verified** | Sky Blue `#0284C7` CareIdDentalLogo molar icon in header, odontogram tooth chart, procedure history. |
| 26 | **Care ID - Dental Record Detail** | `20:25653` | `lib/features/patient/presentation/screens/dental_record_detail_screen.dart` | **Verified** | Individual tooth quadrant procedure breakdown, attending dentist, dental x-ray card. |
| 27 | **Vision Records - Timeline & Vault** | `20:21301` | `lib/features/patient/presentation/screens/vision_records_screen.dart` | **Verified** | CareIdLogo.onlyId header icon, visual acuity timeline, optical examination cards. |
| 28 | **Care ID - Vision Record Detail** | `20:25410` | `lib/features/patient/presentation/screens/vision_record_detail_screen.dart` | **Verified** | Full optical prescription card (OD/OS sphere, cylinder, axis, pupillary distance). |
| 29 | **Vision Records - Vault Alt** | `20:32423` | `lib/features/patient/presentation/screens/vision_records_screen.dart` | **Verified** | Alternative layout for historical eyewear and contact lens prescriptions. |
| 30 | **Vision Record Detail Alt** | `20:32573` | `lib/features/patient/presentation/screens/vision_record_detail_screen.dart` | **Verified** | Refractive surgery and clinical examination note breakdown. |
| 31 | **Care ID - Health Records (Pets)** | `20:26073` | `lib/features/patient/presentation/screens/pet_records_screen.dart` | **Verified** | Pet passport card (Max, Golden Retriever, Microchip #), vaccination compliance pills, category filters. |
| 32 | **Pet Record Details** | `20:26229` | `lib/features/patient/presentation/screens/pet_record_detail_screen.dart` | **Verified** | Rabies Booster certificate card, batch number, attending vet (Dr. Amanda Bell, DVM), vitals matrix. |
| 33 | **Family Dashboard** | `20:21675` | `lib/features/patient/presentation/screens/family_dashboard_screen.dart` | **Verified** | Family care ecosystem, active dependent count, pending invites banner. |
| 34 | **Family Member List** | `20:21825` | `lib/features/patient/presentation/screens/family_members_screen.dart` | **Verified** | **User Reference Screen 2 Match:** Arthur Thompson (Father, 68y, Active), Oliver Thompson (Son, 8y, Active), Sarah Jenkins (Spouse, 39y, Inactive, Resend Invite), search bar, All/Parents/Children/Spouse chips, teal circular `+` button. |
| 35 | **Add Family Member - Form** | `20:22023` | `lib/features/patient/presentation/screens/add_family_member_screen.dart` | **Verified** | Dependent demographic form, relation dropdown, emergency contact flag. |
| 36 | **Add Family Member — Access** | `20:19424` | `lib/features/patient/presentation/screens/add_family_member_screen.dart` | **Verified** | Granular discipline permission toggles (Medical, Dental, Vision, Insurance). |
| 37 | **Add Family Member — Review** | `20:19238` | `lib/features/patient/presentation/screens/add_family_member_screen.dart` | **Verified** | Pre-invite summary card showing selected permissions and dependent info. |
| 38 | **Invitation Sent** | `20:19138` | `lib/features/patient/presentation/screens/invitation_sent_screen.dart` | **Verified** | SMS invitation sent confirmation card with pending status pill and resend button. |
| 39 | **Family Consent & Requests** | `20:22157` | `lib/features/patient/presentation/screens/family_consent_requests_screen.dart` | **Verified** | Incoming proxy consent requests, scope descriptions, Accept / Decline actions. |
| 40 | **Member Permissions & Sharing** | `20:22307` | `lib/features/patient/presentation/screens/member_permissions_sharing_screen.dart`| **Verified** | Granular sharing sliders by medical record type with Save Changes CTA. |
| 41 | **Shared Health Card - Dependent** | `20:22459` | `lib/features/patient/presentation/screens/dependent_health_card_screen.dart` | **Verified** | **User Reference Screen 3 Match:** Benjamin Harrison verified dependent card, QR code pass, severe allergies (PENICILLIN, PEANUTS), BlueCross Platinum Plus active card, Share with Provider pill, Download Health PDF button. |
| 42 | **Shared Medical Records** | `20:22594` | `lib/features/patient/presentation/screens/shared_medical_records_screen.dart` | **Verified** | Filtered medical records view strictly for authorized dependent data. |
| 43 | **Care ID - Family Records** | `20:30521` | `lib/features/patient/presentation/screens/family_records_screen.dart` | **Verified** | Consolidated multi-member timeline with member avatar badges. |
| 44 | **Doctors** | `20:28020` | `lib/features/patient/presentation/screens/doctors_directory_screen.dart` | **Verified** | Specialist search, Dental filter chip with CareIdDentalLogo, doctor cards with credentials and ratings. |
| 45 | **Doctor Profile** | `20:28961` | `lib/features/patient/presentation/screens/doctor_profile_screen.dart` | **Verified** | Doctor biography, facility location, CareIdDentalLogo for DDS specialists, flexible specialization layout. |
| 46 | **Care ID - Book Appt (Type)** | `20:28764` | `lib/features/patient/presentation/screens/book_appointment_screen.dart` | **Verified** | In-Person vs Video Telehealth consultation selector cards. |
| 47 | **Care ID - Book Appt (Date/Time)** | `20:28312` | `lib/features/patient/presentation/screens/book_appointment_screen.dart` | **Verified** | Interactive calendar date selector and morning/afternoon timeslot pills. |
| 48 | **Care ID - Review Appointment** | `20:28595` | `lib/features/patient/presentation/screens/book_appointment_screen.dart` | **Verified** | Appointment review summary card with consultation fee and insurance copay notice. |
| 49 | **Care ID - Appt Confirmation** | `20:29208` | `lib/features/patient/presentation/screens/appointment_confirmation_screen.dart`| **Verified** | **User Reference Screen 4 Match:** Hero celebration checkmark with sparkles, "Appointment Booked!", #APT-88204-NY tag, Dr. Sarah Jenkins Digital Care Pass, 3-step arrival guide with `+ Add to Calendar`, View Details and Return Home buttons. |
| 50 | **Care ID - My Appointments** | `20:29664` | `lib/features/patient/presentation/screens/my_appointments_screen.dart` | **Verified** | Segmented tabs for Upcoming, Completed, and Cancelled appointments with pass cards. |
| 51 | **Care ID - Appointment Details** | `20:29399` | `lib/features/patient/presentation/screens/appointment_details_screen.dart` | **Verified** | Doctor details, facility suite, clinic check-in kiosk instructions, digital care pass code. |
| 52 | **Appointment Details & Actions** | `20:29860` | `lib/features/patient/presentation/screens/appointment_details_screen.dart` | **Verified** | Contextual action sheet with Reschedule and Cancel options. |
| 53 | **Reschedule Appointment** | `20:30086` | `lib/features/patient/presentation/screens/reschedule_appointment_screen.dart` | **Verified** | Date and timeslot picker for moving an existing consultation. |
| 54 | **Cancel Appointment Dialog** | `20:30384` | `lib/features/patient/presentation/screens/appointment_details_screen.dart` | **Verified** | Cancellation reason picker, warning notice, Keep Appointment vs Confirm Cancellation buttons. |
| 55 | **Live_chat_messeges** | `20:31689` | `lib/features/patient/presentation/screens/live_chat_screen.dart` | **Verified** | Doctor consultation messaging stream, chat bubble formatting, send message box. |
| 56 | **Full Kiosk Pass** | `20:32906` | `lib/features/patient/presentation/screens/full_kiosk_pass_screen.dart` | **Verified** | Full-screen high-contrast QR pass with max-brightness toggle for instant kiosk check-in. |
| 57 | **Insurance Dashboard** | `20:20059` | `lib/features/patient/presentation/screens/insurance_screen.dart` | **Verified** | Primary health policy card, deductible bar, copay details, claims adjudication list. |
| 58 | **Insurance Card - Camera Capture**| `20:20258` | `lib/features/patient/presentation/screens/insurance_card_camera_screen.dart` | **Verified** | Card outline viewfinder, camera flip action, front/back capture prompts. |
| 59 | **Add Insurance - Select Method** | `20:20311` | `lib/features/patient/presentation/screens/add_insurance_select_method_screen.dart`| **Verified** | Choice cards for "Scan Physical Card" (OCR) and "Enter Policy Manually". |
| 60 | **OCR Processing - Insurance Card**| `20:20415` | `lib/features/patient/presentation/screens/insurance_ocr_processing_screen.dart` | **Verified** | Animated scanning line and card extraction progress status. |
| 61 | **OCR Extraction Results** | `20:20517` | `lib/features/patient/presentation/screens/insurance_ocr_results_screen.dart` | **Verified** | Extracted carrier, policy number, group number, copays, confidence scores. |
| 62 | **Manual Review & Edit** | `20:20723` | `lib/features/patient/presentation/screens/insurance_ocr_results_screen.dart` | **Verified** | Inline editing form for correcting OCR-extracted fields before policy creation. |
| 63 | **Insurance Card Details** | `20:20890` | `lib/features/patient/presentation/screens/insurance_card_details_screen.dart` | **Verified** | Coverage limits, in-network vs out-of-network deductible status, copay schedule. |
| 64 | **Html → Body (Insurance QR)** | `20:21019` | `lib/features/patient/presentation/screens/insurance_qr_screen.dart` | **Verified** | Verifiable insurance pass QR for pharmacy and reception billing. |
| 65 | **Insurance & Financing Hub** | `20:25895` | `lib/features/patient/presentation/screens/insurance_screen.dart` | **Verified** | Combined hub view for active insurance policies, claims history, and financing options. |
| 66 | **Insurance Status (Uninsured)** | `20:26187` | `lib/features/patient/presentation/screens/uninsured_assistance_screen.dart` | **Verified** | Sliding-scale charity care calculator and hospital financial aid program directory. UI matches approved Figma; client fallback active as no dedicated `/api/v1/assistance` endpoint exists in Postman. |
| 67 | **Care ID payment options** | `20:33152` | `lib/features/patient/presentation/screens/payment_options_screen.dart` | **Verified** | HSA/FSA card selector, installment split options, credit card input form. |
| 68 | **Care ID - Treatment Offers** | `20:26404` | `lib/features/patient/presentation/screens/treatment_offers_screen.dart` | **Verified** | 0% APR hero banner, pre-negotiated clinical procedure savings cards, monthly EMI estimator. |
| 69 | **Financing Option Details** | `20:26692` | `lib/features/patient/presentation/screens/treatment_offers_screen.dart` | **Verified** | Tenure options (3, 6, 12, 18, 24 months), interest breakdown, partner terms. |
| 70 | **Treatment Offer Details** | `20:26922` | `lib/features/patient/presentation/screens/treatment_offer_details_screen.dart` | **Verified** | Procedure scope, savings badge, monthly rate, Claim Offer button. |
| 71 | **Offer Accepted Confirmation** | `20:27176` | `lib/features/patient/presentation/screens/treatment_offer_details_screen.dart` | **Verified** | Digital Health Credit pass, payment schedule breakdown, confirmed procedure date. |
| 72 | **Cash Discount Options** | `20:27380` | `lib/features/patient/presentation/screens/treatment_offer_details_screen.dart` | **Verified** | Prompt-pay cash discounts comparison table and savings calculator. |
| 73 | **Offer Rejected Confirmation** | `20:27613` | `lib/features/patient/presentation/screens/treatment_offer_details_screen.dart` | **Verified** | Rejection acknowledgment card with alternative financial aid links. |
| 74 | **Offer Status & History** | `20:27768` | `lib/features/patient/presentation/screens/treatment_offers_screen.dart` | **Verified** | Application tracking list showing pending, approved, and disbursed EMI contracts. |
| 75 | **Notification Center** | `20:23812` | `lib/features/patient/presentation/screens/notification_center_screen.dart` | **Verified** | Category filter chips (All, Appointments, Records, Medications), unread badges, Mark All as Read CTA. |
| 76 | **Medication Reminder Detail** | `20:24101` | `lib/features/patient/presentation/screens/medication_reminder_detail_screen.dart`| **Verified** | Dosage instructions, schedule times, pharmacy one-touch call button. |
| 77 | **Emergency Center** | `20:23956` | `lib/features/patient/presentation/screens/emergency_center_screen.dart` | **Verified** | High-contrast emergency banner, O+ blood type, severe allergies, ICE contacts, 911 one-touch SOS call, nearest ER clinic list. |
| 78 | **Profile & Settings Hub** | `20:24204` | `lib/features/patient/presentation/screens/patient_profile_screen.dart` | **Verified** | **User Reference Screen 1 Match:** Sarah Jenkins avatar with cyan glow ring (`#00E5FF`), overlapping `VERIFIED` dark teal pill (`#00838F`), `HV-360-9928` tag, purple `Edit Profile` button, status cards (`Card Active`, `Insurance Verified`), settings groups (Account Settings, Medical Information, Security, Privacy, Application, Account Actions), 4-tab bottom navigation with cyan capsule on Profile. Unapproved Support Tickets entry removed; approved Live Medical Chat and FAQ sheet retained. |
| 79 | **Medical Information Summary** | `20:24484` | `lib/features/patient/presentation/screens/medical_info_summary_screen.dart` | **Verified** | Consolidated medical summary (chronic conditions, allergies, primary care physician). |
| 80 | **Personal Details & Identity** | `20:24653` | `lib/features/patient/presentation/screens/personal_details_identity_screen.dart`| **Verified** | Full name, phone, residential address, DOB editing form, profile avatar management. |
| 81 | **Security & Privacy Controls** | `20:24805` | `lib/features/patient/presentation/screens/security_privacy_controls_screen.dart`| **Verified** | Biometric login switch, Vault PIN change dialog, active sessions list, emergency health card lock kill switch. |
| 82 | **QR Dashboard** | `20:22771` | `lib/features/patient/presentation/screens/qr_dashboard_screen.dart` | **Verified** | Temporary QR pass generation (15 min timer) vs Full Kiosk Pass toggle. |
| 83 | **Share Options** | `20:23195` | `lib/features/patient/presentation/screens/share_options_screen.dart` | **Verified** | Scoped sharing checkboxes (Dental-only, Medical-only, Vision-only, Full History). |
| 84 | **QR Preview** | `20:23338` | `lib/features/patient/presentation/screens/qr_preview_screen.dart` | **Verified** | Full-width high-contrast QR matrix with embedded security watermark. |
| 85 | **Access History** | `20:23450` | `lib/features/patient/presentation/screens/access_history_screen.dart` | **Verified** | Real-time audit log of healthcare facilities and clinicians who scanned the pass. |
| 86 | **Manage Shared Access** | `20:23597` | `lib/features/patient/presentation/screens/manage_shared_access_screen.dart` | **Verified** | Active provider sharing grants with one-touch Revoke Access action buttons. |

---

## 3. Visual Verification Evidence Summary

- **Total Frames on Canvas 17:55:** 104 direct canvas nodes (86 full screen/modal frames + 18 decorative vectors/logos).
- **Visually Verified in Flutter:** **86 / 86 (100%)**
- **4 Priority User Screens:** 100% verified matching reference attachments.
- **Support Tickets Inconsistency Resolved:** Removed unapproved screen and profile ListTile, restoring exact Figma frame `20:24204` with Live Medical Chat (`20:31689`) and FAQ bottom sheet.

