import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/insurance_policy_models.dart';

/// CareID Insurance Repository
/// Grounded in `19. Insurance Platform & Claims`
class InsuranceRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  InsuranceRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? apiClient?.tokenStorage ?? AppTokenStorage();

  /// Retrieves all insurance policies for current patient
  /// GET /api/v1/insurance/policies
  Future<ApiResult<List<InsurancePolicyDto>>> getPolicies() async {
    _isLoading = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure(
          message: 'Authentication session required. Please sign in.',
          statusCode: 401,
        );
      }

      final result = await _apiClient.get<List<InsurancePolicyDto>>(
        ApiEndpoints.insurancePolicies,
        requiresAuth: true,
        fromJson: (json) {
          if (json is List) {
            return json
                .map((e) => InsurancePolicyDto.fromJson(
                    e is Map<String, dynamic> ? e : <String, dynamic>{}))
                .toList();
          }
          return [];
        },
      );
      return result;
    } finally {
      _isLoading = false;
    }
  }

  /// Retrieves a specific insurance policy details
  /// GET /api/v1/insurance/policies/:id
  Future<ApiResult<InsurancePolicyDto>> getPolicyById(String id) async {
    return _apiClient.get<InsurancePolicyDto>(
      '${ApiEndpoints.insurancePolicies}/$id',
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return InsurancePolicyDto.fromJson(json);
        }
        return const InsurancePolicyDto(id: '', providerName: '', policyNumber: '');
      },
    );
  }

  /// Registers/issues a full insurance policy
  /// POST /api/v1/insurance/policies
  Future<ApiResult<InsurancePolicyDto>> createPolicy(InsurancePolicyDto policy) async {
    return _apiClient.post<InsurancePolicyDto>(
      ApiEndpoints.insurancePolicies,
      requiresAuth: true,
      body: policy.toJson(),
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return InsurancePolicyDto.fromJson(json);
        }
        return policy;
      },
    );
  }

  /// Verifies an insurance policy
  /// POST /api/v1/insurance/policies/:id/verify
  Future<ApiResult<Map<String, dynamic>>> verifyPolicy(String id) async {
    return _apiClient.post<Map<String, dynamic>>(
      '${ApiEndpoints.insurancePolicies}/$id/verify',
      requiresAuth: true,
      fromJson: (json) => json is Map<String, dynamic> ? json : {'status': 'VERIFIED'},
    );
  }

  /// Retrieves all claim drafts/records for current patient
  /// GET /api/v1/insurance/claims
  Future<ApiResult<List<InsuranceClaimDto>>> getClaims() async {
    return _apiClient.get<List<InsuranceClaimDto>>(
      ApiEndpoints.insuranceClaims,
      requiresAuth: true,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => InsuranceClaimDto.fromJson(
                  e is Map<String, dynamic> ? e : <String, dynamic>{}))
              .toList();
        }
        return [];
      },
    );
  }

  /// Submits an insurance card image URL for OCR extraction
  /// POST /api/v1/insurance/ocr/scan
  Future<ApiResult<Map<String, dynamic>>> scanOcr({required String imageUrl}) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.insuranceOcrScan,
      requiresAuth: true,
      body: {'imageUrl': imageUrl},
      fromJson: (json) => json is Map<String, dynamic> ? json : {},
    );
  }

  /// Confirms extracted OCR data to create insurance policy
  /// POST /api/v1/insurance/ocr/confirm
  Future<ApiResult<InsurancePolicyDto>> confirmOcr({
    required String ocrId,
    required String providerName,
    required String policyNumber,
    String? groupNumber,
  }) async {
    return _apiClient.post<InsurancePolicyDto>(
      ApiEndpoints.insuranceOcrConfirm,
      requiresAuth: true,
      body: {
        'ocrId': ocrId,
        'providerName': providerName,
        'policyNumber': policyNumber,
        if (groupNumber != null) 'groupNumber': groupNumber,
      },
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return InsurancePolicyDto.fromJson(json);
        }
        return InsurancePolicyDto(
          id: ocrId,
          providerName: providerName,
          policyNumber: policyNumber,
          groupNumber: groupNumber,
        );
      },
    );
  }

  /// Submits manual review and field corrections for an OCR job
  /// POST /api/v1/ocr/review/:jobId
  Future<ApiResult<Map<String, dynamic>>> submitOcrReview({
    required String jobId,
    required String reviewStatus,
    String? reviewNotes,
    List<Map<String, dynamic>>? corrections,
  }) async {
    final payload = <String, dynamic>{
      'reviewStatus': reviewStatus,
      'reviewNotes': reviewNotes ?? 'Manual review verified by user',
    };
    if (corrections != null) {
      payload['corrections'] = corrections;
    }
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.ocrReviewById(jobId),
      requiresAuth: true,
      body: payload,
      fromJson: (json) => json is Map<String, dynamic> ? json : {'status': 'REVIEWED'},
    );
  }

  /// Lists active insurance providers
  /// GET /api/v1/insurance/providers
  Future<ApiResult<List<Map<String, dynamic>>>> getProviders() async {
    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.insuranceProviders,
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

  /// Lists insurance plans (supports providerId filter)
  /// GET /api/v1/insurance/plans
  Future<ApiResult<List<Map<String, dynamic>>>> getPlans({String? providerId}) async {
    final query = providerId != null && providerId.isNotEmpty
        ? {'providerId': providerId}
        : null;
    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.insurancePlans,
      queryParams: query,
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

  /// Retrieves platform-wide insurance statistics
  /// GET /api/v1/insurance/statistics
  Future<ApiResult<Map<String, dynamic>>> getStatistics() async {
    return _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.insuranceStatistics,
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return (json['data'] is Map<String, dynamic>)
              ? json['data'] as Map<String, dynamic>
              : json;
        }
        return <String, dynamic>{};
      },
    );
  }

  /// Retrieves all insurance cards for a specific patient
  /// GET /api/v1/patients/:id/insurance-cards
  Future<ApiResult<List<Map<String, dynamic>>>> getInsuranceCards(String patientId) async {
    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.patientInsuranceCards(patientId),
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
}

