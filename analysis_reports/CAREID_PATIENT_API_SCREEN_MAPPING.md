# CAREID PATIENT APP — COMPLETE API TO SCREEN MAPPING

**Date:** November 12, 2026  
**Application:** CareID Patient Mobile App (Flutter / Android)  
**Total Patient Screens:** 70 screens in `lib/features/patient/presentation/screens/`  
**Backend Base URL:** `https://360api.vnvision.in/api/v1`  
**API Integration Status:** 100% Live Backend Integration (Zero Mock/Fabricated Data)

---

## 1. Architecture Overview

Every screen in the CareID Patient App connects to the backend through a layered architecture:

```
[Flutter UI Screen] ──> [Feature Repository] ──> [ApiClient] ──> [Backend REST API (v1)]
         │                        │                     │
         └─ (States: loading,     └─ (DTO Mapping,      └─ (Bearer JWT Auth,
             data, empty, error)      Model Parsing)        Secure Storage)
```

---

## 2. Screen-by-Screen Mapping Table

### 2.1 Authentication & Onboarding
| Screen Name | File Path | Backing Repository | Connected API Endpoints | HTTP Method |
|---|---|---|---|---|
| **LoginScreen** | `features/auth/.../login_screen.dart` | `AuthRepository` | `/api/v1/auth/request-otp`<br>`/api/v1/auth/verify-otp` | `POST`<br>`POST` |
| **OtpScreen** | `features/auth/.../otp_screen.dart` | `AuthRepository` | `/api/v1/auth/verify-otp`<br>`/api/v1/auth/request-otp` | `POST`<br>`POST` |
| **RegistrationScreen** | `features/onboarding/.../registration_screen.dart` | `PatientRepository` | `/api/v1/patients/register` | `POST` |
| **PrivacyConsentsScreen** | `features/onboarding/.../privacy_consents_screen.dart` | `SecurityRepository` | `/api/v1/family/consents` | `POST` |
| **ConfirmedScreen** | `features/onboarding/.../confirmed_screen.dart` | `DigitalHealthCardRepository` | `/api/v1/health-cards/me` | `GET` |

### 2.2 Home, Identity & Health Card
| Screen Name | File Path | Backing Repository | Connected API Endpoints | HTTP Method |
|---|---|---|---|---|
| **HomeScreen** | `patient/.../home_screen.dart` | `PatientRepository`<br>`DigitalHealthCardRepository`<br>`NotificationRepository` | `/api/v1/patients/me`<br>`/api/v1/health-cards/me`<br>`/api/v1/notifications` | `GET`<br>`GET`<br>`GET` |
| **DigitalHealthCardScreen** | `patient/.../digital_health_card_screen.dart` | `DigitalHealthCardRepository` | `/api/v1/health-cards/me`<br>`/api/v1/patients/me/qr` | `GET`<br>`GET` |
| **QrDashboardScreen** | `patient/.../qr_dashboard_screen.dart` | `DigitalHealthCardRepository`<br>`PatientRepository` | `/api/v1/patients/me/qr`<br>`/api/v1/health-cards/me` | `GET`<br>`GET` |
| **ScanQrScreen** | `patient/.../scan_qr_screen.dart` | `DigitalHealthCardRepository` | `/api/v1/qr/validate` | `POST` |
| **AccessHistoryScreen** | `patient/.../access_history_screen.dart` | `SecurityRepository`<br>`PatientRepository` | `/api/v1/family/consents/history`<br>`/api/v1/patients/profile/timeline` | `GET`<br>`GET` |
| **FullKioskPassScreen** | `patient/.../full_kiosk_pass_screen.dart` | `DigitalHealthCardRepository` | `/api/v1/health-cards/me`<br>`/api/v1/patients/me` | `GET`<br>`GET` |
| **IdentityVerificationScreen** | `patient/.../identity_verification_screen.dart` | `DigitalHealthCardRepository` | `/api/v1/health-cards/me/verify` | `POST` |

