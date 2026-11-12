import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:careid_patient_app/core/config/app_config.dart';
import 'package:careid_patient_app/core/network/api_client.dart';
import 'package:careid_patient_app/core/storage/token_storage.dart';
import 'package:careid_patient_app/features/auth/data/repositories/auth_repository.dart';

void main() {
  test('Live Backend API Runtime Probe across all Patient Modules', () async {
    const baseUrl = AppConfig.apiBaseUrl; // https://360api.vnvision.in
    const phone = '+16505550004';
    const otp = '123456';

    final tokenStorage = InMemoryTokenStorage();
    final apiClient = ApiClient(baseUrl: baseUrl, tokenStorage: tokenStorage);
    final authRepo = AuthRepository(apiClient: apiClient, tokenStorage: tokenStorage);

    print('Step 1: Authenticating test account $phone ...');
    final reqRes = await authRepo.requestOtp(phone);
    String? token;

    if (reqRes.isSuccess && reqRes.dataOrNull?.challengeId != null) {
      final challengeId = reqRes.dataOrNull!.challengeId;
      final verifyRes = await authRepo.verifyOtp(challengeId: challengeId, otpCode: otp);
      if (verifyRes.isSuccess) {
        token = verifyRes.dataOrNull?.accessToken;
        print('Authentication SUCCESS! Token acquired.');
      } else {
        print('Verification failed: ${verifyRes.messageOrNull}');
      }
    } else {
      print('Request OTP returned: ${reqRes.messageOrNull}');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final testEndpoints = <Map<String, dynamic>>[
      // Auth & Identity
      {'method': 'GET', 'path': '/auth/me', 'module': 'auth', 'desc': 'Current Auth User'},
      {'method': 'GET', 'path': '/auth/sessions', 'module': 'auth', 'desc': 'Active User Sessions'},
      {'method': 'GET', 'path': '/auth/roles', 'module': 'auth', 'desc': 'Available Roles'},
      {'method': 'GET', 'path': '/auth/permissions', 'module': 'auth', 'desc': 'Available Permissions'},

      // Patient Profile
      {'method': 'GET', 'path': '/patients/me', 'module': 'patient', 'desc': 'Patient Profile Summary'},
      {'method': 'GET', 'path': '/patients/me/full', 'module': 'patient', 'desc': 'Full Patient Profile'},
      {'method': 'GET', 'path': '/patients/profile/completion', 'module': 'patient', 'desc': 'Profile Completion Metrics'},
      {'method': 'GET', 'path': '/patients/profile/timeline', 'module': 'patient', 'desc': 'Profile Timeline'},
      {'method': 'GET', 'path': '/patients/profile/activity', 'module': 'patient', 'desc': 'Profile Activity Log'},
      {'method': 'GET', 'path': '/patients/onboarding/progress', 'module': 'patient', 'desc': 'Onboarding Progress'},
      {'method': 'GET', 'path': '/patients/onboarding/completion', 'module': 'patient', 'desc': 'Onboarding Completion'},

      // Digital Health Cards & Passes
      {'method': 'GET', 'path': '/health-cards', 'module': 'health-card', 'desc': 'Health Cards Catalog'},
      {'method': 'GET', 'path': '/health-cards/statistics', 'module': 'health-card', 'desc': 'Health Card Statistics'},
      {'method': 'GET', 'path': '/health-cards/search', 'module': 'health-card', 'desc': 'Health Card Search'},

      // QR Subsystem
      {'method': 'GET', 'path': '/qr', 'module': 'qr', 'desc': 'List QR Codes'},
      {'method': 'GET', 'path': '/qr/statistics', 'module': 'qr', 'desc': 'QR Statistics'},
      {'method': 'GET', 'path': '/qr/search', 'module': 'qr', 'desc': 'QR Search'},

      // Medical Records (General, Dental, Vision)
      {'method': 'GET', 'path': '/medical-records', 'module': 'medical-record', 'desc': 'Patient Medical Records'},
      {'method': 'GET', 'path': '/medical-records/timeline', 'module': 'medical-record', 'desc': 'Medical Records Timeline'},
      {'method': 'GET', 'path': '/medical-records/search', 'module': 'medical-record', 'desc': 'Medical Records Search'},
      {'method': 'GET', 'path': '/medical-records?category=DENTAL', 'module': 'medical-record', 'desc': 'Dental Records Filter'},
      {'method': 'GET', 'path': '/medical-records?category=VISION', 'module': 'medical-record', 'desc': 'Vision Records Filter'},
      {'method': 'GET', 'path': '/medical-records/encounters', 'module': 'medical-record', 'desc': 'Clinical Encounters'},

      // Appointments & Schedules
      {'method': 'GET', 'path': '/appointments', 'module': 'appointment', 'desc': 'Appointments List'},
      {'method': 'GET', 'path': '/appointments/patient/my-appointments', 'module': 'appointment', 'desc': 'Patient My Appointments'},
      {'method': 'GET', 'path': '/schedules', 'module': 'schedule', 'desc': 'Provider Schedules'},
      {'method': 'GET', 'path': '/schedules/search', 'module': 'schedule', 'desc': 'Schedules Search'},

      // Doctors & Providers
      {'method': 'GET', 'path': '/doctors', 'module': 'doctor', 'desc': 'Doctor Directory'},
      {'method': 'GET', 'path': '/doctors/search', 'module': 'doctor', 'desc': 'Doctor Search'},
      {'method': 'GET', 'path': '/doctors/statistics', 'module': 'doctor', 'desc': 'Doctor Statistics'},

      // Facilities & Clinics
      {'method': 'GET', 'path': '/facilities', 'module': 'facility', 'desc': 'Facilities Directory'},
      {'method': 'GET', 'path': '/facilities/search', 'module': 'facility', 'desc': 'Facility Search'},
      {'method': 'GET', 'path': '/facilities/statistics', 'module': 'facility', 'desc': 'Facility Statistics'},

      // Family Members & Relationships
      {'method': 'GET', 'path': '/family/members', 'module': 'family', 'desc': 'Family Members List'},
      {'method': 'GET', 'path': '/family/invitations', 'module': 'family', 'desc': 'Family Invitations'},
      {'method': 'GET', 'path': '/family/guardians', 'module': 'family', 'desc': 'Family Guardians'},
      {'method': 'GET', 'path': '/family/dependents', 'module': 'family', 'desc': 'Family Dependents'},
      {'method': 'GET', 'path': '/family/consents/history', 'module': 'family', 'desc': 'Family Consent History'},

      // Insurance Platform & Claims
      {'method': 'GET', 'path': '/insurance/policies', 'module': 'insurance', 'desc': 'Insurance Policies'},
      {'method': 'GET', 'path': '/insurance/claims', 'module': 'insurance', 'desc': 'Insurance Claims'},
      {'method': 'GET', 'path': '/insurance/providers', 'module': 'insurance', 'desc': 'Insurance Providers'},
      {'method': 'GET', 'path': '/insurance/plans', 'module': 'insurance', 'desc': 'Insurance Plans'},
      {'method': 'GET', 'path': '/insurance/statistics', 'module': 'insurance', 'desc': 'Insurance Statistics'},

      // Notifications & Alerts
      {'method': 'GET', 'path': '/notifications', 'module': 'notifications', 'desc': 'Patient Notifications'},
      {'method': 'GET', 'path': '/notifications/preferences', 'module': 'notifications', 'desc': 'Notification Preferences'},

      // Referrals & Care Coordination
      {'method': 'GET', 'path': '/referrals', 'module': 'referral', 'desc': 'Referrals List'},
      {'method': 'GET', 'path': '/referrals/my-incoming', 'module': 'referral', 'desc': 'Incoming Referrals'},
      {'method': 'GET', 'path': '/referrals/my-outgoing', 'module': 'referral', 'desc': 'Outgoing Referrals'},
      {'method': 'GET', 'path': '/referrals/dashboard/stats', 'module': 'referral', 'desc': 'Referrals Dashboard Stats'},

      // Immunisations & Vaccines
      {'method': 'GET', 'path': '/immunisation/vaccines', 'module': 'immunisation', 'desc': 'Vaccines Catalog'},
      {'method': 'GET', 'path': '/immunisation/schedules', 'module': 'immunisation', 'desc': 'Immunisation Schedules'},
      {'method': 'GET', 'path': '/immunisation/records', 'module': 'immunisation', 'desc': 'Immunisation Records'},
      {'method': 'GET', 'path': '/immunisation/certificates', 'module': 'immunisation', 'desc': 'Immunisation Certificates'},

      // Healthcare Financing & Treatment Offers
      {'method': 'GET', 'path': '/financing/options', 'module': 'financing', 'desc': 'Financing Options'},
      {'method': 'GET', 'path': '/financing/offers', 'module': 'financing', 'desc': 'Financing Offers'},
      {'method': 'GET', 'path': '/financing/applications', 'module': 'financing', 'desc': 'Financing Applications'},
      {'method': 'GET', 'path': '/patients/treatment-offers', 'module': 'treatment-offer', 'desc': 'Patient Treatment Offers'},

      // Support Tickets & Helpdesk
      {'method': 'GET', 'path': '/support/tickets', 'module': 'support', 'desc': 'Support Tickets'},

      // Pet Health Records
      {'method': 'GET', 'path': '/pets', 'module': 'pet', 'desc': 'Pet Health Records'},

      // CMS & Policies
      {'method': 'GET', 'path': '/cms/faqs', 'module': 'cms', 'desc': 'CMS FAQs'},
      {'method': 'GET', 'path': '/cms/announcements', 'module': 'cms', 'desc': 'CMS Announcements'},
      {'method': 'GET', 'path': '/cms/policies', 'module': 'cms', 'desc': 'CMS Policies'},
      {'method': 'GET', 'path': '/cms/banners', 'module': 'cms', 'desc': 'CMS Banners'},
      {'method': 'GET', 'path': '/cms/pages', 'module': 'cms', 'desc': 'CMS Pages'},

      // OCR & Verification Jobs
      {'method': 'GET', 'path': '/ocr/jobs', 'module': 'ocr', 'desc': 'OCR Jobs List'},
    ];

    final results = <Map<String, dynamic>>[];

    print('\nProbing ${testEndpoints.length} candidate endpoints with authenticated session...\n');

    for (final ep in testEndpoints) {
      final method = ep['method'] as String;
      final path = ep['path'] as String;
      final desc = ep['desc'] as String;
      final module = ep['module'] as String;

      final fullRoute = '$baseUrl/api/v1$path';
      final uri = Uri.parse(fullRoute);
      final stopwatch = Stopwatch()..start();

      int statusCode = 0;
      String outcome = '';
      dynamic responseData;

      try {
        final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
        stopwatch.stop();
        statusCode = res.statusCode;

        if (res.body.isNotEmpty) {
          try {
            responseData = jsonDecode(res.body);
          } catch (_) {
            responseData = res.body.substring(0, res.body.length > 200 ? 200 : res.body.length);
          }
        }

        if (statusCode >= 200 && statusCode < 300) {
          outcome = 'SUCCESS (2xx)';
        } else if (statusCode == 401) {
          outcome = 'UNAUTHORIZED (401)';
        } else if (statusCode == 403) {
          outcome = 'FORBIDDEN (403 - Role Restricted)';
        } else if (statusCode == 404) {
          outcome = 'NOT FOUND (404)';
        } else if (statusCode >= 500) {
          outcome = 'SERVER ERROR ($statusCode)';
        } else {
          outcome = 'HTTP $statusCode';
        }
      } catch (e) {
        stopwatch.stop();
        outcome = 'NETWORK / TIMEOUT ERROR: $e';
      }

      final resultItem = {
        'method': method,
        'path': '/api/v1$path',
        'module': module,
        'description': desc,
        'statusCode': statusCode,
        'durationMs': stopwatch.elapsedMilliseconds,
        'outcome': outcome,
        'hasData': responseData != null,
        'sample': responseData is Map ? (responseData['data'] ?? responseData['message']) : null,
      };

      results.add(resultItem);

      final statusStr = statusCode != 0 ? statusCode.toString() : 'ERR';
      print('[${statusStr.padRight(3)}] ${method.padRight(4)} /api/v1$path ($desc) -> $outcome (${stopwatch.elapsedMilliseconds}ms)');
    }

    final output = {
      'timestamp': DateTime.now().toIso8601String(),
      'baseUrl': '$baseUrl/api/v1',
      'totalTested': results.length,
      'successful': results.where((r) => ((r['statusCode'] as int?) ?? 0) >= 200 && ((r['statusCode'] as int?) ?? 0) < 300).length,
      'forbidden': results.where((r) => r['statusCode'] == 403).length,
      'notFound': results.where((r) => r['statusCode'] == 404).length,
      'unauthorized': results.where((r) => r['statusCode'] == 401).length,
      'serverError': results.where((r) => ((r['statusCode'] as int?) ?? 0) >= 500).length,
      'results': results,
    };

    File('api_runtime_test_results.json').writeAsStringSync(jsonEncode(output));
    print('\n=== RUNTIME PROBE COMPLETE ===');
    print('Total tested: ${results.length}');
    print('Successful: ${output["successful"]}');
    print('Forbidden (Role Restricted): ${output["forbidden"]}');
    print('Not Found: ${output["notFound"]}');
    print('Unauthorized: ${output["unauthorized"]}');
    print('Server Error: ${output["serverError"]}');
  }, timeout: const Timeout(Duration(minutes: 4)));
}
