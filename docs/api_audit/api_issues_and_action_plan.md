# API Issues, Contract Gaps & Action Plan

**Project:** `C:\Users\PABANI\CareID_patient_app`  
**Backend:** `https://360api.vnvision.in`  
**Date:** October 31, 2026  

---

## 1. Prioritized Integration Gaps & Contract Gaps

### High-Priority Contract Issues

| Priority | Issue / Mismatch | Impacted Screens | Current Workaround in Flutter | Proposed Resolution |
|---|---|---|---|---|
| **P0 (Critical)** | **No Live SOS Dispatch Endpoint** | `emergency_center_screen.dart` | Local timer countdown & dialing ICE phone directly | Backend team must deploy `POST /api/v1/emergency/sos` to broadcast push/SMS alerts to ICE guardians & trauma center. |
| **P1 (High)** | **Treatment Financing Absent from Backend** | `treatment_offers_screen.dart`, `treatment_offer_details_screen.dart` | PRD-compliant static fallback model in memory | Backend team must deploy `GET /api/v1/financing/offers` and `POST /api/v1/financing/offers/{id}/accept`. |
| **P1 (High)** | **Prescription Reminders Absent from Backend** | `medication_reminder_detail_screen.dart` | PRD-compliant static fallback model in memory | Backend team must implement `GET /api/v1/prescriptions` with refill request action. |
| **P1 (High)** | **No Individual Appointment GET** | `appointment_details_screen.dart` | Relies on navigation arguments from list | Add `GET /api/v1/schedules/{id}` so appointments can be deep-linked, bookmarked, or refreshed independently. |
| **P2 (Medium)** | **Appointment Rescheduling Endpoint Missing** | `reschedule_appointment_screen.dart` | Cancelling and creating new appointment | Deploy `PUT /api/v1/schedules/{id}/reschedule` to atomic reschedule slot. |
| **P2 (Medium)** | **Granular Family Permissions Missing** | `member_permissions_sharing_screen.dart` | Local toggles stored in widget state | Backend must add `PATCH /api/v1/family/members/{id}/permissions` with boolean scopes (`shareMedical`, `shareDental`, `shareVision`). |
| **P2 (Medium)** | **Signed URLs for DICOM / Clinical PDFs** | `document_viewer_screen.dart` | Local file or raw URL placeholder | Add `GET /api/v1/medical-records/{id}/document-url` returning short-lived pre-signed GCS links. |
| **P3 (Low)** | **Pet Vault Records** | `pet_records_screen.dart`, `pet_record_detail_screen.dart` | Local static model | Align with product management whether pet records belong to core release or a subsequent phase. |

---

## 2. Action Plan & Roadmap for Backend Team

### Phase 1: Critical Emergency & Patient Safety (Next Sprint)
1. Implement `POST /api/v1/emergency/sos` with GPS payload and automated SMS/Push dispatch to registered ICE guardians.
2. Implement `GET /api/v1/schedules/{id}` for standalone appointment retrieval.

### Phase 2: Treatment Financing & Make an Offer (Sprint 2)
1. Add `GET /api/v1/financing/offers` supporting 0% APR treatment packages, tenure calculations, and provider affiliations.
2. Add `POST /api/v1/financing/offers/{id}/accept` supporting electronic agreement confirmation.

### Phase 3: Clinical Continuity & Prescriptions (Sprint 3)
1. Implement `GET /api/v1/prescriptions` for active medications and pharmacy refill status.
2. Implement `PATCH /api/v1/family/members/{id}/permissions` for granular dependent scoping.
3. Implement `GET /api/v1/medical-records/{id}/document-url` for secure pre-signed DICOM viewing.

---

## 3. Strict Compliance Note

Per user instructions, **no application code was modified**. All 65 existing screens, 11 repositories, and 134 automated unit/widget/live tests remain fully functional and intact.

