/// CareID Backend API Endpoints
/// Grounded strictly in the OpenAPI 3.0.0 specification from https://360api.vnvision.in/docs.
class ApiEndpoints {
  ApiEndpoints._();

  // Health Check
  static const String health = '/api/v1/health';

  // Authentication & Session
  static const String otpRequest = '/api/v1/auth/otp/request';
  static const String otpVerify = '/api/v1/auth/otp/verify';
  static const String otpResend = '/api/v1/auth/otp/resend';
  static const String tokenRefresh = '/api/v1/auth/token/refresh';
  static const String authMe = '/api/v1/auth/me';
  static const String logout = '/api/v1/auth/logout';
  static const String logoutAll = '/api/v1/auth/logout-all';
  static const String sessions = '/api/v1/auth/sessions';

  // Patient Registration & Onboarding Lifecycle
  static const String patientRegisterDraft = '/api/v1/patients/register';
  static const String patientRegisterStatus =
      '/api/v1/patients/register/status';
  static const String patientRegisterResume =
      '/api/v1/patients/register/resume';

  // Step-by-Step Onboarding
  static const String onboardingProgress =
      '/api/v1/patients/onboarding/progress';
  static const String onboardingDemographics =
      '/api/v1/patients/onboarding/demographics';
  static const String onboardingEmergencyContact =
      '/api/v1/patients/onboarding/emergency-contact';
  static const String onboardingInsurance =
      '/api/v1/patients/onboarding/insurance';
  static const String onboardingHealthCard =
      '/api/v1/patients/onboarding/health-card';
  static const String onboardingFamilyInvite =
      '/api/v1/patients/onboarding/family-invite';
  static const String onboardingComplete =
      '/api/v1/patients/onboarding/complete';

  // Patient Profile
  static const String patientProfileMe = '/api/v1/patients/me';
  static const String patientProfileFull = '/api/v1/patients/me/full';
  static const String patientMedicalSummary =
      '/api/v1/patients/me/medical-summary';
  static const String patientAddress = '/api/v1/patients/me/address';
  static const String patientBasic = '/api/v1/patients/me/basic';
  static const String patientContact = '/api/v1/patients/me/contact';
  static const String patientPreferences = '/api/v1/patients/me/preferences';
  static const String patientProfileCompletion =
      '/api/v1/patients/profile/completion';
  static const String patientProfileTimeline =
      '/api/v1/patients/profile/timeline';
  static const String patientProfileActivity =
      '/api/v1/patients/profile/activity';
  static const String patientEmergencyProfile =
      '/api/v1/patients/profile/emergency';
  static const String patientHealthCards = '/api/v1/patients/me/health-cards';
  static const String healthCards = '/api/v1/health-cards';
  static const String healthCardsVerifyQr = '/api/v1/health-cards/verify-qr';

  // Medical Records (General, Dental & Vision)
  static const String medicalRecords = '/api/v1/medical-records';
  static const String medicalRecordsTimeline =
      '/api/v1/medical-records/timeline';
  static const String medicalRecordsSearch = '/api/v1/medical-records/search';

  // Insurance & OCR
  static const String insuranceOnboard = '/api/v1/insurance/onboard';
  static const String insurancePolicies = '/api/v1/insurance/policies';
  static const String insuranceProviders = '/api/v1/insurance/providers';
  static const String insurancePlans = '/api/v1/insurance/plans';
  static const String insuranceStatistics = '/api/v1/insurance/statistics';
  static const String insuranceClaims = '/api/v1/insurance/claims';
  static const String insuranceOcrScan = '/api/v1/insurance/ocr/scan';
  static const String insuranceOcrConfirm = '/api/v1/insurance/ocr/confirm';

  // Family Members & Relationships
  static const String familyInvitations = '/api/v1/family/invitations';
  static const String familyMembers = '/api/v1/family/members';
  static const String familyConsents = '/api/v1/family/consents';
  static const String familyGuardians = '/api/v1/family/guardians';
  static const String familyDependents = '/api/v1/family/dependents';

  // Doctors & Providers
  static const String doctors = '/api/v1/doctors';
  static const String doctorsSearch = '/api/v1/doctors/search';
  static String doctorSlots(String id) => '/api/v1/doctors/$id/slots';

  // Schedules & Appointments
  static const String schedules = '/api/v1/schedules';
  static const String schedulesSearch = '/api/v1/schedules/search';

  // Appointments (Folder 10)
  static const String appointments = '/api/v1/appointments';
  static const String patientMyAppointments =
      '/api/v1/appointments/patient/my-appointments';
  static const String patientAppointmentsMe =
      '/api/v1/appointments/patient/me';
  static String appointmentById(String id) => '/api/v1/appointments/$id';
  static String appointmentCancel(String id) =>
      '/api/v1/appointments/$id/cancel';
  static String appointmentReschedule(String id) =>
      '/api/v1/appointments/$id/reschedule';
  static String appointmentStatus(String id) =>
      '/api/v1/appointments/$id/status';

