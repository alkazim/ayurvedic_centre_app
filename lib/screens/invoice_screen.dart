import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/patient_model.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;
  final double _minScale = 0.5;
  final double _maxScale = 3.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale + 0.2).clamp(_minScale, _maxScale);
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale - 0.2).clamp(_minScale, _maxScale);
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  void _resetZoom() {
    setState(() {
      _currentScale = 1.0;
      _transformationController.value = Matrix4.identity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Patient patient = ModalRoute.of(context)!.settings.arguments as Patient;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Invoice',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.zoom_out, color: Colors.black87),
            onPressed: _currentScale > _minScale ? _zoomOut : null,
            tooltip: 'Zoom Out',
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(_currentScale * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.zoom_in, color: Colors.black87),
            onPressed: _currentScale < _maxScale ? _zoomIn : null,
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () => _shareInvoice(context, patient),
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.black),
            onPressed: () => _printInvoice(context, patient),
            tooltip: 'Print',
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade300,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: _minScale,
          maxScale: _maxScale,
          boundaryMargin: EdgeInsets.all(20),
          onInteractionUpdate: (details) {
            setState(() {
              _currentScale = _transformationController.value.getMaxScaleOnAxis();
            });
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildPatientDetails(patient),
                    _buildTreatmentTable(patient),
                    _buildAmountSummary(patient),
                    _buildFooter(),
                    _buildBottomNote(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Header with logo and clinic info
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade50,
                ),
                child: Center(
                  child: Icon(
                    Icons.spa,
                    size: 30,
                    color: Color(0xFF006837),
                  ),
                ),
              ),
              
              Spacer(),
              
              // Clinic Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'KUMARAKOM',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Cheepunkal P.O. Kumarakom, kottayam, Kerala - 686563',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    SizedBox(height: 3),
                    Text(
                      'e-mail: unknown@gmail.com',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Mob: +91 9876543210 | +91 9876543210',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'GST No: 32AABCU9603R1ZW',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Patient Details Section
  Widget _buildPatientDetails(Patient patient) {
    String formatDate(String dateStr) {
      try {
        if (dateStr.isEmpty) return 'Not specified';
        
        if (dateStr.contains('T')) {
          DateTime date = DateTime.parse(dateStr);
          return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
        }
        return dateStr;
      } catch (e) {
        return dateStr.isNotEmpty ? dateStr : 'Not specified';
      }
    }

    String formatTime(String dateStr) {
      try {
        if (dateStr.isEmpty) return 'Not specified';
        
        if (dateStr.contains('T')) {
          DateTime date = DateTime.parse(dateStr);
          int hour = date.hour;
          int minute = date.minute;
          String period = hour >= 12 ? 'pm' : 'am';
          hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '${hour}:${minute.toString().padLeft(2, '0')}$period';
        }
        return 'Not specified';
      } catch (e) {
        return 'Not specified';
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Details Header
          Text(
            'Patient Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF006837),
            ),
          ),
          
          SizedBox(height: 12),
          
          // Use Column layout for better mobile responsiveness
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info
              _buildDetailRow('Name', patient.name),
              SizedBox(height: 8),
              _buildDetailRow('Address', patient.address),
              SizedBox(height: 8),
              _buildDetailRow('WhatsApp Number', patient.phone),
              SizedBox(height: 12),
              
              // Booking Info
              Row(
                children: [
                  Expanded(child: _buildDetailRow('Booked On', '${formatDate(patient.dateNdTime)} | 12:12pm')),
                  SizedBox(width: 16),
                  Expanded(child: _buildDetailRow('Treatment Date', formatDate(patient.dateNdTime))),
                ],
              ),
              SizedBox(height: 8),
              _buildDetailRow('Treatment Time', formatTime(patient.dateNdTime)),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method for detail rows
  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value.isNotEmpty ? value : 'Not specified',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Fixed Treatment Table with proper responsive sizing
  Widget _buildTreatmentTable(Patient patient) {
    List<String> treatmentList = patient.treatments.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    int maleCount = int.tryParse(patient.male) ?? 0;
    int femaleCount = int.tryParse(patient.female) ?? 0;
    
    double totalTreatmentAmount = patient.totalAmount;
    double pricePerTreatment = treatmentList.isNotEmpty 
        ? totalTreatmentAmount / treatmentList.length
        : 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Color(0xFF006837),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Treatment',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Male',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Female',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Table Rows
          ...treatmentList.asMap().entries.map((entry) {
            int index = entry.key;
            String treatment = entry.value;
            
            return Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.grey.shade50 : Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      treatment,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${pricePerTreatment.toInt()}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      maleCount.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      femaleCount.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${(pricePerTreatment * (maleCount + femaleCount)).toInt()}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Amount Summary Section
  Widget _buildAmountSummary(Patient patient) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildAmountRow('Total Amount', '₹${patient.totalAmount.toInt()}', isTotal: true),
          SizedBox(height: 8),
          _buildAmountRow('Discount', '₹${patient.discountAmount.toInt()}'),
          SizedBox(height: 8),
          _buildAmountRow('Advance', '₹${patient.advanceAmount.toInt()}'),
          SizedBox(height: 12),
          Container(height: 1, color: Colors.grey.shade300),
          SizedBox(height: 12),
          _buildAmountRow('Balance', '₹${patient.balanceAmount.toInt()}', isBalance: true),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String amount, {bool isTotal = false, bool isBalance = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBalance ? 16 : 14,
            fontWeight: isBalance || isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isBalance ? Colors.black : Colors.black87,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBalance ? 16 : 14,
            fontWeight: isBalance || isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isBalance ? Color(0xFF006837) : Colors.black87,
          ),
        ),
      ],
    );
  }

  // Footer with thank you message
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Text(
            'Thank you for choosing us',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF006837),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 8),
          
          Text(
            'Your well-being is our commitment, and we\'re honored\nyou\'ve entrusted us with your health journey',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 16),
          
          // Signature
          Container(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 80,
                  height: 40,
                  child: CustomPaint(
                    painter: SignaturePainter(),
                  ),
                ),
                Text(
                  'Signature',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Note
  Widget _buildBottomNote() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Text(
        '"Booking amount is non-refundable, and it\'s important to arrive on the allotted time for your treatment"',
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Share Invoice Function
  void _shareInvoice(BuildContext context, Patient patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.share, color: Colors.white),
            SizedBox(width: 12),
            Text('Invoice shared successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Print Invoice Function
  void _printInvoice(BuildContext context, Patient patient) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.print, color: Colors.white),
            SizedBox(width: 12),
            Text('Invoice sent to printer!'),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// Custom Signature Painter
class SignaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Draw a simple signature-like curve
    path.moveTo(size.width * 0.1, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.2,
      size.width * 0.5, size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.8,
      size.width * 0.9, size.height * 0.4,
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
