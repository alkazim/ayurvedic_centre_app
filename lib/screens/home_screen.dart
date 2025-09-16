import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('🏠 HomeScreen: initState called');

    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏠 HomeScreen: PostFrameCallback triggered');
      final provider = context.read<PatientProvider>();
      print('🏠 HomeScreen: Got provider instance: $provider');
      provider.fetchPatients(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Add this method to your HomeScreen class:

  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Filter by Date',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Single Date Option
              ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.green),
                title: Text('Select Single Date'),
                subtitle: Text('Filter appointments for specific date'),
                onTap: () async {
                  Navigator.pop(context);
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
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
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (selectedDate != null) {
                    context.read<PatientProvider>().filterByDate(selectedDate);
                  }
                },
              ),

              Divider(),

              // Date Range Option
              ListTile(
                leading: Icon(Icons.date_range, color: Colors.green),
                title: Text('Select Date Range'),
                subtitle: Text('Filter appointments between two dates'),
                onTap: () async {
                  Navigator.pop(context);
                  DateTimeRange? selectedRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    initialDateRange: DateTimeRange(
                      start: DateTime.now().subtract(Duration(days: 7)),
                      end: DateTime.now(),
                    ),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Color(0xFF006837),
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (selectedRange != null) {
                    context.read<PatientProvider>().filterByDateRange(
                      selectedRange,
                    );
                  }
                },
              ),

              Divider(),

              // Clear Filter Option
              Consumer<PatientProvider>(
                builder: (context, provider, child) {
                  if (provider.selectedDate != null ||
                      provider.selectedDateRange != null) {
                    return ListTile(
                      leading: Icon(Icons.clear, color: Colors.red),
                      title: Text('Clear Date Filter'),
                      subtitle: Text('Show all appointments'),
                      onTap: () {
                        Navigator.pop(context);
                        context.read<PatientProvider>().clearDateFilter();
                      },
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        );
      },
    );
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: Color(0xFFb3b3b3)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            context.read<PatientProvider>().updateSearch(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search for treatments',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade400,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: TextButton(
                        onPressed: () {
                          // Search is handled in onChanged
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
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

              // Sort Section
              // Replace the sort section with this:
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
                  Consumer<PatientProvider>(
                    builder: (context, provider, child) {
                      return GestureDetector(
                        onTap: _showDateFilterDialog,
                        child: Container(
                          height: 40,
                          width: 169,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(25),
                            color:
                                (provider.selectedDate != null ||
                                    provider.selectedDateRange != null)
                                ? Colors.green.shade50
                                : Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    provider.sortDisplayText,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          (provider.selectedDate != null ||
                                              provider.selectedDateRange !=
                                                  null)
                                          ? Colors.green.shade700
                                          : Colors.black87,
                                      fontWeight:
                                          (provider.selectedDate != null ||
                                              provider.selectedDateRange !=
                                                  null)
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  (provider.selectedDate != null ||
                                          provider.selectedDateRange != null)
                                      ? Icons.filter_alt
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.green.shade600,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 2,
                color: Color(0xfff1f1f1),
              ),
              const SizedBox(height: 20),

              // Patient List with Pagination and Lazy Loading
              Expanded(
                child: Consumer<PatientProvider>(
                  builder: (context, patientProvider, child) {
                    // Initial Loading State
                    if (patientProvider.isLoading &&
                        patientProvider.patients.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF006837),
                        ),
                      );
                    }

                    // Error State (when no patients loaded)
                    if (patientProvider.error != null &&
                        patientProvider.patients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Error: ${patientProvider.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                patientProvider.clearError();
                                patientProvider.fetchPatients(refresh: true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF006837),
                              ),
                              child: Text(
                                'Retry',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final patients = patientProvider.filteredPatients;

                    // Empty State
                    if (patients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No patients found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Patient List with Lazy Loading
                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        // Load more when user scrolls to 80% of the content
                        if (!patientProvider.isLoadingMore &&
                            patientProvider.hasMore &&
                            patientProvider.searchQuery.isEmpty &&
                            scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent * 0.8) {
                          patientProvider.loadMorePatients();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        itemCount:
                            patients.length +
                            (patientProvider.hasMore &&
                                    patientProvider.searchQuery.isEmpty
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          // Show loading indicator at the end
                          if (index == patients.length) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: patientProvider.isLoadingMore
                                    ? Column(
                                        children: [
                                          CircularProgressIndicator(
                                            color: Color(0xFF006837),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Loading more patients...',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox.shrink(),
                              ),
                            );
                          }

                          final patient = patients[index];

                          // Patient Card (Your existing design)
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Color(0xFFf1f1f1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              spacing: 2,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    top: 12,
                                  ),
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
                                    patient.treatments.isNotEmpty
                                        ? patient.treatments
                                        : 'No treatments',
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
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: Colors.red.shade400,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        patient.dateNdTime.isNotEmpty
                                            ? patient.dateNdTime
                                            : 'No Date',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          color: Colors.red.shade400,
                                        ),
                                      ),

                                      const SizedBox(width: 20),

                                      Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: Colors.red.shade400,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          patient.executive.isNotEmpty
                                              ? patient.executive
                                              : 'No Executive',
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
                                        print(
                                          'View details for: ${patient.name}',
                                        );
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
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                            color: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // Register Now Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle register button
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF006837),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Register Now',
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
      ),
    );
  }
}
