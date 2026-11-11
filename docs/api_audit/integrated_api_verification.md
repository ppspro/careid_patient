# Integrated API Verification & Contract Audit

**Project:** `C:\Users\PABANI\CareID_patient_app`  
**Backend Base URL:** `https://360api.vnvision.in`  
**Postman Collection:** `CareID-Staging.postman_collection.json`  
**Date:** October 31, 2026  

---

## 1. Executive Summary

This document performs an exhaustive contract audit of all integrated Patient App API endpoints across Flutter repositories, validating:
1. Exact HTTP method alignment.
2. Endpoint path structure and parameter substitution.
3. Authentication token headers (`Authorization: Bearer <accessToken>`).
4. Request body JSON payload schemas.
5. Response models and DTO deserialization.
6. Verification status (automated test proof, live integration test against Staging, or contract-verified).

---

## 2. Integrated API Verification Matrix

| Module | HTTP Method | Endpoint Path | Flutter Repository Method | Response DTO Model | Auth Type | Verification Status | Notes / Edge Cases |
|---|:---:|---|---|---|:---:|:---:|---|
| **Health Check** | `GET` | `/api/v1/health` | `ApiClient.healthCheck()` | `Map<String, dynamic>` | Public | **VERIFIED (Live)** | Verified in `api_health_integration_test.dart` (Live HTTP 200) |
| **Authentication** | `POST` | `/api/v1/auth/otp/request` | `AuthRepository.requestOtp()` | `RequestOtpResponseDto` | Public | **VERIFIED (Live)** | Verified with live phone `+16505550004` (OTP issued) |
| **Authentication** | `POST` | `/api/v1/auth/otp/verify` | `AuthRepository.verifyOtp()` | `VerifyOtpResponseDto` | Public | **VERIFIED (Live)** | Issues JWT `accessToken` & `refreshToken` stored in `TokenStorage` |
| **Authentication** | `POST` | `/api/v1/auth/otp/resend` | `AuthRepository.resendOtp()` | `ResendOtpResponseDto` | Public | **VERIFIED (Unit)** | Cooldown timer respected |
| **Authentication** | `POST` | `/api/v1/auth/token/refresh` | `ApiClient._refreshToken()` | `VerifyOtpResponseDto` | Bearer (Refresh) | **VERIFIED (Unit)** | Interceptor transparently retries 401s |
| **Authentication** | `GET` | `/api/v1/auth/me` | `AuthRepository.getAuthMe()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Validates active session token identity |
| **Authentication** | `POST` | `/api/v1/auth/logout` | `AuthRepository.logout()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Clears secure tokens on server & device |
| **Authentication** | `POST` | `/api/v1/auth/logout-all` | `AuthRepository.logoutAll()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Revokes all active sessions |
| **Authentication** | `GET` | `/api/v1/auth/sessions` | `AuthRepository.getSessions()` | `List<SessionModel>` | Bearer | **VERIFIED (Unit)** | Lists active browser/device tokens with IP/location |
| **Onboarding** | `POST` | `/api/v1/patients/register` | `RegistrationRepository.registerDraft()` | `PatientRegistrationDraft` | Public | **VERIFIED (Live)** | Draft registration validated |
| **Onboarding** | `GET` | `/api/v1/patients/onboarding/progress` | `OnboardingRepository.getProgress()` | `OnboardingProgressDto` | Bearer | **VERIFIED (Unit)** | Tracks 6-step registration state |
| **Onboarding** | `POST` | `/api/v1/patients/onboarding/demographics` | `OnboardingRepository.saveDemographics()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Saves blood group, dob, gender, allergies |
| **Onboarding** | `POST` | `/api/v1/patients/onboarding/emergency-contact`| `OnboardingRepository.saveEmergencyContact()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Sets primary ICE contact name and phone |
| **Onboarding** | `POST` | `/api/v1/patients/onboarding/insurance` | `OnboardingRepository.saveInsurance()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Links initial policy number and provider |
| **Onboarding** | `POST` | `/api/v1/patients/onboarding/complete` | `OnboardingRepository.completeOnboarding()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Finalizes onboarding workflow |
| **Patient Profile** | `GET` | `/api/v1/patients/me` | `PatientRepository.getPatientProfile()` | `PatientProfileDto` | Bearer | **VERIFIED (Live)** | Live endpoint returns John Doe |
| **Patient Profile** | `GET` | `/api/v1/patients/me/full` | `PatientRepository.getFullProfile()` | `PatientProfileDto` | Bearer | **VERIFIED (Live)** | Returns nested address, ICE contacts, medical baseline |
| **Patient Profile** | `GET` | `/api/v1/patients/profile/completion` | `PatientRepository.getProfileCompletion()` | `ProfileCompletionDto` | Bearer | **VERIFIED (Live)** | Renders Bento health score percentage |
| **Patient Profile** | `PATCH` | `/api/v1/patients/me/basic` | `PatientRepository.updateBasicDetails()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Updates first/last name, phone, dob |
| **Patient Profile** | `PATCH` | `/api/v1/patients/me/medical-summary` | `PatientRepository.updateMedicalSummary()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Updates allergies, conditions, blood group |
| **Patient Profile** | `PATCH` | `/api/v1/patients/me/address` | `PatientRepository.updateAddress()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Updates street, city, state, zip code |
| **Digital Health Cards**| `GET` | `/api/v1/health-cards` | `DigitalHealthCardRepository.getCard()` | `HealthCardDto` | Bearer | **VERIFIED (Live)** | Retrieves verifiable digital pass & token |
| **Digital Health Cards**| `POST` | `/api/v1/health-cards` | `DigitalHealthCardRepository.createCard()` | `HealthCardDto` | Bearer | **VERIFIED (Unit)** | Generates new Apple Wallet pass |
| **Digital Health Cards**| `POST` | `/api/v1/health-cards/verify-qr` | `DigitalHealthCardRepository.verifyQr()` | `VerifyQrResponseDto` | Bearer | **VERIFIED (Live)** | Cryptographic verification of scanned QR payload |
| **Digital Health Cards**| `GET` | `/api/v1/health-cards/{id}/history` | `DigitalHealthCardRepository.getCardHistory()` | `List<HealthCardHistoryItemDto>` | Bearer | **VERIFIED (Live)** | Audit trail of clinical vault access |
| **Digital Health Cards**| `POST` | `/api/v1/health-cards/{id}/activate` | `DigitalHealthCardRepository.activateCard()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Unfreezes suspended pass |
| **Digital Health Cards**| `POST` | `/api/v1/health-cards/{id}/deactivate` | `DigitalHealthCardRepository.deactivateCard()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Temporarily freezes compromised pass |
| **Medical Records** | `GET` | `/api/v1/medical-records` | `MedicalRecordsRepository.getMedicalRecords()` | `List<MedicalRecordDto>` | Bearer | **VERIFIED (Live)** | Categorized clinical records (General, Dental, Vision) |
| **Medical Records** | `POST` | `/api/v1/medical-records` | `MedicalRecordsRepository.createRecord()` | `MedicalRecordDto` | Bearer | **VERIFIED (Unit)** | Self-reported vitals and symptoms upload |
| **Medical Records** | `GET` | `/api/v1/medical-records/timeline` | `MedicalRecordsRepository.getTimeline()` | `List<MedicalTimelineItemDto>` | Bearer | **VERIFIED (Live)** | Chronological history view |
| **Medical Records** | `GET` | `/api/v1/medical-records/search` | `MedicalRecordsRepository.searchRecords()` | `List<MedicalRecordDto>` | Bearer | **VERIFIED (Unit)** | Full-text keyword search across records |
| **Medical Records** | `GET` | `/api/v1/medical-records/{id}` | `MedicalRecordsRepository.getRecordDetail()` | `MedicalRecordDto` | Bearer | **VERIFIED (Unit)** | Detailed clinical diagnostic report |
| **Insurance & Claims** | `GET` | `/api/v1/insurance/policies` | `InsuranceRepository.getPolicies()` | `List<InsurancePolicyDto>` | Bearer | **VERIFIED (Live)** | Active policies and coverage tiers |
| **Insurance & Claims** | `POST` | `/api/v1/insurance/policies` | `InsuranceRepository.addPolicy()` | `InsurancePolicyDto` | Bearer | **VERIFIED (Unit)** | Manual policy entry |
| **Insurance & Claims** | `GET` | `/api/v1/insurance/policies/{id}` | `InsuranceRepository.getPolicyDetail()` | `InsurancePolicyDto` | Bearer | **VERIFIED (Unit)** | In-network copays and deductibles |
| **Insurance & Claims** | `POST` | `/api/v1/insurance/policies/{id}/verify` | `InsuranceRepository.verifyPolicy()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Real-time payer eligibility ping |
| **Insurance & Claims** | `GET` | `/api/v1/insurance/claims` | `InsuranceRepository.getClaims()` | `List<InsuranceClaimDto>` | Bearer | **VERIFIED (Live)** | Adjudication timeline and explanation of benefits |
| **Insurance & OCR** | `POST` | `/api/v1/insurance/ocr/scan` | `InsuranceRepository.scanCardOcr()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Uploads card image to AI OCR processor |
| **Insurance & OCR** | `POST` | `/api/v1/insurance/ocr/confirm` | `InsuranceRepository.confirmOcrPolicy()` | `InsurancePolicyDto` | Bearer | **VERIFIED (Unit)** | Confirms extracted policy fields into vault |
| **Family Management** | `GET` | `/api/v1/family/invitations` | `FamilyRepository.getInvitations()` | `List<FamilyInvitationDto>` | Bearer | **VERIFIED (Live)** | Pending family circle invites |
| **Family Management** | `POST` | `/api/v1/family/invitations` | `FamilyRepository.sendInvitation()` | `FamilyInvitationDto` | Bearer | **VERIFIED (Live)** | Invites spouse/dependent/guardian |
| **Family Management** | `GET` | `/api/v1/family/members` | `FamilyRepository.getMembers()` | `List<FamilyMemberDto>` | Bearer | **VERIFIED (Live)** | Active family ecosystem circle |
| **Family Management** | `GET` | `/api/v1/family/consents` | `FamilyRepository.getConsents()` | `List<SharedAccessGrantDto>` | Bearer | **VERIFIED (Live)** | Third-party clinic/doctor consent grants |
| **Family Management** | `PATCH` | `/api/v1/family/consents/{id}` | `FamilyRepository.updateConsentStatus()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Approves or revokes clinic sharing grant |
| **Doctors & Clinicians**| `GET` | `/api/v1/doctors` | `DoctorRepository.getDoctors()` | `List<DoctorModel>` | Bearer | **VERIFIED (Live)** | Clinicians directory across specialties |
| **Doctors & Clinicians**| `GET` | `/api/v1/doctors/search` | `DoctorRepository.searchDoctors()` | `List<DoctorModel>` | Bearer | **VERIFIED (Unit)** | Filter by clinic name, doctor, or specialty |
| **Doctors & Clinicians**| `GET` | `/api/v1/doctors/{id}` | `DoctorRepository.getDoctorById()` | `DoctorModel` | Bearer | **VERIFIED (Unit)** | Complete credentials and hospital affiliations |
| **Doctors & Clinicians**| `GET` | `/api/v1/doctors/{id}/slots` | `DoctorRepository.getDoctorSlots()` | `List<DoctorScheduleSlotModel>`| Bearer | **VERIFIED (Live)** | Real-time open appointment calendar slots |
| **Appointments** | `GET` | `/api/v1/schedules` | `DoctorRepository.getMyAppointments()` | `List<AppointmentModel>` | Bearer | **VERIFIED (Live)** | Upcoming, Completed, and Cancelled visits |
| **Appointments** | `POST` | `/api/v1/schedules` | `DoctorRepository.bookAppointment()` | `AppointmentModel` | Bearer | **VERIFIED (Live)** | Books confirmed consultation with digital pass |
| **Notifications** | `GET` | `/api/v1/notifications` | `NotificationRepository.getNotifications()` | `List<NotificationModel>` | Bearer | **VERIFIED (Live)** | Emergency, Medication, and Security alerts |
| **Notifications** | `PUT` | `/api/v1/notifications/{id}/read`| `NotificationRepository.markAsRead()` | `Map<String, dynamic>` | Bearer | **VERIFIED (Unit)** | Updates single notification read state |
| **Notifications** | `GET` | `/api/v1/notifications/preferences`| `NotificationRepository.getPreferences()` | `NotificationPreferencesDto` | Bearer | **VERIFIED (Unit)** | SMS, Email, and Push notification toggles |

---

## 3. Discovered Integration Gaps & Edge Cases

1. **Missing Individual GET for Appointments (`/api/v1/schedules/{id}`):**
   - Flutter's `AppointmentDetailsScreen` receives an `AppointmentModel` from navigation arguments. If a patient deep-links to an appointment or refreshes the view, the screen cannot re-fetch a single schedule item independently.
2. **Quota-Based Cancellation Notification:**
   - In Figma `20:30384` ("Cancel Appointment Dialog"), the UI displays *"You have 2 free cancellations remaining this month"*. Postman currently provides generic schedule deletion without returning cancellation quota metadata.
3. **Emergency SOS Trigger Endpoint:**
   - In Figma `20:23956` ("Emergency Center"), pressing the SOS hero button initiates local timer countdowns, but the backend lacks a dedicated `POST /api/v1/emergency/sos` endpoint to alert registered ICE guardians via automated SMS/Push.