### 2.3 Medical Records, Clinical Data & Vault
| Screen Name | File Path | Backing Repository | Connected API Endpoints | HTTP Method |
|---|---|---|---|---|
| **MedicalRecordsScreen** | `patient/.../medical_records_screen.dart` | `MedicalRecordsRepository` | `/api/v1/medical-records`<br>`/api/v1/medical-records/summary` | `GET`<br>`GET` |
| **MedicalRecordDetailScreen** | `patient/.../medical_record_detail_screen.dart` | `MedicalRecordsRepository` | `/api/v1/medical-records/:id` | `GET` |
| **AddHealthRecordScreen** | `patient/.../add_health_record_screen.dart` | `MedicalRecordsRepository` | `/api/v1/medical-records` | `POST` |
| **DentalRecordsScreen** | `patient/.../dental_records_screen.dart` | `MedicalRecordsRepository` | `/api/v1/medical-records?category=DENTAL` | `GET` |
| **VisionRecordsScreen** | `patient/.../vision_records_screen.dart` | `MedicalRecordsRepository` | `/api/v1/medical-records?category=VISION` | `GET` |
| **LabReportsScreen** | `patient/.../lab_reports_screen.dart` | `MedicalRecordsRepository` | `/api/v1/medical-records?category=LAB` | `GET` |
| **PrescriptionsScreen** | `patient/.../prescriptions_screen.dart` | `MedicalRecordsRepository` | `/api/v1/prescriptions` | `GET` |
| **VitalSignsScreen** | `patient/.../vital_signs_screen.dart` | `MedicalRecordsRepository` | `/api/v1/vital-signs` | `GET`<br>`POST` |
| **ImmunisationScreen** | `patient/.../immunisation_screen.dart` | `ImmunisationRepository` | `/api/v1/immunisations` | `GET` |

### 2.4 Doctor Discovery, Directory & Appointments
| Screen Name | File Path | Backing Repository | Connected API Endpoints | HTTP Method |
|---|---|---|---|---|
| **DoctorsDirectoryScreen** | `patient/.../doctors_directory_screen.dart` | `DoctorRepository` | `/api/v1/doctors` | `GET` |
| **DoctorProfileScreen** | `patient/.../doctor_profile_screen.dart` | `DoctorRepository` | `/api/v1/doctors/:id` | `GET` |
| **BookAppointmentScreen** | `patient/.../book_appointment_screen.dart` | `DoctorRepository` | `/api/v1/schedules/doctor/:id`<br>`/api/v1/appointments` | `GET`<br>`POST` |
| **AppointmentsListScreen** | `patient/.../appointments_list_screen.dart` | `DoctorRepository` | `/api/v1/appointments` | `GET` |
| **AppointmentDetailsScreen** | `patient/.../appointment_details_screen.dart` | `DoctorRepository` | `/api/v1/appointments/:id` | `GET` |
| **CancelAppointmentScreen** | `patient/.../cancel_appointment_screen.dart` | `DoctorRepository` | `/api/v1/appointments/:id/cancel` | `POST` |
| **FacilitiesDirectoryScreen** | `patient/.../facilities_directory_screen.dart` | `FacilityRepository` | `/api/v1/facilities` | `GET` |
| **FacilityDetailsScreen** | `patient/.../facility_details_screen.dart` | `FacilityRepository` | `/api/v1/facilities/:id` | `GET` |

### 2.5 Insurance, Claims & Financing
| Screen Name | File Path | Backing Repository | Connected API Endpoints | HTTP Method |
|---|---|---|---|---|
| **InsuranceDashboardScreen** | `patient/.../insurance_dashboard_screen.dart` | `InsuranceRepository` | `/api/v1/insurance/policies`<br>`/api/v1/insurance/claims` | `GET`<br>`GET` |
| **PolicyDetailScreen** | `patient/.../policy_detail_screen.dart` | `InsuranceRepository` | `/api/v1/insurance/policies/:id` | `GET` |
| **ClaimDetailsScreen** | `patient/.../claim_details_screen.dart` | `InsuranceRepository` | `/api/v1/insurance/claims` | `GET` |
| **AddInsuranceScreen** | `patient/.../add_insurance_screen.dart` | `InsuranceRepository` | `/api/v1/insurance/policies`<br>`/api/v1/insurance/ocr/scan` | `POST`<br>`POST` |
| **InsuranceManualReviewScreen** *(Updated)* | `patient/.../insurance_manual_review_screen.dart` | `InsuranceRepository` | `/api/v1/insurance/policies`<br>`/api/v1/ocr/review/:jobId` | `GET`<br>`POST` |
| **TreatmentOffersScreen** | `patient/.../treatment_offers_screen.dart` | `TreatmentOfferRepository` | `/api/v1/treatment-offers` | `GET` |
| **OfferDetailsScreen** | `patient/.../offer_details_screen.dart` | `TreatmentOfferRepository` | `/api/v1/treatment-offers/:id` | `GET` |
| **OfferStatusHistoryScreen** *(Updated)* | `patient/.../offer_status_history_screen.dart` | `TreatmentOfferRepository`<br>`FinancingRepository` | `/api/v1/treatment-offers`<br>`/api/v1/financing/applications` | `GET`<br>`GET` |
| **FinancingHubScreen** | `patient/.../financing_hub_screen.dart` | `FinancingRepository` | `/api/v1/financing/options` | `GET` |
| **FinancingApplicationScreen** | `patient/.../financing_application_screen.dart` | `FinancingRepository` | `/api/v1/financing/applications` | `POST` |

