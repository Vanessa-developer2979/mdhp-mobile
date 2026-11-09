
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecordModel {
  // Firestore document ID
  final String id;

  // Firebase UID references
  final String patientUID;
  final String providerUID;
  final String? facilityId;

  final DateTime visitDate;
  final String diagnosis;
  final String prescription;

  final String? labResults;
  final String? notes;

  // Display information
  final String? citizenName;
  final String? citizenNationalId;
  final String? providerName;
  final String? facilityName;
  final String? facilityDistrict;

  final String? createdAt;

  HealthRecordModel({
    required this.id,
    required this.patientUID,
    required this.providerUID,
    this.facilityId,
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

  factory HealthRecordModel.fromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is DateTime) {
        return value;
      }

      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }

      return DateTime.now();
    }

    final created = data['createdAt'];

    String? formattedCreatedAt;

    if (created is Timestamp) {
      formattedCreatedAt = created.toDate().toIso8601String();
    } else if (created is DateTime) {
      formattedCreatedAt = created.toIso8601String();
    } else if (created is String) {
      formattedCreatedAt = created;
    }

    return HealthRecordModel(
      id: documentId,
      patientUID: data['patientUID']?.toString() ?? '',
      providerUID: data['providerUID']?.toString() ?? '',
      facilityId: data['facilityId']?.toString(),
      visitDate: parseDate(data['visitDate']),
      diagnosis: data['diagnosis'] as String? ?? 'General Consultation',
      prescription: data['prescription'] as String? ?? 'No prescriptions',
      labResults: data['labResults'] as String?,
      notes: data['notes'] as String?,
      citizenName: data['citizenName'] as String?,
      citizenNationalId: data['citizenNationalId'] as String?,
      providerName: data['providerName'] as String?,
      facilityName: data['facilityName'] as String?,
      facilityDistrict: data['facilityDistrict'] as String?,
      createdAt: formattedCreatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientUID': patientUID,
      'providerUID': providerUID,
      'facilityId': facilityId,
      'visitDate': Timestamp.fromDate(visitDate),
      'diagnosis': diagnosis,
      'prescription': prescription,
      'labResults': labResults,
      'notes': notes,
      'citizenName': citizenName,
      'citizenNationalId': citizenNationalId,
      'providerName': providerName,
      'facilityName': facilityName,
      'facilityDistrict': facilityDistrict,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
