import 'dart:convert';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/medical_record_models.dart';

/// CareID Medical Records Repository
/// Grounded in `08. Medical Records (General, Dental & Vision)`
class MedicalRecordsRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MedicalRecordsRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
      : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? apiClient?.tokenStorage ?? AppTokenStorage();

  /// Retrieves all medical records for the authenticated patient
  /// GET /api/v1/medical-records
  Future<ApiResult<List<MedicalRecordDto>>> getMedicalRecords() async {
    _isLoading = true;
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiFailure(
          message: 'Authentication session required. Please sign in.',
          statusCode: 401,
        );
      }

      final result = await _apiClient.get<List<MedicalRecordDto>>(
        ApiEndpoints.medicalRecords,
        requiresAuth: true,
        fromJson: (json) {
          if (json is List) {
            return json
                .map((e) => MedicalRecordDto.fromJson(
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

  /// Searches medical records by query text
  /// GET /api/v1/medical-records/search?q=query
  Future<ApiResult<List<MedicalRecordDto>>> searchRecords(String query) async {
    return _apiClient.get<List<MedicalRecordDto>>(
      ApiEndpoints.medicalRecordsSearch,
      queryParams: {'q': query},
      requiresAuth: true,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => MedicalRecordDto.fromJson(
                  e is Map<String, dynamic> ? e : <String, dynamic>{}))
              .toList();
        }
        return [];
      },
    );
  }

  /// Retrieves unified medical timeline
  /// GET /api/v1/medical-records/timeline
  Future<ApiResult<List<MedicalTimelineItemDto>>> getTimeline() async {
    return _apiClient.get<List<MedicalTimelineItemDto>>(
      ApiEndpoints.medicalRecordsTimeline,
      requiresAuth: true,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => MedicalTimelineItemDto.fromJson(
                  e is Map<String, dynamic> ? e : <String, dynamic>{}))
              .toList();
        }
        return [];
      },
    );
  }

  /// Retrieves a specific medical record by ID
  /// GET /api/v1/medical-records/:id
  Future<ApiResult<MedicalRecordDto>> getRecordById(String id) async {
    return _apiClient.get<MedicalRecordDto>(
      '${ApiEndpoints.medicalRecords}/$id',
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return MedicalRecordDto.fromJson(json);
        }
        return const MedicalRecordDto(id: '', title: '');
      },
    );
  }

  /// Creates a new medical record
  /// POST /api/v1/medical-records
  Future<ApiResult<MedicalRecordDto>> createRecord(MedicalRecordDto record) async {
    final payload = {
      'title': record.title,
      'chiefComplaint': record.chiefComplaint ?? 'Routine clinical examination',
      'clinicalNotes': record.clinicalNotes ?? 'Recorded via CareID Patient App',
      if (record.treatmentPlan != null && record.treatmentPlan!.isNotEmpty)
        'treatmentPlan': record.treatmentPlan,
      'status': record.status.toUpperCase() == 'ACTIVE' ? 'FINAL' : record.status,
      if (record.diagnosis != null && record.diagnosis!.isNotEmpty)
        'diagnoses': [
          {
            'description': record.diagnosis,
            'code': 'Z00.00',
            'type': 'PRIMARY',
            'status': 'ACTIVE',
          }
        ],
    };

    return _apiClient.post<MedicalRecordDto>(
      ApiEndpoints.medicalRecords,
      requiresAuth: true,
      body: payload,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return MedicalRecordDto.fromJson(json);
        }
        return record;
      },
    );
  }

  /// Uploads and links an attachment to a specific medical record
  /// POST /api/v1/medical-records/:id/attachments
  Future<ApiResult<Map<String, dynamic>>> uploadRecordAttachment(
    String recordId, {
    required String fileName,
    required String originalName,
    required int fileSize,
    required String mimeType,
    String? storageKey,
    String? storageUrl,
  }) async {
    final payload = {
      'fileName': fileName,
      'originalName': originalName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'storageKey': storageKey ?? 'attachments/${DateTime.now().year}/$fileName',
      'storageUrl': storageUrl ?? 'https://360api.vnvision.in/attachments/$fileName',
    };

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.recordAttachments(recordId),
      requiresAuth: true,
      body: payload,
      fromJson: (json) => json is Map<String, dynamic> ? json : {'status': 'SUCCESS'},
    );
  }

  /// Submits medical document image for OCR extraction
  /// POST /api/v1/ai/ocr/extract
  Future<ApiResult<Map<String, dynamic>>> extractMedicalDocumentOcr({
    required String imageUrl,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.aiOcrExtract,
      requiresAuth: true,
      body: {'imageUrl': imageUrl},
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return json;
        }
        return <String, dynamic>{};
      },
    );
  }

  /// Confirms extracted OCR candidate fields
  /// POST /api/v1/ai/ocr/confirm
  Future<ApiResult<Map<String, dynamic>>> confirmMedicalDocumentOcr({
    required String documentId,
    required Map<String, dynamic> confirmedData,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.aiOcrConfirm,
      requiresAuth: true,
      body: {
        'documentId': documentId,
        'confirmedData': jsonEncode(confirmedData),
      },
      fromJson: (json) => json is Map<String, dynamic> ? json : {},
    );
  }
}

