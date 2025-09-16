import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController advanceController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();
  
  String selectedLocation = 'Choose your location';
  String selectedBranch = 'Select the branch';
  String selectedTreatment = 'Choose preferred treatment';
  String paymentMethod = '';
  DateTime? treatmentDate;
  TimeOfDay? treatmentTime;
  
  bool _isLoading = false;
  
  // Predefined location options
  final List<String> _locationOptions = [
    'Kochi, Kerala',
    'Calicut, Kerala',
    'Thrissur, Kerala',
    'Trivandrum, Kerala',
    'Kottayam, Kerala',
    'Alappuzha, Kerala',
    'Palakkad, Kerala',
    'Kannur, Kerala',
  ];
  
  // Branch options based on location
  final Map<String, List<String>> _branchOptions = {
    'Kochi, Kerala': [
      'Kochi Main Branch',
      'Ernakulam Branch', 
      'Kakkanad Branch',
      'Edapally Branch',
    ],
    'Calicut, Kerala': [
      'Calicut Central Branch',
      'Kozhikode Branch',
      'Mavoor Branch',
    ],
    'Thrissur, Kerala': [
      'Thrissur Main Branch',
      'Kunnamkulam Branch',
      'Guruvayur Branch',
    ],
    'Trivandrum, Kerala': [
      'Trivandrum Central Branch',
      'Neyyattinkara Branch',
      'Attingal Branch',
    ],
    'Kottayam, Kerala': [
      'Kottayam Main Branch',
      'Kumarakom Branch',
      'Changanassery Branch',
    ],
    'Alappuzha, Kerala': [
      'Alappuzha Main Branch',
      'Cherthala Branch',
    ],
    'Palakkad, Kerala': [
      'Palakkad Main Branch',
      'Ottapalam Branch',
    ],
    'Kannur, Kerala': [
      'Kannur Main Branch',
      'Thalassery Branch',
    ],
  };
  
  // Time slot options
  final List<String> _timeSlots = [
    '09:00 AM',
    '09:30 AM', 
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
    '05:30 PM',
    '06:00 PM',
  ];
  
  // Predefined treatment options
  final List<TreatmentOption> _treatmentOptions = [
    TreatmentOption(
      name: 'Couple Combo Package',
      description: 'Full body rejuvenation therapy for couples',
      price: 2500,
      duration: '90 minutes',
    ),
    TreatmentOption(
      name: 'Panchakarma Treatment',
      description: 'Traditional detoxification and rejuvenation',
      price: 4000,
      duration: '120 minutes',
    ),
    TreatmentOption(
      name: 'Full Body Massage',
      description: 'Therapeutic oil massage for relaxation',
      price: 1800,
      duration: '60 minutes',
    ),
    TreatmentOption(
      name: 'Head & Neck Massage',
      description: 'Stress relief therapy for head and neck',
      price: 800,
      duration: '30 minutes',
    ),
    TreatmentOption(
      name: 'Herbal Steam Therapy',
      description: 'Detoxifying herbal steam treatment',
      price: 1200,
      duration: '45 minutes',
    ),
    TreatmentOption(
      name: 'Foot Massage',
      description: 'Relaxing therapeutic foot massage',
      price: 600,
      duration: '30 minutes',
    ),
  ];
  
  List<Treatment> treatments = [];

  @override
  void initState() {
    super.initState();
    // Get treatment from navigation arguments if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? treatmentFromHome = ModalRoute.of(context)?.settings.arguments as String?;
      if (treatmentFromHome != null) {
        // FIXED: Find the treatment option using where().isNotEmpty instead of firstOrNull
        var matchingTreatments = _treatmentOptions.where((t) => t.name == treatmentFromHome);
        
        if (matchingTreatments.isNotEmpty) {
          TreatmentOption selectedTreatmentOption = matchingTreatments.first;
          setState(() {
            treatments = [Treatment(
              name: selectedTreatmentOption.name,
              price: selectedTreatmentOption.price,
              maleCount: 1, 
              femaleCount: 1
            )];
            _calculateTotalAmount();
          });
        }
      }
    });

    // Add listeners for automatic calculations
    advanceController.addListener(_calculateBalanceAmount);
    discountController.addListener(_calculateBalanceAmount);
  }

  @override
  void dispose() {
    advanceController.removeListener(_calculateBalanceAmount);
    discountController.removeListener(_calculateBalanceAmount);
    nameController.dispose();
    whatsappController.dispose();
    addressController.dispose();
    totalAmountController.dispose();
    discountController.dispose();
    advanceController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  // Calculate total amount based on selected treatments
  void _calculateTotalAmount() {
    double total = 0;
    for (Treatment treatment in treatments) {
      total += treatment.price * (treatment.maleCount + treatment.femaleCount);
    }
    
    setState(() {
      totalAmountController.text = total.toStringAsFixed(0);
    });
    _calculateBalanceAmount();
  }

  // Calculate balance amount automatically
  void _calculateBalanceAmount() {
    double totalAmount = double.tryParse(totalAmountController.text) ?? 0;
    double discountAmount = double.tryParse(discountController.text) ?? 0;
    double advanceAmount = double.tryParse(advanceController.text) ?? 0;
    
    double balanceAmount = (totalAmount - discountAmount) - advanceAmount;
    
    // Ensure balance is not negative
    if (balanceAmount < 0) {
      balanceAmount = 0;
    }
    
    setState(() {
      balanceController.text = balanceAmount.toStringAsFixed(0);
    });
  }

  // Validation method
  bool _validateFields() {
    if (nameController.text.trim().isEmpty) return false;
    if (whatsappController.text.trim().isEmpty) return false;
    if (addressController.text.trim().isEmpty) return false;
    if (selectedLocation == 'Choose your location') return false;
    if (selectedBranch == 'Select the branch') return false;
    if (treatments.isEmpty) return false;
    if (totalAmountController.text.trim().isEmpty) return false;
    if (paymentMethod.isEmpty) return false;
    if (treatmentDate == null) return false;
    
    return true;
  }

  // Show validation dialog
  void _showValidationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text(
                'Missing Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            'Please fill all the required fields before saving.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF006837),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show location selection dialog
  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Select Location',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF006837),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _locationOptions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.location_on, color: Color(0xFF006837)),
                  title: Text(_locationOptions[index]),
                  onTap: () {
                    setState(() {
                      selectedLocation = _locationOptions[index];
                      selectedBranch = 'Select the branch'; // Reset branch
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Show branch selection dialog
  void _showBranchDialog() {
    if (selectedLocation == 'Choose your location') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select location first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    List<String> branches = _branchOptions[selectedLocation] ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Select Branch',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF006837),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: branches.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.business, color: Color(0xFF006837)),
                  title: Text(branches[index]),
                  onTap: () {
                    setState(() {
                      selectedBranch = branches[index];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Show time slot selection dialog
  void _showTimeSlotDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Select Time Slot',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF006837),
            ),
          ),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Convert string to TimeOfDay
                    String timeString = _timeSlots[index];
                    List<String> parts = timeString.split(' ');
                    List<String> timeParts = parts[0].split(':');
                    int hour = int.parse(timeParts[0]);
                    int minute = int.parse(timeParts[1]);
                    
                    if (parts[1] == 'PM' && hour != 12) {
                      hour += 12;
                    } else if (parts[1] == 'AM' && hour == 12) {
                      hour = 0;
                    }
                    
                    setState(() {
                      treatmentTime = TimeOfDay(hour: hour, minute: minute);
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Center(
                      child: Text(
                        _timeSlots[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF006837),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Save patient data
  Future<void> _savePatient() async {
    if (!_validateFields()) {
      _showValidationDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final patientProvider = context.read<PatientProvider>();
      
      // Prepare treatment string
      String treatmentString = treatments.map((t) => t.name).join(', ');
      
      // Prepare male and female counts
      int totalMale = treatments.fold(0, (sum, treatment) => sum + treatment.maleCount);
      int totalFemale = treatments.fold(0, (sum, treatment) => sum + treatment.femaleCount);
      
      // Format date and time
      String formattedDateTime = '';
      if (treatmentDate != null) {
        formattedDateTime = '${treatmentDate!.year}-${treatmentDate!.month.toString().padLeft(2, '0')}-${treatmentDate!.day.toString().padLeft(2, '0')}';
        if (treatmentTime != null) {
          formattedDateTime += 'T${treatmentTime!.hour.toString().padLeft(2, '0')}:${treatmentTime!.minute.toString().padLeft(2, '0')}:00';
        } else {
          formattedDateTime += 'T10:00:00';
        }
      }

      bool success = await patientProvider.addPatient(
        name: nameController.text.trim(),
        executive: 'Admin',
        payment: paymentMethod,
        phone: whatsappController.text.trim(),
        address: addressController.text.trim(),
        totalAmount: double.tryParse(totalAmountController.text.trim()) ?? 0.0,
        discountAmount: double.tryParse(discountController.text.trim()) ?? 0.0,
        advanceAmount: double.tryParse(advanceController.text.trim()) ?? 0.0,
        balanceAmount: double.tryParse(balanceController.text.trim()) ?? 0.0,
        dateNdTime: formattedDateTime,
        male: totalMale.toString(),
        female: totalFemale.toString(),
        branch: selectedBranch,
        treatments: treatmentString,
      );

      if (success) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Patient registered successfully!',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Navigate back to home screen
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Error occurred, try again',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error saving patient: $e');
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Error occurred, try again',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Register',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Name', 'Enter your full name', nameController),
            const SizedBox(height: 20),
            _buildTextField('Whatsapp Number', 'Enter your Whatsapp number', whatsappController),
            const SizedBox(height: 20),
            _buildTextField('Address', 'Enter your full address', addressController),
            const SizedBox(height: 20),
            _buildDropdown('Location', selectedLocation, _showLocationDialog),
            const SizedBox(height: 20),
            _buildDropdown('Branch', selectedBranch, _showBranchDialog),
            const SizedBox(height: 20),
            _buildTreatmentsSection(),
            const SizedBox(height: 20),
            _buildTextField('Total Amount', 'Auto-calculated', totalAmountController, readOnly: true),
            const SizedBox(height: 20),
            _buildTextField('Discount Amount', 'Enter discount amount', discountController),
            const SizedBox(height: 20),
            _buildPaymentOptions(),
            const SizedBox(height: 20),
            _buildTextField('Advance Amount', 'Enter advance amount', advanceController),
            const SizedBox(height: 20),
            _buildTextField('Balance Amount', 'Auto-calculated', balanceController, readOnly: true),
            const SizedBox(height: 20),
            _buildDatePicker(),
            const SizedBox(height: 20),
            _buildTimePicker(),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: label.contains('Amount') ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: readOnly ? Colors.grey.shade400 : Colors.grey),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade50 : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: TextStyle(
            color: readOnly ? Colors.grey.shade700 : Colors.black,
            fontWeight: readOnly ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: value.contains('Choose') || value.contains('Select') 
                          ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTreatmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Treatments',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...treatments.asMap().entries.map((entry) {
          int index = entry.key;
          Treatment treatment = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        treatment.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          treatments.removeAt(index);
                          _calculateTotalAmount();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Price: ₹${treatment.price}', 
                         style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Male: ${treatment.maleCount}',
                        style: TextStyle(color: Colors.green[700], fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Female: ${treatment.femaleCount}',
                        style: TextStyle(color: Colors.green[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showTreatmentDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Text(
              '+ Add Treatments',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Option',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildRadioOption('Cash'),
            const SizedBox(width: 40),
            _buildRadioOption('Card'),
            const SizedBox(width: 40),
            _buildRadioOption('UPI'),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: paymentMethod,
          onChanged: (String? newValue) {
            setState(() {
              paymentMethod = newValue!;
            });
          },
          activeColor: Colors.green,
        ),
        Text(value),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Treatment Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: treatmentDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Color(0xFF006837),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                    dialogBackgroundColor: Colors.white,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                treatmentDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  treatmentDate != null 
                      ? '${treatmentDate!.day}/${treatmentDate!.month}/${treatmentDate!.year}'
                      : 'Select treatment date',
                  style: TextStyle(
                    color: treatmentDate != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, color: Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Treatment Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showTimeSlotDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  treatmentTime != null 
                      ? treatmentTime!.format(context)
                      : 'Select treatment time',
                  style: TextStyle(
                    color: treatmentTime != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.access_time, color: Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _savePatient,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Saving...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Text(
                'Save',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // Treatment Dialog with Predefined Options
  void _showTreatmentDialog() {
    int maleCount = 1;
    int femaleCount = 1;
    TreatmentOption? selectedTreatmentOption;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Treatment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Treatment Dropdown with Predefined Options
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TreatmentOption>(
                          isExpanded: true,
                          hint: Text(
                            'Choose preferred treatment',
                            style: TextStyle(color: Colors.grey),
                          ),
                          value: selectedTreatmentOption,
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.green),
                          onChanged: (TreatmentOption? newValue) {
                            setStateDialog(() {
                              selectedTreatmentOption = newValue;
                            });
                          },
                          items: _treatmentOptions.map((TreatmentOption treatment) {
                            return DropdownMenuItem<TreatmentOption>(
                              value: treatment,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    treatment.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '₹${treatment.price} - ${treatment.duration}',
                                    style: TextStyle(
                                      color: Colors.green[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Text(
                      'Add Patients',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPatientCounter('Male', maleCount, (count) {
                      setStateDialog(() {
                        maleCount = count;
                      });
                    }),
                    const SizedBox(height: 16),
                    _buildPatientCounter('Female', femaleCount, (count) {
                      setStateDialog(() {
                        femaleCount = count;
                      });
                    }),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedTreatmentOption != null && (maleCount > 0 || femaleCount > 0)) {
                            setState(() {
                              treatments.add(Treatment(
                                name: selectedTreatmentOption!.name,
                                price: selectedTreatmentOption!.price,
                                maleCount: maleCount,
                                femaleCount: femaleCount,
                              ));
                              _calculateTotalAmount();
                            });
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select treatment and add patients'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPatientCounter(String gender, int count, Function(int) onCountChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            gender,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (count > 0) {
                    onCountChanged(count - 1);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              GestureDetector(
                onTap: () {
                  onCountChanged(count + 1);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Treatment Option Model
class TreatmentOption {
  final String name;
  final String description;
  final int price;
  final String duration;

  TreatmentOption({
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
  });
}

// Updated Treatment Model with price
class Treatment {
  final String name;
  final int price;
  final int maleCount;
  final int femaleCount;

  Treatment({
    required this.name,
    required this.price,
    required this.maleCount,
    required this.femaleCount,
  });
}
