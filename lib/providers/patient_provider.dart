import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../services/api_service.dart';

class PatientProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Patient> _patients = [];
  List<Branch> _branches = [];
  List<Treatment> _treatments = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  
  // Getters
  List<Patient> get patients => _patients;
  List<Branch> get branches => _branches;
  List<Treatment> get treatments => _treatments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Filtered patients
  List<Patient> get filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    return _patients.where((patient) => 
      patient.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      patient.treatments.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }
  
  // Fetch all data
  Future<void> fetchPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _patients = await _apiService.getPatients();
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> fetchBranches() async {
    try {
      _branches = await _apiService.getBranches();
      notifyListeners();
    } catch (e) {
      print('Branch error: $e');
    }
  }
  
  Future<void> fetchTreatments() async {
    try {
      _treatments = await _apiService.getTreatments();
      notifyListeners();
    } catch (e) {
      print('Treatment error: $e');
    }
  }
  
  // Search
  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  // Add patient
  Future<bool> addPatient(Map<String, String> patientData) async {
    try {
      bool success = await _apiService.addPatient(patientData);
      if (success) {
        fetchPatients(); // Refresh list
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
