# Complete Postman API Inventory

**Collection:** CareID API — Staging Integration Collection
**Backend Base URL:** https://360api.vnvision.in
**Total Requests in Postman:** 453
**Authoritative Reference:** CareID-Staging.postman_collection.json

---

## 1. Inventory Summary by Module

| Folder / Module | Request Count | Patient App Relevant | Shared / Cross-Platform | Portal / Admin / Staff Only |
|---|:---:|:---:|:---:|:---:|
| **01. Environment & Health Checks** | 3 | 0 | 3 | 0 |
| **02. Authentication & OTP** | 8 | 8 | 0 | 0 |
| **03. User Profile & Account** | 6 | 6 | 0 | 0 |
| **04. Admin Portal & System Operations** | 29 | 0 | 0 | 29 |
| **05. Doctor Portal** | 24 | 0 | 0 | 24 |
| **06. Patient App** | 28 | 28 | 0 | 0 |
| **07. Digital Health Cards & Passes** | 16 | 16 | 0 | 0 |
| **08. Medical Records (General, Dental & Vision)** | 11 | 11 | 0 | 0 |
| **09. Facilities & Branches** | 20 | 0 | 20 | 0 |
| **10. Appointments, Schedules & Shifts** | 29 | 8 | 21 | 0 |
| **11. Referrals & Care Coordination** | 14 | 0 | 0 | 14 |
| **12. Family Members & Relationships** | 22 | 22 | 0 | 0 |
| **13. Staff Management** | 16 | 0 | 0 | 16 |
| **14. Notifications & Alerts** | 17 | 17 | 0 | 0 |
| **15. OCR & Document Verification** | 18 | 18 | 0 | 0 |
| **16. File Uploads & Attachments** | 6 | 0 | 6 | 0 |
| **17. Governance, Legal & Compliance** | 28 | 1 | 27 | 0 |
| **18. Security, Threat Detection & Sessions** | 18 | 5 | 13 | 0 |
| **19. Insurance Platform & Claims** | 22 | 22 | 0 | 0 |
| **20. Clinical Reports & Analytics** | 34 | 0 | 0 | 34 |
| **21. Content Management System (CMS)** | 31 | 0 | 0 | 31 |
| **22. Enterprise QR Subsystem** | 20 | 0 | 20 | 0 |
| **23. Observability & Performance Probes** | 15 | 0 | 0 | 15 |
| **24. Immunisation Platform & Vaccines** | 18 | 13 | 5 | 0 |
| **TOTAL** | **453** | **175** | **115** | **163** |

---

## 2. Detailed Request-by-Request Inventory

### 01. Environment & Health Checks

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Platform Health Check | GET | /api/v1/health | noauth | Shared | Shared / Backend Only |
| 2 | Platform Readiness Probe | GET | /api/v1/ready | noauth | Shared | No |
| 3 | Platform Liveness Probe | GET | /api/v1/live | noauth | Shared | No |

### 02. Authentication & OTP

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | CareID Admin/Super Admin Password Login | POST | /api/v1/auth/password/login | noauth | Patient App | Yes |
| 2 | Admin Email/Password Login (Legacy Alias) | POST | /api/v1/auth/admin/login | noauth | Patient App | Yes |
| 3 | Request Phone OTP | POST | /api/v1/auth/otp/request | noauth | Patient App | Yes |
| 4 | Verify Phone OTP & Login | POST | /api/v1/auth/otp/verify | noauth | Patient App | Yes |
| 5 | Resend OTP to registered phone number | POST | /api/v1/auth/otp/resend | noauth | Patient App | Yes |
| 6 | Refresh JWT Access Token | POST | /api/v1/auth/token/refresh | noauth | Patient App | Yes |
| 7 | User Session Logout | POST | /api/v1/auth/logout | noauth | Patient App | Yes |
| 8 | Logout all devices and revoke all tokens | POST | /api/v1/auth/logout-all | noauth | Patient App | Yes |

### 03. User Profile & Account

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Get current user profile and claims | GET | /api/v1/auth/me | bearer | Portal / Admin | Shared / Backend Only |
| 2 | List active sessions for authenticated user | GET | /api/v1/auth/sessions | bearer | Portal / Admin | Shared / Backend Only |
| 3 | Terminate all other active sessions | DELETE | /api/v1/auth/sessions | bearer | Portal / Admin | Shared / Backend Only |
| 4 | Terminate a specific active session | DELETE | /api/v1/auth/sessions/:sessionId | bearer | Portal / Admin | Shared / Backend Only |
| 5 | Get current user assigned roles | GET | /api/v1/auth/roles | bearer | Portal / Admin | Shared / Backend Only |
| 6 | Get current user assigned permissions | GET | /api/v1/auth/permissions | bearer | Portal / Admin | Shared / Backend Only |

### 04. Admin Portal & System Operations

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Get quick legacy dashboard statistics | GET | /api/v1/admin/dashboard/stats | bearer | Portal / Admin | No |
| 2 | Get platform-wide aggregated summary & growth metrics | GET | /api/v1/admin/dashboard/summary | bearer | Portal / Admin | No |
| 3 | Search and list platform users with filter & roles | GET | /api/v1/admin/users | bearer | Portal / Admin | No |
| 4 | Get user details by ID | GET | /api/v1/admin/users/:id | bearer | Portal / Admin | No |
| 5 | Soft-delete / block a user account | DELETE | /api/v1/admin/users/:id | bearer | Portal / Admin | No |
| 6 | Search and list patients with server-side pagination and filters | GET | /api/v1/admin/patients | bearer | Portal / Admin | No |
| 7 | Get unified medical timeline for a specific patient | GET | /api/v1/admin/patients/:patientId/medical-records/timeline | bearer | Portal / Admin | No |
| 8 | List medical records for a specific patient with pagination | GET | /api/v1/admin/patients/:patientId/medical-records | bearer | Portal / Admin | No |
| 9 | Get comprehensive patient details by ID or User ID | GET | /api/v1/admin/patients/:patientId | bearer | Portal / Admin | No |
| 10 | Search and list medical records platform-wide with pagination | GET | /api/v1/admin/medical-records | bearer | Portal / Admin | No |
| 11 | Get clinical details of a specific medical record | GET | /api/v1/admin/medical-records/:recordId | bearer | Portal / Admin | No |
| 12 | Activate, deactivate, or lock/block user account | PUT | /api/v1/admin/users/:id/status | bearer | Portal / Admin | No |
| 13 | Assign RBAC roles to user | PUT | /api/v1/admin/users/:id/roles | bearer | Portal / Admin | No |
| 14 | Restore a blocked/soft-deleted user account | POST | /api/v1/admin/users/:id/restore | bearer | Portal / Admin | No |
| 15 | List all RBAC roles with assigned permissions | GET | /api/v1/admin/roles | bearer | Portal / Admin | No |
| 16 | List all system permissions | GET | /api/v1/admin/permissions | bearer | Portal / Admin | No |
| 17 | Create a new granular permission | POST | /api/v1/admin/permissions | bearer | Portal / Admin | No |
| 18 | List permission groups with permissions | GET | /api/v1/admin/permission-groups | bearer | Portal / Admin | No |
| 19 | Create a new permission group | POST | /api/v1/admin/permission-groups | bearer | Portal / Admin | No |
| 20 | Assign permissions to a role | PUT | /api/v1/admin/roles/:id/permissions | bearer | Portal / Admin | No |
| 21 | Get complete Role-Permission matrix | GET | /api/v1/admin/permission-matrix | bearer | Portal / Admin | No |
| 22 | Create an organization profile | POST | /api/v1/admin/organizations | bearer | Portal / Admin | No |
| 23 | List all registered organizations | GET | /api/v1/admin/organizations | bearer | Portal / Admin | No |
| 24 | Get organization details | GET | /api/v1/admin/organizations/:id | bearer | Portal / Admin | No |
| 25 | Update organization details and settings | PUT | /api/v1/admin/organizations/:id | bearer | Portal / Admin | No |
| 26 | Soft-delete an organization | DELETE | /api/v1/admin/organizations/:id | bearer | Portal / Admin | No |
| 27 | Get system settings by category or all | GET | /api/v1/admin/settings | bearer | Portal / Admin | No |
| 28 | Upsert platform configuration setting | PUT | /api/v1/admin/settings | bearer | Portal / Admin | No |
| 29 | Get global system audit trail | GET | /api/v1/admin/audit-logs | bearer | Portal / Admin | No |

