import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/record.dart';

class RecordService extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  List<HealthRecordModel> _records = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<HealthRecordModel> get records => _records;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyRecords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.dio.get('/citizens/me/records', queryParameters: {
        'page': 1,
        'page_size': 50,
      });

      final items = response.data['items'] as List<dynamic>? ?? [];
      _records = items.map((item) => HealthRecordModel.fromJson(item)).toList();
      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _isLoading = false;
      _errorMessage = e.response?.data?['detail'] ?? 'Could not load medical records.';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading records: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<HealthRecordModel?> getRecordById(int id) async {
    try {
      final response = await _api.dio.get('/records/$id');
      return HealthRecordModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> fetchRecordPdf(int id) async {
    try {
      final response = await _api.dio.get<List<int>>(
        '/records/$id/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null) {
        return Uint8List.fromList(response.data!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
