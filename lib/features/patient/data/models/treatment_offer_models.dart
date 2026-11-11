/// CareID Patient App — Treatment Offer Domain Models
/// Grounded strictly in OpenAPI 3.0.0 and Postman Collection Section 45
class ProcedureItemModel {
  final String id;
  final String procedureCode;
  final String procedureName;
  final String category;
  final int quantity;
  final double unitCost;
  final double totalCost;
  final bool isOptional;
  final String? clinicalJustification;

  const ProcedureItemModel({
    required this.id,
    required this.procedureCode,
    required this.procedureName,
    required this.category,
    this.quantity = 1,
    required this.unitCost,
    required this.totalCost,
    this.isOptional = false,
    this.clinicalJustification,
  });

  factory ProcedureItemModel.fromJson(Map<String, dynamic> json) {
    return ProcedureItemModel(
      id: json['id']?.toString() ?? '',
      procedureCode: json['procedureCode']?.toString() ?? '',
      procedureName: json['procedureName']?.toString() ?? '',
      category: json['category']?.toString() ?? 'SURGICAL',
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : 1,
      unitCost: (json['unitCost'] is num) ? (json['unitCost'] as num).toDouble() : 0.0,
      totalCost: (json['totalCost'] is num) ? (json['totalCost'] as num).toDouble() : 0.0,
      isOptional: json['isOptional'] == true,
      clinicalJustification: json['clinicalJustification']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'procedureCode': procedureCode,
      'procedureName': procedureName,
      'category': category,
      'quantity': quantity,
      'unitCost': unitCost,
      'totalCost': totalCost,
      'isOptional': isOptional,
      'clinicalJustification': clinicalJustification,
    };
  }
}

class TreatmentOfferModel {
  final String id;
  final String offerNumber;
  final String patientProfileId;
  final String doctorId;
  final String facilityId;
  final String clinicalIndication;
  final double totalProceduresCost;
  final double discountAmount;
  final double netPayableCost;
  final bool financingEligible;
  final int recommendedTenureMonths;
  final String status;
  final String validUntil;
  final String? clinicalNotes;
  final String? termsAndConditions;
  final int version;
  final List<ProcedureItemModel> procedures;
  final String? doctorName;
  final String? doctorSpecialization;
  final String? facilityName;

  const TreatmentOfferModel({
    required this.id,
    required this.offerNumber,
    required this.patientProfileId,
    required this.doctorId,
    required this.facilityId,
    required this.clinicalIndication,
    required this.totalProceduresCost,
    required this.discountAmount,
    required this.netPayableCost,
    this.financingEligible = false,
    this.recommendedTenureMonths = 12,
    required this.status,
    required this.validUntil,
    this.clinicalNotes,
    this.termsAndConditions,
    this.version = 1,
    this.procedures = const [],
    this.doctorName,
    this.doctorSpecialization,
    this.facilityName,
  });

  factory TreatmentOfferModel.fromJson(Map<String, dynamic> json) {
    final proceduresList = (json['procedures'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => ProcedureItemModel.fromJson(e))
            .toList() ??
        [];

    final doctorObj = json['doctor'] as Map<String, dynamic>?;
    final facilityObj = json['facility'] as Map<String, dynamic>?;

    return TreatmentOfferModel(
      id: json['id']?.toString() ?? '',
      offerNumber: json['offerNumber']?.toString() ?? '',
      patientProfileId: json['patientProfileId']?.toString() ?? '',
      doctorId: json['doctorId']?.toString() ?? '',
      facilityId: json['facilityId']?.toString() ?? '',
      clinicalIndication: json['clinicalIndication']?.toString() ?? '',
      totalProceduresCost: (json['totalProceduresCost'] is num) ? (json['totalProceduresCost'] as num).toDouble() : 0.0,
      discountAmount: (json['discountAmount'] is num) ? (json['discountAmount'] as num).toDouble() : 0.0,
      netPayableCost: (json['netPayableCost'] is num) ? (json['netPayableCost'] as num).toDouble() : 0.0,
      financingEligible: json['financingEligible'] == true,
      recommendedTenureMonths: (json['recommendedTenureMonths'] is num) ? (json['recommendedTenureMonths'] as num).toInt() : 12,
      status: json['status']?.toString() ?? 'DISPATCHED',
      validUntil: json['validUntil']?.toString() ?? '',
      clinicalNotes: json['clinicalNotes']?.toString(),
      termsAndConditions: json['termsAndConditions']?.toString(),
      version: (json['version'] is num) ? (json['version'] as num).toInt() : 1,
      procedures: proceduresList,
      doctorName: doctorObj?['fullName']?.toString() ?? doctorObj?['name']?.toString(),
      doctorSpecialization: doctorObj?['primarySpecialization']?.toString() ?? doctorObj?['specialization']?.toString(),
      facilityName: facilityObj?['name']?.toString(),
    );
  }

  Map<String, dynamic> toOfferMap() {
    return {
      'id': id,
      'offerNumber': offerNumber,
      'title': clinicalIndication.isNotEmpty ? clinicalIndication : 'Comprehensive Treatment Plan ($offerNumber)',
      'specialty': doctorSpecialization ?? 'Specialized Care',
      'clinic': facilityName ?? 'CareID Network Facility',
      'doctor': doctorName ?? 'Assigned Specialist',
      'standardPrice': totalProceduresCost > 0 ? totalProceduresCost : netPayableCost + discountAmount,
      'careIdPrice': netPayableCost > 0 ? netPayableCost : totalProceduresCost,
      'savings': discountAmount > 0 ? discountAmount : (totalProceduresCost - netPayableCost),
      'monthlyRate': recommendedTenureMonths > 0 ? (netPayableCost / recommendedTenureMonths) : netPayableCost,
      'tenure': recommendedTenureMonths > 0 ? recommendedTenureMonths : 12,
      'status': status,
      'version': version,
      'validUntil': validUntil,
      'procedures': procedures.map((p) => p.toJson()).toList(),
      'financingEligible': financingEligible,
    };
  }
}

