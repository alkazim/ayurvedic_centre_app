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
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    // Extract treatments from patientdetails_set
    String treatmentNames = '';
    if (json['patientdetails_set'] != null) {
      List<dynamic> treatments = json['patientdetails_set'];
      treatmentNames = treatments
          .map((treatment) => treatment['treatment_name'] ?? '')
          .join(', ');
    }

    // Extract branch name
    String branchName = '';
    if (json['branch'] != null && json['branch']['name'] != null) {
      branchName = json['branch']['name'];
    }

    return Patient(
      id: json['id'],
      name: json['name'] ?? '',
      executive: json['user'] ?? '', // API uses 'user' for executive
      payment: json['payment'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      advanceAmount: (json['advance_amount'] ?? 0).toDouble(),
      balanceAmount: (json['balance_amount'] ?? 0).toDouble(),
      dateNdTime: json['date_nd_time'] ?? '',
      male: json['patientdetails_set']?.isNotEmpty == true 
          ? (json['patientdetails_set'][0]['male'] ?? '') 
          : '',
      female: json['patientdetails_set']?.isNotEmpty == true 
          ? (json['patientdetails_set'][0]['female'] ?? '') 
          : '',
      branch: branchName,
      treatments: treatmentNames,
    );
  }
}

// Keep your existing Branch and Treatment classes
class Branch {
  final int id;
  final String name;
  final String location;

  Branch({
    required this.id,
    required this.name,
    this.location = '',
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
    );
  }
}

class Treatment {
  final int id;
  final String name;
  final String duration;
  final double price;

  Treatment({
    required this.id,
    required this.name,
    this.duration = '',
    this.price = 0.0,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      duration: json['duration'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
