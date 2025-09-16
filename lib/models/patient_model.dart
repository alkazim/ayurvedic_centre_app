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
    return Patient(
      id: json['id'],
      name: json['name'] ?? '',
      executive: json['executive'] ?? '',
      payment: json['payment'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      advanceAmount: (json['advance_amount'] ?? 0).toDouble(),
      balanceAmount: (json['balance_amount'] ?? 0).toDouble(),
      dateNdTime: json['date_nd_time'] ?? '',
      male: json['male'] ?? '',
      female: json['female'] ?? '',
      branch: json['branch'] ?? '',
      treatments: json['treatments'] ?? '',
    );
  }
}

class Branch {
  final int id;
  final String name;

  Branch({required this.id, required this.name});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Treatment {
  final int id;
  final String name;

  Treatment({required this.id, required this.name});

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
