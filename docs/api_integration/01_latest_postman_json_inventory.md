# 01. CareID Patient App — Latest Postman JSON API Inventory

**Postman Collection:** `CareID-Staging.postman_collection(2).json`  
**Release Version:** November 3, 2026 Staging Release  
**Backend Base URL:** `https://360api.vnvision.in` (`/api/v1`)  
**Total Collection Requests:** 510 across 27 domain folders  
**Patient App Applicable Requests:** 383 across 22 domain folders  
**Excluded Platform-Only Requests:** 127 (Doctor Portal, Admin, Staff, Hospital Analytics, Probes)  

---

## 1. Domain Summary of Patient App Applicable APIs

| Domain Folder | Total Requests | Patient Applicable | Key Capabilities Covered |
|---|:---:|:---:|---|
| **01. Environment & Health Checks** | 3 | 3 | Patient Applicable |
| **02. Authentication & OTP** | 9 | 9 | Patient Applicable |
| **03. User Profile & Account** | 8 | 8 | Patient Applicable |
| **04. Admin Portal & System Operations** | 38 | 0 | Platform Only (Excluded) |
| **05. Doctor Portal** | 24 | 0 | Platform Only (Excluded) |
| **06. Patient App** | 28 | 28 | Patient Applicable |
| **07. Digital Health Cards & Passes** | 16 | 16 | Patient Applicable |
| **08. Medical Records (General, Dental & Vision)** | 11 | 11 | Patient Applicable |
| **09. Facilities & Branches** | 20 | 20 | Patient Applicable |
| **10. Appointments, Schedules & Shifts** | 29 | 29 | Patient Applicable |
| **11. Referrals & Care Coordination** | 16 | 16 | Patient Applicable |
| **12. Family Members & Relationships** | 22 | 22 | Patient Applicable |
| **13. Staff Management** | 16 | 0 | Platform Only (Excluded) |
| **14. Notifications & Alerts** | 29 | 29 | Patient Applicable |
| **15. OCR & Document Verification** | 18 | 18 | Patient Applicable |
| **16. File Uploads & Attachments** | 6 | 6 | Patient Applicable |
| **17. Governance, Legal & Compliance** | 28 | 28 | Patient Applicable |
| **18. Security, Threat Detection & Sessions** | 23 | 23 | Patient Applicable |
| **19. Insurance Platform & Claims** | 29 | 29 | Patient Applicable |
| **20. Clinical Reports & Analytics** | 34 | 0 | Platform Only (Excluded) |
| **21. Content Management System (CMS)** | 31 | 31 | Patient Applicable |
| **22. Enterprise QR Subsystem** | 20 | 20 | Patient Applicable |
| **23. Observability & Performance Probes** | 15 | 0 | Platform Only (Excluded) |
| **24. Immunisation Platform & Vaccines** | 18 | 18 | Patient Applicable |
| **25. Support Tickets & Helpdesk** | 6 | 6 | Patient Applicable |
| **26. Pet Health Records** | 7 | 7 | Patient Applicable |
| **27. Healthcare Financing & Financial Assistance** | 6 | 6 | Patient Applicable |

---

## 2. Complete Patient App Request Catalog

### 01. Environment & Health Checks (3 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Platform Health Check | `GET` | `/api/v1/health` | noauth | none | - |
| Platform Readiness Probe | `GET` | `/api/v1/ready` | noauth | none | - |
| Platform Liveness Probe | `GET` | `/api/v1/live` | noauth | none | - |

### 02. Authentication & OTP (9 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| CareID Admin/Super Admin Password Login | `POST` | `/api/v1/auth/password/login` | noauth | raw | - |
| Admin Email/Password Login (Legacy Alias) | `POST` | `/api/v1/auth/admin/login` | noauth | raw | - |
| Request Phone OTP | `POST` | `/api/v1/auth/otp/request` | noauth | raw | - |
| Verify Phone OTP & Login | `POST` | `/api/v1/auth/otp/verify` | noauth | raw | - |
| Resend OTP to registered phone number | `POST` | `/api/v1/auth/otp/resend` | noauth | raw | - |
| Refresh JWT Access Token | `POST` | `/api/v1/auth/token/refresh` | noauth | raw | - |
| User Session Logout | `POST` | `/api/v1/auth/logout` | noauth | raw | - |
| Logout all devices and revoke all tokens | `POST` | `/api/v1/auth/logout-all` | noauth | raw | - |
| Change authenticated user password | `POST` | `/api/v1/auth/password/change` | bearer | raw | - |

### 03. User Profile & Account (8 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Get current user profile and claims | `GET` | `/api/v1/auth/me` | bearer | none | - |
| Update current user profile | `PUT` | `/api/v1/auth/me` | bearer | raw | - |
| Partially update current user profile | `PATCH` | `/api/v1/auth/me` | bearer | raw | - |
| List active sessions for authenticated user | `GET` | `/api/v1/auth/sessions` | bearer | none | - |
| Terminate all other active sessions | `DELETE` | `/api/v1/auth/sessions` | bearer | none | - |
| Terminate a specific active session | `DELETE` | `/api/v1/auth/sessions/:sessionId` | bearer | none | - |
| Get current user assigned roles | `GET` | `/api/v1/auth/roles` | bearer | none | - |
| Get current user assigned permissions | `GET` | `/api/v1/auth/permissions` | bearer | none | - |