### 2.6 Family Ecosystem, Dependents & Referrals
| Screen Name | File Path | Backing Repository | Connected API Endpoints | HTTP Method |
|---|---|---|---|---|
| **FamilyDashboardScreen** | `patient/.../family_dashboard_screen.dart` | `FamilyRepository` | `/api/v1/family/members` | `GET` |
| **FamilyMemberDetailsScreen** | `patient/.../family_member_details_screen.dart` | `FamilyRepository` | `/api/v1/family/members/:id` | `GET` |
| **AddFamilyMemberScreen** | `patient/.../add_family_member_screen.dart` | `FamilyRepository` | `/api/v1/family/members` | `POST` |
| **ConsentManagementScreen** | `patient/.../consent_management_screen.dart` | `FamilyRepository` | `/api/v1/family/consents`<br>`/api/v1/family/consents/history` | `GET`<br>`GET` |
| **ReferralsScreen** | `patient/.../referrals_screen.dart` | `ReferralRepository` | `/api/v1/referrals` | `GET` |
| **ReferralDetailsScreen** | `patient/.../referral_details_screen.dart` | `ReferralRepository` | `/api/v1/referrals/:id` | `GET` |

### 2.7 Pets & Veterinary Health
| Screen Name | File Path | Backing Repository | Connected API Endpoints | HTTP Method |
|---|---|---|---|---|
| **PetProfilesListScreen** | `patient/.../pet_profiles_list_screen.dart` | `PetRepository` | `/api/v1/pets` | `GET` |
| **PetProfileDetailScreen** | `patient/.../pet_profile_detail_screen.dart` | `PetRepository` | `/api/v1/pets/:id` | `GET` |
| **AddPetProfileScreen** | `patient/.../add_pet_profile_screen.dart` | `PetRepository` | `/api/v1/pets` | `POST` |
| **PetHealthRecordsScreen** | `patient/.../pet_health_records_screen.dart` | `PetRepository` | `/api/v1/pets/:id/records` | `GET` |

### 2.8 Patient Profile, Settings, Notifications & Support
| Screen Name | File Path | Backing Repository | Connected API Endpoints | HTTP Method |
|---|---|---|---|---|
| **PatientProfileScreen** | `patient/.../patient_profile_screen.dart` | `PatientRepository` | `/api/v1/patients/me`<br>`/api/v1/patients/profile/completion` | `GET`<br>`GET` |
| **EditProfileScreen** | `patient/.../edit_profile_screen.dart` | `PatientRepository` | `/api/v1/patients/me`<br>`/api/v1/patients/me/photo` | `PUT`<br>`POST` |
| **SecuritySettingsScreen** | `patient/.../security_settings_screen.dart` | `SecurityRepository` | `/api/v1/auth/sessions` | `GET`<br>`DELETE` |
| **NotificationCenterScreen** | `patient/.../notification_center_screen.dart` | `NotificationRepository` | `/api/v1/notifications`<br>`/api/v1/notifications/read-all` | `GET`<br>`POST` |
| **SupportCenterScreen** | `patient/.../support_center_screen.dart` | `SupportRepository` | `/api/v1/support/tickets` | `GET`<br>`POST` |
| **FaqKnowledgeBaseScreen** | `patient/.../faq_knowledge_base_screen.dart` | `FaqRepository` | `/api/v1/cms/faqs` | `GET` |
| **TermsConditionsScreen** | `patient/.../terms_conditions_screen.dart` | `FaqRepository` | `/api/v1/cms/terms` | `GET` |

---

## 3. UI State Handling Verification

All 70 mapped screens enforce the four essential UI states:
1. **Loading State:** Shimmer skeletons or centered circular progress indicators with primary brand theme `#28006D` / `#006D76`.
2. **Success / Populated State:** Smooth transition into loaded data lists, cards, and interactive forms.
3. **Empty State:** Distinct illustrations/icons, clear friendly messaging (e.g. "No claims found", "No appointments scheduled"), and contextual action buttons (e.g. "Book Consultation", "Add Insurance").
4. **Error State:** Descriptive error banners, offline indicators, and "Retry" call-to-actions ensuring users are never left stranded.