### 05. Doctor Portal

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Register/Create a doctor profile in Master Registry | POST | /api/v1/doctors | bearer | Portal / Admin | Yes |
| 2 | List all registered doctor profiles in Master Registry | GET | /api/v1/doctors | bearer | Portal / Admin | Yes |
| 3 | Enterprise doctor search (by name, registration, license, dept, specialization) | GET | /api/v1/doctors/search | bearer | Portal / Admin | Yes |
| 4 | Get platform-wide doctor directory statistics | GET | /api/v1/doctors/statistics | bearer | Portal / Admin | Yes |
| 5 | List doctor profiles pending admin verification | GET | /api/v1/doctors/verification/pending | bearer | Portal / Admin | Yes |
| 6 | Get current authenticated doctor profile | GET | /api/v1/doctors/me | bearer | Portal / Admin | Yes |
| 7 | Get authorized patient medical record timeline | GET | /api/v1/doctors/patients/:patientProfileId/medical-records/timeline | bearer | Portal / Admin | Yes |
| 8 | Get authorized patient medical records with pagination | GET | /api/v1/doctors/patients/:patientProfileId/medical-records | bearer | Portal / Admin | Yes |
| 9 | Create medical record for an authorized patient | POST | /api/v1/doctors/patients/:patientProfileId/medical-records | bearer | Portal / Admin | Yes |
| 10 | Document clinical encounter, diagnoses, vitals, procedures for an authorized patient | POST | /api/v1/doctors/patients/:patientProfileId/encounters | bearer | Portal / Admin | Yes |
| 11 | Update clinical notes/record documented by doctor | PUT | /api/v1/doctors/patients/:patientProfileId/medical-records/:recordId | bearer | Portal / Admin | Yes |
| 12 | Get complete doctor profile details | GET | /api/v1/doctors/:id | bearer | Portal / Admin | Yes |
| 13 | Update doctor profile details | PUT | /api/v1/doctors/:id | bearer | Portal / Admin | Yes |
| 14 | Soft-delete a doctor profile | DELETE | /api/v1/doctors/:id | bearer | Portal / Admin | Yes |
| 15 | Approve & verify doctor registration | POST | /api/v1/doctors/:id/verify | bearer | Portal / Admin | Yes |
| 16 | Reject doctor verification with reason | POST | /api/v1/doctors/:id/reject | bearer | Portal / Admin | Yes |
| 17 | Suspend doctor registration | POST | /api/v1/doctors/:id/suspend | bearer | Portal / Admin | Yes |
| 18 | Restore suspended doctor registration | POST | /api/v1/doctors/:id/restore | bearer | Portal / Admin | Yes |
| 19 | Renew medical registration license (extends expiry) | POST | /api/v1/doctors/:id/renew-license | bearer | Portal / Admin | Yes |
| 20 | Generate/Issue Doctor Digital Verification QR token | POST | /api/v1/doctors/:id/generate-qr | bearer | Portal / Admin | Yes |
| 21 | List attached doctor credential documents | GET | /api/v1/doctors/:id/documents | bearer | Portal / Admin | Yes |
| 22 | Attach credential document (reusing MedicalAttachment) | POST | /api/v1/doctors/:id/documents | bearer | Portal / Admin | Yes |
| 23 | Get complete verification & status lifecycle history | GET | /api/v1/doctors/:id/history | bearer | Portal / Admin | Yes |
| 24 | Get Doctor Availability Schedule Slots | GET | /api/v1/doctors/:id/slots | bearer | Portal / Admin | Yes |

### 06. Patient App

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Step 1: Initialize Patient Draft Registration | POST | /api/v1/patients/register | bearer | Patient App | Yes |
| 2 | Check Draft Registration Progress Status | GET | /api/v1/patients/register/status | bearer | Patient App | Yes |
| 3 | Resume and update registration progress | PATCH | /api/v1/patients/register/resume | bearer | Patient App | Yes |
| 4 | Step 2: Patient Demographic Registration | POST | /api/v1/patients/onboarding/demographics | bearer | Patient App | Yes |
| 5 | Step 2: Update Demographics Details | PUT | /api/v1/patients/onboarding/demographics | bearer | Patient App | Yes |
| 6 | Step 3: Save Emergency Contact | POST | /api/v1/patients/onboarding/emergency-contact | bearer | Patient App | Yes |
| 7 | Step 3: Update Emergency Contact | PUT | /api/v1/patients/onboarding/emergency-contact | bearer | Patient App | Yes |
| 8 | Step 4: Save Primary/Secondary Insurance Link | POST | /api/v1/patients/onboarding/insurance | bearer | Patient App | Yes |
| 9 | Step 4: Update Insurance Details | PUT | /api/v1/patients/onboarding/insurance | bearer | Patient App | Yes |
| 10 | Step 5: Initialize Secure Digital Health Card | POST | /api/v1/patients/onboarding/health-card | bearer | Patient App | Yes |
| 11 | Step 6: Family Account Linkage Request | POST | /api/v1/patients/onboarding/family-invite | bearer | Patient App | Yes |
| 12 | Get Step-by-Step Onboarding Progress Checklist | GET | /api/v1/patients/onboarding/progress | bearer | Patient App | Yes |
| 13 | Finalize and Complete Onboarding Registration | POST | /api/v1/patients/onboarding/complete | bearer | Patient App | Yes |
| 14 | Get overall Patient Onboarding Completion percentage | GET | /api/v1/patients/onboarding/completion | bearer | Patient App | Yes |
| 15 | Get Patient Profile Details | GET | /api/v1/patients/me | bearer | Patient App | Yes |
| 16 | Update Patient Profile | PUT | /api/v1/patients/me | bearer | Patient App | Yes |
| 17 | Accept / Reject Family Linkage Consent | PATCH | /api/v1/patients/family-consents/:id | bearer | Patient App | Yes |
| 18 | Get Full Patient Profile with all extended fields | GET | /api/v1/patients/me/full | bearer | Patient App | Yes |
| 19 | Update Basic Patient Information (name, DOB, gender, nationality, etc.) | PATCH | /api/v1/patients/me/basic | bearer | Patient App | Yes |
| 20 | Update Contact Preferences | PATCH | /api/v1/patients/me/contact | bearer | Patient App | Yes |
| 21 | Update Current and Permanent Address | PATCH | /api/v1/patients/me/address | bearer | Patient App | Yes |
| 22 | Update Communication Preferences and Privacy Settings | PATCH | /api/v1/patients/me/preferences | bearer | Patient App | Yes |
| 23 | Update Medical Summary (blood group, allergies, conditions, disabilities) | PATCH | /api/v1/patients/me/medical-summary | bearer | Patient App | Yes |
| 24 | Upload or Replace Profile Photo (provide photoUrl and photoKey) | POST | /api/v1/patients/me/photo | bearer | Patient App | Yes |
| 25 | Delete Profile Photo | DELETE | /api/v1/patients/me/photo | bearer | Patient App | Yes |
| 26 | Get Patient Profile Completion Status with section breakdown | GET | /api/v1/patients/profile/completion | bearer | Patient App | Yes |
| 27 | Get Patient Profile Change Timeline | GET | /api/v1/patients/profile/timeline | bearer | Patient App | Yes |
| 28 | Get Patient Profile Activity Summary | GET | /api/v1/patients/profile/activity | bearer | Patient App | Yes |

