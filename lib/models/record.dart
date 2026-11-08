class HealthRecordModel {
  final int id;
  final int citizenId;
  final int providerId;
  final int facilityId;
  final DateTime visitDate;
  final String diagnosis;
  final String prescription;
  final String? labResults;
  final String? notes;
  final String? citizenName;
  final String? citizenNationalId;
  final String? providerName;
  final String? facilityName;
  final String? facilityDistrict;
  final String? createdAt;

  HealthRecordModel({
    required this.id,
    required this.citizenId,
    required this.providerId,
    required this.facilityId,
    required this.visitDate,
    required this.diagnosis,
    required this.prescription,
    this.labResults,
    this.notes,
    this.citizenName,
    this.citizenNationalId,
    this.providerName,
    this.facilityName,
    this.facilityDistrict,
    this.createdAt,
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      id: json['id'] as int,
      citizenId: json['citizen_id'] as int,
      providerId: json['provider_id'] as int,
      facilityId: json['facility_id'] as int,
      visitDate: DateTime.tryParse(json['visit_date'] as String? ?? '') ?? DateTime.now(),
      diagnosis: json['diagnosis'] as String? ?? 'General Consultation',
      prescription: json['prescription'] as String? ?? 'No prescriptions',
      labResults: json['lab_results'] as String?,
      notes: json['notes'] as String?,
      citizenName: json['citizen_name'] as String?,
      citizenNationalId: json['citizen_national_id'] as String?,
      providerName: json['provider_name'] as String?,
      facilityName: json['facility_name'] as String?,
      facilityDistrict: json['facility_district'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'citizen_id': citizenId,
      'provider_id': providerId,
      'facility_id': facilityId,
      'visit_date': visitDate.toIso8601String(),
      'diagnosis': diagnosis,
      'prescription': prescription,
      'lab_results': labResults,
      'notes': notes,
      'citizen_name': citizenName,
      'citizen_national_id': citizenNationalId,
      'provider_name': providerName,
      'facility_name': facilityName,
      'facility_district': facilityDistrict,
      'created_at': createdAt,
    };
  }
}
