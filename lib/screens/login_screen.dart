import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/login_provider.dart';
import 'home_screen.dart';
import 'dart:ui';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with test credentials
    _usernameController.text = 'test_user';
    _passwordController.text = '12345678';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    print('🔄 Starting login process...');

    final loginProvider = context.read<LoginProvider>();

    // Add null checks
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    bool success = await loginProvider.login(username, password);

    print('📊 Login result: $success');

    if (success) {
      print('✅ Login successful, navigating to home...');

      // Use mounted check
      if (mounted) {
        print('🔄 Widget is mounted, starting navigation...');
        Navigator.pushReplacementNamed(context, '/home');
        print('✅ Navigation command sent');
      }
    } else {
      print('❌ Login failed: ${loginProvider.error}');
      // Error will be shown in the UI through Consumer
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Important for keyboard handling
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Header Image - Responsive height
                  Container(
                    height: screenHeight * 0.22, // 22% of screen height
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Background Image with Blur
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'lib/assets/images/Login_Image.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              color: Colors.black.withOpacity(
                                0.2,
                              ), // Slight dark overlay
                            ),
                          ),
                        ),

                        // Centered Logo
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                             // color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Image.asset(
                                'lib/assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Title Section
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05, // 5% of screen width
                      vertical: screenHeight * 0.02, // 2% of screen height
                    ),
                    width: double.infinity,
                    child: Text(
                      "Login Or register To Book \nYour Appointments",
                      style: TextStyle(
                        fontSize: screenWidth * 0.06, // Responsive font size
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        height: 1.3,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Email Field
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                    ),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Email",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFf5f5f5),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            border: Border.all(
                              color: Color(0xFFdddddd),
                              width: 2,
                            ),
                          ),
                          height: screenHeight * 0.06, // Responsive height
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: TextField(
                              controller: _usernameController,
                              style: TextStyle(fontSize: screenWidth * 0.04),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter your email',
                                hintStyle: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey.shade600,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Password Field
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                    ),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Password",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFf5f5f5),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            border: Border.all(
                              color: Color(0xFFdddddd),
                              width: 2,
                            ),
                          ),
                          height: screenHeight * 0.06, // Responsive height
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: TextStyle(fontSize: screenWidth * 0.04),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter password',
                                hintStyle: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey.shade600,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Error message
                  Consumer<LoginProvider>(
                    builder: (context, loginProvider, child) {
                      if (loginProvider.error != null) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(
                              bottom: screenHeight * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              loginProvider.error!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: screenWidth * 0.035,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),

                  

                  // Login Button
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                    ),
                    child: Container(
                      height: screenHeight * 0.06,
                      width: double.infinity,
                      child: Consumer<LoginProvider>(
                        builder: (context, loginProvider, child) {
                          return ElevatedButton(
                            onPressed: loginProvider.isLoading
                                ? null
                                : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.52),
                              ),
                              backgroundColor: Color(0xFF006837),
                            ),
                            child: loginProvider.isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Spacer to push footer to bottom
                  Expanded(child: Container()),

                  // Footer Terms - Always at bottom
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.black,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text:
                                "By creating or logging into an account you are agreeing with our ",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          TextSpan(
                            text: "Terms and Conditions",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: " and "),
                          TextSpan(
                            text: "Privacy Policy.",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
