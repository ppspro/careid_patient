import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../models/treatment_offer_models.dart';

/// CareID Patient App — Treatment Offer Repository
/// Grounded strictly in OpenAPI 3.0.0 and Postman Collection Section 45
class TreatmentOfferRepository {
  final ApiClient _apiClient;

  TreatmentOfferRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Retrieves clinical treatment offers dispatched to the authenticated patient
  /// GET /api/v1/patients/treatment-offers
  Future<ApiResult<List<TreatmentOfferModel>>> getTreatmentOffers({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    return _apiClient.get<List<TreatmentOfferModel>>(
      ApiEndpoints.patientTreatmentOffers,
      queryParams: queryParams,
      requiresAuth: true,
      fromJson: (json) {
        final list = (json is Map<String, dynamic> && json.containsKey('data'))
            ? json['data']
            : json;
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((e) => TreatmentOfferModel.fromJson(e))
              .toList();
        }
        return <TreatmentOfferModel>[];
      },
    );
  }

  /// Retrieves full treatment offer details by ID
  /// GET /api/v1/patients/treatment-offers/:offerId
  Future<ApiResult<TreatmentOfferModel>> getTreatmentOfferById(String offerId) async {
    return _apiClient.get<TreatmentOfferModel>(
      ApiEndpoints.patientTreatmentOfferById(offerId),
      requiresAuth: true,
      fromJson: (json) {
        final data = (json is Map<String, dynamic> && json.containsKey('data'))
            ? json['data']
            : json;
        return TreatmentOfferModel.fromJson(data as Map<String, dynamic>);
      },
    );
  }

  /// Ratifies informed clinical consent to accept a treatment proposal
  /// POST /api/v1/patients/treatment-offers/:offerId/accept
  Future<ApiResult<Map<String, dynamic>>> acceptTreatmentOffer({
    required String offerId,
    required bool signatureConsent,
    String? patientResponseNotes,
    int? expectedVersion,
  }) async {
    final payload = <String, dynamic>{
      'signatureConsent': signatureConsent,
    };
    if (patientResponseNotes != null && patientResponseNotes.isNotEmpty) {
      payload['patientResponseNotes'] = patientResponseNotes;
    }
    if (expectedVersion != null) {
      payload['expectedVersion'] = expectedVersion;
    }

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.patientTreatmentOfferAccept(offerId),
      requiresAuth: true,
      body: payload,
      fromJson: (json) => json is Map<String, dynamic> ? json : {'status': 'ACCEPTED'},
    );
  }

  /// Declines a treatment proposal with clinical rationale
  /// POST /api/v1/patients/treatment-offers/:offerId/reject
  Future<ApiResult<Map<String, dynamic>>> rejectTreatmentOffer({
    required String offerId,
    required String declineReason,
    int? expectedVersion,
  }) async {
    final payload = <String, dynamic>{
      'declineReason': declineReason,
    };
    if (expectedVersion != null) {
      payload['expectedVersion'] = expectedVersion;
    }

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.patientTreatmentOfferReject(offerId),
      requiresAuth: true,
      body: payload,
      fromJson: (json) => json is Map<String, dynamic> ? json : {'status': 'REJECTED'},
    );
  }
}

