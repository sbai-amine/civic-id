import 'package:flutter/foundation.dart';

import '../models/register_request.dart';
import '../models/register_result.dart';
import '../services/api_service.dart';

class RegisterController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<RegisterResult> register(RegisterRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await ApiService().register(request);
      if (result is RegisterFailure) {
        _errorMessage = result.message;
      }
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
