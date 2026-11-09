import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/record.dart';

class QrService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isResolving = false;
  String? _errorMessage;

  bool get isResolving => _isResolving;
  String? get errorMessage => _errorMessage;

  Future<HealthRecordModel?> resolveQrToken(String qrToken) async {
    _isResolving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;

      if (user == null) {
        _errorMessage = 'Please log in before scanning a medical record.';
        return null;
      }

      final recordId = qrToken.trim();

      if (recordId.isEmpty || recordId.contains('/')) {
        _errorMessage =
            'The QR code does not contain a valid medical record ID.';
        return null;
      }

      final document = await _firestore
          .collection('medical_records')
          .doc(recordId)
          .get();

      if (!document.exists) {
        _errorMessage = 'This medical record could not be found.';
        return null;
      }

      final data = document.data();

      if (data == null) {
        _errorMessage = 'The medical record contains no data.';
        return null;
      }

      // Confirm that the record belongs to the signed-in patient.
      if (data['patientUID']?.toString() != user.uid) {
        _errorMessage =
            'Access denied. This medical record does not belong to your account.';
        return null;
      }

      return HealthRecordModel.fromFirestore(document.id, data);
    } on FirebaseException catch (e) {
      _errorMessage = e.code == 'permission-denied'
          ? 'You do not have permission to access this medical record.'
          : 'Could not retrieve medical record: ${e.message ?? e.code}';

      return null;
    } catch (e) {
      _errorMessage = 'QR retrieval error: $e';
      return null;
    } finally {
      _isResolving = false;
      notifyListeners();
    }
  }
}