### 07. Digital Health Cards & Passes

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Issue a new Health Card for authenticated patient | POST | /api/v1/health-cards | noauth | Patient App | Yes |
| 2 | Get active Health Card details for current patient | GET | /api/v1/health-cards | noauth | Patient App | Yes |
| 3 | Search Health Cards by card number or patient name | GET | /api/v1/health-cards/search | noauth | Patient App | Yes |
| 4 | Get specific Health Card details by ID | GET | /api/v1/health-cards/:id | noauth | Patient App | Yes |
| 5 | Update Health Card emergency flag or metadata | PUT | /api/v1/health-cards/:id | noauth | Patient App | Yes |
| 6 | Activate an ISSUED or DEACTIVATED Health Card | POST | /api/v1/health-cards/:id/activate | noauth | Patient App | Yes |
| 7 | Deactivate Health Card | POST | /api/v1/health-cards/:id/deactivate | noauth | Patient App | Yes |
| 8 | Suspend Health Card | POST | /api/v1/health-cards/:id/suspend | noauth | Patient App | Yes |
| 9 | Block Health Card for security or lost card reasons | POST | /api/v1/health-cards/:id/block | noauth | Patient App | Yes |
| 10 | Unblock a BLOCKED Health Card | POST | /api/v1/health-cards/:id/unblock | noauth | Patient App | Yes |
| 11 | Replace Health Card — generates a new card number and increments version | POST | /api/v1/health-cards/:id/replace | noauth | Patient App | Yes |
| 12 | Renew Health Card — extends validity period by 1 year | POST | /api/v1/health-cards/:id/renew | noauth | Patient App | Yes |
| 13 | Archive Health Card | POST | /api/v1/health-cards/:id/archive | noauth | Patient App | Yes |
| 14 | Restore an ARCHIVED Health Card | POST | /api/v1/health-cards/:id/restore | noauth | Patient App | Yes |
| 15 | Get complete status lifecycle audit history for Health Card | GET | /api/v1/health-cards/:id/history | noauth | Patient App | Yes |
| 16 | Verify digital Health Card QR payload | POST | /api/v1/health-cards/verify-qr | noauth | Patient App | Yes |

### 08. Medical Records (General, Dental & Vision)

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Create a new medical record with encounter, vitals, diagnosis, and procedures | POST | /api/v1/medical-records | bearer | Patient App | Yes |
| 2 | Get all medical records for the authenticated patient | GET | /api/v1/medical-records | bearer | Patient App | Yes |
| 3 | Get unified medical timeline combining records and attachments | GET | /api/v1/medical-records/timeline | bearer | Patient App | Yes |
| 4 | Search medical records by title, complaints, notes, diagnosis, or plan | GET | /api/v1/medical-records/search | bearer | Patient App | Yes |
| 5 | Get a specific medical record by ID | GET | /api/v1/medical-records/:id | bearer | Patient App | Yes |
| 6 | Update an existing medical record (blocked if ARCHIVED) | PUT | /api/v1/medical-records/:id | bearer | Patient App | Yes |
| 7 | Soft delete a medical record | DELETE | /api/v1/medical-records/:id | bearer | Patient App | Yes |
| 8 | Archive a medical record (makes record immutable) | POST | /api/v1/medical-records/:id/archive | bearer | Patient App | Yes |
| 9 | Restore a soft-deleted or archived medical record | POST | /api/v1/medical-records/:id/restore | bearer | Patient App | Yes |
| 10 | Upload and link an attachment to a specific medical record | POST | /api/v1/medical-records/:id/attachments | bearer | Patient App | Yes |
| 11 | List all attachments linked to a specific medical record | GET | /api/v1/medical-records/:id/attachments | bearer | Patient App | Yes |

### 09. Facilities & Branches

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Register/Create a facility profile in Master Registry | POST | /api/v1/facilities | bearer | Shared | No |
| 2 | List all registered facility profiles | GET | /api/v1/facilities | bearer | Shared | No |
| 3 | Enterprise facility search (by name, code, city, type) | GET | /api/v1/facilities/search | bearer | Shared | No |
| 4 | Get platform-wide facility directory statistics | GET | /api/v1/facilities/statistics | bearer | Shared | No |
| 5 | Get complete facility details | GET | /api/v1/facilities/:id | bearer | Shared | No |
| 6 | Update facility details | PUT | /api/v1/facilities/:id | bearer | Shared | No |
| 7 | Soft-delete a facility | DELETE | /api/v1/facilities/:id | bearer | Shared | No |
| 8 | Approve & verify facility registration | POST | /api/v1/facilities/:id/verify | bearer | Shared | No |
| 9 | Suspend facility registration | POST | /api/v1/facilities/:id/suspend | bearer | Shared | No |
| 10 | Restore suspended facility registration | POST | /api/v1/facilities/:id/restore | bearer | Shared | No |
| 11 | Generate Facility Digital Identity QR token | POST | /api/v1/facilities/:id/generate-qr | bearer | Shared | No |
| 12 | List facility departments | GET | /api/v1/facilities/:id/departments | bearer | Shared | No |
| 13 | Create facility department | POST | /api/v1/facilities/:id/departments | bearer | Shared | No |
| 14 | List facility rooms | GET | /api/v1/facilities/:id/rooms | bearer | Shared | No |
| 15 | Create facility room | POST | /api/v1/facilities/:id/rooms | bearer | Shared | No |
| 16 | Assign doctor to facility | POST | /api/v1/facilities/:id/assign-doctor | bearer | Shared | No |
| 17 | List associated facility doctors | GET | /api/v1/facilities/:id/doctors | bearer | Shared | No |
| 18 | List attached facility credential documents | GET | /api/v1/facilities/:id/documents | bearer | Shared | No |
| 19 | Attach credential document (reusing MedicalAttachment) | POST | /api/v1/facilities/:id/documents | bearer | Shared | No |
| 20 | Get complete verification & status lifecycle history | GET | /api/v1/facilities/:id/history | bearer | Shared | No |

