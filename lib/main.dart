import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/login_register_screen.dart';
import 'Screens/RootScreen.dart'; // Import your RootScreen if needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Firebase is initialized
  try {
    await Firebase.initializeApp(); // Initialize Firebase
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.orange),
      initialRoute: '/login_register_screen', // Set the initial route to LoginRegisterScreen
      routes: {
        '/login_register_screen': (context) => LoginRegisterScreen(), // Define login/register route
        '/': (context) => RootScreen(), // Define RootScreen route
      },
    );
  }
}
