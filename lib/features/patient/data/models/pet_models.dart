/// Pet Health Records Models & DTOs
/// Grounded strictly in the CareID Postman Collection (Folder 26. Pet Health Records)
class PetVaccinationModel {
  final String id;
  final String petId;
  final String vaccineName;
  final String administeredDate;
  final String dueDate;
  final String? batchNumber;
  final String? veterinarian;
  final String? clinicName;
  final String? notes;
  final String? createdAt;

  const PetVaccinationModel({
    required this.id,
    required this.petId,
    required this.vaccineName,
    required this.administeredDate,
    required this.dueDate,
    this.batchNumber,
    this.veterinarian,
    this.clinicName,
    this.notes,
    this.createdAt,
  });

  factory PetVaccinationModel.fromJson(Map<String, dynamic> json) {
    return PetVaccinationModel(
      id: json['id']?.toString() ?? '',
      petId: json['petId']?.toString() ?? '',
      vaccineName: json['vaccineName']?.toString() ?? 'Vaccine',
      administeredDate: json['administeredDate']?.toString() ?? '',
      dueDate: json['dueDate']?.toString() ?? '',
      batchNumber: json['batchNumber']?.toString(),
      veterinarian: json['veterinarian']?.toString(),
      clinicName: json['clinicName']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vaccineName': vaccineName,
      'administeredDate': administeredDate,
      'dueDate': dueDate,
      if (batchNumber != null) 'batchNumber': batchNumber,
      if (veterinarian != null) 'veterinarian': veterinarian,
      if (clinicName != null) 'clinicName': clinicName,
      if (notes != null) 'notes': notes,
    };
  }
}

class PetModel {
  final String id;
  final String? ownerUserId;
  final String name;
  final String species;
  final String? breed;
  final double? age;
  final String? dob;
  final String? gender;
  final double? weight;
  final String? microchipId;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;
  final List<PetVaccinationModel> vaccinations;

  const PetModel({
    required this.id,
    this.ownerUserId,
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.dob,
    this.gender,
    this.weight,
    this.microchipId,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.vaccinations = const [],
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    final rawVac = json['vaccinations'];
    List<PetVaccinationModel> vacList = [];
    if (rawVac is List) {
      vacList = rawVac
          .whereType<Map<String, dynamic>>()
          .map((v) => PetVaccinationModel.fromJson(v))
          .toList();
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return PetModel(
      id: json['id']?.toString() ?? '',
      ownerUserId: json['ownerUserId']?.toString(),
      name: json['name']?.toString() ?? 'Pet',
      species: json['species']?.toString() ?? 'CANINE',
      breed: json['breed']?.toString(),
      age: parseDouble(json['age']),
      dob: json['dob']?.toString(),
      gender: json['gender']?.toString(),
      weight: parseDouble(json['weight']),
      microchipId: json['microchipId']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      vaccinations: vacList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      if (breed != null) 'breed': breed,
      if (age != null) 'age': age,
      if (dob != null) 'dob': dob,
      if (gender != null) 'gender': gender,
      if (weight != null) 'weight': weight,
      if (microchipId != null) 'microchipId': microchipId,
      if (notes != null) 'notes': notes,
    };
  }
}