### 10. Appointments, Schedules & Shifts

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Book a new appointment | POST | /api/v1/appointments | bearer | Portal / Admin | No |
| 2 | List appointments with filtering and pagination | GET | /api/v1/appointments | bearer | Portal / Admin | No |
| 3 | Get appointments scheduled for authenticated doctor | GET | /api/v1/appointments/doctor/my-appointments | bearer | Portal / Admin | No |
| 4 | Get appointments scheduled for authenticated doctor | GET | /api/v1/appointments/doctor/me | bearer | Portal / Admin | No |
| 5 | Get appointments scheduled for authenticated patient | GET | /api/v1/appointments/patient/my-appointments | bearer | Portal / Admin | No |
| 6 | Get appointments scheduled for authenticated patient | GET | /api/v1/appointments/patient/me | bearer | Portal / Admin | No |
| 7 | Get appointment details by ID | GET | /api/v1/appointments/:id | bearer | Portal / Admin | No |
| 8 | Reschedule an existing appointment | PUT | /api/v1/appointments/:id/reschedule | bearer | Portal / Admin | No |
| 9 | Cancel an appointment | PUT | /api/v1/appointments/:id/cancel | bearer | Portal / Admin | No |
| 10 | Update appointment status (clinical & operational staff) | PUT | /api/v1/appointments/:id/status | bearer | Portal / Admin | No |
| 11 | Create a schedule profile (doctor / staff / facility) | POST | /api/v1/schedules | bearer | Portal / Admin | Yes |
| 12 | List all schedule profiles | GET | /api/v1/schedules | bearer | Portal / Admin | Yes |
| 13 | Search schedules by owner type, title, facility or doctor | GET | /api/v1/schedules/search | bearer | Portal / Admin | Yes |
| 14 | Platform-wide scheduling engine statistics | GET | /api/v1/schedules/statistics | bearer | Portal / Admin | Yes |
| 15 | Get schedule detail with working hours, exceptions, leave blocks | GET | /api/v1/schedules/:id | bearer | Portal / Admin | Yes |
| 16 | Update schedule profile and/or working hours | PUT | /api/v1/schedules/:id | bearer | Portal / Admin | Yes |
| 17 | Soft-delete a schedule profile | DELETE | /api/v1/schedules/:id | bearer | Portal / Admin | Yes |
| 18 | Run slot generation engine for a date range | POST | /api/v1/schedules/:id/generate-slots | bearer | Portal / Admin | Yes |
| 19 | Get generated slots for a schedule in a date range | GET | /api/v1/schedules/:id/slots | bearer | Portal / Admin | Yes |
| 20 | Add schedule exception (vacation, conference, emergency, etc.) | POST | /api/v1/schedules/:id/block | bearer | Portal / Admin | Yes |
| 21 | Remove a schedule exception by its ID | POST | /api/v1/schedules/:id/unblock | bearer | Portal / Admin | Yes |
| 22 | Add leave block (sick, casual, earned, emergency) to schedule | POST | /api/v1/schedules/:id/leave | bearer | Portal / Admin | Yes |
| 23 | Get full schedule audit & modification history | GET | /api/v1/schedules/:id/history | bearer | Portal / Admin | Yes |
| 24 | Create shift definition (Morning / Evening / Night / Split / Custom) | POST | /api/v1/shifts | bearer | Portal / Admin | No |
| 25 | List shift definitions, optionally filtered by facility | GET | /api/v1/shifts | bearer | Portal / Admin | No |
| 26 | Assign a staff member to a shift for a specific date | POST | /api/v1/shifts/:id/assign | bearer | Portal / Admin | No |
| 27 | Get all staff assignments for a specific shift | GET | /api/v1/shifts/:id/assignments | bearer | Portal / Admin | No |
| 28 | Add a holiday to the calendar (global or facility-specific) | POST | /api/v1/holidays | bearer | Portal / Admin | No |
| 29 | List holidays (global + optional facility-specific) | GET | /api/v1/holidays | bearer | Portal / Admin | No |

### 11. Referrals & Care Coordination

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Create patient care referral | POST | /api/v1/referrals | bearer | Portal / Admin | No |
| 2 | List patient care referrals with optional filters | GET | /api/v1/referrals | bearer | Portal / Admin | No |
| 3 | List incoming referrals for current doctor/facility | GET | /api/v1/referrals/my-incoming | bearer | Portal / Admin | No |
| 4 | List outgoing referrals created by current doctor | GET | /api/v1/referrals/my-outgoing | bearer | Portal / Admin | No |
| 5 | Get referral dashboard metrics and SLA performance analytics | GET | /api/v1/referrals/dashboard/stats | bearer | Portal / Admin | No |
| 6 | Get referral details by ID | GET | /api/v1/referrals/:id | bearer | Portal / Admin | No |
| 7 | Soft-delete referral | DELETE | /api/v1/referrals/:id | bearer | Portal / Admin | No |
| 8 | Triage patient referral (Approve/Decline/Redirect) | PUT | /api/v1/referrals/:id/triage | bearer | Portal / Admin | No |
| 9 | Update referral status (IN_PROGRESS, COMPLETED, CANCELLED) | PUT | /api/v1/referrals/:id/status | bearer | Portal / Admin | No |
| 10 | Add clinical coordination note to referral | POST | /api/v1/referrals/:id/notes | bearer | Portal / Admin | No |
| 11 | List clinical notes for referral | GET | /api/v1/referrals/:id/notes | bearer | Portal / Admin | No |
| 12 | Link medical attachment to referral | POST | /api/v1/referrals/:id/attachments | bearer | Portal / Admin | No |
| 13 | List linked medical attachments for referral | GET | /api/v1/referrals/:id/attachments | bearer | Portal / Admin | No |
| 14 | Get immutable status transition history for referral | GET | /api/v1/referrals/:id/history | bearer | Portal / Admin | No |

### 12. Family Members & Relationships

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Create a family invitation | POST | /api/v1/family/invitations | bearer | Patient App | Yes |
| 2 | List all invitations sent by the patient | GET | /api/v1/family/invitations | bearer | Patient App | Yes |
| 3 | Resend a pending family invitation (max 5 times) | POST | /api/v1/family/invitations/:id/resend | bearer | Patient App | Yes |
| 4 | Accept a family invitation — auto-creates family member record | POST | /api/v1/family/invitations/:id/accept | bearer | Patient App | Yes |
| 5 | Reject a family invitation | POST | /api/v1/family/invitations/:id/reject | bearer | Patient App | Yes |
| 6 | Cancel a pending family invitation | DELETE | /api/v1/family/invitations/:id | bearer | Patient App | Yes |
| 7 | List all active family members | GET | /api/v1/family/members | bearer | Patient App | Yes |
| 8 | Get a specific family member | GET | /api/v1/family/members/:id | bearer | Patient App | Yes |
| 9 | Update family member details or status | PATCH | /api/v1/family/members/:id | bearer | Patient App | Yes |
| 10 | Remove (archive) a family member | DELETE | /api/v1/family/members/:id | bearer | Patient App | Yes |
| 11 | Grant a consent category to a family member | POST | /api/v1/family/consents | bearer | Patient App | Yes |
| 12 | List all active consents granted by the patient | GET | /api/v1/family/consents | bearer | Patient App | Yes |
| 13 | Update consent (expiry date, notes) | PUT | /api/v1/family/consents/:id | bearer | Patient App | Yes |
| 14 | Revoke a granted consent — blocks access immediately | DELETE | /api/v1/family/consents/:id | bearer | Patient App | Yes |
| 15 | Get full consent audit history for the patient | GET | /api/v1/family/consents/history | bearer | Patient App | Yes |
| 16 | List all guardians assigned to the patient | GET | /api/v1/family/guardians | bearer | Patient App | Yes |
| 17 | Assign a guardian to the patient | POST | /api/v1/family/guardians | bearer | Patient App | Yes |
| 18 | Update guardian verification status or primary flag | PATCH | /api/v1/family/guardians/:id | bearer | Patient App | Yes |
| 19 | List all dependents registered under this patient | GET | /api/v1/family/dependents | bearer | Patient App | Yes |
| 20 | Register a dependent (minor, senior, or care patient) | POST | /api/v1/family/dependents | bearer | Patient App | Yes |
| 21 | Update dependent details | PATCH | /api/v1/family/dependents/:id | bearer | Patient App | Yes |
| 22 | Remove a dependent | DELETE | /api/v1/family/dependents/:id | bearer | Patient App | Yes |

