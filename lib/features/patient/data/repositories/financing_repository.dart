import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../models/financing_models.dart';

/// CareID Patient App — Healthcare Financing Repository
/// Grounded in OpenAPI 3.0.0 and Postman Collection Folder 27
class FinancingRepository {
  final ApiClient _apiClient;

  FinancingRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Retrieves available healthcare financing options and partner plans
  /// GET /api/v1/financing/options
  Future<ApiResult<List<FinancingOptionDto>>> getFinancingOptions() async {
    return _apiClient.get<List<FinancingOptionDto>>(
      ApiEndpoints.financingOptions,
      requiresAuth: true,
      fromJson: (json) {
        final list = (json is Map<String, dynamic> && json.containsKey('data'))
            ? json['data']
            : json;
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((e) => FinancingOptionDto.fromJson(e))
              .toList();
        }
        return <FinancingOptionDto>[];
      },
    );
  }

  /// Retrieves pre-approved healthcare financing offers for current patient
  /// GET /api/v1/financing/offers
  Future<ApiResult<List<FinancingOfferDto>>> getPreApprovedOffers() async {
    return _apiClient.get<List<FinancingOfferDto>>(
      ApiEndpoints.financingOffers,
      requiresAuth: true,
      fromJson: (json) {
        final list = (json is Map<String, dynamic> && json.containsKey('data'))
            ? json['data']
            : json;
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((e) => FinancingOfferDto.fromJson(e))
              .toList();
        }
        return <FinancingOfferDto>[];
      },
    );
  }

  /// Alias for getPreApprovedOffers
  Future<ApiResult<List<FinancingOfferDto>>> getFinancingOffers() => getPreApprovedOffers();

  /// Submits an application for healthcare financing / EMI assistance
  /// POST /api/v1/financing/apply
  Future<ApiResult<Map<String, dynamic>>> applyForFinancing({
    required String financingOptionId,
    required double requestedAmount,
    required int tenureMonths,
    String? treatmentDescription,
    String? treatmentOfferId,
    String? employmentStatus,
    String? employmentType,
    double? monthlyIncome,
    String? panOrNationalId,
    String? facilityId,
    String? notes,
  }) async {
    final effectiveEmp = employmentType ?? employmentStatus ?? 'SALARIED';
    final payload = <String, dynamic>{
      'optionId': financingOptionId,
      'financingOptionId': financingOptionId,
      'requestedAmount': requestedAmount,
      'tenureMonths': tenureMonths,
      'treatmentName': treatmentDescription ?? 'Elective and specialized healthcare treatment',
      'employmentType': effectiveEmp,
    };
    if (facilityId != null && facilityId.isNotEmpty) {
      payload['facilityId'] = facilityId;
    }
    if (treatmentOfferId != null && treatmentOfferId.isNotEmpty) {
      payload['treatmentOfferId'] = treatmentOfferId;
    }
    if (notes != null && notes.isNotEmpty) {
      payload['notes'] = notes;
    }
    if (monthlyIncome != null) {
      payload['monthlyIncome'] = monthlyIncome;
    }
    if (panOrNationalId != null && panOrNationalId.isNotEmpty) {
      payload['panOrNationalId'] = panOrNationalId;
    }

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.financingApply,
      requiresAuth: true,
      body: payload,
      fromJson: (json) => json is Map<String, dynamic> ? json : {'status': 'SUBMITTED'},
    );
  }

  /// Accepts a partner financing offer (initiates underwriting review)
  /// POST /api/v1/financing/offers/:id/accept
  Future<ApiResult<Map<String, dynamic>>> acceptFinancingOffer(
    String offerId, {
    String? notes,
    bool signatureConsent = true,
  }) async {
    final payload = <String, dynamic>{
      'signatureConsent': signatureConsent,
    };
    if (notes != null && notes.isNotEmpty) {
      payload['notes'] = notes;
    }

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.financingOfferAccept(offerId),
      requiresAuth: true,
      body: payload,
      fromJson: (json) => json is Map<String, dynamic> ? json : {'status': 'ACCEPTED'},
    );
  }

  /// Rejects a partner financing offer
  /// POST /api/v1/financing/offers/:id/reject
  Future<ApiResult<Map<String, dynamic>>> rejectFinancingOffer(
    String offerId, {
    String? reason,
  }) async {
    final payload = <String, dynamic>{};
    if (reason != null && reason.isNotEmpty) {
      payload['reason'] = reason;
      payload['declineReason'] = reason;
    }

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.financingOfferReject(offerId),
      requiresAuth: true,
      body: payload,
      fromJson: (json) => json is Map<String, dynamic> ? json : {'status': 'REJECTED'},
    );
  }

  /// Retrieves all financing applications for the current user
  /// GET /api/v1/financing/applications
  Future<ApiResult<List<Map<String, dynamic>>>> getFinancingApplications({
    int page = 1,
    int limit = 20,
  }) async {
    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.financingApplications,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      requiresAuth: true,
      fromJson: (json) {
        final list = (json is Map<String, dynamic> && json.containsKey('data'))
            ? json['data']
            : json;
        if (list is List) {
          return list.whereType<Map<String, dynamic>>().toList();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  /// Retrieves a specific financing application by ID
  /// GET /api/v1/financing/applications/:id
  Future<ApiResult<Map<String, dynamic>>> getFinancingApplicationById(String id) async {
    return _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.financingApplicationById(id),
      requiresAuth: true,
      fromJson: (json) {
        final data = (json is Map<String, dynamic> && json.containsKey('data'))
            ? json['data']
            : json;
        return data is Map<String, dynamic> ? data : <String, dynamic>{};
      },
    );
  }
}
