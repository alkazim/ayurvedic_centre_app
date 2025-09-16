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
      print('🔗 API URL: $baseUrl/Login');
      
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

  // ⚡ Get branches from API
  Future<List<Branch>> getBranches() async {
    try {
      print('🔄 Loading branches from BranchList API...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/BranchList'),
        headers: headers,
      ).timeout(Duration(seconds: 30));
      
      print('📊 BranchList Response Status: ${response.statusCode}');
      print('📝 BranchList Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        List<dynamic> data;
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map<String, dynamic>) {
          data = responseData['branches'] ?? responseData['data'] ?? [responseData];
        } else {
          throw Exception('Unexpected branch response format');
        }
        
        List<Branch> branches = data.map((json) => Branch.fromJson(json)).toList();
        print('✅ Loaded ${branches.length} branches from API');
        return branches;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get Branches Error: $e');
      throw Exception('Error loading branches: $e');
    }
  }

  // ⚡ Get treatments from API
  Future<List<Treatment>> getTreatments() async {
    try {
      print('🔄 Loading treatments from TreatmentList API...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/TreatmentList'),
        headers: headers,
      ).timeout(Duration(seconds: 30));
      
      print('📊 TreatmentList Response Status: ${response.statusCode}');
      print('📝 TreatmentList Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        List<dynamic> data;
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map<String, dynamic>) {
          data = responseData['treatments'] ?? responseData['data'] ?? [responseData];
        } else {
          throw Exception('Unexpected treatment response format');
        }
        
        List<Treatment> treatments = data.map((json) => Treatment.fromJson(json)).toList();
        print('✅ Loaded ${treatments.length} treatments from API');
        return treatments;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get Treatments Error: $e');
      throw Exception('Error loading treatments: $e');
    }
  }

  // ⚡ FIXED: Add Patient method with correct field handling
  // Replace your addPatient method in ApiService with this:
Future<bool> addPatient(Map<String, String> patientData) async {
  try {
    print('🚀 ApiService: Adding patient with JSON approach');
    
    // Create JSON payload instead of form data
    Map<String, dynamic> jsonData = {
      'id': null,  // Use null instead of empty string
      'name': patientData['name'] ?? '',
      'excecutive': patientData['excecutive'] ?? '',  
      'payment': patientData['payment'] ?? '',
      'phone': patientData['phone'] ?? '',
      'address': patientData['address'] ?? '',
      'total_amount': int.tryParse(patientData['total_amount'] ?? '0') ?? 0,
      'discount_amount': int.tryParse(patientData['discount_amount'] ?? '0') ?? 0,
      'advance_amount': int.tryParse(patientData['advance_amount'] ?? '0') ?? 0,
      'balance_amount': int.tryParse(patientData['balance_amount'] ?? '0') ?? 0,
      'date_nd_time': patientData['date_nd_time'] ?? '',
      'male': int.tryParse(patientData['male'] ?? '0') ?? 0,
      'female': int.tryParse(patientData['female'] ?? '0') ?? 0,
      'branch': patientData['branch'] ?? '',
      'treatments': patientData['treatments'] ?? '',
    };
    
    print('🔍 JSON payload: ${json.encode(jsonData)}');
    
    var response = await http.post(
      Uri.parse('$baseUrl/PatientUpdate'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
      body: json.encode(jsonData),
    ).timeout(Duration(seconds: 30));
    
    print('📊 JSON Response Status: ${response.statusCode}');
    print('📝 JSON Response Body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Patient added successfully with JSON');
      return true;
    } else {
      print('❌ JSON failed, trying different endpoint...');
      return await _tryDifferentEndpoint(patientData);
    }
    
  } catch (e) {
    print('❌ JSON approach failed: $e');
    return await _tryDifferentEndpoint(patientData);
  }
}