### 13. Staff Management

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Register/Create a staff member profile in Master Workforce Registry | POST | /api/v1/staff | bearer | Portal / Admin | No |
| 2 | List all registered staff members in Master Workforce Registry | GET | /api/v1/staff | bearer | Portal / Admin | No |
| 3 | Enterprise staff search (by name, code, designation, staff type) | GET | /api/v1/staff/search | bearer | Portal / Admin | No |
| 4 | Get platform-wide workforce directory statistics | GET | /api/v1/staff/statistics | bearer | Portal / Admin | No |
| 5 | Get complete staff member details | GET | /api/v1/staff/:id | bearer | Portal / Admin | No |
| 6 | Update staff member profile details | PUT | /api/v1/staff/:id | bearer | Portal / Admin | No |
| 7 | Soft-delete a staff member profile | DELETE | /api/v1/staff/:id | bearer | Portal / Admin | No |
| 8 | Approve & verify staff registration | POST | /api/v1/staff/:id/verify | bearer | Portal / Admin | No |
| 9 | Suspend staff registration | POST | /api/v1/staff/:id/suspend | bearer | Portal / Admin | No |
| 10 | Restore suspended staff registration | POST | /api/v1/staff/:id/restore | bearer | Portal / Admin | No |
| 11 | Generate Staff Digital Identity QR token | POST | /api/v1/staff/:id/generate-qr | bearer | Portal / Admin | No |
| 12 | Assign staff member to primary / secondary facilities | POST | /api/v1/staff/:id/assign-facility | bearer | Portal / Admin | No |
| 13 | Assign staff member to primary / secondary departments | POST | /api/v1/staff/:id/assign-department | bearer | Portal / Admin | No |
| 14 | List attached staff credential documents | GET | /api/v1/staff/:id/documents | bearer | Portal / Admin | No |
| 15 | Attach credential document (reusing MedicalAttachment) | POST | /api/v1/staff/:id/documents | bearer | Portal / Admin | No |
| 16 | Get complete verification & employment status history | GET | /api/v1/staff/:id/history | bearer | Portal / Admin | No |

### 14. Notifications & Alerts

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Get Enterprise Notification Platform stats & queue summary | GET | /api/v1/notifications/dashboard/stats | bearer | Patient App | Yes |
| 2 | Publish/dispatch a notification across channels | POST | /api/v1/notifications | bearer | Patient App | Yes |
| 3 | List notifications for recipient or platform | GET | /api/v1/notifications | bearer | Patient App | Yes |
| 4 | Get notification details by ID | GET | /api/v1/notifications/:id | bearer | Patient App | Yes |
| 5 | Soft-delete a notification | DELETE | /api/v1/notifications/:id | bearer | Patient App | Yes |
| 6 | Mark notification as READ | PUT | /api/v1/notifications/:id/read | bearer | Patient App | Yes |
| 7 | Get current user notification preferences | GET | /api/v1/notifications/preferences | bearer | Patient App | Yes |
| 8 | Update current user notification channel preferences | PUT | /api/v1/notifications/preferences | bearer | Patient App | Yes |
| 9 | List pending/queued notification delivery items | GET | /api/v1/notifications/queue | bearer | Patient App | Yes |
| 10 | Retry queued/failed notification delivery attempts | POST | /api/v1/notifications/queue/retry | bearer | Patient App | Yes |
| 11 | Process pending notification queue and dispatch via gateways | POST | /api/v1/notifications/queue/process | bearer | Patient App | Yes |
| 12 | List notification audit logs | GET | /api/v1/notifications/audit | bearer | Patient App | Yes |
| 13 | Create a new notification template with variable placeholders | POST | /api/v1/notifications/templates | bearer | Patient App | Yes |
| 14 | List all notification templates | GET | /api/v1/notifications/templates | bearer | Patient App | Yes |
| 15 | Get notification template by ID | GET | /api/v1/notifications/templates/:id | bearer | Patient App | Yes |
| 16 | Update template body or subject and increment version | PUT | /api/v1/notifications/templates/:id | bearer | Patient App | Yes |
| 17 | Soft-delete a notification template | DELETE | /api/v1/notifications/templates/:id | bearer | Patient App | Yes |

### 15. OCR & Document Verification

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Get Enterprise OCR Platform analytics dashboard summary | GET | /api/v1/ocr/dashboard | bearer | Portal / Admin | No |
| 2 | Get Enterprise OCR accuracy & throughput statistics | GET | /api/v1/ocr/statistics | bearer | Portal / Admin | No |
| 3 | Submit medical attachment for local CPU OCR processing | POST | /api/v1/ocr/jobs | bearer | Portal / Admin | No |
| 4 | List all OCR jobs with optional status, document type and pagination filters | GET | /api/v1/ocr/jobs | bearer | Portal / Admin | No |
| 5 | Reprocess a completed, failed, or review-required OCR job | POST | /api/v1/ocr/reprocess/:jobId | bearer | Portal / Admin | No |
| 6 | Get OCR job status and details by ID | GET | /api/v1/ocr/jobs/:id | bearer | Portal / Admin | No |
| 7 | Get extracted raw OCR text for job | GET | /api/v1/ocr/jobs/:id/text | bearer | Portal / Admin | No |
| 8 | Get extracted structured fields with confidence scores | GET | /api/v1/ocr/jobs/:id/fields | bearer | Portal / Admin | No |
| 9 | Get formatted structured JSON output of OCR job | GET | /api/v1/ocr/jobs/:id/json | bearer | Portal / Admin | No |
| 10 | Create an OCR Document Template with field definitions | POST | /api/v1/ocr/templates | bearer | Portal / Admin | No |
| 11 | List all OCR Document Templates | GET | /api/v1/ocr/templates | bearer | Portal / Admin | No |
| 12 | Update OCR Document Template and increment version | PUT | /api/v1/ocr/templates/:id | bearer | Portal / Admin | No |
| 13 | Soft-delete an OCR Document Template | DELETE | /api/v1/ocr/templates/:id | bearer | Portal / Admin | No |
| 14 | Get paginated audit history of completed human OCR reviews | GET | /api/v1/ocr/reviews/history | bearer | Portal / Admin | No |
| 15 | List OCR jobs requiring manual human verification | GET | /api/v1/ocr/review | bearer | Portal / Admin | No |
| 16 | Submit human verification review for low-confidence OCR job | POST | /api/v1/ocr/review/:jobId | bearer | Portal / Admin | No |
| 17 | Image Scan & Candidate Metadata Extraction | POST | /api/v1/ai/ocr/extract | bearer | Portal / Admin | No |
| 18 | OCR Candidate Field Review & Manual Confirmation | POST | /api/v1/ai/ocr/confirm | bearer | Portal / Admin | No |

### 16. File Uploads & Attachments

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Upload an unlinked or global attachment (reusable across system) | POST | /api/v1/attachments | bearer | Shared | No |
| 2 | Get attachment metadata by ID | GET | /api/v1/attachments/:id | bearer | Shared | No |
| 3 | Update attachment category, metadata, or upload a new file version | PATCH | /api/v1/attachments/:id | bearer | Shared | No |
| 4 | Soft-delete an attachment | DELETE | /api/v1/attachments/:id | bearer | Shared | No |
| 5 | Restore a soft-deleted attachment | POST | /api/v1/attachments/:id/restore | bearer | Shared | No |
| 6 | Get file version history for an attachment | GET | /api/v1/attachments/:id/versions | bearer | Shared | No |

