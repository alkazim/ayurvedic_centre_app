import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/login_provider.dart';
import 'home_screen.dart';

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
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 217,
            color: Colors.green,
            child: Image(image: AssetImage('lib/assets/images/Login_Image.png')),
          ),
          Container(
            padding: EdgeInsets.all(18),
            width: MediaQuery.of(context).size.width,
            child: Text("Login Or register To Book \nYour Appointments",style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            )),
          ),
          
          SizedBox(height: 20),
          
          Container(
            padding: EdgeInsets.all(18),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text("Email",style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    )),
                ),
                SizedBox(height:10),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFf5f5f5),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    border: Border.all(
                      color: Color(0xFFdddddd),
                      width: 2
                    )
                  ),
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(left:8.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter your email',
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),  

          Container(
            padding: EdgeInsets.all(18),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text("Password",style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    )),
                ),
                SizedBox(height:10),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFf5f5f5),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    border: Border.all(
                      color: Color(0xFFdddddd),
                      width: 2
                    )
                  ),
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(left:8.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter password',
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          
          // Error message
          Consumer<LoginProvider>(
            builder: (context, loginProvider, child) {
              if (loginProvider.error != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      loginProvider.error!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
          
          SizedBox(height:40),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Container(
              height: 50,
              width: double.infinity,
              child: Consumer<LoginProvider>(
                builder: (context, loginProvider, child) {
                  return ElevatedButton(
                    onPressed: loginProvider.isLoading ? null : _handleLogin,
                    child: loginProvider.isLoading 
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Login", style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                          )),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.52)),
                      backgroundColor: Color(0xFF006837)
                    ),
                  );
                },
              ),
            ),
          ),
          
          Expanded(
            child: Container(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.only(bottom:25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:[ 
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: "By creating or logging into an account you are agreeing with our ",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
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
                  ]
                ),
              )
            ),
          ),
        ],
      ),
    );
  }
}