### 06. Patient App (28 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Step 1: Initialize Patient Draft Registration | `POST` | `/api/v1/patients/register` | bearer | none | - |
| Check Draft Registration Progress Status | `GET` | `/api/v1/patients/register/status` | bearer | none | - |
| Resume and update registration progress | `PATCH` | `/api/v1/patients/register/resume` | bearer | none | step |
| Step 2: Patient Demographic Registration | `POST` | `/api/v1/patients/onboarding/demographics` | bearer | raw | - |
| Step 2: Update Demographics Details | `PUT` | `/api/v1/patients/onboarding/demographics` | bearer | raw | - |
| Step 3: Save Emergency Contact | `POST` | `/api/v1/patients/onboarding/emergency-contact` | bearer | raw | - |
| Step 3: Update Emergency Contact | `PUT` | `/api/v1/patients/onboarding/emergency-contact` | bearer | raw | - |
| Step 4: Save Primary/Secondary Insurance Link | `POST` | `/api/v1/patients/onboarding/insurance` | bearer | raw | - |
| Step 4: Update Insurance Details | `PUT` | `/api/v1/patients/onboarding/insurance` | bearer | raw | - |
| Step 5: Initialize Secure Digital Health Card | `POST` | `/api/v1/patients/onboarding/health-card` | bearer | none | - |
| Step 6: Family Account Linkage Request | `POST` | `/api/v1/patients/onboarding/family-invite` | bearer | raw | - |
| Get Step-by-Step Onboarding Progress Checklist | `GET` | `/api/v1/patients/onboarding/progress` | bearer | none | - |
| Finalize and Complete Onboarding Registration | `POST` | `/api/v1/patients/onboarding/complete` | bearer | none | - |
| Get overall Patient Onboarding Completion percentage | `GET` | `/api/v1/patients/onboarding/completion` | bearer | none | - |
| Get Patient Profile Details | `GET` | `/api/v1/patients/me` | bearer | none | - |
| Update Patient Profile | `PUT` | `/api/v1/patients/me` | bearer | raw | - |
| Accept / Reject Family Linkage Consent | `PATCH` | `/api/v1/patients/family-consents/:id` | bearer | raw | - |
| Get Full Patient Profile with all extended fields | `GET` | `/api/v1/patients/me/full` | bearer | none | - |
| Update Basic Patient Information (name, DOB, gender, nationality, etc.) | `PATCH` | `/api/v1/patients/me/basic` | bearer | raw | - |
| Update Contact Preferences | `PATCH` | `/api/v1/patients/me/contact` | bearer | raw | - |
| Update Current and Permanent Address | `PATCH` | `/api/v1/patients/me/address` | bearer | raw | - |
| Update Communication Preferences and Privacy Settings | `PATCH` | `/api/v1/patients/me/preferences` | bearer | raw | - |
| Update Medical Summary (blood group, allergies, conditions, disabilities) | `PATCH` | `/api/v1/patients/me/medical-summary` | bearer | raw | - |
| Upload or Replace Profile Photo (provide photoUrl and photoKey) | `POST` | `/api/v1/patients/me/photo` | bearer | none | - |
| Delete Profile Photo | `DELETE` | `/api/v1/patients/me/photo` | bearer | none | - |
| Get Patient Profile Completion Status with section breakdown | `GET` | `/api/v1/patients/profile/completion` | bearer | none | - |
| Get Patient Profile Change Timeline | `GET` | `/api/v1/patients/profile/timeline` | bearer | none | - |
| Get Patient Profile Activity Summary | `GET` | `/api/v1/patients/profile/activity` | bearer | none | - |

### 07. Digital Health Cards & Passes (16 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Issue a new Health Card for authenticated patient | `POST` | `/api/v1/health-cards` | noauth | raw | - |
| Get active Health Card details for current patient | `GET` | `/api/v1/health-cards` | noauth | none | - |
| Search Health Cards by card number or patient name | `GET` | `/api/v1/health-cards/search` | noauth | none | q |
| Get specific Health Card details by ID | `GET` | `/api/v1/health-cards/:id` | noauth | none | - |
| Update Health Card emergency flag or metadata | `PUT` | `/api/v1/health-cards/:id` | noauth | raw | - |
| Activate an ISSUED or DEACTIVATED Health Card | `POST` | `/api/v1/health-cards/:id/activate` | noauth | raw | - |
| Deactivate Health Card | `POST` | `/api/v1/health-cards/:id/deactivate` | noauth | raw | - |
| Suspend Health Card | `POST` | `/api/v1/health-cards/:id/suspend` | noauth | raw | - |
| Block Health Card for security or lost card reasons | `POST` | `/api/v1/health-cards/:id/block` | noauth | raw | - |
| Unblock a BLOCKED Health Card | `POST` | `/api/v1/health-cards/:id/unblock` | noauth | raw | - |
| Replace Health Card — generates a new card number and increments version | `POST` | `/api/v1/health-cards/:id/replace` | noauth | raw | - |
| Renew Health Card — extends validity period by 1 year | `POST` | `/api/v1/health-cards/:id/renew` | noauth | raw | - |
| Archive Health Card | `POST` | `/api/v1/health-cards/:id/archive` | noauth | raw | - |
| Restore an ARCHIVED Health Card | `POST` | `/api/v1/health-cards/:id/restore` | noauth | raw | - |
| Get complete status lifecycle audit history for Health Card | `GET` | `/api/v1/health-cards/:id/history` | noauth | none | - |
| Verify digital Health Card QR payload | `POST` | `/api/v1/health-cards/verify-qr` | noauth | raw | - |

### 08. Medical Records (General, Dental & Vision) (11 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Create a new medical record with encounter, vitals, diagnosis, and procedures | `POST` | `/api/v1/medical-records` | bearer | raw | - |
| Get all medical records for the authenticated patient | `GET` | `/api/v1/medical-records` | bearer | none | - |
| Get unified medical timeline combining records and attachments | `GET` | `/api/v1/medical-records/timeline` | bearer | none | - |
| Search medical records by title, complaints, notes, diagnosis, or plan | `GET` | `/api/v1/medical-records/search` | bearer | none | q |
| Get a specific medical record by ID | `GET` | `/api/v1/medical-records/:id` | bearer | none | - |
| Update an existing medical record (blocked if ARCHIVED) | `PUT` | `/api/v1/medical-records/:id` | bearer | raw | - |
| Soft delete a medical record | `DELETE` | `/api/v1/medical-records/:id` | bearer | none | - |
| Archive a medical record (makes record immutable) | `POST` | `/api/v1/medical-records/:id/archive` | bearer | none | - |
| Restore a soft-deleted or archived medical record | `POST` | `/api/v1/medical-records/:id/restore` | bearer | none | - |
| Upload and link an attachment to a specific medical record | `POST` | `/api/v1/medical-records/:id/attachments` | bearer | raw | - |
| List all attachments linked to a specific medical record | `GET` | `/api/v1/medical-records/:id/attachments` | bearer | none | - |

