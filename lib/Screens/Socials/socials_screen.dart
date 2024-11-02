import 'package:flutter/material.dart';

class SocialsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/assets/images/hands.png', width: 80),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        children: [
          _SocialCard(title: 'Facebook', icon: Icons.facebook),
          _SocialCard(title: 'Twitter', icon: Icons.share), // Using share icon
          _SocialCard(title: 'Instagram', icon: Icons.photo), // Using photo icon
          _SocialCard(title: 'LinkedIn', icon: Icons.business_center), // Using business center icon
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}

class _SocialCard extends StatelessWidget {
  final String title;
  final IconData icon;

  _SocialCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.grey[800]),
          SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
