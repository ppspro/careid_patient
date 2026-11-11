# 05. Available APIs Pending Integration — CareID Patient App
**Project:** `C:\Users\PABANI\CareID_patient_app`  
**Postman Source:** `CareID-Staging.postman_collection.json`  
**Status:** **ALL IDENTIFIED APIS 100% INTEGRATED & VERIFIED** (November 2, 2026)  

---

## 1. Executive Summary

In Phase 2, all 13 high-value available APIs previously identified as pending have been successfully integrated into the Flutter client, wired into screens, and verified with unit tests and physical device runtime execution.

| Endpoint | Method | Module | Flutter Implementation | Status |
|---|---|---|---|---|
| `/api/v1/facilities` | `GET` | Facilities & Branches | `FacilityRepository`, `EmergencyCenterScreen` | **INTEGRATED & VERIFIED** |
| `/api/v1/facilities/search` | `GET` | Facilities & Branches | `FacilityRepository`, `EmergencyCenterScreen` | **INTEGRATED & VERIFIED** |
| `/api/v1/facilities/:id` | `GET` | Facilities & Branches | `FacilityRepository` | **INTEGRATED & VERIFIED** |
| `/api/v1/immunisation/vaccines` | `GET` | Immunisation Management | `ImmunisationRepository`, `MedicalRecordsScreen` (Vaccines tab) | **INTEGRATED & VERIFIED** |
| `/api/v1/immunisation/records` | `GET` | Immunisation Management | `ImmunisationRepository`, `MedicalRecordsScreen` | **INTEGRATED & VERIFIED** |
| `/api/v1/patients/me/photo` | `POST` | Patient Profile | `PatientRepository`, `PersonalDetailsIdentityScreen`, `PatientProfileScreen` | **INTEGRATED & VERIFIED** |
| `/api/v1/patients/me/photo` | `DELETE` | Patient Profile | `PatientRepository`, `PersonalDetailsIdentityScreen`, `PatientProfileScreen` | **INTEGRATED & VERIFIED** |
| `/api/v1/health-cards/:id/history` | `GET` | Digital Health Cards | `DigitalHealthCardRepository`, `HealthCardScreen` | **INTEGRATED & VERIFIED** |
| `/api/v1/health-cards/:id/block` | `POST` | Digital Health Cards | `DigitalHealthCardRepository`, `HealthCardScreen`, `SecurityPrivacyControlsScreen` | **INTEGRATED & VERIFIED** |
| `/api/v1/health-cards/:id/unblock` | `POST` | Digital Health Cards | `DigitalHealthCardRepository`, `HealthCardScreen`, `SecurityPrivacyControlsScreen` | **INTEGRATED & VERIFIED** |
| `/api/v1/cms/faqs` | `GET` | CMS Content Management | `FaqRepository`, `PatientProfileScreen` (FAQ bottom sheet) | **INTEGRATED & VERIFIED** |
| `/api/v1/auth/sessions` | `DELETE` | Security & Sessions | `SecurityRepository`, `SecurityPrivacyControlsScreen` | **INTEGRATED & VERIFIED** |
| `/api/v1/auth/sessions/:sessionId` | `DELETE` | Security & Sessions | `SecurityRepository`, `AccessHistoryScreen` (Individual device revocation) | **INTEGRATED & VERIFIED** |

---

## 2. Remaining Unintegrated APIs in Postman Collection

The only endpoints remaining unintegrated from the Postman collection belong to non-patient administrative modules:
- Admin User Management (`/api/v1/admin/users/*`) — Hospital administrator portal only.
- CMS Content Block Authoring (`POST/PUT /api/v1/cms/blocks`) — Staff editorial actions.
- Doctor Roster Provisioning (`POST/PUT /api/v1/doctors/*`) — Hospital credentialing staff only.
- Vaccine Schedule Provisioning (`POST /api/v1/immunisation/schedules`) — Ministry of Health administrator only.