### 09. Facilities & Branches (20 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Register/Create a facility profile in Master Registry | `POST` | `/api/v1/facilities` | bearer | raw | - |
| List all registered facility profiles | `GET` | `/api/v1/facilities` | bearer | none | page, limit |
| Enterprise facility search (by name, code, city, type) | `GET` | `/api/v1/facilities/search` | bearer | none | q |
| Get platform-wide facility directory statistics | `GET` | `/api/v1/facilities/statistics` | bearer | none | - |
| Get complete facility details | `GET` | `/api/v1/facilities/:id` | bearer | none | - |
| Update facility details | `PUT` | `/api/v1/facilities/:id` | bearer | none | - |
| Soft-delete a facility | `DELETE` | `/api/v1/facilities/:id` | bearer | none | - |
| Approve & verify facility registration | `POST` | `/api/v1/facilities/:id/verify` | bearer | raw | - |
| Suspend facility registration | `POST` | `/api/v1/facilities/:id/suspend` | bearer | raw | - |
| Restore suspended facility registration | `POST` | `/api/v1/facilities/:id/restore` | bearer | raw | - |
| Generate Facility Digital Identity QR token | `POST` | `/api/v1/facilities/:id/generate-qr` | bearer | none | - |
| List facility departments | `GET` | `/api/v1/facilities/:id/departments` | bearer | none | - |
| Create facility department | `POST` | `/api/v1/facilities/:id/departments` | bearer | raw | - |
| List facility rooms | `GET` | `/api/v1/facilities/:id/rooms` | bearer | none | - |
| Create facility room | `POST` | `/api/v1/facilities/:id/rooms` | bearer | raw | - |
| Assign doctor to facility | `POST` | `/api/v1/facilities/:id/assign-doctor` | bearer | raw | - |
| List associated facility doctors | `GET` | `/api/v1/facilities/:id/doctors` | bearer | none | - |
| List attached facility credential documents | `GET` | `/api/v1/facilities/:id/documents` | bearer | none | - |
| Attach credential document (reusing MedicalAttachment) | `POST` | `/api/v1/facilities/:id/documents` | bearer | raw | - |
| Get complete verification & status lifecycle history | `GET` | `/api/v1/facilities/:id/history` | bearer | none | - |

### 10. Appointments, Schedules & Shifts (29 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Book a new appointment | `POST` | `/api/v1/appointments` | bearer | raw | - |
| List appointments with filtering and pagination | `GET` | `/api/v1/appointments` | bearer | none | page, limit, patientProfileId, doctorProfileId, facilityId, status, type, fromDate, toDate |
| Get appointments scheduled for authenticated doctor | `GET` | `/api/v1/appointments/doctor/my-appointments` | bearer | none | page, limit, patientProfileId, doctorProfileId, facilityId, status, type, fromDate, toDate |
| Get appointments scheduled for authenticated doctor | `GET` | `/api/v1/appointments/doctor/me` | bearer | none | page, limit, patientProfileId, doctorProfileId, facilityId, status, type, fromDate, toDate |
| Get appointments scheduled for authenticated patient | `GET` | `/api/v1/appointments/patient/my-appointments` | bearer | none | page, limit, patientProfileId, doctorProfileId, facilityId, status, type, fromDate, toDate |
| Get appointments scheduled for authenticated patient | `GET` | `/api/v1/appointments/patient/me` | bearer | none | page, limit, patientProfileId, doctorProfileId, facilityId, status, type, fromDate, toDate |
| Get appointment details by ID | `GET` | `/api/v1/appointments/:id` | bearer | none | - |
| Reschedule an existing appointment | `PUT` | `/api/v1/appointments/:id/reschedule` | bearer | raw | - |
| Cancel an appointment | `PUT` | `/api/v1/appointments/:id/cancel` | bearer | raw | - |
| Update appointment status (clinical & operational staff) | `PUT` | `/api/v1/appointments/:id/status` | bearer | raw | - |
| Create a schedule profile (doctor / staff / facility) | `POST` | `/api/v1/schedules` | bearer | raw | - |
| List all schedule profiles | `GET` | `/api/v1/schedules` | bearer | none | - |
| Search schedules by owner type, title, facility or doctor | `GET` | `/api/v1/schedules/search` | bearer | none | q |
| Platform-wide scheduling engine statistics | `GET` | `/api/v1/schedules/statistics` | bearer | none | - |
| Get schedule detail with working hours, exceptions, leave blocks | `GET` | `/api/v1/schedules/:id` | bearer | none | - |
| Update schedule profile and/or working hours | `PUT` | `/api/v1/schedules/:id` | bearer | none | - |
| Soft-delete a schedule profile | `DELETE` | `/api/v1/schedules/:id` | bearer | none | - |
| Run slot generation engine for a date range | `POST` | `/api/v1/schedules/:id/generate-slots` | bearer | raw | - |
| Get generated slots for a schedule in a date range | `GET` | `/api/v1/schedules/:id/slots` | bearer | none | fromDate, toDate |
| Add schedule exception (vacation, conference, emergency, etc.) | `POST` | `/api/v1/schedules/:id/block` | bearer | raw | - |
| Remove a schedule exception by its ID | `POST` | `/api/v1/schedules/:id/unblock` | bearer | none | exceptionId |
| Add leave block (sick, casual, earned, emergency) to schedule | `POST` | `/api/v1/schedules/:id/leave` | bearer | raw | - |
| Get full schedule audit & modification history | `GET` | `/api/v1/schedules/:id/history` | bearer | none | - |
| Create shift definition (Morning / Evening / Night / Split / Custom) | `POST` | `/api/v1/shifts` | bearer | raw | - |
| List shift definitions, optionally filtered by facility | `GET` | `/api/v1/shifts` | bearer | none | facilityId |
| Assign a staff member to a shift for a specific date | `POST` | `/api/v1/shifts/:id/assign` | bearer | raw | - |
| Get all staff assignments for a specific shift | `GET` | `/api/v1/shifts/:id/assignments` | bearer | none | - |
| Add a holiday to the calendar (global or facility-specific) | `POST` | `/api/v1/holidays` | bearer | raw | - |
| List holidays (global + optional facility-specific) | `GET` | `/api/v1/holidays` | bearer | none | facilityId |