### 17. Governance, Legal & Compliance

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Get Enterprise Governance Dashboard summary | GET | /api/v1/governance/dashboard | bearer | Portal / Admin | No |
| 2 | Create a new system configuration key-value entry | POST | /api/v1/governance/configurations | bearer | Portal / Admin | No |
| 3 | List all system configurations, optionally filtered by category | GET | /api/v1/governance/configurations | bearer | Portal / Admin | No |
| 4 | Export system configurations in JSON format | GET | /api/v1/governance/configurations/export | bearer | Portal / Admin | No |
| 5 | Bulk import system configurations | POST | /api/v1/governance/configurations/import | bearer | Portal / Admin | No |
| 6 | Get system configuration by ID | GET | /api/v1/governance/configurations/:id | bearer | Portal / Admin | No |
| 7 | Update system configuration value and increment version | PUT | /api/v1/governance/configurations/:id | bearer | Portal / Admin | No |
| 8 | Soft-delete system configuration entry | DELETE | /api/v1/governance/configurations/:id | bearer | Portal / Admin | No |
| 9 | Create a new feature flag with rollout rules | POST | /api/v1/governance/features | bearer | Portal / Admin | No |
| 10 | List all feature flags | GET | /api/v1/governance/features | bearer | Portal / Admin | No |
| 11 | Get feature flag details by ID | GET | /api/v1/governance/features/:id | bearer | Portal / Admin | No |
| 12 | Update feature flag status, roles, or rollout percentage | PUT | /api/v1/governance/features/:id | bearer | Portal / Admin | No |
| 13 | Soft-delete a feature flag | DELETE | /api/v1/governance/features/:id | bearer | Portal / Admin | No |
| 14 | Create a master data category | POST | /api/v1/governance/master-data/categories | bearer | Portal / Admin | No |
| 15 | List all master data categories with items | GET | /api/v1/governance/master-data/categories | bearer | Portal / Admin | No |
| 16 | Create a master data item under a category | POST | /api/v1/governance/master-data/items | bearer | Portal / Admin | No |
| 17 | List master data items, optionally filtered by category | GET | /api/v1/governance/master-data/items | bearer | Portal / Admin | No |
| 18 | Update master data item | PUT | /api/v1/governance/master-data/items/:id | bearer | Portal / Admin | No |
| 19 | Soft-delete a master data item | DELETE | /api/v1/governance/master-data/items/:id | bearer | Portal / Admin | No |
| 20 | Create a new platform governance policy | POST | /api/v1/governance/policies | bearer | Portal / Admin | No |
| 21 | List all platform governance policies | GET | /api/v1/governance/policies | bearer | Portal / Admin | No |
| 22 | Get policy details by ID | GET | /api/v1/governance/policies/:id | bearer | Portal / Admin | No |
| 23 | Update policy title, content, or version | PUT | /api/v1/governance/policies/:id | bearer | Portal / Admin | No |
| 24 | Soft-delete a platform policy | DELETE | /api/v1/governance/policies/:id | bearer | Portal / Admin | No |
| 25 | Get active platform maintenance configuration | GET | /api/v1/governance/maintenance | bearer | Portal / Admin | No |
| 26 | Set or update platform maintenance mode (OFF / READ_ONLY / FULL) | PUT | /api/v1/governance/maintenance | bearer | Portal / Admin | No |
| 27 | List governance audit logs | GET | /api/v1/governance/audit | bearer | Portal / Admin | No |
| 28 | Get governance audit log detail by ID | GET | /api/v1/governance/audit/:id | bearer | Portal / Admin | No |

### 18. Security, Threat Detection & Sessions

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Get Enterprise Security & Compliance Dashboard summary | GET | /api/v1/security/dashboard | bearer | Portal / Admin | No |
| 2 | Capture patient consent record | POST | /api/v1/security/consents | bearer | Portal / Admin | No |
| 3 | List patient consents with optional filters | GET | /api/v1/security/consents | bearer | Portal / Admin | No |
| 4 | Get consent record details by ID | GET | /api/v1/security/consents/:id | bearer | Portal / Admin | No |
| 5 | Withdraw patient consent | POST | /api/v1/security/consents/:id/withdraw | bearer | Portal / Admin | No |
| 6 | Confirm and grant a pending patient consent record | POST | /api/v1/security/consents/:id/confirm | bearer | Portal / Admin | No |
| 7 | Create data retention policy | POST | /api/v1/security/retention | bearer | Portal / Admin | No |
| 8 | List all data retention policies | GET | /api/v1/security/retention | bearer | Portal / Admin | No |
| 9 | Update retention policy parameters | PUT | /api/v1/security/retention/:id | bearer | Portal / Admin | No |
| 10 | Soft-delete a retention policy | DELETE | /api/v1/security/retention/:id | bearer | Portal / Admin | No |
| 11 | Report a security incident | POST | /api/v1/security/incidents | bearer | Portal / Admin | No |
| 12 | List reported security incidents | GET | /api/v1/security/incidents | bearer | Portal / Admin | No |
| 13 | Mark security incident as RESOLVED | PUT | /api/v1/security/incidents/:id/resolve | bearer | Portal / Admin | No |
| 14 | Get active KMS encryption key metadata | GET | /api/v1/security/keys/active | bearer | Portal / Admin | No |
| 15 | Trigger KMS encryption key rotation | POST | /api/v1/security/keys/rotate | bearer | Portal / Admin | No |
| 16 | Generate automated compliance assessment report | POST | /api/v1/security/compliance/report | bearer | Portal / Admin | No |
| 17 | List generated compliance reports | GET | /api/v1/security/compliance/reports | bearer | Portal / Admin | No |
| 18 | List security audit logs | GET | /api/v1/security/audit | bearer | Portal / Admin | No |

### 19. Insurance Platform & Claims

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Create an insurance provider | POST | /api/v1/insurance/providers | bearer | Patient App | Yes |
| 2 | List active insurance providers | GET | /api/v1/insurance/providers | bearer | Patient App | Yes |
| 3 | Create an insurance plan | POST | /api/v1/insurance/plans | bearer | Patient App | Yes |
| 4 | List insurance plans (supports providerId filter) | GET | /api/v1/insurance/plans | bearer | Patient App | Yes |
| 5 | Issue/Register a full insurance policy for patient | POST | /api/v1/insurance/policies | bearer | Patient App | Yes |
| 6 | Get all insurance policies for current patient | GET | /api/v1/insurance/policies | bearer | Patient App | Yes |
| 7 | Search insurance policies by provider or policy number | GET | /api/v1/insurance/search | bearer | Patient App | Yes |
| 8 | Get platform-wide insurance statistics | GET | /api/v1/insurance/statistics | bearer | Patient App | Yes |
| 9 | Get specific insurance policy details | GET | /api/v1/insurance/policies/:id | bearer | Patient App | Yes |
| 10 | Update insurance policy details (blocked if ARCHIVED) | PUT | /api/v1/insurance/policies/:id | bearer | Patient App | Yes |
| 11 | Activate an insurance policy | POST | /api/v1/insurance/policies/:id/activate | bearer | Patient App | Yes |
| 12 | Renew an insurance policy (extends validity by 1 year) | POST | /api/v1/insurance/policies/:id/renew | bearer | Patient App | Yes |
| 13 | Suspend an insurance policy | POST | /api/v1/insurance/policies/:id/suspend | bearer | Patient App | Yes |
| 14 | Cancel an insurance policy | POST | /api/v1/insurance/policies/:id/cancel | bearer | Patient App | Yes |
| 15 | Archive an insurance policy | POST | /api/v1/insurance/policies/:id/archive | bearer | Patient App | Yes |
| 16 | Restore an archived insurance policy | POST | /api/v1/insurance/policies/:id/restore | bearer | Patient App | Yes |
| 17 | Verify coverage status for an insurance policy | POST | /api/v1/insurance/policies/:id/verify | bearer | Patient App | Yes |
| 18 | Create a claim draft attaching medical records and reports | POST | /api/v1/insurance/claims | bearer | Patient App | Yes |
| 19 | List all claim drafts for current patient | GET | /api/v1/insurance/claims | bearer | Patient App | Yes |
| 20 | Save insurance details during 6-step patient onboarding (Step 4) | POST | /api/v1/insurance/onboard | bearer | Patient App | Yes |
| 21 | Scan insurance card image via OCR extraction | POST | /api/v1/insurance/ocr/scan | bearer | Patient App | Yes |
| 22 | Confirm extracted OCR data to create insurance policy | POST | /api/v1/insurance/ocr/confirm | bearer | Patient App | Yes |

