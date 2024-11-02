import 'package:flutter/material.dart';
import 'Screens/login_register_screen.dart'; // Import the login/register screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: LoginRegisterScreen(), // Start with the Login/Register screen
    );
  }
}