  // Medical Document OCR & Processing (Folder 15)
  static const String aiOcrExtract = '/api/v1/ai/ocr/extract';
  static const String aiOcrConfirm = '/api/v1/ai/ocr/confirm';
  static const String ocrJobs = '/api/v1/ocr/jobs';
  static String ocrJobById(String id) => '/api/v1/ocr/jobs/$id';
  static String ocrJobFields(String id) => '/api/v1/ocr/jobs/$id/fields';

  // File Attachments (Folder 16 & Folder 08)
  static const String attachments = '/api/v1/attachments';
  static String attachmentById(String id) => '/api/v1/attachments/$id';
  static String recordAttachments(String recordId) =>
      '/api/v1/medical-records/$recordId/attachments';

  // Enterprise QR Subsystem (Folder 22)
  static const String qrTokens = '/api/v1/qr';
  static const String qrGenerate = '/api/v1/qr/generate';
  static const String qrVerify = '/api/v1/qr/verify';
  static const String qrSearch = '/api/v1/qr/search';
  static const String qrStatistics = '/api/v1/qr/statistics';
  static String qrById(String id) => '/api/v1/qr/$id';
  static String qrScans(String qrId) => '/api/v1/qr/$qrId/scans';
  static String qrHistory(String qrId) => '/api/v1/qr/$qrId/history';

  // Sessions & Security
  static String sessionById(String id) => '/api/v1/auth/sessions/$id';
  static const String consentHistory = '/api/v1/family/consents/history';
  static String healthCardBlock(String id) => '/api/v1/health-cards/$id/block';

  // Facilities & Branches
  static const String facilities = '/api/v1/facilities';
  static const String facilitiesSearch = '/api/v1/facilities/search';
  static String facilityById(String id) => '/api/v1/facilities/$id';

  // Immunisation & Vaccines
  static const String vaccines = '/api/v1/immunisation/vaccines';
  static const String immunisationRecords = '/api/v1/immunisation/records';
  static const String immunisationSchedules = '/api/v1/immunisation/schedules';
  static const String immunisationCertificates = '/api/v1/immunisation/certificates';

  // Profile Photo
  static const String patientPhoto = '/api/v1/patients/me/photo';

  // CMS Content & FAQs
  static const String cmsFaqs = '/api/v1/cms/faqs';
  static const String cmsAnnouncements = '/api/v1/cms/announcements';
  static const String cmsPolicies = '/api/v1/cms/policies';
  static const String cmsBanners = '/api/v1/cms/banners';
  static const String cmsPages = '/api/v1/cms/pages';

  // Notifications
  static const String notifications = '/api/v1/notifications';
  static const String notificationPreferences = '/api/v1/notifications/preferences';
  static String notificationMarkRead(String id) => '/api/v1/notifications/$id/read';

  // Pet Health Records (Folder 26)
  static const String pets = '/api/v1/pets';
  static String petById(String id) => '/api/v1/pets/$id';
  static String petVaccinations(String petId) => '/api/v1/pets/$petId/vaccinations';

  // Treatment Offers Subsystem (Section 45)
  static const String patientTreatmentOffers = '/api/v1/patients/treatment-offers';
  static String patientTreatmentOfferById(String id) => '/api/v1/patients/treatment-offers/$id';
  static String patientTreatmentOfferAccept(String id) => '/api/v1/patients/treatment-offers/$id/accept';
  static String patientTreatmentOfferReject(String id) => '/api/v1/patients/treatment-offers/$id/reject';

  // Healthcare Financing & Financial Assistance (Folder 27)
  static const String financingOptions = '/api/v1/financing/options';
  static const String financingOffers = '/api/v1/financing/offers';
  static String financingOfferById(String id) => '/api/v1/financing/offers/$id';
  static String financingOfferAccept(String id) => '/api/v1/financing/offers/$id/accept';
  static String financingOfferReject(String id) => '/api/v1/financing/offers/$id/reject';
  static const String financingApply = '/api/v1/financing/apply';
  static const String financingApplications = '/api/v1/financing/applications';
  static String financingApplicationById(String id) => '/api/v1/financing/applications/$id';

  // Referrals & Care Coordination (Folder 11)
  static const String referrals = '/api/v1/referrals';
  static String referralById(String id) => '/api/v1/referrals/$id';

  // Support Tickets & Helpdesk (Folder 25)
  static const String supportTickets = '/api/v1/support/tickets';
  static String supportTicketById(String id) => '/api/v1/support/tickets/$id';
  static String supportTicketReplies(String id) => '/api/v1/support/tickets/$id/replies';
  static String supportTicketReply(String id) => '/api/v1/support/tickets/$id/reply';

  // Insurance Cards & OCR (Folder 15 & 19)
  static const String insuranceOcr = '/api/v1/insurance/ocr';
  static String insuranceOcrById(String id) => '/api/v1/insurance/ocr/$id';
  static const String ocrReviews = '/api/v1/ocr/review';
  static String ocrReviewById(String jobId) => '/api/v1/ocr/review/$jobId';
  static String patientInsuranceCards(String patientId) => '/api/v1/patients/$patientId/insurance-cards';
  static String insuranceCardById(String id) => '/api/v1/insurance-cards/$id';
}
