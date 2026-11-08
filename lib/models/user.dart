import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String nationalId;
  final String dob;
  final String homeVillage;
  final String phone;
  final String role;
  final String status;
  final String identityVerificationStatus;
  final String? facilityId;
  final String? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.nationalId,
    required this.dob,
    required this.homeVillage,
    required this.phone,
    required this.role,
    required this.status,
    this.identityVerificationStatus = 'unverified',
    this.facilityId,
    this.createdAt,
  });

  factory UserModel.fromFirestore(String uid, Map<String, dynamic> data) {
    final created = data['createdAt'];

    String? formattedCreatedAt;

    if (created is Timestamp) {
      formattedCreatedAt = created.toDate().toIso8601String();
    } else if (created is DateTime) {
      formattedCreatedAt = created.toIso8601String();
    } else if (created is String) {
      formattedCreatedAt = created;
    }

    return UserModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      nationalId: data['nationalId'] as String? ?? '',
      dob: data['dob'] as String? ?? '',
      homeVillage: data['homeVillage'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? 'citizen',
      status: data['status'] as String? ?? 'active',
      identityVerificationStatus:
          data['identityVerificationStatus'] as String? ?? 'unverified',
      facilityId: data['facilityId']?.toString(),
      createdAt: formattedCreatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'nationalId': nationalId,
      'dob': dob,
      'homeVillage': homeVillage,
      'phone': phone,
      'role': role,
      'status': status,
      'identityVerificationStatus': identityVerificationStatus,
      'facilityId': facilityId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