### 20. Clinical Reports & Analytics

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Get Executive Dashboard platform summary statistics | GET | /api/v1/reports/dashboard/executive | bearer | Portal / Admin | No |
| 2 | Get domain analytics for a specific module | GET | /api/v1/reports/analytics/modules/:module | bearer | Portal / Admin | No |
| 3 | Create a new Report Definition | POST | /api/v1/reports/definitions | bearer | Portal / Admin | No |
| 4 | List Report Definitions, optionally filtered by module | GET | /api/v1/reports/definitions | bearer | Portal / Admin | No |
| 5 | Get Report Definition by ID | GET | /api/v1/reports/definitions/:id | bearer | Portal / Admin | No |
| 6 | Update a Report Definition | PUT | /api/v1/reports/definitions/:id | bearer | Portal / Admin | No |
| 7 | Soft-delete a Report Definition | DELETE | /api/v1/reports/definitions/:id | bearer | Portal / Admin | No |
| 8 | Generate a report based on a Report Definition or custom filters | POST | /api/v1/reports/generate | bearer | Portal / Admin | No |
| 9 | List generated reports for user or platform | GET | /api/v1/reports/generated | bearer | Portal / Admin | No |
| 10 | Get generated report details | GET | /api/v1/reports/generated/:id | bearer | Portal / Admin | No |
| 11 | Export a generated report to PDF, CSV, XLSX, or JSON | POST | /api/v1/reports/generated/:id/export | bearer | Portal / Admin | No |
| 12 | Create a new configurable Dashboard Widget | POST | /api/v1/reports/widgets | bearer | Portal / Admin | No |
| 13 | List configured Dashboard Widgets | GET | /api/v1/reports/widgets | bearer | Portal / Admin | No |
| 14 | Update a Dashboard Widget configuration | PUT | /api/v1/reports/widgets/:id | bearer | Portal / Admin | No |
| 15 | Reorder Dashboard Widgets display order | POST | /api/v1/reports/widgets/reorder | bearer | Portal / Admin | No |
| 16 | Record an immutable Analytics Snapshot | POST | /api/v1/reports/snapshots | bearer | Portal / Admin | No |
| 17 | Get Analytics Snapshots for a module and metric | GET | /api/v1/reports/snapshots | bearer | Portal / Admin | No |
| 18 | Upload and register a diagnostic medical report | POST | /api/v1/reports | bearer | Portal / Admin | No |
| 19 | Get all diagnostic reports for the patient (supports category filtering) | GET | /api/v1/reports | bearer | Portal / Admin | No |
| 20 | Get report categories list with record count breakdown | GET | /api/v1/reports/categories | bearer | Portal / Admin | No |
| 21 | Search diagnostic reports by title, description, doctor, provider, or tags | GET | /api/v1/reports/search | bearer | Portal / Admin | No |
| 22 | Get diagnostic reports timeline ordered by report date | GET | /api/v1/reports/timeline | bearer | Portal / Admin | No |
| 23 | Get specific diagnostic report details by ID | GET | /api/v1/reports/:id | bearer | Portal / Admin | No |
| 24 | Update diagnostic report metadata (blocked if ARCHIVED) | PUT | /api/v1/reports/:id | bearer | Portal / Admin | No |
| 25 | Soft-delete a diagnostic report | DELETE | /api/v1/reports/:id | bearer | Portal / Admin | No |
| 26 | Archive a report (makes report read-only) | POST | /api/v1/reports/:id/archive | bearer | Portal / Admin | No |
| 27 | Restore a soft-deleted or archived report | POST | /api/v1/reports/:id/restore | bearer | Portal / Admin | No |
| 28 | Replace PDF file for report — creates a new immutable version snapshot | POST | /api/v1/reports/:id/replace | bearer | Portal / Admin | No |
| 29 | Get full version history for a diagnostic report | GET | /api/v1/reports/:id/versions | bearer | Portal / Admin | No |
| 30 | Mark diagnostic report as VERIFIED with verification notes | POST | /api/v1/reports/:id/verify | bearer | Portal / Admin | No |
| 31 | Generate a secure timed download URL/token for a report file | GET | /api/v1/reports/download/:id | bearer | Portal / Admin | No |
| 32 | Execute verified secure download of a report attachment | GET | /api/v1/reports/download/:id/file | bearer | Portal / Admin | No |
| 33 | Execute verified secure download of a report attachment (alias) | GET | /api/v1/reports/:id/file | bearer | Portal / Admin | No |
| 34 | Get PDF preview metadata (page count, size, MIME type, storage URL) | GET | /api/v1/reports/preview/:id | bearer | Portal / Admin | No |

### 21. Content Management System (CMS)

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Get platform-wide CMS content statistics | GET | /api/v1/cms/statistics | bearer | Portal / Admin | No |
| 2 | Create a new CMS page | POST | /api/v1/cms/pages | bearer | Portal / Admin | No |
| 3 | List published CMS pages | GET | /api/v1/cms/pages | bearer | Portal / Admin | No |
| 4 | Search published CMS pages by title, slug, content, or summary | GET | /api/v1/cms/pages/search | bearer | Portal / Admin | No |
| 5 | Get published CMS page by ID or slug | GET | /api/v1/cms/pages/:id | bearer | Portal / Admin | No |
| 6 | Update CMS page details or publication status | PUT | /api/v1/cms/pages/:id | bearer | Portal / Admin | No |
| 7 | Soft-delete a CMS page | DELETE | /api/v1/cms/pages/:id | bearer | Portal / Admin | No |
| 8 | Create a new FAQ item | POST | /api/v1/cms/faqs | bearer | Portal / Admin | No |
| 9 | List published FAQs, optionally filtered by category | GET | /api/v1/cms/faqs | bearer | Portal / Admin | No |
| 10 | Update FAQ question, answer, category or display order | PUT | /api/v1/cms/faqs/:id | bearer | Portal / Admin | No |
| 11 | Soft-delete a FAQ item | DELETE | /api/v1/cms/faqs/:id | bearer | Portal / Admin | No |
| 12 | Create a new system announcement | POST | /api/v1/cms/announcements | bearer | Portal / Admin | No |
| 13 | List active announcements | GET | /api/v1/cms/announcements | bearer | Portal / Admin | No |
| 14 | Update announcement | PUT | /api/v1/cms/announcements/:id | bearer | Portal / Admin | No |
| 15 | Soft-delete an announcement | DELETE | /api/v1/cms/announcements/:id | bearer | Portal / Admin | No |
| 16 | Create a new platform policy | POST | /api/v1/cms/policies | bearer | Portal / Admin | No |
| 17 | List published platform policies | GET | /api/v1/cms/policies | bearer | Portal / Admin | No |
| 18 | Update policy details or version | PUT | /api/v1/cms/policies/:id | bearer | Portal / Admin | No |
| 19 | Soft-delete a policy | DELETE | /api/v1/cms/policies/:id | bearer | Portal / Admin | No |
| 20 | Create a new promotional banner | POST | /api/v1/cms/banners | bearer | Portal / Admin | No |
| 21 | List active promotional banners | GET | /api/v1/cms/banners | bearer | Portal / Admin | No |
| 22 | Update banner image, redirect URL or display order | PUT | /api/v1/cms/banners/:id | bearer | Portal / Admin | No |
| 23 | Soft-delete a banner | DELETE | /api/v1/cms/banners/:id | bearer | Portal / Admin | No |
| 24 | Register a media item in Media Library | POST | /api/v1/cms/media | bearer | Portal / Admin | No |
| 25 | List media items in library | GET | /api/v1/cms/media | bearer | Portal / Admin | No |
| 26 | Search media library by file name or mime type | GET | /api/v1/cms/media/search | bearer | Portal / Admin | No |
| 27 | Soft-delete a media item | DELETE | /api/v1/cms/media/:id | bearer | Portal / Admin | No |
| 28 | Create a reusable content block | POST | /api/v1/cms/blocks | bearer | Portal / Admin | No |
| 29 | List all content blocks | GET | /api/v1/cms/blocks | bearer | Portal / Admin | No |
| 30 | Update a reusable content block | PUT | /api/v1/cms/blocks/:id | bearer | Portal / Admin | No |
| 31 | Soft-delete a content block | DELETE | /api/v1/cms/blocks/:id | bearer | Portal / Admin | No |