// Try different endpoint
Future<bool> _tryDifferentEndpoint(Map<String, String> patientData) async {
  try {
    print('🔄 Trying PatientCreate endpoint...');
    
    // Try without id field completely
    Map<String, String> simpleData = {
      'name': patientData['name'] ?? '',
      'excecutive': patientData['excecutive'] ?? '',  
      'payment': patientData['payment'] ?? '',
      'phone': patientData['phone'] ?? '',
      'address': patientData['address'] ?? '',
      'total_amount': patientData['total_amount'] ?? '0',
      'discount_amount': patientData['discount_amount'] ?? '0',
      'advance_amount': patientData['advance_amount'] ?? '0',
      'balance_amount': patientData['balance_amount'] ?? '0',
      'date_nd_time': patientData['date_nd_time'] ?? '',
      'male': patientData['male'] ?? '0',
      'female': patientData['female'] ?? '0',
      'branch': patientData['branch'] ?? '',
      'treatments': patientData['treatments'] ?? '',
    };
    
    // Try different endpoints
    List<String> endpointsToTry = [
      '$baseUrl/PatientCreate',
      '$baseUrl/PatientAdd', 
      '$baseUrl/AddPatient',
      '$baseUrl/CreatePatient',
    ];
    
    for (String endpoint in endpointsToTry) {
      print('🔄 Trying endpoint: $endpoint');
      
      var response = await http.post(
        Uri.parse(endpoint),
        headers: formHeaders,
        body: simpleData,
      ).timeout(Duration(seconds: 30));
      
      print('📊 $endpoint Response: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Success with endpoint: $endpoint');
        return true;
      } else if (response.statusCode != 404) {
        print('📝 $endpoint Response Body: ${response.body}');
      }
    }
    
    // Last resort - try original endpoint with branch ID
    return await _tryWithBranchId(patientData);
    
  } catch (e) {
    print('❌ Different endpoints failed: $e');
    return await _tryWithBranchId(patientData);
  }
}

// Try with branch ID instead of branch name
// Final fix - add id field properly
Future<bool> _tryWithBranchId(Map<String, String> patientData) async {
  try {
    print('🔄 Final attempt - using branch ID with id field...');
    
    // Convert branch name to ID
    String branchId = _getBranchId(patientData['branch'] ?? '');
    
    // ⚡ CRITICAL: Build the form data with 'id' field included
    Map<String, String> formData = {
      'id': '',  // ⚡ MUST INCLUDE THIS - Django expects it
      'name': patientData['name'] ?? '',
      'excecutive': patientData['excecutive'] ?? '',  
      'payment': patientData['payment'] ?? '',
      'phone': patientData['phone'] ?? '',
      'address': patientData['address'] ?? '',
      'total_amount': patientData['total_amount'] ?? '0',
      'discount_amount': patientData['discount_amount'] ?? '0',
      'advance_amount': patientData['advance_amount'] ?? '0',
      'balance_amount': patientData['balance_amount'] ?? '0',
      'date_nd_time': patientData['date_nd_time'] ?? '',
      'male': patientData['male'] ?? '0',
      'female': patientData['female'] ?? '0',
      'branch': branchId,  // ⚡ Use branch ID (1,2,3,4) not name
      'treatments': patientData['treatments'] ?? '',
    };
    
    print('🔍 Final form data with id and branch ID: $formData');
    
    var response = await http.post(
      Uri.parse('$baseUrl/PatientUpdate'),
      headers: formHeaders,
      body: formData,  // ⚡ Send as Map directly (not manual string)
    ).timeout(Duration(seconds: 30));
    
    print('📊 Final Response: ${response.statusCode}');
    print('📝 Final Response Body: ${response.body}');
    
    return response.statusCode == 200 || response.statusCode == 201;
    
  } catch (e) {
    print('❌ Final attempt failed: $e');
    return false;
  }
}



