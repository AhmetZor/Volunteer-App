import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'badges_achievements_screen.dart';
import 'loyalty_benefits_screen.dart';
import 'membered_societies_screen.dart';
import 'attended_events_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Center(child: Text('No user is currently logged in.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'lib/assets/images/hands.png',
          width: 80,
          alignment: Alignment.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('individuals').doc(currentUser.uid).get().then((doc) {
          if (!doc.exists) {
            return _firestore.collection('associations').doc(currentUser.uid).get();
          }
          return doc;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading profile: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String name = userData['name'] ?? 'N/A';
          String surname = userData['surname'] ?? 'N/A';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfilePicture(userData['profilePicture']),
                SizedBox(height: 20),
                _buildUserInfo(name, surname),
                SizedBox(height: 20),
                Divider(thickness: 2, color: Colors.grey[300]),
                SizedBox(height: 20),
                _buildProfileMenu(context),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildProfilePicture(String? profilePicture) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          profilePicture ?? 'https://via.placeholder.com/150',
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildUserInfo(String name, String surname) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$name $surname',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMenuItem(context, 'Badges & Achievements', Icons.star, BadgesAchievementsScreen()),
            _buildMenuItem(context, 'Loyalty Benefits', Icons.card_giftcard, LoyaltyBenefitsScreen()),
            _buildMenuItem(context, 'View Membered Societies', Icons.group, MemberedSocietiesScreen()),
            _buildMenuItem(context, 'Attended Events', Icons.event, AttendedEventsScreen()),
            _buildMenuItem(context, 'Settings', Icons.settings, SettingsScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal[600]),
      title: Text(title, style: TextStyle(color: Colors.black87, fontSize: 18)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
