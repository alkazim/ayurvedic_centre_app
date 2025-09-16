import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../services/api_service.dart';

enum SortBy { date, name, totalAmount, branch }
enum SortOrder { ascending, descending }

class PatientProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // All patients from API
  List<Patient> _allPatients = [];
  
  // Currently displayed patients (paginated)
  List<Patient> _displayedPatients = [];
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  
  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMore = true;
  
  // Sorting variables
  SortBy _sortBy = SortBy.date;
  SortOrder _sortOrder = SortOrder.descending;
  
  // Date filtering variables
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;
  
  // Public getters
  List<Patient> get patients => _displayedPatients;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasMore => _hasMore;
  SortBy get sortBy => _sortBy;
  SortOrder get sortOrder => _sortOrder;
  DateTime? get selectedDate => _selectedDate;
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  
  // Get sort display text
  String get sortDisplayText {
    if (_selectedDate != null) {
      return '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
    } else if (_selectedDateRange != null) {
      return '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}';
    }
    return 'Date';
  }
  
  // Filtered and sorted patients
  List<Patient> get filteredPatients {
    List<Patient> patients = _allPatients;
    
    // Apply date filter first
    if (_selectedDate != null) {
      patients = patients.where((patient) {
        DateTime patientDate = _parseDate(patient.dateNdTime);
        return _isSameDate(patientDate, _selectedDate!);
      }).toList();
    } else if (_selectedDateRange != null) {
      patients = patients.where((patient) {
        DateTime patientDate = _parseDate(patient.dateNdTime);
        return patientDate.isAfter(_selectedDateRange!.start.subtract(Duration(days: 1))) &&
               patientDate.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
      }).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      patients = patients.where((patient) => 
        patient.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        patient.treatments.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        patient.branch.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Sort patients
    _sortPatients(patients);
    
    // For search or date filter, return all filtered results
    if (_searchQuery.isNotEmpty || _selectedDate != null || _selectedDateRange != null) {
      return patients;
    }
    
    // Otherwise return paginated results
    return _displayedPatients;
  }
  
  // Check if two dates are the same day
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  // Sort patients
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
  
  // Parse date from string
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
  
  // Filter by specific date
  void filterByDate(DateTime date) {
    _selectedDate = date;
    _selectedDateRange = null;
    print('🔄 Filtering by date: ${date.day}/${date.month}/${date.year}');
    notifyListeners();
  }
  
  // Filter by date range
  void filterByDateRange(DateTimeRange dateRange) {
    _selectedDateRange = dateRange;
    _selectedDate = null;
    print('🔄 Filtering by date range: ${dateRange.start} to ${dateRange.end}');
    notifyListeners();
  }
  
  // Clear date filter
  void clearDateFilter() {
    _selectedDate = null;
    _selectedDateRange = null;
    print('🔄 Cleared date filter');
    notifyListeners();
  }
  
  // Update sort criteria
  void updateSort(SortBy newSortBy) {
    if (_sortBy == newSortBy) {
      _sortOrder = _sortOrder == SortOrder.ascending 
          ? SortOrder.descending 
          : SortOrder.ascending;
    } else {
      _sortBy = newSortBy;
      _sortOrder = SortOrder.descending;
    }
    
    _sortPatients(_allPatients);
    _currentPage = 1;
    _displayedPatients.clear();
    _paginateLocally();
    
    notifyListeners();
  }
  
  // Fetch patients from API
  Future<void> fetchPatients({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _displayedPatients.clear();
      _allPatients.clear();
      _hasMore = true;
    }
    
    if (_allPatients.isNotEmpty && !refresh) {
      _paginateLocally();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _allPatients = await _apiService.getPatients();
      _sortPatients(_allPatients);
      _paginateLocally();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Paginate locally
  void _paginateLocally() {
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    
    if (startIndex >= _allPatients.length) {
      _hasMore = false;
      return;
    }
    
    List<Patient> newItems = _allPatients.sublist(
      startIndex, 
      endIndex > _allPatients.length ? _allPatients.length : endIndex
    );
    
    if (_currentPage == 1) {
      _displayedPatients = newItems;
    } else {
      _displayedPatients.addAll(newItems);
    }
    
    _hasMore = endIndex < _allPatients.length;
  }
  
  // Load more patients
  Future<void> loadMorePatients() async {
    if (_isLoadingMore || !_hasMore || _searchQuery.isNotEmpty || 
        _selectedDate != null || _selectedDateRange != null) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    await Future.delayed(Duration(milliseconds: 500));
    
    try {
      _currentPage++;
      _paginateLocally();
    } catch (e) {
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  // Search functionality
  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  Future<void> refreshData() async {
    await fetchPatients(refresh: true);
  }
}
