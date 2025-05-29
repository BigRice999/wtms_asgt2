import 'package:flutter/material.dart';
import 'package:wtms/screens/login_screen.dart';

void main() {
  runApp(const WTMSApp());
}

class WTMSApp extends StatelessWidget {
  const WTMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worker Task Management System',
      theme: ThemeData(),
      home: LoginScreen(), // enter login screen when lauched
    );
  }
}

