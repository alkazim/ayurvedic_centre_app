class Patient {
  final int? id;
  final String name;
  final String executive;
  final String payment;
  final String phone;
  final String address;
  final double totalAmount;
  final double discountAmount;
  final double advanceAmount;
  final double balanceAmount;
  final String dateNdTime;
  final String male;
  final String female;
  final String branch;
  final String treatments;
  final List<PatientDetail> patientdetailsSet;

  Patient({
    this.id,
    required this.name,
    required this.executive,
    required this.payment,
    required this.phone,
    required this.address,
    required this.totalAmount,
    required this.discountAmount,
    required this.advanceAmount,
    required this.balanceAmount,
    required this.dateNdTime,
    required this.male,
    required this.female,
    required this.branch,
    required this.treatments,
    this.patientdetailsSet = const [],
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    // Extract treatments from patientdetails_set
    String treatmentNames = '';
    List<PatientDetail> patientDetails = [];
    
    if (json['patientdetails_set'] != null) {
      List<dynamic> treatments = json['patientdetails_set'];
      treatmentNames = treatments
          .map((treatment) => treatment['treatment_name'] ?? '')
          .where((name) => name.isNotEmpty)
          .join(', ');
      
      patientDetails = treatments
          .map((detail) => PatientDetail.fromJson(detail))
          .toList();
    }

    // Extract branch name
    String branchName = '';
    if (json['branch'] != null) {
      if (json['branch'] is Map<String, dynamic> && json['branch']['name'] != null) {
        branchName = json['branch']['name'];
      } else if (json['branch'] is String) {
        branchName = json['branch'];
      }
    }

    return Patient(
      id: json['id'],
      name: json['name'] ?? '',
      executive: json['user'] ?? json['executive'] ?? '', // API uses 'user' for executive
      payment: json['payment'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      advanceAmount: (json['advance_amount'] ?? 0).toDouble(),
      balanceAmount: (json['balance_amount'] ?? 0).toDouble(),
      dateNdTime: json['date_nd_time'] ?? '',
      male: patientDetails.isNotEmpty 
          ? (patientDetails[0].male ?? '') 
          : (json['male']?.toString() ?? ''),
      female: patientDetails.isNotEmpty 
          ? (patientDetails[0].female ?? '') 
          : (json['female']?.toString() ?? ''),
      branch: branchName,
      treatments: treatmentNames,
      patientdetailsSet: patientDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'executive': executive,
      'payment': payment,
      'phone': phone,
      'address': address,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'advance_amount': advanceAmount,
      'balance_amount': balanceAmount,
      'date_nd_time': dateNdTime,
      'male': male,
      'female': female,
      'branch': branch,
      'treatments': treatments,
    };
  }
}

class PatientDetail {
  final int? id;
  final String? male;
  final String? female;
  final String? treatmentName;

  PatientDetail({
    this.id,
    this.male,
    this.female,
    this.treatmentName,
  });

  factory PatientDetail.fromJson(Map<String, dynamic> json) {
    return PatientDetail(
      id: json['id'],
      male: json['male']?.toString(),
      female: json['female']?.toString(),
      treatmentName: json['treatment_name'] ?? json['treatment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'male': male,
      'female': female,
      'treatment_name': treatmentName,
    };
  }
}

class Branch {
  final int id;
  final String name;
  final String location;
  final bool? isActive;

  Branch({
    required this.id,
    required this.name,
    this.location = '',
    this.isActive,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? json['address'] ?? json['place'] ?? '',
      isActive: json['is_active'] ?? json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'is_active': isActive,
    };
  }

  @override
  String toString() => name;
}

class Treatment {
  final int id;
  final String name;
  final String duration;
  final double price;
  final bool? isActive;
  final String? description;

  Treatment({
    required this.id,
    required this.name,
    this.duration = '',
    this.price = 0.0,
    this.isActive,
    this.description,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      duration: json['duration'] ?? json['time'] ?? json['treatment_time'] ?? '',
      price: _parsePrice(json['price'] ?? json['amount'] ?? json['cost'] ?? 0),
      isActive: json['is_active'] ?? json['active'],
      description: json['description'] ?? json['details'] ?? '',
    );
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      // Remove currency symbols and parse
      String cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanPrice) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'price': price,
      'is_active': isActive,
      'description': description,
    };
  }

  @override
  String toString() => name;
}

// Additional models for API responses
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? json['status'] ?? false,
      message: json['message'] ?? json['msg'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> results;
  final int count;
  final String? next;
  final String? previous;

  PaginatedResponse({
    required this.results,
    required this.count,
    this.next,
    this.previous,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(Map<String, dynamic>) fromJsonT
  ) {
    return PaginatedResponse<T>(
      results: (json['results'] as List<dynamic>?)
          ?.map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList() ?? [],
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
    );
  }
}

// Enums for better type safety
enum PaymentMethod {
  cash('Cash'),
  card('Card'),
  upi('UPI'),
  online('Online');

  const PaymentMethod(this.displayName);
  final String displayName;

  static PaymentMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      case 'upi':
        return PaymentMethod.upi;
      case 'online':
        return PaymentMethod.online;
      default:
        return PaymentMethod.cash;
    }
  }
}

enum PatientStatus {
  active('Active'),
  inactive('Inactive'),
  completed('Completed'),
  cancelled('Cancelled');

  const PatientStatus(this.displayName);
  final String displayName;

  static PatientStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return PatientStatus.active;
      case 'inactive':
        return PatientStatus.inactive;
      case 'completed':
        return PatientStatus.completed;
      case 'cancelled':
        return PatientStatus.cancelled;
      default:
        return PatientStatus.active;
    }
  }
}

// Extension methods for easier data manipulation
extension PatientExtensions on Patient {
  bool get hasBalance => balanceAmount > 0;
  bool get isFullyPaid => balanceAmount <= 0;
  double get totalPaidAmount => advanceAmount;
  double get remainingAmount => totalAmount - advanceAmount - discountAmount;
  
  String get formattedTotalAmount => '₹${totalAmount.toStringAsFixed(0)}';
  String get formattedBalanceAmount => '₹${balanceAmount.toStringAsFixed(0)}';
  String get formattedAdvanceAmount => '₹${advanceAmount.toStringAsFixed(0)}';
  String get formattedDiscountAmount => '₹${discountAmount.toStringAsFixed(0)}';
  
  bool get hasTreatments => treatments.isNotEmpty;
  int get totalPatients => (int.tryParse(male) ?? 0) + (int.tryParse(female) ?? 0);
}

extension TreatmentExtensions on Treatment {
  String get formattedPrice => '₹${price.toStringAsFixed(0)}';
  bool get hasValidPrice => price > 0;
  bool get hasValidDuration => duration.isNotEmpty;
}

extension BranchExtensions on Branch {
  bool get hasLocation => location.isNotEmpty;
  String get displayName => hasLocation ? '$name ($location)' : name;
}
