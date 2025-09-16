import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/patient_model.dart';
import '../models/login_model.dart';

class ApiService {
  static const String baseUrl = 'https://flutter-amr.noviindus.in/api';
  static String? _authToken;
  
 Future<LoginResponse> login(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/Login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'password': password,
      },
    ).timeout(Duration(seconds: 30));
    
    print('Login Response Status: ${response.statusCode}');
    print('Login Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      LoginResponse loginResponse = LoginResponse.fromJson(data);
      
      if (loginResponse.success && loginResponse.token.isNotEmpty) {
        _authToken = loginResponse.token;
      }
      
      return loginResponse;
    } else {
      return LoginResponse(
        success: false,
        message: 'Login failed: ${response.statusCode}',
      );
    }
  } catch (e) {
    print('Login Error: $e');
    return LoginResponse(
      success: false,
      message: 'Login error: $e',
    );
  }
}

  
  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };
  
 Future<List<Patient>> getPatients() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/PatientList'),
      headers: authHeaders,
    ).timeout(Duration(seconds: 30));
    
    print('📊 Patient API Response Status: ${response.statusCode}');
    
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
    } else {
      throw Exception('Server returned ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network Error: $e');
  }
}





  // ADD THIS METHOD - it was missing
  Future<List<Branch>> getBranches() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/BranchList'),
        headers: authHeaders,
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Branch.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load branches');
      }
    } catch (e) {
      throw Exception('Error loading branches: $e');
    }
  }

  // ADD THIS METHOD - it was missing  
  Future<List<Treatment>> getTreatments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/TreatmentList'),
        headers: authHeaders,
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Treatment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load treatments');
      }
    } catch (e) {
      throw Exception('Error loading treatments: $e');
    }
  }

  Future<bool> addPatient(Map<String, String> patientData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/PatientUpdate'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: patientData,
      ).timeout(Duration(seconds: 30));
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error adding patient: $e');
    }
  }
  
  void logout() {
    _authToken = null;
  }
  
  bool get isLoggedIn => _authToken != null;
}
