import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/models/registration_context.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/onboarding/presentation/screens/add_insurance_screen.dart';
import 'features/onboarding/presentation/screens/confirmed_screen.dart';
import 'features/onboarding/presentation/screens/create_account_screen.dart';
import 'features/onboarding/presentation/screens/health_info_screen.dart';
import 'features/onboarding/presentation/screens/mobile_number_screen.dart';
import 'features/onboarding/presentation/screens/privacy_consents_screen.dart';
import 'features/onboarding/presentation/screens/splash_screen.dart';
import 'features/onboarding/presentation/screens/welcome_screen.dart';
import 'features/patient/presentation/screens/health_card_screen.dart';
import 'features/patient/presentation/screens/insurance_screen.dart';
import 'features/patient/data/models/insurance_policy_models.dart';
import 'features/patient/presentation/screens/insurance_qr_screen.dart';

import 'features/patient/presentation/screens/emergency_center_screen.dart';
import 'features/patient/presentation/screens/dependent_health_card_screen.dart';
import 'features/patient/presentation/screens/family_members_screen.dart';
import 'features/patient/presentation/screens/patient_main_navigation_shell.dart';
import 'features/patient/data/models/doctor_models.dart';
import 'features/patient/presentation/screens/doctor_profile_screen.dart';
import 'features/patient/presentation/screens/scan_health_card_qr_screen.dart';
import 'features/patient/presentation/screens/scan_medical_document_ocr_screen.dart';
import 'features/patient/presentation/screens/qr_dashboard_screen.dart';
import 'features/patient/presentation/screens/share_options_screen.dart';
import 'features/patient/presentation/screens/qr_preview_screen.dart';
import 'features/patient/presentation/screens/access_history_screen.dart';
import 'features/patient/presentation/screens/referrals_screen.dart';
import 'features/patient/presentation/screens/access_verification_screen.dart';
import 'features/patient/presentation/screens/record_saved_success_screen.dart';
import 'features/patient/presentation/screens/insurance_financing_hub_screen.dart';
import 'features/patient/presentation/screens/financing_option_details_screen.dart';
import 'features/patient/presentation/screens/cash_discount_options_screen.dart';
import 'features/patient/presentation/screens/insurance_manual_review_screen.dart';
import 'features/patient/presentation/screens/offer_accepted_confirmation_screen.dart';
import 'features/patient/presentation/screens/offer_rejected_confirmation_screen.dart';
import 'features/patient/presentation/screens/offer_status_history_screen.dart';
import 'features/patient/presentation/screens/record_details_hub_screen.dart';
import 'features/patient/presentation/screens/health_records_landing_screen.dart';
import 'features/patient/presentation/screens/treatment_offers_screen.dart';
import 'features/patient/presentation/screens/medical_records_screen.dart';
import 'features/patient/presentation/screens/dental_records_screen.dart';
import 'features/patient/presentation/screens/vision_records_screen.dart';
import 'features/patient/presentation/screens/my_appointments_screen.dart';

/// Root Application Widget for CareID Patient App
class CareIdPatientApp extends StatelessWidget {
  final ApiClient? apiClient;
  final Widget? home;
  final String? initialRoute;

  const CareIdPatientApp({
    super.key,
    this.apiClient,
    this.home,
    this.initialRoute,
  });

