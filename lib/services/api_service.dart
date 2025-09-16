import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient_model.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-url.com'; // Replace with your API URL
  
  // GET Patient List
  Future<List<Patient>> getPatients() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/PatientList'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Patient.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load patients');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // GET Branch List
  Future<List<Branch>> getBranches() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/BranchList'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Branch.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load branches');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // GET Treatment List
  Future<List<Treatment>> getTreatments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/TreatmentList'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Treatment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load treatments');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  // POST Patient Update
  Future<bool> addPatient(Map<String, String> patientData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/PatientUpdate'),
        body: patientData,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
