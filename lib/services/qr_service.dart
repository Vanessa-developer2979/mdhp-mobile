import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/record.dart';

class QrService extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  bool _isResolving = false;
  String? _errorMessage;

  bool get isResolving => _isResolving;
  String? get errorMessage => _errorMessage;

  Future<HealthRecordModel?> resolveQrToken(String qrToken) async {
    _isResolving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.dio.post('/qr/resolve', data: {
        'qr_token': qrToken.trim(),
      });

      _isResolving = false;
      notifyListeners();
      return HealthRecordModel.fromJson(response.data);
    } on DioException catch (e) {
      _isResolving = false;
      _errorMessage = e.response?.data?['detail'] ?? 'Failed to authenticate and decrypt QR token.';
      notifyListeners();
      return null;
    } catch (e) {
      _isResolving = false;
      _errorMessage = 'Resolution error: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
}
