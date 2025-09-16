import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/login_model.dart';

class LoginProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      LoginResponse response = await _apiService.login(username, password);
      
      // Fix null check issue
      if (response.success == true) {
        _isLoggedIn = true;
        _error = null;
        return true;
      } else {
        _error = response.message.isNotEmpty ? response.message : 'Login failed';
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void logout() {
    _apiService.logout();
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