  static const RegistrationContext _defaultContext = RegistrationContext(
    fullName: 'Sarah Jenkins',
    phone: '+16505550004',
    email: 'sarah.jenkins@careid.health',
    bloodGroup: 'O+',
    careIdNumber: 'CID-8472-9102-4821',
    chronicConditions: ['Asthma'],
    knownAllergies: ['Penicillin'],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: home,
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';
        final route = name.startsWith('/') ? name : '/$name';

        switch (route) {
          case '/login':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => LoginScreen(apiClient: apiClient),
            );
          case '/create-account':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => CreateAccountScreen(apiClient: apiClient),
            );
          case '/mobile-number':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => MobileNumberScreen(
                apiClient: apiClient,
                registrationContext: _defaultContext,
              ),
            );
          case '/health-info':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => HealthInfoScreen(
                apiClient: apiClient,
                registrationContext: _defaultContext,
              ),
            );
          case '/add-insurance':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => AddInsuranceScreen(
                apiClient: apiClient,
                registrationContext: _defaultContext,
              ),
            );
          case '/privacy-consents':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => PrivacyConsentsScreen(
                apiClient: apiClient,
                registrationContext: _defaultContext,
              ),
            );
          case '/confirmed':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => ConfirmedScreen(
                apiClient: apiClient,
                registrationContext: _defaultContext,
              ),
            );
          case '/dashboard':
          case '/home':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => PatientMainNavigationShell(
                apiClient: apiClient,
                initialIndex: 0,
                registrationContext: settings.arguments is RegistrationContext
                    ? settings.arguments as RegistrationContext
                    : null,
              ),
            );
          case '/records':
          case '/family-records':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => PatientMainNavigationShell(
                apiClient: apiClient,
                initialIndex: 1,
                registrationContext: settings.arguments is RegistrationContext
                    ? settings.arguments as RegistrationContext
                    : null,
              ),
            );
          case '/family':
          case '/family/members':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => FamilyMembersScreen(apiClient: apiClient),
            );
          case '/family/dependent-card':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => DependentHealthCardScreen(apiClient: apiClient),
            );
          case '/doctors':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => PatientMainNavigationShell(
                apiClient: apiClient,
                initialIndex: 2,
                registrationContext: settings.arguments is RegistrationContext
                    ? settings.arguments as RegistrationContext
                    : null,
              ),
            );
          case '/doctor-profile':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) {
                final doctor = settings.arguments is DoctorModel
                    ? settings.arguments as DoctorModel
                    : DoctorModel.seededDoctors.first;
                return DoctorProfileScreen(doctor: doctor);
              },
            );
          case '/doctor-profile-mid':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) {
                final doctor = settings.arguments is DoctorModel
                    ? settings.arguments as DoctorModel
                    : DoctorModel.seededDoctors.first;
                return DoctorProfileScreen(doctor: doctor, initialScrollOffset: 650);
              },
            );
          case '/doctor-profile-bottom':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) {
                final doctor = settings.arguments is DoctorModel
                    ? settings.arguments as DoctorModel
                    : DoctorModel.seededDoctors.first;
                return DoctorProfileScreen(doctor: doctor, initialScrollOffset: 1350);
              },
            );
          case '/profile':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => PatientMainNavigationShell(
                apiClient: apiClient,
                initialIndex: 3,
                registrationContext: settings.arguments is RegistrationContext
                    ? settings.arguments as RegistrationContext
                    : null,
              ),
            );
          case '/qr-sharing':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => QrDashboardScreen(apiClient: apiClient),
            );
          case '/share-options':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => ShareOptionsScreen(apiClient: apiClient),
            );
          case '/qr-preview':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => QrPreviewScreen(apiClient: apiClient),
            );
          case '/access-history':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const AccessHistoryScreen(),
            );
          case '/referrals':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => ReferralsScreen(apiClient: apiClient),
            );
          case '/health-card':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => HealthCardScreen(
                apiClient: apiClient,
                registrationContext: settings.arguments is RegistrationContext
                    ? settings.arguments as RegistrationContext
                    : null,
              ),
            );
          case '/insurance/qr':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => InsuranceQrScreen(
                apiClient: apiClient,
                policy: settings.arguments is InsurancePolicyDto
                    ? settings.arguments as InsurancePolicyDto
                    : const InsurancePolicyDto(
                        id: 'pol-default-1',
                        providerName: 'BlueCross BlueShield',
                        policyNumber: 'BCBS-88421903',
                        groupNumber: 'GRP-99201',
                        planName: 'Platinum Plus Comprehensive',
                        status: 'ACTIVE',
                        validThru: '2026-12-31',
                      ),
              ),
            );
          case '/insurance':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => InsuranceScreen(
                apiClient: apiClient,
                registrationContext: settings.arguments is RegistrationContext
                    ? settings.arguments as RegistrationContext
                    : null,
              ),
            );
          case '/scan-health-card':
          case '/qr-scanner':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => ScanHealthCardQrScreen(apiClient: apiClient),
            );
          case '/scan-document':
          case '/ocr-scanner':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => ScanMedicalDocumentOcrScreen(apiClient: apiClient),
            );
          case '/dashboard-qr-menu':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => PatientMainNavigationShell(
                apiClient: apiClient,
                initialIndex: 0,
                initialExpandQrMenu: true,
              ),
            );
          case '/emergency':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => EmergencyCenterScreen(apiClient: apiClient),
            );
          case '/access-verification':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const AccessVerificationScreen(),
            );
          case '/record-saved-success':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const RecordSavedSuccessScreen(),
            );
          case '/insurance-financing-hub':
          case '/financing-hub':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const InsuranceFinancingHubScreen(),
            );
          case '/insurance-financing-details':
          case '/financing-details':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const FinancingOptionDetailsScreen(),
            );
          case '/insurance-cash-discounts':
          case '/cash-discounts':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const CashDiscountOptionsScreen(),
            );
          case '/insurance-manual-review':
          case '/manual-review':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const InsuranceManualReviewScreen(),
            );
          case '/insurance-offer-accepted':
          case '/offer-accepted':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const OfferAcceptedConfirmationScreen(),
            );
          case '/insurance-offer-rejected':
          case '/offer-rejected':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const OfferRejectedConfirmationScreen(),
            );
          case '/insurance-offer-history':
          case '/offer-history':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const OfferStatusHistoryScreen(),
            );
          case '/record-details-hub':
          case '/record-hub':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const RecordDetailsHubScreen(),
            );
          case '/health-records-landing':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const HealthRecordsLandingScreen(),
            );
          case '/treatment-offers':
          case '/insurance-treatment-offers':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => TreatmentOffersScreen(apiClient: apiClient),
            );
          case '/medical-records':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const MedicalRecordsScreen(),
            );
          case '/dental-records':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const DentalRecordsScreen(),
            );
          case '/vision-records':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const VisionRecordsScreen(),
            );
          case '/my-appointments':
          case '/appointments':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const MyAppointmentsScreen(),
            );
          case '/splash':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => SplashScreen(apiClient: apiClient),
            );
          case '/welcome':
          case '/':
          default:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => home ?? WelcomeScreen(apiClient: apiClient),
            );
        }
      },
    );
  }
}
