import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:careid_patient_app/core/config/app_config.dart';
import 'package:careid_patient_app/core/constants/api_endpoints.dart';
import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/auth/data/repositories/auth_repository.dart';
import 'package:careid_patient_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/digital_health_card_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/doctor_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/family_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/insurance_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/medical_records_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/notification_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/patient_repository.dart';
import 'package:careid_patient_app/features/patient/data/repositories/treatment_offer_repository.dart';

/// CareID E2E Testing Harness & Mock In-Memory Server
/// Faithfully mirrors Postman collection endpoints and schemas from
/// CareID-Staging.postman_collection.json and OpenAPI 3.0 specification.
class E2ETestHarness {
  final ApiClient apiClient;
  final InMemoryTokenStorage tokenStorage;
  final CareIDMockBackend mockBackend;

  // Repositories wired to this harness
  final AuthRepository authRepo;
  final PatientRepository patientRepo;
  final OnboardingRepository onboardingRepo;
  final DigitalHealthCardRepository healthCardRepo;
  final MedicalRecordsRepository recordsRepo;
  final DoctorRepository doctorRepo;
  final InsuranceRepository insuranceRepo;
  final FamilyRepository familyRepo;
  final NotificationRepository notificationRepo;
  final TreatmentOfferRepository treatmentOfferRepo;

  E2ETestHarness._({
    required this.apiClient,
    required this.tokenStorage,
    required this.mockBackend,
    required this.authRepo,
    required this.patientRepo,
    required this.onboardingRepo,
    required this.healthCardRepo,
    required this.recordsRepo,
    required this.doctorRepo,
    required this.insuranceRepo,
    required this.familyRepo,
    required this.notificationRepo,
    required this.treatmentOfferRepo,
  });

  /// Factory to instantiate a clean, isolated E2E Test Harness
  factory E2ETestHarness.create({
    bool startAuthenticated = false,
    String? customAccessToken,
  }) {
    final tokenStorage = InMemoryTokenStorage();
    final mockBackend = CareIDMockBackend();

    final client = MockClient((request) async {
      return mockBackend.handleRequest(request);
    });

    final apiClient = ApiClient(
      baseUrl: AppConfig.apiBaseUrl,
      httpClient: client,
      tokenStorage: tokenStorage,
    );

    if (startAuthenticated) {
      final token = customAccessToken ?? 'mock-valid-jwt-token-patient-0004';
      tokenStorage.saveTokens(
        accessToken: token,
        refreshToken: 'mock-valid-refresh-token-patient-0004',
      );
    }

    return E2ETestHarness._(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
      mockBackend: mockBackend,
      authRepo: AuthRepository(apiClient: apiClient, tokenStorage: tokenStorage),
      patientRepo: PatientRepository(apiClient: apiClient, tokenStorage: tokenStorage),
      onboardingRepo: OnboardingRepository(apiClient: apiClient, tokenStorage: tokenStorage),
      healthCardRepo: DigitalHealthCardRepository(apiClient: apiClient, tokenStorage: tokenStorage),
      recordsRepo: MedicalRecordsRepository(apiClient: apiClient, tokenStorage: tokenStorage),
      doctorRepo: DoctorRepository(apiClient: apiClient),
      insuranceRepo: InsuranceRepository(apiClient: apiClient, tokenStorage: tokenStorage),
      familyRepo: FamilyRepository(apiClient: apiClient, tokenStorage: tokenStorage),
      notificationRepo: NotificationRepository(apiClient: apiClient),
      treatmentOfferRepo: TreatmentOfferRepository(apiClient: apiClient),
    );
  }

  /// Convenience helper to authenticate with the standard seeded patient account
  Future<void> loginAsSeededPatient() async {
    const validPhone = '+16505550004';
    final otpRes = await authRepo.requestOtp(validPhone);
    final challengeId = otpRes.dataOrNull?.challengeId ?? 'ch-test-12345';
    await authRepo.verifyOtp(challengeId: challengeId, otpCode: '123456');
  }
}

/// Simulated Staging In-Memory CareID Backend
class CareIDMockBackend {
  // Fault injection controls
  bool simulateTimeout = false;
  bool simulateSocketError = false;
  int? forceStatusCode;
  String? forceErrorMessage;
  int _idCounter = 0;

