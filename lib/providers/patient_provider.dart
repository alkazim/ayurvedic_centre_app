import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../services/api_service.dart';

enum SortBy { date, name, totalAmount, branch }
enum SortOrder { ascending, descending }

class PatientProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // ⚡ OPTIMIZED: Better state management
  List<Patient> _allPatients = [];
  List<Patient> _cachedFilteredPatients = []; // Cache filtered results
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  
  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMore = true;
  
  // Sorting
  SortBy _sortBy = SortBy.date;
  SortOrder _sortOrder = SortOrder.descending;
  
  // Date filtering
  DateTime? _selectedDate;
  
  // ⚡ OPTIMIZED: Debouncing for search
  Timer? _searchDebouncer;
  
  // ⚡ OPTIMIZED: Cache management
  bool _needsRefresh = true;
  
  // Public getters
  List<Patient> get patients => _allPatients;
  List<Patient> get displayedPatients => _cachedFilteredPatients;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasMore => _hasMore;
  SortBy get sortBy => _sortBy;
  SortOrder get sortOrder => _sortOrder;
  DateTime? get selectedDate => _selectedDate;
  
  String get sortDisplayText {
    if (_selectedDate != null) {
      return '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
    }
    return 'Date';
  }
  
  // ⚡ OPTIMIZED: Cached filtered patients with better performance
  void _updateFilteredPatients() {
    List<Patient> filtered = List.from(_allPatients);
    
    // Apply date filter
    if (_selectedDate != null) {
      filtered = filtered.where((patient) {
        DateTime patientDate = _parseDate(patient.dateNdTime);
        return _isSameDate(patientDate, _selectedDate!);
      }).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      String query = _searchQuery.toLowerCase();
      filtered = filtered.where((patient) => 
        patient.name.toLowerCase().contains(query) ||
        patient.treatments.toLowerCase().contains(query) ||
        patient.branch.toLowerCase().contains(query)
      ).toList();
    }
    
    // Sort patients
    _sortPatients(filtered);
    
    _cachedFilteredPatients = filtered;
  }
  
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  void _sortPatients(List<Patient> patients) {
    patients.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case SortBy.date:
          DateTime dateA = _parseDate(a.dateNdTime);
          DateTime dateB = _parseDate(b.dateNdTime);
          comparison = dateA.compareTo(dateB);
          break;
        case SortBy.name:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortBy.totalAmount:
          comparison = a.totalAmount.compareTo(b.totalAmount);
          break;
        case SortBy.branch:
          comparison = a.branch.toLowerCase().compareTo(b.branch.toLowerCase());
          break;
      }
      
      return _sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
  }
  
  DateTime _parseDate(String dateString) {
    try {
      if (dateString.isEmpty) return DateTime(1900);
      
      if (dateString.contains('T')) {
        return DateTime.parse(dateString);
      }
      
      if (dateString.contains('/')) {
        String datePart = dateString.split('-')[0];
        List<String> parts = datePart.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
      
      return DateTime(1900);
    } catch (e) {
      return DateTime(1900);
    }
  }
  
  // ⚡ OPTIMIZED: Smart fetching with caching
  Future<void> fetchPatients({bool refresh = false}) async {
    // Don't fetch if data exists and not refreshing
    if (_allPatients.isNotEmpty && !refresh && !_needsRefresh) {
      return;
    }
    
    if (refresh) {
      _currentPage = 1;
      _allPatients.clear();
      _cachedFilteredPatients.clear();
      _hasMore = true;
      _needsRefresh = false;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      print('⚡ Fetching patients from API...');
      final stopwatch = Stopwatch()..start();
      
      _allPatients = await _apiService.getPatients();
      _updateFilteredPatients();
      
      stopwatch.stop();
      print('⚡ API call completed in ${stopwatch.elapsedMilliseconds}ms');
      
    } catch (e) {
      _error = e.toString();
      print('❌ Error fetching patients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ⚡ OPTIMIZED: Debounced search
  void debouncedSearch(String query) {
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(Duration(milliseconds: 300), () {
      _searchQuery = query;
      _updateFilteredPatients();
      notifyListeners();
    });
  }
  
  void filterByDate(DateTime date) {
    _selectedDate = date;
    _updateFilteredPatients();
    notifyListeners();
  }
  
  void clearDateFilter() {
    _selectedDate = null;
    _updateFilteredPatients();
    notifyListeners();
  }
  
  void updateSort(SortBy newSortBy) {
    if (_sortBy == newSortBy) {
      _sortOrder = _sortOrder == SortOrder.ascending 
          ? SortOrder.descending 
          : SortOrder.ascending;
    } else {
      _sortBy = newSortBy;
      _sortOrder = SortOrder.descending;
    }
    
    _updateFilteredPatients();
    notifyListeners();
  }
  
  // ⚡ OPTIMIZED: Immediate search update
  void updateSearch(String query) {
    _searchQuery = query;
    _updateFilteredPatients();
    notifyListeners();
  }

  // Add this method to your PatientProvider class
Future<void> loadPatients() async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('🔄 PatientProvider: Loading patients...');
    
    List<Patient> patients = await _apiService.getPatients();
    
    _allPatients = patients;
    _needsRefresh = false;
    _isLoading = false;
    
    print('✅ PatientProvider: Loaded ${patients.length} patients');
    
    notifyListeners();
  } catch (e) {
    _error = 'Failed to load patients: ${e.toString()}';
    _isLoading = false;
    print('❌ PatientProvider: Error loading patients - $e');
    notifyListeners();
  }
}

  
Future<bool> addPatient({
  required String name,
  required String executive,
  required String payment,
  required String phone,
  required String address,
  required double totalAmount,
  required double discountAmount,
  required double advanceAmount,
  required double balanceAmount,
  required String dateNdTime,
  required String male,
  required String female,
  required String branch,
  required String treatments,
}) async {
  try {
    _error = null;
    _isLoading = true;
    notifyListeners();

    // ⚡ Fixed data structure - ensure no field conflicts
    Map<String, String> patientData = {
        // Empty string for new patient (NOT the branch name)
      'name': name,
      'excecutive': executive, // Note: keeping the typo as server expects it
      'payment': payment,
      'phone': phone,
      'address': address,
      'total_amount': totalAmount.toString(),
      'discount_amount': discountAmount.toString(),
      'advance_amount': advanceAmount.toString(),
      'balance_amount': balanceAmount.toString(),
      'date_nd_time': dateNdTime,
      'male': male,
      'female': female,
      'branch': branch,  // This should be branch name, not ID
      'treatments': treatments,
    };

    print('🚀 PatientProvider: Sending data to API...');
    print('📝 Final data structure: $patientData');

    bool success = await _apiService.addPatient(patientData);

    if (success) {
      _needsRefresh = true; // Refresh patient list
      await loadPatients(); // Reload patients
    } else {
      _error = 'Failed to add patient. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return success;

  } catch (e) {
    _error = 'Error: ${e.toString()}';
    _isLoading = false;
    notifyListeners();
    return false;
  }
}

  
  Future<void> loadMorePatients() async {
    // Simplified - not needed with current implementation
    return;
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  Future<void> refreshData() async {
    await fetchPatients(refresh: true);
  }
  
  @override
  void dispose() {
    _searchDebouncer?.cancel();
    super.dispose();
  }
}