### 11. Referrals & Care Coordination (16 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Create patient care referral | `POST` | `/api/v1/referrals` | bearer | raw | - |
| List patient care referrals with optional filters | `GET` | `/api/v1/referrals` | bearer | none | - |
| List incoming referrals for current doctor/facility | `GET` | `/api/v1/referrals/my-incoming` | bearer | none | - |
| List outgoing referrals created by current doctor | `GET` | `/api/v1/referrals/my-outgoing` | bearer | none | - |
| Get referral dashboard metrics and SLA performance analytics | `GET` | `/api/v1/referrals/dashboard/stats` | bearer | none | facilityId |
| Get referral details by ID | `GET` | `/api/v1/referrals/:id` | bearer | none | - |
| Update referral clinical details | `PUT` | `/api/v1/referrals/:id` | bearer | raw | - |
| Soft-delete referral | `DELETE` | `/api/v1/referrals/:id` | bearer | none | - |
| Triage patient referral (Approve/Decline/Redirect) | `PUT` | `/api/v1/referrals/:id/triage` | bearer | raw | - |
| Update referral status (IN_PROGRESS, COMPLETED, CANCELLED) | `PUT` | `/api/v1/referrals/:id/status` | bearer | raw | - |
| Update referral status (alias for PUT :id/status) | `PATCH` | `/api/v1/referrals/:id/status` | bearer | raw | - |
| Add clinical coordination note to referral | `POST` | `/api/v1/referrals/:id/notes` | bearer | raw | - |
| List clinical notes for referral | `GET` | `/api/v1/referrals/:id/notes` | bearer | none | - |
| Link medical attachment to referral | `POST` | `/api/v1/referrals/:id/attachments` | bearer | raw | - |
| List linked medical attachments for referral | `GET` | `/api/v1/referrals/:id/attachments` | bearer | none | - |
| Get immutable status transition history for referral | `GET` | `/api/v1/referrals/:id/history` | bearer | none | - |

### 12. Family Members & Relationships (22 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Create a family invitation | `POST` | `/api/v1/family/invitations` | bearer | raw | - |
| List all invitations sent by the patient | `GET` | `/api/v1/family/invitations` | bearer | none | - |
| Resend a pending family invitation (max 5 times) | `POST` | `/api/v1/family/invitations/:id/resend` | bearer | none | - |
| Accept a family invitation — auto-creates family member record | `POST` | `/api/v1/family/invitations/:id/accept` | bearer | none | - |
| Reject a family invitation | `POST` | `/api/v1/family/invitations/:id/reject` | bearer | none | - |
| Cancel a pending family invitation | `DELETE` | `/api/v1/family/invitations/:id` | bearer | none | - |
| List all active family members | `GET` | `/api/v1/family/members` | bearer | none | - |
| Get a specific family member | `GET` | `/api/v1/family/members/:id` | bearer | none | - |
| Update family member details or status | `PATCH` | `/api/v1/family/members/:id` | bearer | raw | - |
| Remove (archive) a family member | `DELETE` | `/api/v1/family/members/:id` | bearer | none | - |
| Grant a consent category to a family member | `POST` | `/api/v1/family/consents` | bearer | raw | - |
| List all active consents granted by the patient | `GET` | `/api/v1/family/consents` | bearer | none | - |
| Update consent (expiry date, notes) | `PUT` | `/api/v1/family/consents/:id` | bearer | raw | - |
| Revoke a granted consent — blocks access immediately | `DELETE` | `/api/v1/family/consents/:id` | bearer | none | - |
| Get full consent audit history for the patient | `GET` | `/api/v1/family/consents/history` | bearer | none | - |
| List all guardians assigned to the patient | `GET` | `/api/v1/family/guardians` | bearer | none | - |
| Assign a guardian to the patient | `POST` | `/api/v1/family/guardians` | bearer | raw | - |
| Update guardian verification status or primary flag | `PATCH` | `/api/v1/family/guardians/:id` | bearer | raw | - |
| List all dependents registered under this patient | `GET` | `/api/v1/family/dependents` | bearer | none | - |
| Register a dependent (minor, senior, or care patient) | `POST` | `/api/v1/family/dependents` | bearer | raw | - |
| Update dependent details | `PATCH` | `/api/v1/family/dependents/:id` | bearer | raw | - |
| Remove a dependent | `DELETE` | `/api/v1/family/dependents/:id` | bearer | none | - |

