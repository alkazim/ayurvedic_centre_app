import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/patient_model.dart';
import '../models/login_model.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // ✅ Direct API (no proxy)
  static const String baseUrl = 'https://flutter-amr.noviindus.in/api';
  static String? _authToken;
  
  Future<LoginResponse> login(String username, String password) async {
    try {
      print('🔄 Starting login process...');
      print('🌐 Platform: ${kIsWeb ? "Web Browser" : "Mobile Device"}');
      print('🔗 API URL: $baseUrl/Login'); // Should show direct URL now
      
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };
      
      final body = {
        'username': username,
        'password': password,
      };
      
      print('📤 Sending request to direct API...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/Login'),
        headers: headers,
        body: body,
      ).timeout(Duration(seconds: 30));
      
      print('📊 Response Status Code: ${response.statusCode}');
      print('📝 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        LoginResponse loginResponse = LoginResponse.fromJson(data);
        
        if (loginResponse.success && loginResponse.token.isNotEmpty) {
          _authToken = loginResponse.token;
          print('✅ Login successful - Token saved');
        }
        
        return loginResponse;
      } else {
        return LoginResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Login Error: $e');
      
      String errorMessage;
      if (e.toString().contains('Failed to fetch') || 
          e.toString().contains('ClientException') ||
          e.toString().contains('CORS')) {
        errorMessage = kIsWeb 
            ? 'CORS Error: Please ensure you are running Edge with disabled security flags'
            : 'Network error: Please check your internet connection';
      } else {
        errorMessage = 'Login error: ${e.toString()}';
      }
      
      return LoginResponse(
        success: false,
        message: errorMessage,
      );
    }
  }
  
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Map<String, String> get formHeaders => {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<List<Patient>> getPatients() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/PatientList'),
        headers: headers,
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        List<dynamic> data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('patient')) {
            data = responseData['patient'] as List<dynamic>;
            print('✅ Found ${data.length} total patients from API');
          } else {
            throw Exception('Unable to find patient array in response');
          }
        } else {
          throw Exception('Unexpected response format');
        }
        
        List<Patient> patients = data.map((json) => Patient.fromJson(json)).toList();
        return patients;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get Patients Error: $e');
      throw Exception('Network Error: $e');
    }
  }

  Future<bool> addPatient(Map<String, String> patientData) async {
    try {
      print('🚀 ApiService: Adding patient (${kIsWeb ? "Web" : "Mobile"})');
      
      Map<String, String> cleanData = Map<String, String>.from(patientData);
      cleanData.remove('id');
      
      print('🔍 Clean data: $cleanData');
      
      var response = await http.post(
        Uri.parse('$baseUrl/PatientUpdate'),
        headers: formHeaders,
        body: cleanData,
      ).timeout(Duration(seconds: 30));
      
      print('📊 Response Status: ${response.statusCode}');
      print('📝 Response: ${response.body.length > 300 ? response.body.substring(0, 300) + "..." : response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Patient added successfully');
        return true;
      }
      
      return false;
      
    } catch (e) {
      print('❌ ApiService: Exception occurred - $e');
      return false;
    }
  }

  void logout() {
    _authToken = null;
  }
  
  bool get isLoggedIn => _authToken != null;
}
