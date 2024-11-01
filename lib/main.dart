import 'package:flutter/material.dart';
import 'Screens/RootScreen.dart'; // Import your root screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: RootScreen(), // Use RootScreen as the main screen
    );
  }
}