### 14. Notifications & Alerts (29 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Get Enterprise Notification Platform stats & queue summary | `GET` | `/api/v1/notifications/dashboard/stats` | bearer | none | - |
| Get Enterprise Notification Platform stats & queue summary | `GET` | `/api/v1/notification/dashboard/stats` | bearer | none | - |
| Get current user notification preferences | `GET` | `/api/v1/notifications/preferences` | bearer | none | - |
| Update current user notification channel preferences | `PUT` | `/api/v1/notifications/preferences` | bearer | raw | - |
| Get current user notification preferences | `GET` | `/api/v1/notification/preferences` | bearer | none | - |
| Update current user notification channel preferences | `PUT` | `/api/v1/notification/preferences` | bearer | raw | - |
| List pending/queued notification delivery items with optional filters | `GET` | `/api/v1/notifications/queue` | bearer | none | status, notificationType, dateFrom, dateTo, page, limit |
| List pending/queued notification delivery items with optional filters | `GET` | `/api/v1/notification/queue` | bearer | none | status, notificationType, dateFrom, dateTo, page, limit |
| Retry queued/failed notification delivery attempts | `POST` | `/api/v1/notifications/queue/retry` | bearer | raw | - |
| Retry queued/failed notification delivery attempts | `POST` | `/api/v1/notification/queue/retry` | bearer | raw | - |
| Process pending notification queue and dispatch via gateways | `POST` | `/api/v1/notifications/queue/process` | bearer | none | - |
| Process pending notification queue and dispatch via gateways | `POST` | `/api/v1/notification/queue/process` | bearer | none | - |
| List notification audit logs | `GET` | `/api/v1/notifications/audit` | bearer | none | - |
| List notification audit logs | `GET` | `/api/v1/notification/audit` | bearer | none | - |
| Publish/dispatch a notification across channels | `POST` | `/api/v1/notifications` | bearer | raw | - |
| List notifications for recipient or platform | `GET` | `/api/v1/notifications` | bearer | none | recipientUserId, status |
| Publish/dispatch a notification across channels | `POST` | `/api/v1/notification` | bearer | raw | - |
| List notifications for recipient or platform | `GET` | `/api/v1/notification` | bearer | none | recipientUserId, status |
| Get notification details by ID | `GET` | `/api/v1/notifications/:id` | bearer | none | - |
| Soft-delete a notification | `DELETE` | `/api/v1/notifications/:id` | bearer | none | - |
| Get notification details by ID | `GET` | `/api/v1/notification/:id` | bearer | none | - |
| Soft-delete a notification | `DELETE` | `/api/v1/notification/:id` | bearer | none | - |
| Mark notification as READ | `PUT` | `/api/v1/notifications/:id/read` | bearer | none | - |
| Mark notification as READ | `PUT` | `/api/v1/notification/:id/read` | bearer | none | - |
| Create a new notification template with variable placeholders | `POST` | `/api/v1/notifications/templates` | bearer | raw | - |
| List all notification templates | `GET` | `/api/v1/notifications/templates` | bearer | none | - |
| Get notification template by ID | `GET` | `/api/v1/notifications/templates/:id` | bearer | none | - |
| Update template body or subject and increment version | `PUT` | `/api/v1/notifications/templates/:id` | bearer | raw | - |
| Soft-delete a notification template | `DELETE` | `/api/v1/notifications/templates/:id` | bearer | none | - |

### 15. OCR & Document Verification (18 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Get Enterprise OCR Platform analytics dashboard summary | `GET` | `/api/v1/ocr/dashboard` | bearer | none | - |
| Get Enterprise OCR accuracy & throughput statistics | `GET` | `/api/v1/ocr/statistics` | bearer | none | - |
| Submit medical attachment for local CPU OCR processing | `POST` | `/api/v1/ocr/jobs` | bearer | raw | - |
| List all OCR jobs with optional status, document type and pagination filters | `GET` | `/api/v1/ocr/jobs` | bearer | none | status, documentType, page, limit |
| Reprocess a completed, failed, or review-required OCR job | `POST` | `/api/v1/ocr/reprocess/:jobId` | bearer | none | - |
| Get OCR job status and details by ID | `GET` | `/api/v1/ocr/jobs/:id` | bearer | none | - |
| Get extracted raw OCR text for job | `GET` | `/api/v1/ocr/jobs/:id/text` | bearer | none | - |
| Get extracted structured fields with confidence scores | `GET` | `/api/v1/ocr/jobs/:id/fields` | bearer | none | - |
| Get formatted structured JSON output of OCR job | `GET` | `/api/v1/ocr/jobs/:id/json` | bearer | none | - |
| Create an OCR Document Template with field definitions | `POST` | `/api/v1/ocr/templates` | bearer | raw | - |
| List all OCR Document Templates | `GET` | `/api/v1/ocr/templates` | bearer | none | - |
| Update OCR Document Template and increment version | `PUT` | `/api/v1/ocr/templates/:id` | bearer | raw | - |
| Soft-delete an OCR Document Template | `DELETE` | `/api/v1/ocr/templates/:id` | bearer | none | - |
| Get paginated audit history of completed human OCR reviews | `GET` | `/api/v1/ocr/reviews/history` | bearer | none | page, limit, status, reviewerId, startDate, endDate |
| List OCR jobs requiring manual human verification | `GET` | `/api/v1/ocr/review` | bearer | none | - |
| Submit human verification review for low-confidence OCR job | `POST` | `/api/v1/ocr/review/:jobId` | bearer | raw | - |
| Image Scan & Candidate Metadata Extraction | `POST` | `/api/v1/ai/ocr/extract` | bearer | raw | - |
| OCR Candidate Field Review & Manual Confirmation | `POST` | `/api/v1/ai/ocr/confirm` | bearer | raw | - |

### 16. File Uploads & Attachments (6 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Upload an unlinked or global attachment (reusable across system) | `POST` | `/api/v1/attachments` | bearer | raw | - |
| Get attachment metadata by ID | `GET` | `/api/v1/attachments/:id` | bearer | none | - |
| Update attachment category, metadata, or upload a new file version | `PATCH` | `/api/v1/attachments/:id` | bearer | raw | - |
| Soft-delete an attachment | `DELETE` | `/api/v1/attachments/:id` | bearer | none | - |
| Restore a soft-deleted attachment | `POST` | `/api/v1/attachments/:id/restore` | bearer | none | - |
| Get file version history for an attachment | `GET` | `/api/v1/attachments/:id/versions` | bearer | none | - |

