import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../models/pet_models.dart';

/// Repository for Pet Health Records (Folder 26 in Postman Collection)
class PetRepository {
  final ApiClient _apiClient;

  PetRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /api/v1/pets - List pets owned by current user
  Future<ApiResult<List<PetModel>>> getPets() async {
    return _apiClient.get<List<PetModel>>(
      ApiEndpoints.pets,
      requiresAuth: true,
      fromJson: (json) {
        if (json is List) {
          return json
              .whereType<Map<String, dynamic>>()
              .map((e) => PetModel.fromJson(e))
              .toList();
        } else if (json is Map<String, dynamic> && json['data'] is List) {
          return (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => PetModel.fromJson(e))
              .toList();
        }
        return [];
      },
    );
  }

  /// GET /api/v1/pets/:id - Get pet details by ID
  Future<ApiResult<PetModel>> getPetById(String id) async {
    return _apiClient.get<PetModel>(
      ApiEndpoints.petById(id),
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
          return PetModel.fromJson(data as Map<String, dynamic>);
        }
        throw Exception('Invalid pet JSON structure');
      },
    );
  }

  /// POST /api/v1/pets - Register a new pet profile
  Future<ApiResult<PetModel>> registerPet(PetModel pet) async {
    return _apiClient.post<PetModel>(
      ApiEndpoints.pets,
      body: pet.toJson(),
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
          return PetModel.fromJson(data as Map<String, dynamic>);
        }
        throw Exception('Invalid pet creation response');
      },
    );
  }

  /// PUT /api/v1/pets/:id - Update pet profile demographics
  Future<ApiResult<PetModel>> updatePet(String id, Map<String, dynamic> updates) async {
    return _apiClient.put<PetModel>(
      ApiEndpoints.petById(id),
      body: updates,
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
          return PetModel.fromJson(data as Map<String, dynamic>);
        }
        throw Exception('Invalid pet update response');
      },
    );
  }

  /// DELETE /api/v1/pets/:id - Soft-delete pet profile
  Future<ApiResult<void>> deletePet(String id) async {
    return _apiClient.delete<void>(
      ApiEndpoints.petById(id),
      requiresAuth: true,
    );
  }

  /// GET /api/v1/pets/:id/vaccinations - List vaccinations for pet
  Future<ApiResult<List<PetVaccinationModel>>> getPetVaccinations(String petId) async {
    return _apiClient.get<List<PetVaccinationModel>>(
      ApiEndpoints.petVaccinations(petId),
      requiresAuth: true,
      fromJson: (json) {
        if (json is List) {
          return json
              .whereType<Map<String, dynamic>>()
              .map((e) => PetVaccinationModel.fromJson(e))
              .toList();
        } else if (json is Map<String, dynamic> && json['data'] is List) {
          return (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => PetVaccinationModel.fromJson(e))
              .toList();
        }
        return [];
      },
    );
  }

  /// POST /api/v1/pets/:id/vaccinations - Add vaccination record to pet
  Future<ApiResult<PetVaccinationModel>> addPetVaccination(
      String petId, PetVaccinationModel vaccination) async {
    return _apiClient.post<PetVaccinationModel>(
      ApiEndpoints.petVaccinations(petId),
      body: vaccination.toJson(),
      requiresAuth: true,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
          return PetVaccinationModel.fromJson(data as Map<String, dynamic>);
        }
        throw Exception('Invalid vaccination response');
      },
    );
  }
}

