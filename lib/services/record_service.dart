import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/record.dart';

class RecordService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<HealthRecordModel> _records = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<HealthRecordModel> get records => _records;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyRecords() async {
    final user = _auth.currentUser;

    if (user == null) {
      _records = [];
      _errorMessage = 'Please log in to view your medical records.';
      _isLoading = false;
      debugPrint('RECORD FETCH ERROR: No authenticated user.');
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint('RECORD FETCH: Starting...');
    debugPrint('RECORD FETCH: Current patient UID = ${user.uid}');

    try {
      final snapshot = await _firestore
          .collection('medical_records')
          .where('patientUID', isEqualTo: user.uid)
          .orderBy('visitDate', descending: true)
          .limit(50)
          .get();

      debugPrint(
        'RECORD FETCH SUCCESS: Firestore returned ${snapshot.docs.length} records.',
      );

      for (final document in snapshot.docs) {
        debugPrint('RECORD FETCH DOCUMENT: ${document.id}');
        debugPrint(
          'RECORD FETCH PATIENT UID: ${document.data()['patientUID']}',
        );
      }

      _records = snapshot.docs.map((document) {
        return HealthRecordModel.fromFirestore(
          document.id,
          document.data(),
        );
      }).toList();

      _errorMessage = null;
    } on FirebaseException catch (e) {
      debugPrint('RECORD FETCH FIREBASE ERROR: ${e.code}');
      debugPrint('RECORD FETCH MESSAGE: ${e.message}');

      _errorMessage = e.code == 'permission-denied'
          ? 'You do not have permission to access these medical records.'
          : 'Could not load medical records: ${e.message ?? e.code}';
    } catch (e) {
      debugPrint('RECORD FETCH GENERAL ERROR: $e');
      _errorMessage = 'Error loading medical records: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<HealthRecordModel?> getRecordById(Object id) async {
    final user = _auth.currentUser;

    if (user == null) {
      _errorMessage = 'Please log in to view this medical record.';
      debugPrint('RECORD DETAIL ERROR: No authenticated user.');
      notifyListeners();
      return null;
    }

    try {
      debugPrint('RECORD DETAIL: Retrieving document $id');

      final document = await _firestore
          .collection('medical_records')
          .doc(id.toString())
          .get();

      if (!document.exists) {
        debugPrint('RECORD DETAIL: Document does not exist.');
        return null;
      }

      final data = document.data();

      if (data == null || data['patientUID'] != user.uid) {
        debugPrint('RECORD DETAIL: Patient UID does not match.');
        return null;
      }

      debugPrint('RECORD DETAIL SUCCESS: ${document.id}');

      return HealthRecordModel.fromFirestore(
        document.id,
        data,
      );
    } on FirebaseException catch (e) {
      debugPrint('RECORD DETAIL FIREBASE ERROR: ${e.code}');
      debugPrint('RECORD DETAIL MESSAGE: ${e.message}');

      _errorMessage =
          'Could not retrieve medical record: ${e.message ?? e.code}';
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('RECORD DETAIL GENERAL ERROR: $e');

      _errorMessage = 'Error retrieving medical record: $e';
      notifyListeners();
      return null;
    }
  }

  // PDF generation will be implemented through a trusted backend
  // or an authorised document-generation service.
  Future<Uint8List?> fetchRecordPdf(Object id) async {
    return null;
  }
}