### 17. Governance, Legal & Compliance (28 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Get Enterprise Governance Dashboard summary | `GET` | `/api/v1/governance/dashboard` | bearer | none | - |
| Create a new system configuration key-value entry | `POST` | `/api/v1/governance/configurations` | bearer | raw | - |
| List all system configurations, optionally filtered by category | `GET` | `/api/v1/governance/configurations` | bearer | none | category |
| Export system configurations in JSON format | `GET` | `/api/v1/governance/configurations/export` | bearer | none | category |
| Bulk import system configurations | `POST` | `/api/v1/governance/configurations/import` | bearer | raw | - |
| Get system configuration by ID | `GET` | `/api/v1/governance/configurations/:id` | bearer | none | - |
| Update system configuration value and increment version | `PUT` | `/api/v1/governance/configurations/:id` | bearer | raw | - |
| Soft-delete system configuration entry | `DELETE` | `/api/v1/governance/configurations/:id` | bearer | none | - |
| Create a new feature flag with rollout rules | `POST` | `/api/v1/governance/features` | bearer | raw | - |
| List all feature flags | `GET` | `/api/v1/governance/features` | bearer | none | - |
| Get feature flag details by ID | `GET` | `/api/v1/governance/features/:id` | bearer | none | - |
| Update feature flag status, roles, or rollout percentage | `PUT` | `/api/v1/governance/features/:id` | bearer | none | - |
| Soft-delete a feature flag | `DELETE` | `/api/v1/governance/features/:id` | bearer | none | - |
| Create a master data category | `POST` | `/api/v1/governance/master-data/categories` | bearer | raw | - |
| List all master data categories with items | `GET` | `/api/v1/governance/master-data/categories` | bearer | none | - |
| Create a master data item under a category | `POST` | `/api/v1/governance/master-data/items` | bearer | raw | - |
| List master data items, optionally filtered by category | `GET` | `/api/v1/governance/master-data/items` | bearer | none | categoryId |
| Update master data item | `PUT` | `/api/v1/governance/master-data/items/:id` | bearer | none | - |
| Soft-delete a master data item | `DELETE` | `/api/v1/governance/master-data/items/:id` | bearer | none | - |
| Create a new platform governance policy | `POST` | `/api/v1/governance/policies` | bearer | raw | - |
| List all platform governance policies | `GET` | `/api/v1/governance/policies` | bearer | none | - |
| Get policy details by ID | `GET` | `/api/v1/governance/policies/:id` | bearer | none | - |
| Update policy title, content, or version | `PUT` | `/api/v1/governance/policies/:id` | bearer | none | - |
| Soft-delete a platform policy | `DELETE` | `/api/v1/governance/policies/:id` | bearer | none | - |
| Get active platform maintenance configuration | `GET` | `/api/v1/governance/maintenance` | bearer | none | - |
| Set or update platform maintenance mode (OFF / READ_ONLY / FULL) | `PUT` | `/api/v1/governance/maintenance` | bearer | raw | - |
| List governance audit logs | `GET` | `/api/v1/governance/audit` | bearer | none | entityType |
| Get governance audit log detail by ID | `GET` | `/api/v1/governance/audit/:id` | bearer | none | - |

### 18. Security, Threat Detection & Sessions (23 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Get Enterprise Security & Compliance Dashboard summary | `GET` | `/api/v1/security/dashboard` | bearer | none | - |
| Capture patient consent record | `POST` | `/api/v1/security/consents` | bearer | raw | - |
| List patient consents with optional filters | `GET` | `/api/v1/security/consents` | bearer | none | patientId, status, consentType, startDate, endDate, page, limit |
| Get consent record details by ID | `GET` | `/api/v1/security/consents/:id` | bearer | none | - |
| Withdraw patient consent | `POST` | `/api/v1/security/consents/:id/withdraw` | bearer | none | - |
| Confirm and grant a pending patient consent record | `POST` | `/api/v1/security/consents/:id/confirm` | bearer | none | - |
| Create data retention policy | `POST` | `/api/v1/security/retention` | bearer | raw | - |
| List all retention policies | `GET` | `/api/v1/security/retention` | bearer | none | - |
| Update retention policy parameters | `PUT` | `/api/v1/security/retention/:id` | bearer | raw | - |
| Deactivate / soft-delete retention policy | `DELETE` | `/api/v1/security/retention/:id` | bearer | none | - |
| Log new security incident | `POST` | `/api/v1/security/incidents` | bearer | raw | - |
| List security incidents with severity/status filters | `GET` | `/api/v1/security/incidents` | bearer | none | severity, status |
| Resolve an open security incident | `PUT` | `/api/v1/security/incidents/:id/resolve` | bearer | raw | - |
| Get active KMS encryption key metadata | `GET` | `/api/v1/security/keys/active` | bearer | none | - |
| Trigger KMS encryption key rotation | `POST` | `/api/v1/security/keys/rotate` | bearer | none | - |
| Generate automated compliance assessment report | `POST` | `/api/v1/security/compliance/report` | bearer | raw | - |
| List generated compliance reports | `GET` | `/api/v1/security/compliance/reports` | bearer | none | - |
| List security audit logs | `GET` | `/api/v1/security/audit` | bearer | none | userId, resource |
| Create API key for developer / partner system integration | `POST` | `/api/v1/security/api-keys` | bearer | raw | - |
| List all active and revoked API keys | `GET` | `/api/v1/security/api-keys` | bearer | none | - |
| Get API key metadata by ID | `GET` | `/api/v1/security/api-keys/:id` | bearer | none | - |
| Delete an API key | `DELETE` | `/api/v1/security/api-keys/:id` | bearer | none | - |
| Revoke an active API key | `PATCH` | `/api/v1/security/api-keys/:id/revoke` | bearer | none | - |