  // In-memory data store
  final Map<String, dynamic> patientProfile = {
    'id': '787e5187-7859-4320-bb1a-465a57dd086a',
    'patientNumber': 'PT-2026-0004',
    'firstName': 'John',
    'lastName': 'Doe',
    'phone': '+16505550004',
    'email': 'john.doe@careid.test',
    'dateOfBirth': '1990-01-01',
    'gender': 'Male',
    'bloodGroup': 'O+',
    'knownAllergies': ['Penicillin', 'Peanuts'],
    'chronicConditions': ['Asthma'],
    'emergencyContact': {
      'name': 'Jane Doe',
      'relationship': 'Spouse',
      'phone': '+14155552671',
    },
    'emergencyContacts': [
      {
        'name': 'Jane Doe',
        'relationship': 'Spouse',
        'phone': '+14155552671',
      }
    ],
    'addresses': [
      {
        'address': '123 Main St, New York, NY',
        'type': 'CURRENT',
      }
    ],
    'status': 'ACTIVE',
  };

  final Map<String, dynamic> activeHealthCard = {
    'id': 'hc-001',
    'patientProfileId': '787e5187-7859-4320-bb1a-465a57dd086a',
    'cardNumber': 'HC-CAREID-2026-0004',
    'status': 'ACTIVE',
    'qrPayload': 'HC-CAREID-2026-0004|787e5187-7859-4320-bb1a-465a57dd086a|SIG123',
    'issuedAt': '2026-01-01T00:00:00.000Z',
    'expiresAt': '2028-01-01T00:00:00.000Z',
    'emergencyFlag': false,
  };

  final List<Map<String, dynamic>> medicalRecords = [
    {
      'id': 'rec-001',
      'title': 'Comprehensive Cardiovascular Screening',
      'category': 'GENERAL',
      'chiefComplaint': 'Chest tightness on moderate exertion',
      'clinicalNotes': 'Resting ECG normal, BP 120/80 mmHg, cholesterol within target.',
      'treatmentPlan': 'Low sodium Mediterranean diet, regular aerobic exercise, follow-up in 6 months.',
      'status': 'FINAL',
      'doctorName': 'Dr. Robert Chen',
      'facilityName': 'Metro Health Medical Center',
      'recordDate': '2026-05-15T10:30:00.000Z',
    },
    {
      'id': 'rec-002',
      'title': 'Annual Dental Examination & Scaling',
      'category': 'DENTAL',
      'chiefComplaint': 'Routine prophylactic examination',
      'clinicalNotes': 'Gingival tissue firm and pink, no active caries detected.',
      'treatmentPlan': 'Prophylaxis and fluoride varnish application, maintain brushing.',
      'status': 'FINAL',
      'doctorName': 'Dr. Emily Taylor',
      'facilityName': 'CareID Dental Clinic',
      'recordDate': '2026-06-20T14:00:00.000Z',
    },
    {
      'id': 'rec-003',
      'title': 'Bilateral Visual Acuity & Refraction',
      'category': 'VISION',
      'chiefComplaint': 'Mild astigmatism and distant blurriness',
      'clinicalNotes': 'OD: -1.25, OS: -1.00. Intraocular pressure 14 mmHg OU.',
      'treatmentPlan': 'Corrective anti-reflective spectacle lenses prescribed.',
      'status': 'FINAL',
      'doctorName': 'Dr. Michael Vance',
      'facilityName': 'Apex Vision Center',
      'recordDate': '2026-07-02T09:15:00.000Z',
    },
  ];

  final List<Map<String, dynamic>> appointments = [
    {
      'id': 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380e55',
      'doctorId': '1f06067b-e229-4707-84e2-afa27da2e4cd',
      'doctorName': 'Dr. Robert Chen',
      'specialization': 'Cardiology',
      'facility': 'Metro Health Medical Center',
      'dateTime': '2026-11-20T10:00:00.000Z',
      'consultationType': 'In-Person Consultation',
      'status': 'UPCOMING',
      'reasonForVisit': 'Cardiovascular review',
      'qrPassCode': 'CAREID-APT-PASS-8842',
      'durationMinutes': 30,
    }
  ];

