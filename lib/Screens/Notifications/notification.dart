import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/assets/images/hands.png', width: 80),
      ),
      body: Center(
        child: Text('Notification Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
