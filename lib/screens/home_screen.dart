import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import '../models/patient_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  
  // Keep alive to prevent rebuilds
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    print('🏠 HomeScreen: initState called');
    
    // ⚡ OPTIMIZED: Only fetch if data doesn't exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PatientProvider>();
      if (provider.patients.isEmpty && !provider.isLoading) {
        provider.fetchPatients(refresh: false); // Don't force refresh
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ⚡ OPTIMIZED: Cached date picker
  Future<void> _showDatePicker() async {
    final provider = context.read<PatientProvider>();
    
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    
    if (selectedDate != null) {
      provider.filterByDate(selectedDate);
    }
  }

  // ⚡ OPTIMIZED: Extracted patient card widget
  Widget _buildPatientCard(Patient patient, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFFf1f1f1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 12),
            child: Row(
              children: [
                Text(
                  '${index + 1}.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    patient.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 6),
          
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text(
              patient.treatments.isNotEmpty ? patient.treatments : 'No treatments',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF006837),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 16, color: Colors.red.shade400),
                const SizedBox(width: 6),
                Text(
                  patient.dateNdTime.isNotEmpty ? patient.dateNdTime : 'No Date',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(width: 20),
                Icon(Icons.person_outline, size: 16, color: Colors.red.shade400),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    patient.executive.isNotEmpty ? patient.executive : 'No Executive',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          Container(
            height: 1.5,
            width: double.infinity,
            color: Color(0xFFc1c1c1),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  print('View details for: ${patient.name}');
                  // Navigate to patient details screen
                },
                child: Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'View Booking details',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<PatientProvider>().refreshData(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: Color(0xFFb3b3b3))
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            // ⚡ OPTIMIZED: Debounced search
                            context.read<PatientProvider>().debouncedSearch(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search for treatments',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 24),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: TextButton(
                        onPressed: () {/* Search handled in onChanged */},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),

              // ⚡ OPTIMIZED: Use Selector for date filter only
              Row(
                children: [
                  const Text(
                    'Sort by :',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Selector<PatientProvider, String>(
                    selector: (_, provider) => provider.sortDisplayText,
                    builder: (context, sortText, child) {
                      return Selector<PatientProvider, DateTime?>(
                        selector: (_, provider) => provider.selectedDate,
                        builder: (context, selectedDate, child) {
                          return GestureDetector(
                            onTap: _showDatePicker,
                            child: Container(
                              height: 40,
                              width: 169,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(25),
                                color: selectedDate != null ? Colors.green.shade50 : Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        sortText,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: selectedDate != null
                                              ? Colors.green.shade700
                                              : Colors.black87,
                                          fontWeight: selectedDate != null
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (selectedDate != null) ...[
                                          GestureDetector(
                                            onTap: () => context.read<PatientProvider>().clearDateFilter(),
                                            child: Icon(Icons.clear, color: Colors.red.shade400, size: 16),
                                          ),
                                          SizedBox(width: 4),
                                        ],
                                        Icon(
                                          selectedDate != null ? Icons.calendar_today : Icons.keyboard_arrow_down,
                                          color: Colors.green.shade600,
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 10),
              Container(width: double.infinity, height: 2, color: Color(0xfff1f1f1)),
              const SizedBox(height: 20),
              
              // ⚡ OPTIMIZED: Efficient list with Selector
              Expanded(
                child: Selector<PatientProvider, bool>(
                  selector: (_, provider) => provider.isLoading,
                  builder: (context, isLoading, child) {
                    if (isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF006837)),
                      );
                    }

                    return Selector<PatientProvider, String?>(
                      selector: (_, provider) => provider.error,
                      builder: (context, error, child) {
                        if (error != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 60, color: Colors.red),
                                SizedBox(height: 16),
                                Text('Error: $error', textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<PatientProvider>().clearError();
                                    context.read<PatientProvider>().fetchPatients(refresh: true);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF006837)),
                                  child: Text('Retry', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        }

                        return Selector<PatientProvider, List<Patient>>(
                          selector: (_, provider) => provider.displayedPatients,
                          builder: (context, patients, child) {
                            if (patients.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.people_outline, size: 80, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text('No patients found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              // ⚡ OPTIMIZED: Add caching and performance hints
                              cacheExtent: 1000, // Cache more items
                              itemCount: patients.length,
                              itemBuilder: (context, index) {
                                return _buildPatientCard(patients[index], index);
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              
              // Register Now Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF006837),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Register Now',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