  final List<Map<String, dynamic>> doctors = [
    {
      'id': '1f06067b-e229-4707-84e2-afa27da2e4cd',
      'fullName': 'Dr. Robert Chen',
      'firstName': 'Robert',
      'lastName': 'Chen',
      'primarySpecialization': 'Cardiology',
      'secondarySpecializations': ['Internal Medicine'],
      'rating': 4.9,
      'yearsOfExperience': 14,
      'facilityName': 'Metro Health Medical Center',
      'languages': ['English', 'Spanish'],
      'availableToday': true,
      'bio': 'Board-certified cardiologist specializing in preventive cardiovascular wellness.',
    },
    {
      'id': '2f06067b-e229-4707-84e2-afa27da2e4ce',
      'fullName': 'Dr. Emily Taylor',
      'firstName': 'Emily',
      'lastName': 'Taylor',
      'primarySpecialization': 'Dentistry',
      'secondarySpecializations': ['Orthodontics'],
      'rating': 4.8,
      'yearsOfExperience': 10,
      'facilityName': 'CareID Dental Clinic',
      'languages': ['English'],
      'availableToday': true,
      'bio': 'Experienced general and cosmetic dental practitioner.',
    }
  ];

  final List<Map<String, dynamic>> notifications = [
    {
      'id': 'notif-001',
      'title': 'Upcoming Consultation Reminder',
      'message': 'Your consultation with Dr. Robert Chen is scheduled for tomorrow at 10:00 AM.',
      'priority': 'HIGH',
      'channel': 'IN_APP',
      'status': 'SENT',
      'sentAt': '2026-11-19T08:00:00.000Z',
      'isRead': false,
    },
    {
      'id': 'notif-002',
      'title': 'New Lab Result Available',
      'message': 'Cardiovascular screening report has been attached to your health vault.',
      'priority': 'NORMAL',
      'channel': 'IN_APP',
      'status': 'READ',
      'sentAt': '2026-11-15T12:00:00.000Z',
      'isRead': true,
    }
  ];

  final List<Map<String, dynamic>> insurancePolicies = [
    {
      'id': 'pol-001',
      'providerName': 'Blue Cross Blue Shield',
      'policyNumber': 'POL-998877',
      'groupNumber': 'GRP-5544',
      'status': 'ACTIVE',
      'holderName': 'John Doe',
      'effectiveDate': '2026-01-01',
      'expirationDate': '2027-01-01',
      'copay': 20.0,
      'deductible': 500.0,
    }
  ];

  final List<Map<String, dynamic>> familyInvitations = [
    {
      'id': 'inv-001',
      'inviteeName': 'Jane Doe',
      'inviteePhone': '+14155552671',
      'relationship': 'Spouse',
      'status': 'PENDING',
    }
  ];

  final List<Map<String, dynamic>> treatmentOffers = [
    {
      'id': 'offer-001',
      'offerNumber': 'TO-2026-0001',
      'patientProfileId': '787e5187-7859-4320-bb1a-465a57dd086a',
      'doctorId': '1f06067b-e229-4707-84e2-afa27da2e4cd',
      'facilityId': '3b6a3f47-ed9c-4010-bb1a-e0fdea5f4abb',
      'clinicalIndication': 'Comprehensive Orthodontic Aligners',
      'totalProceduresCost': 2400.0,
      'discountAmount': 600.0,
      'netPayableCost': 1800.0,
      'financingEligible': true,
      'recommendedTenureMonths': 12,
      'status': 'ACTIVE',
      'validUntil': '2026-12-31T23:59:59.000Z',
      'doctorName': 'Dr. Emily Taylor',
      'facilityName': 'CareID Dental Clinic',
    }
  ];