### 19. Insurance Platform & Claims (29 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Create an insurance provider | `POST` | `/api/v1/insurance/providers` | bearer | raw | - |
| List active insurance providers | `GET` | `/api/v1/insurance/providers` | bearer | none | - |
| Create an insurance plan | `POST` | `/api/v1/insurance/plans` | bearer | raw | - |
| List insurance plans (supports providerId filter) | `GET` | `/api/v1/insurance/plans` | bearer | none | providerId |
| Issue/Register a full insurance policy for patient | `POST` | `/api/v1/insurance/policies` | bearer | raw | - |
| Get all insurance policies for current patient | `GET` | `/api/v1/insurance/policies` | bearer | none | - |
| Search insurance policies by provider or policy number | `GET` | `/api/v1/insurance/search` | bearer | none | q |
| Get platform-wide insurance statistics | `GET` | `/api/v1/insurance/statistics` | bearer | none | - |
| Get specific insurance policy details | `GET` | `/api/v1/insurance/policies/:id` | bearer | none | - |
| Update insurance policy details (blocked if ARCHIVED) | `PUT` | `/api/v1/insurance/policies/:id` | bearer | none | - |
| Activate an insurance policy | `POST` | `/api/v1/insurance/policies/:id/activate` | bearer | raw | - |
| Renew an insurance policy (extends validity by 1 year) | `POST` | `/api/v1/insurance/policies/:id/renew` | bearer | raw | - |
| Suspend an insurance policy | `POST` | `/api/v1/insurance/policies/:id/suspend` | bearer | raw | - |
| Cancel an insurance policy | `POST` | `/api/v1/insurance/policies/:id/cancel` | bearer | raw | - |
| Archive an insurance policy | `POST` | `/api/v1/insurance/policies/:id/archive` | bearer | raw | - |
| Restore an archived insurance policy | `POST` | `/api/v1/insurance/policies/:id/restore` | bearer | raw | - |
| Verify coverage status for an insurance policy | `POST` | `/api/v1/insurance/policies/:id/verify` | bearer | none | - |
| Create a claim draft attaching medical records and reports | `POST` | `/api/v1/insurance/claims` | bearer | raw | - |
| List all claim drafts for current patient | `GET` | `/api/v1/insurance/claims` | bearer | none | - |
| Save insurance details during 6-step patient onboarding (Step 4) | `POST` | `/api/v1/insurance/onboard` | bearer | raw | - |
| Scan insurance card image via OCR extraction (standard endpoint) | `POST` | `/api/v1/insurance/ocr` | bearer | raw | - |
| Get insurance card OCR scan record details by ID | `GET` | `/api/v1/insurance/ocr/:id` | bearer | none | - |
| Scan insurance card image via OCR extraction | `POST` | `/api/v1/insurance/ocr/scan` | bearer | raw | - |
| Confirm extracted OCR data to create insurance policy | `POST` | `/api/v1/insurance/ocr/confirm` | bearer | raw | - |
| Get all insurance cards for a specific patient | `GET` | `/api/v1/patients/:patientId/insurance-cards` | bearer | none | - |
| Create / add an insurance card for a specific patient | `POST` | `/api/v1/patients/:patientId/insurance-cards` | bearer | raw | - |
| Get insurance card details by ID | `GET` | `/api/v1/insurance-cards/:id` | bearer | none | - |
| Update insurance card details | `PUT` | `/api/v1/insurance-cards/:id` | bearer | none | - |
| Remove / soft-delete an insurance card | `DELETE` | `/api/v1/insurance-cards/:id` | bearer | none | - |

### 21. Content Management System (CMS) (31 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Get platform-wide CMS content statistics | `GET` | `/api/v1/cms/statistics` | bearer | none | - |
| Create a new CMS page | `POST` | `/api/v1/cms/pages` | bearer | raw | - |
| List published CMS pages | `GET` | `/api/v1/cms/pages` | bearer | none | status |
| Search published CMS pages by title, slug, content, or summary | `GET` | `/api/v1/cms/pages/search` | bearer | none | q |
| Get published CMS page by ID or slug | `GET` | `/api/v1/cms/pages/:id` | bearer | none | - |
| Update CMS page details or publication status | `PUT` | `/api/v1/cms/pages/:id` | bearer | none | - |
| Soft-delete a CMS page | `DELETE` | `/api/v1/cms/pages/:id` | bearer | none | - |
| Create a new FAQ item | `POST` | `/api/v1/cms/faqs` | bearer | raw | - |
| List published FAQs, optionally filtered by category | `GET` | `/api/v1/cms/faqs` | bearer | none | category |
| Update FAQ question, answer, category or display order | `PUT` | `/api/v1/cms/faqs/:id` | bearer | none | - |
| Soft-delete a FAQ item | `DELETE` | `/api/v1/cms/faqs/:id` | bearer | none | - |
| Create a new system announcement | `POST` | `/api/v1/cms/announcements` | bearer | raw | - |
| List active announcements | `GET` | `/api/v1/cms/announcements` | bearer | none | activeOnly |
| Update announcement | `PUT` | `/api/v1/cms/announcements/:id` | bearer | none | - |
| Soft-delete an announcement | `DELETE` | `/api/v1/cms/announcements/:id` | bearer | none | - |
| Create a new platform policy | `POST` | `/api/v1/cms/policies` | bearer | raw | - |
| List published platform policies | `GET` | `/api/v1/cms/policies` | bearer | none | policyType |
| Update policy details or version | `PUT` | `/api/v1/cms/policies/:id` | bearer | none | - |
| Soft-delete a policy | `DELETE` | `/api/v1/cms/policies/:id` | bearer | none | - |
| Create a new promotional banner | `POST` | `/api/v1/cms/banners` | bearer | raw | - |
| List active promotional banners | `GET` | `/api/v1/cms/banners` | bearer | none | activeOnly |
| Update banner image, redirect URL or display order | `PUT` | `/api/v1/cms/banners/:id` | bearer | none | - |
| Soft-delete a banner | `DELETE` | `/api/v1/cms/banners/:id` | bearer | none | - |
| Register a media item in Media Library | `POST` | `/api/v1/cms/media` | bearer | raw | - |
| List media items in library | `GET` | `/api/v1/cms/media` | bearer | none | mediaType |
| Search media library by file name or mime type | `GET` | `/api/v1/cms/media/search` | bearer | none | q |
| Soft-delete a media item | `DELETE` | `/api/v1/cms/media/:id` | bearer | none | - |
| Create a reusable content block | `POST` | `/api/v1/cms/blocks` | bearer | raw | - |
| List all content blocks | `GET` | `/api/v1/cms/blocks` | bearer | none | - |
| Update a reusable content block | `PUT` | `/api/v1/cms/blocks/:id` | bearer | none | - |
| Soft-delete a content block | `DELETE` | `/api/v1/cms/blocks/:id` | bearer | none | - |

