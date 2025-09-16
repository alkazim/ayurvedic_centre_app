import 'package:ayurvedic_centre_app/screens/invoice_screen.dart';
import 'package:ayurvedic_centre_app/screens/register_screen.dart';
import 'package:ayurvedic_centre_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/patient_provider.dart';
import 'providers/login_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
      ],
      child: MaterialApp(
        title: 'Patient Management',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        initialRoute: '/splash',
        routes: {
          '/': (context) => LoginScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/register': (context) => const RegisterScreen(),
          '/invoice': (context) => InvoiceScreen(),
          '/splash': (context) => SplashScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