  // Request router
  Future<http.Response> handleRequest(http.Request request) async {
    if (simulateTimeout) {
      throw TimeoutException('Simulated network timeout');
    }
    if (simulateSocketError) {
      throw const SocketException('Simulated connection failure');
    }
    if (forceStatusCode != null) {
      return http.Response(
        jsonEncode({
          'success': false,
          'statusCode': forceStatusCode,
          'message': forceErrorMessage ?? 'Forced test status code error',
        }),
        forceStatusCode!,
        headers: {'content-type': 'application/json'},
      );
    }

    final path = request.url.path;
    final method = request.method;

    // Check token authorization header for protected routes
    final authHeader = request.headers['authorization'];

    // Reject invalid tokens on protected endpoints
    if (authHeader != null && authHeader.contains('invalid-token')) {
      return http.Response(
        jsonEncode({'success': false, 'statusCode': 401, 'message': 'Invalid authentication token'}),
        401,
        headers: {'content-type': 'application/json'},
      );
    }

    // 1. Auth Endpoints
    if (path == ApiEndpoints.otpRequest && method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final phone = body['phone']?.toString() ?? '';
      if (phone.isEmpty || phone.length < 7) {
        return http.Response(
          jsonEncode({'success': false, 'statusCode': 422, 'message': 'Invalid phone number format'}),
          422,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response(
        jsonEncode({
          'success': true,
          'statusCode': 200,
          'message': 'OTP sent successfully',
          'challengeId': 'ch-test-12345',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.otpVerify && method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final otpCode = body['otpCode']?.toString();
      if (otpCode == '123456') {
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'message': 'OTP verified successfully',
            'accessToken': 'jwt.mock.access.token.123',
            'refreshToken': 'jwt.mock.refresh.token.456',
            'expiresIn': 3600,
            'tokenType': 'Bearer',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response(
        jsonEncode({'success': false, 'statusCode': 401, 'message': 'Invalid or expired OTP code'}),
        401,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.tokenRefresh && method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final refresh = body['refreshToken']?.toString();
      if (refresh != null && refresh.isNotEmpty && !refresh.contains('invalid')) {
        return http.Response(
          jsonEncode({
            'success': true,
            'statusCode': 200,
            'accessToken': 'jwt.mock.refreshed.access.token',
            'refreshToken': 'jwt.mock.refreshed.refresh.token',
            'tokenType': 'Bearer',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response(
        jsonEncode({'success': false, 'statusCode': 401, 'message': 'Invalid refresh token'}),
        401,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.logout && method == 'POST') {
      return http.Response(
        jsonEncode({'success': true, 'statusCode': 200, 'message': 'Logged out successfully'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.logoutAll && method == 'POST') {
      return http.Response(
        jsonEncode({'success': true, 'statusCode': 200, 'message': 'All active sessions terminated'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.authMe && method == 'GET') {
      return http.Response(
        jsonEncode({
          'id': 'user-uuid-v4',
          'phone': '+16505550004',
          'status': 'ACTIVE',
          'roles': ['PATIENT'],
          'permissions': ['read:profile', 'write:profile'],
          'email': 'patient@careid.test',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.sessions && method == 'GET') {
      return http.Response(
        jsonEncode([
          {
            'id': 'sess-1',
            'ipAddress': '192.168.1.1',
            'userAgent': 'CareID Patient App/1.0.0',
            'createdAt': '2026-07-31T06:00:00.000Z',
          }
        ]),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    // 2. Patient Profile & Onboarding Endpoints
    if (path == ApiEndpoints.patientRegisterDraft && method == 'POST') {
      return http.Response(
        jsonEncode({
          'profileId': '787e5187-7859-4320-bb1a-465a57dd086a',
          'patientNumber': 'PT-2026-0004',
          'status': 'DRAFT',
          'onboardingStep': 1,
        }),
        201,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.patientRegisterStatus && method == 'GET') {
      return http.Response(
        jsonEncode({
          'status': 'DRAFT',
          'currentStep': 1,
          'completedSteps': <String>[],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.onboardingDemographics && (method == 'POST' || method == 'PUT')) {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      patientProfile['firstName'] = body['firstName'] ?? patientProfile['firstName'];
      patientProfile['lastName'] = body['lastName'] ?? patientProfile['lastName'];
      patientProfile['bloodGroup'] = body['bloodGroup'] ?? patientProfile['bloodGroup'];
      return http.Response(
        jsonEncode({
          'profileId': '787e5187-7859-4320-bb1a-465a57dd086a',
          'message': 'Demographics saved successfully',
          'nextStep': 3,
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.onboardingEmergencyContact && (method == 'POST' || method == 'PUT')) {
      return http.Response(
        jsonEncode({
          'contactId': 'em-001',
          'message': 'Emergency contact registered',
          'nextStep': 4,
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.onboardingInsurance && (method == 'POST' || method == 'PUT')) {
      return http.Response(
        jsonEncode({
          'policyId': 'pol-001',
          'message': 'Insurance linked',
          'nextStep': 5,
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.onboardingComplete && method == 'POST') {
      patientProfile['status'] = 'ACTIVE';
      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'Onboarding completed successfully',
          'status': 'ACTIVE',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.patientProfileFull && method == 'GET') {
      return http.Response(
        jsonEncode(patientProfile),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.patientProfileMe && method == 'GET') {
      return http.Response(
        jsonEncode(patientProfile),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.patientBasic && method == 'PATCH') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      patientProfile.addAll(body);
      return http.Response(
        jsonEncode(patientProfile),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.patientProfileCompletion && method == 'GET') {
      return http.Response(
        jsonEncode({
          'percentage': 100,
          'isComplete': true,
          'sections': {'demographics': true, 'emergency': true, 'insurance': true},
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    // 3. Digital Health Card Endpoints
    if (path == ApiEndpoints.healthCards && method == 'GET') {
      return http.Response(
        jsonEncode(activeHealthCard),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.healthCards && method == 'POST') {
      return http.Response(
        jsonEncode(activeHealthCard),
        201,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.healthCardsVerifyQr && method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final qr = body['qrPayload']?.toString() ?? '';
      if ((qr.contains('HC-CAREID') || qr.contains('CAREID')) && !qr.contains('INVALID')) {
        return http.Response(
          jsonEncode({
            'isValid': true,
            'cardNumber': 'HC-CAREID-2026-0004',
            'patientName': 'John Doe',
            'firstName': 'John',
            'lastName': 'Doe',
            'patientNumber': 'PT-2026-0004',
            'dateOfBirth': '1990-01-01',
            'bloodGroup': 'O+',
            'status': 'VALID',
            'message': 'Digital Health Card verified successfully',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response(
        jsonEncode({
          'isValid': false,
          'status': 'INVALID',
          'message': 'Unrecognized or corrupted QR payload',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    // 4. Medical Records Endpoints
    if (path == ApiEndpoints.medicalRecords && method == 'GET') {
      return http.Response(
        jsonEncode(medicalRecords),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.medicalRecordsSearch && method == 'GET') {
      final q = request.url.queryParameters['q']?.toLowerCase() ?? '';
      final filtered = medicalRecords.where((r) {
        final title = (r['title'] ?? '').toString().toLowerCase();
        final notes = (r['clinicalNotes'] ?? '').toString().toLowerCase();
        return title.contains(q) || notes.contains(q);
      }).toList();
      return http.Response(
        jsonEncode(filtered),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.medicalRecordsTimeline && method == 'GET') {
      final timeline = medicalRecords.map((r) => {
        'id': r['id'],
        'title': r['title'],
        'category': r['category'],
        'date': r['recordDate'],
      }).toList();
      return http.Response(
        jsonEncode(timeline),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.medicalRecords && method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final newRec = {
        'id': 'rec-created-${DateTime.now().microsecondsSinceEpoch}-${++_idCounter}',
        'title': body['title'] ?? 'New Consultation Record',
        'category': body['category'] ?? 'GENERAL',
        'chiefComplaint': body['chiefComplaint'] ?? '',
        'clinicalNotes': body['clinicalNotes'] ?? '',
        'treatmentPlan': body['treatmentPlan'] ?? '',
        'status': body['status'] ?? 'FINAL',
        'recordDate': DateTime.now().toIso8601String(),
      };
      medicalRecords.insert(0, newRec);
      return http.Response(
        jsonEncode(newRec),
        201,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path.startsWith('${ApiEndpoints.medicalRecords}/') && method == 'GET') {
      final id = path.substring('${ApiEndpoints.medicalRecords}/'.length);
      final found = medicalRecords.firstWhere(
        (r) => r['id'] == id,
        orElse: () => medicalRecords.first,
      );
      return http.Response(
        jsonEncode(found),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    // 5. Doctors & Appointments Endpoints
    if (path == ApiEndpoints.doctors && method == 'GET') {
      return http.Response(
        jsonEncode({'data': doctors}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.doctorsSearch && method == 'GET') {
      final q = request.url.queryParameters['q']?.toLowerCase() ?? '';
      final filtered = doctors.where((d) {
        final name = '${d['firstName']} ${d['lastName']}'.toLowerCase();
        final spec = (d['primarySpecialization'] ?? '').toString().toLowerCase();
        return name.contains(q) || spec.contains(q);
      }).toList();
      return http.Response(
        jsonEncode({'data': filtered}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path.startsWith('${ApiEndpoints.doctors}/') && path.endsWith('/slots') && method == 'GET') {
      return http.Response(
        jsonEncode({
          'data': [
            {'id': 'slot-1', 'date': '2026-11-20', 'startTime': '09:00', 'endTime': '09:30', 'isAvailable': true},
            {'id': 'slot-2', 'date': '2026-11-20', 'startTime': '10:00', 'endTime': '10:30', 'isAvailable': true},
            {'id': 'slot-3', 'date': '2026-11-20', 'startTime': '14:00', 'endTime': '14:30', 'isAvailable': true},
          ]
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path.startsWith('${ApiEndpoints.doctors}/') && method == 'GET') {
      final id = path.substring('${ApiEndpoints.doctors}/'.length);
      final doc = doctors.firstWhere((d) => d['id'] == id, orElse: () => doctors.first);
      return http.Response(
        jsonEncode({'data': doc}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.patientMyAppointments && method == 'GET') {
      return http.Response(
        jsonEncode({'data': appointments}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.appointments && method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final newApt = {
        'id': 'apt-${DateTime.now().millisecondsSinceEpoch}',
        'doctorId': body['doctorProfileId'] ?? '1f06067b-e229-4707-84e2-afa27da2e4cd',
        'doctorName': 'Dr. Robert Chen',
        'specialization': 'Cardiology',
        'facility': 'Metro Health Medical Center',
        'dateTime': '${body['appointmentDate'] ?? '2026-11-25'}T${body['startTime'] ?? '09:00'}:00.000Z',
        'consultationType': body['type'] ?? 'In-Person Consultation',
        'status': 'UPCOMING',
        'reasonForVisit': body['reason'] ?? 'Clinical follow-up',
        'qrPassCode': 'CAREID-APT-PASS-9921',
        'durationMinutes': body['durationMinutes'] ?? 30,
      };
      appointments.insert(0, newApt);
      return http.Response(
        jsonEncode({'data': newApt, 'message': 'Appointment booked successfully'}),
        201,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path.startsWith('/api/v1/appointments/') && path.endsWith('/cancel') && method == 'PUT') {
      return http.Response(
        jsonEncode({'data': true, 'message': 'Appointment cancelled successfully'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path.startsWith('/api/v1/appointments/') && path.endsWith('/reschedule') && method == 'PUT') {
      return http.Response(
        jsonEncode({'data': true, 'message': 'Appointment rescheduled successfully'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    // 6. Insurance & Treatment Offers Endpoints
    if (path == ApiEndpoints.insurancePolicies && method == 'GET') {
      return http.Response(
        jsonEncode(insurancePolicies),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path.startsWith('${ApiEndpoints.insurancePolicies}/') && method == 'GET') {
      final id = path.substring('${ApiEndpoints.insurancePolicies}/'.length);
      final found = insurancePolicies.firstWhere((p) => p['id'] == id, orElse: () => insurancePolicies.first);
      return http.Response(
        jsonEncode(found),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.patientTreatmentOffers && method == 'GET') {
      return http.Response(
        jsonEncode({'data': treatmentOffers}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path.startsWith('${ApiEndpoints.patientTreatmentOffers}/') && method == 'GET') {
      final id = path.substring('${ApiEndpoints.patientTreatmentOffers}/'.length);
      final offer = treatmentOffers.firstWhere((o) => o['id'] == id, orElse: () => treatmentOffers.first);
      return http.Response(
        jsonEncode({'data': offer}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    // 7. Family Members Endpoints
    if (path == ApiEndpoints.familyInvitations && method == 'GET') {
      return http.Response(
        jsonEncode(familyInvitations),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path == ApiEndpoints.familyInvitations && method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final newInv = {
        'id': 'inv-${DateTime.now().millisecondsSinceEpoch}',
        'inviteeName': body['inviteeName'] ?? 'Family Member',
        'inviteePhone': body['inviteePhone'] ?? '+14155550000',
        'relationship': body['relationship'] ?? 'Dependent',
        'status': 'PENDING',
      };
      familyInvitations.insert(0, newInv);
      return http.Response(
        jsonEncode(newInv),
        201,
        headers: {'content-type': 'application/json'},
      );
    }

    // 8. Notifications Endpoints
    if (path == ApiEndpoints.notifications && method == 'GET') {
      return http.Response(
        jsonEncode({'data': notifications}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path.startsWith('/api/v1/notifications/') && path.endsWith('/read') && method == 'PUT') {
      return http.Response(
        jsonEncode({'message': 'Notification marked as read'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    // Default Fallback
    return http.Response(
      jsonEncode({'statusCode': 200, 'message': 'Mock endpoint response'}),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}