### 22. Enterprise QR Subsystem (20 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Generate a cryptographically signed QR token for any business entity | `POST` | `/api/v1/qr` | bearer | raw | - |
| List all QR tokens owned by current user (supports entityType filtering) | `GET` | `/api/v1/qr` | bearer | none | entityType |
| Alias for generating a signed QR identity | `POST` | `/api/v1/qr/generate` | bearer | raw | - |
| Verify QR token signature, check validity status, and log scan details | `POST` | `/api/v1/qr/verify` | bearer | raw | - |
| Rotate QR token by ID | `POST` | `/api/v1/qr/rotate` | bearer | none | - |
| Rotate QR token (invalidates old token, generates new version) | `POST` | `/api/v1/qr/:id/rotate` | bearer | raw | - |
| Revoke QR token by ID | `POST` | `/api/v1/qr/revoke` | bearer | none | - |
| Revoke a QR token | `POST` | `/api/v1/qr/:id/revoke` | bearer | raw | - |
| Restore a revoked or archived QR token | `POST` | `/api/v1/qr/:id/restore` | bearer | none | - |
| Archive a QR token | `POST` | `/api/v1/qr/:id/archive` | bearer | none | - |
| Search QR tokens directory by token or entity ID | `GET` | `/api/v1/qr/search` | bearer | none | q |
| Get QR scan and usage analytics | `GET` | `/api/v1/qr/statistics` | bearer | none | - |
| Get QR details by ID | `GET` | `/api/v1/qr/:id` | bearer | none | - |
| Update QR code validity or parameters | `PUT` | `/api/v1/qr/:id` | bearer | raw | - |
| Soft-delete a QR token | `DELETE` | `/api/v1/qr/:id` | bearer | none | - |
| Get complete status lifecycle history for a QR code | `GET` | `/api/v1/qr/:id/history` | bearer | none | - |
| Get scan audit log history for a QR code | `GET` | `/api/v1/qr/:id/scans` | bearer | none | - |
| Bulk generate QR tokens for multiple entities | `POST` | `/api/v1/qr/bulk-generate` | bearer | raw | - |
| Bulk rotate multiple QR tokens | `POST` | `/api/v1/qr/bulk-rotate` | bearer | raw | - |
| Bulk revoke multiple QR tokens | `POST` | `/api/v1/qr/bulk-revoke` | bearer | raw | - |

### 24. Immunisation Platform & Vaccines (18 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Register a vaccine in directory | `POST` | `/api/v1/immunisation/vaccines` | bearer | raw | - |
| List all available vaccines | `GET` | `/api/v1/immunisation/vaccines` | bearer | none | - |
| Create a vaccination schedule / dose rule | `POST` | `/api/v1/immunisation/schedules` | bearer | raw | - |
| List vaccination schedules (supports vaccineId filter) | `GET` | `/api/v1/immunisation/schedules` | bearer | none | vaccineId |
| Create/Schedule a patient vaccination record | `POST` | `/api/v1/immunisation/records` | bearer | raw | - |
| List all vaccination records for current patient | `GET` | `/api/v1/immunisation/records` | bearer | none | - |
| Search immunisation directory by vaccine, batch, or facility | `GET` | `/api/v1/immunisation/search` | bearer | none | q |
| Get immunisation platform statistics | `GET` | `/api/v1/immunisation/statistics` | bearer | none | - |
| Get specific vaccination record details | `GET` | `/api/v1/immunisation/records/:id` | bearer | none | - |
| Update vaccination record details (blocked if ARCHIVED) | `PUT` | `/api/v1/immunisation/records/:id` | bearer | none | - |
| Administer a dose (captures batch, lot, site, administrator) | `POST` | `/api/v1/immunisation/records/:id/administer` | bearer | raw | - |
| Mark vaccination record / series as completed | `POST` | `/api/v1/immunisation/records/:id/complete` | bearer | raw | - |
| Defer a dose with clinical reason and rescheduled date | `POST` | `/api/v1/immunisation/records/:id/defer` | bearer | raw | - |
| Archive a vaccination record | `POST` | `/api/v1/immunisation/records/:id/archive` | bearer | raw | - |
| Restore an archived vaccination record | `POST` | `/api/v1/immunisation/records/:id/restore` | bearer | raw | - |
| Generate digital vaccine certificate with QR token & PDF link | `POST` | `/api/v1/immunisation/certificates` | bearer | raw | - |
| List all digital vaccine certificates for current patient | `GET` | `/api/v1/immunisation/certificates` | bearer | none | - |
| Configure vaccination reminder metadata & preferences | `POST` | `/api/v1/immunisation/reminders/config` | bearer | raw | - |

### 25. Support Tickets & Helpdesk (6 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Create support ticket | `POST` | `/api/v1/support/tickets` | bearer | raw | - |
| List support tickets (filtered by user ownership or admin/staff access) | `GET` | `/api/v1/support/tickets` | bearer | none | status, priority, category, search, page, limit |
| Get support ticket details by ID | `GET` | `/api/v1/support/tickets/:id` | bearer | none | - |
| Update support ticket status, priority or assignment (Admin/Staff) | `PUT` | `/api/v1/support/tickets/:id` | bearer | raw | - |
| Add message reply to support ticket | `POST` | `/api/v1/support/tickets/:id/reply` | bearer | raw | - |
| Get all replies for support ticket | `GET` | `/api/v1/support/tickets/:id/replies` | bearer | none | - |

### 26. Pet Health Records (7 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| Register a new pet profile | `POST` | `/api/v1/pets` | bearer | raw | - |
| List pets (filtered by user ownership or admin/staff access) | `GET` | `/api/v1/pets` | bearer | none | species, search, page, limit |
| Get pet profile by ID | `GET` | `/api/v1/pets/:id` | bearer | none | - |
| Update pet profile | `PUT` | `/api/v1/pets/:id` | bearer | raw | - |
| Delete pet profile | `DELETE` | `/api/v1/pets/:id` | bearer | none | - |
| Add vaccination record to pet | `POST` | `/api/v1/pets/:id/vaccinations` | bearer | raw | - |
| Get all vaccination records for pet | `GET` | `/api/v1/pets/:id/vaccinations` | bearer | none | - |

### 27. Healthcare Financing & Financial Assistance (6 Requests)

| Request Name | Method | Endpoint Path | Auth | Body Mode | Query / Params |
|---|:---:|---|:---:|:---:|---|
| List available healthcare financing options and partners | `GET` | `/api/v1/financing/options` | bearer | none | - |
| List pre-approved healthcare financing offers for current patient | `GET` | `/api/v1/financing/offers` | bearer | none | - |
| Submit application for healthcare financing / EMI assistance | `POST` | `/api/v1/financing/apply` | bearer | raw | - |
| List financing applications (scoped to patient or global for admin/staff) | `GET` | `/api/v1/financing/applications` | bearer | none | status, partnerName, search, page, limit |
| Get financing application details by ID | `GET` | `/api/v1/financing/applications/:id` | bearer | none | - |
| Update financing application review status (Admin/Staff) | `PATCH` | `/api/v1/financing/applications/:id/status` | bearer | raw | - |