### 22. Enterprise QR Subsystem

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Generate a cryptographically signed QR token for any business entity | POST | /api/v1/qr | bearer | Portal / Admin | No |
| 2 | List all QR tokens owned by current user (supports entityType filtering) | GET | /api/v1/qr | bearer | Portal / Admin | No |
| 3 | Alias for generating a signed QR identity | POST | /api/v1/qr/generate | bearer | Portal / Admin | No |
| 4 | Verify QR token signature, check validity status, and log scan details | POST | /api/v1/qr/verify | bearer | Portal / Admin | No |
| 5 | Rotate QR token by ID | POST | /api/v1/qr/rotate | bearer | Portal / Admin | No |
| 6 | Rotate QR token (invalidates old token, generates new version) | POST | /api/v1/qr/:id/rotate | bearer | Portal / Admin | No |
| 7 | Revoke QR token by ID | POST | /api/v1/qr/revoke | bearer | Portal / Admin | No |
| 8 | Revoke a QR token | POST | /api/v1/qr/:id/revoke | bearer | Portal / Admin | No |
| 9 | Restore a revoked or archived QR token | POST | /api/v1/qr/:id/restore | bearer | Portal / Admin | No |
| 10 | Archive a QR token | POST | /api/v1/qr/:id/archive | bearer | Portal / Admin | No |
| 11 | Search QR tokens directory by token or entity ID | GET | /api/v1/qr/search | bearer | Portal / Admin | No |
| 12 | Get QR scan and usage analytics | GET | /api/v1/qr/statistics | bearer | Portal / Admin | No |
| 13 | Get QR details by ID | GET | /api/v1/qr/:id | bearer | Portal / Admin | No |
| 14 | Update QR code validity or parameters | PUT | /api/v1/qr/:id | bearer | Portal / Admin | No |
| 15 | Soft-delete a QR token | DELETE | /api/v1/qr/:id | bearer | Portal / Admin | No |
| 16 | Get complete status lifecycle history for a QR code | GET | /api/v1/qr/:id/history | bearer | Portal / Admin | No |
| 17 | Get scan audit log history for a QR code | GET | /api/v1/qr/:id/scans | bearer | Portal / Admin | No |
| 18 | Bulk generate QR tokens for multiple entities | POST | /api/v1/qr/bulk-generate | bearer | Portal / Admin | No |
| 19 | Bulk rotate multiple QR tokens | POST | /api/v1/qr/bulk-rotate | bearer | Portal / Admin | No |
| 20 | Bulk revoke multiple QR tokens | POST | /api/v1/qr/bulk-revoke | bearer | Portal / Admin | No |

### 23. Observability & Performance Probes

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Get Enterprise Observability Platform operational dashboard | GET | /api/v1/observability/dashboard | bearer | Portal / Admin | No |
| 2 | Get full component health diagnostics status | GET | /api/v1/observability/health | noauth | Portal / Admin | No |
| 3 | Liveness probe endpoint | GET | /api/v1/observability/health/live | noauth | Portal / Admin | No |
| 4 | Readiness probe endpoint | GET | /api/v1/observability/health/ready | noauth | Portal / Admin | No |
| 5 | Record custom system/application metric | POST | /api/v1/observability/metrics | bearer | Portal / Admin | No |
| 6 | List recorded metrics | GET | /api/v1/observability/metrics | bearer | Portal / Admin | No |
| 7 | Get metrics by category | GET | /api/v1/observability/metrics/:category | bearer | Portal / Admin | No |
| 8 | Query structured application logs | GET | /api/v1/observability/logs | bearer | Portal / Admin | No |
| 9 | Get all logs for a specific Request ID | GET | /api/v1/observability/logs/:requestId | bearer | Portal / Admin | No |
| 10 | List distributed trace executions | GET | /api/v1/observability/traces | bearer | Portal / Admin | No |
| 11 | Get distributed trace by Trace ID | GET | /api/v1/observability/traces/:traceId | bearer | Portal / Admin | No |
| 12 | List background job execution history | GET | /api/v1/observability/jobs | bearer | Portal / Admin | No |
| 13 | Get background job execution details by ID | GET | /api/v1/observability/jobs/:id | bearer | Portal / Admin | No |
| 14 | Get latest application performance snapshot | GET | /api/v1/observability/performance | bearer | Portal / Admin | No |
| 15 | Get platform operational throughput & latency statistics | GET | /api/v1/observability/statistics | bearer | Portal / Admin | No |

### 24. Immunisation Platform & Vaccines

| # | API Name | Method | Path | Auth | Relevance | Integrated in Flutter? |
|---|---|:---:|---|:---:|:---:|:---:|
| 1 | Register a vaccine in directory | POST | /api/v1/immunisation/vaccines | bearer | Portal / Admin | No |
| 2 | List all available vaccines | GET | /api/v1/immunisation/vaccines | bearer | Portal / Admin | No |
| 3 | Create a vaccination schedule / dose rule | POST | /api/v1/immunisation/schedules | bearer | Portal / Admin | No |
| 4 | List vaccination schedules (supports vaccineId filter) | GET | /api/v1/immunisation/schedules | bearer | Portal / Admin | No |
| 5 | Create/Schedule a patient vaccination record | POST | /api/v1/immunisation/records | bearer | Portal / Admin | No |
| 6 | List all vaccination records for current patient | GET | /api/v1/immunisation/records | bearer | Portal / Admin | No |
| 7 | Search immunisation directory by vaccine, batch, or facility | GET | /api/v1/immunisation/search | bearer | Portal / Admin | No |
| 8 | Get immunisation platform statistics | GET | /api/v1/immunisation/statistics | bearer | Portal / Admin | No |
| 9 | Get specific vaccination record details | GET | /api/v1/immunisation/records/:id | bearer | Portal / Admin | No |
| 10 | Update vaccination record details (blocked if ARCHIVED) | PUT | /api/v1/immunisation/records/:id | bearer | Portal / Admin | No |
| 11 | Administer a dose (captures batch, lot, site, administrator) | POST | /api/v1/immunisation/records/:id/administer | bearer | Portal / Admin | No |
| 12 | Mark vaccination record / series as completed | POST | /api/v1/immunisation/records/:id/complete | bearer | Portal / Admin | No |
| 13 | Defer a dose with clinical reason and rescheduled date | POST | /api/v1/immunisation/records/:id/defer | bearer | Portal / Admin | No |
| 14 | Archive a vaccination record | POST | /api/v1/immunisation/records/:id/archive | bearer | Portal / Admin | No |
| 15 | Restore an archived vaccination record | POST | /api/v1/immunisation/records/:id/restore | bearer | Portal / Admin | No |
| 16 | Generate digital vaccine certificate with QR token & PDF link | POST | /api/v1/immunisation/certificates | bearer | Portal / Admin | No |
| 17 | List all digital vaccine certificates for current patient | GET | /api/v1/immunisation/certificates | bearer | Portal / Admin | No |
| 18 | Configure vaccination reminder metadata & preferences | POST | /api/v1/immunisation/reminders/config | bearer | Portal / Admin | No |