// Helper to convert branch name to ID
String _getBranchId(String branchName) {
  switch (branchName.toLowerCase()) {
    case 'nadakkavu':
      return '1';
    case 'thondayadu':
      return '2';
    case 'edappali':
      return '3';
    case 'kumarakom':
      return '4';
    default:
      return '1'; // Default branch ID
  }
}


  // ⚡ FIXED: Manual encoding method with proper field order
  Future<bool> _sendPatientData(Map<String, String> formData) async {
    try {
      print('🔄 Encoding patient data for API...');
      
      // ⚡ CRITICAL FIX: Build form body with 'id' first, then other fields
      List<String> bodyParts = [];
      
      // Add empty 'id' field FIRST for new patient creation
      bodyParts.add('id=');
      
      // Add other fields in specific order (NEVER include 'id' in this list)
      List<String> fieldOrder = [
        'name', 'excecutive', 'payment', 'phone', 'address',
        'total_amount', 'discount_amount', 'advance_amount', 'balance_amount',
        'date_nd_time', 'male', 'female', 'branch', 'treatments'
      ];
      
      for (String field in fieldOrder) {
        String value = formData[field] ?? '';
        bodyParts.add('$field=${Uri.encodeComponent(value)}');
      }
      
      String body = bodyParts.join('&');
      print('🔍 Final encoded body: $body');
      
      var response = await http.post(
        Uri.parse('$baseUrl/PatientUpdate'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Accept': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: body,
      ).timeout(Duration(seconds: 30));
      
      print('📊 Response Status: ${response.statusCode}');
      print('📝 Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Patient added successfully');
        return true;
      } else {
        print('❌ Server error: ${response.statusCode} - ${response.body}');
        return false;
      }
      
    } catch (e) {
      print('❌ Patient data encoding failed: $e');
      return false;
    }
  }

  // ⚡ UPDATE: Update patient method (for editing existing patients)
  Future<bool> updatePatient(String patientId, Map<String, String> patientData) async {
    try {
      print('🔄 ApiService: Updating patient ID: $patientId');
      
      // Clean data for update (includes the patient ID)
      Map<String, String> cleanData = {
        'name': patientData['name'] ?? '',
        'excecutive': patientData['excecutive'] ?? '',  
        'payment': patientData['payment'] ?? '',
        'phone': patientData['phone'] ?? '',
        'address': patientData['address'] ?? '',
        'total_amount': patientData['total_amount'] ?? '0',
        'discount_amount': patientData['discount_amount'] ?? '0',
        'advance_amount': patientData['advance_amount'] ?? '0',
        'balance_amount': patientData['balance_amount'] ?? '0',
        'date_nd_time': patientData['date_nd_time'] ?? '',
        'male': patientData['male'] ?? '0',
        'female': patientData['female'] ?? '0',
        'branch': patientData['branch'] ?? '',
        'treatments': patientData['treatments'] ?? '',
      };
      
      // Build form body with patient ID first
      List<String> bodyParts = [];
      bodyParts.add('id=${Uri.encodeComponent(patientId)}'); // Use actual patient ID
      
      List<String> fieldOrder = [
        'name', 'excecutive', 'payment', 'phone', 'address',
        'total_amount', 'discount_amount', 'advance_amount', 'balance_amount',
        'date_nd_time', 'male', 'female', 'branch', 'treatments'
      ];
      
      for (String field in fieldOrder) {
        String value = cleanData[field] ?? '';
        bodyParts.add('$field=${Uri.encodeComponent(value)}');
      }
      
      String body = bodyParts.join('&');
      print('🔍 Update body: $body');
      
      var response = await http.post(
        Uri.parse('$baseUrl/PatientUpdate'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Accept': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: body,
      ).timeout(Duration(seconds: 30));
      
      print('📊 Update Response: ${response.statusCode}');
      print('📝 Update Body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
      
    } catch (e) {
      print('❌ Patient update failed: $e');
      return false;
    }
  }

  void logout() {
    _authToken = null;
    print('👋 User logged out - Token cleared');
  }
  
  bool get isLoggedIn => _authToken != null;
}
