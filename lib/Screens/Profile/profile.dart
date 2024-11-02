import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'badges_achievements_screen.dart';
import 'loyalty_benefits_screen.dart';
import 'membered_societies_screen.dart';
import 'attended_events_screen.dart';
import 'settings_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Import path_provider
import '../../Constant/colors.dart';

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
        future: _firestore.collection('individuals').doc(currentUser.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading profile: ${snapshot.error}'));
          }

          // Check if the individual document exists
          if (snapshot.hasData && snapshot.data!.exists) {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String name = userData['name'] ?? 'N/A';
            String surname = userData['surname'] ?? 'N/A';

            return _buildProfileContent(context, name, surname, currentUser.uid);
          } else {
            // If not found in individuals, check in associations
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('associations').doc(currentUser.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading profile: ${snapshot.error}'));
                }

                // Check if the association document exists
                if (snapshot.hasData && snapshot.data!.exists) {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  String associationName = userData['associationName'] ?? 'N/A';
                  String email = userData['email'] ?? 'N/A';

                  return _buildProfileContent(
                    context,
                    associationName,
                    email,
                    currentUser.uid,
                    isAssociation: true, // Flag to indicate that this is an association
                  );
                } else {
                  return Center(child: Text('User not found'));
                }
              },
            );
          }
        },
      ),
      backgroundColor: Colors.white,
    );
  }

  Future<File?> _getLocalProfilePicture(String userId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagePath = '${appDir.path}/$userId.jpg'; // Use user ID as filename
      final File localImageFile = File(imagePath);
      if (await localImageFile.exists()) {
        return localImageFile; // Return the local image file if it exists
      }
    } catch (e) {
      // Handle any exceptions
    }
    return null; // Return null if no file is found
  }

  Widget _buildProfilePicture(String userId) {
    return FutureBuilder<File?>(
      future: _getLocalProfilePicture(userId), // Fetch the local image
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loader while fetching
        }

        // Use the local image if available, otherwise fallback to network
        return Container(
          width: 200, // Increased width
          height: 200, // Increased height
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
            child: snapshot.data != null
                ? Image.file(
              snapshot.data!,
              width: 150, // Increased width
              height: 150, // Increased height
              fit: BoxFit.cover,
            )
                : Image.network(
              'https://via.placeholder.com/150', // Fallback placeholder
              width: 150, // Increased width
              height: 150, // Increased height
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }


  Widget _buildUserInfo(String name, String surname, {bool isAssociation = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 0), // Add this line to adjust spacing above the title
            Text(
              isAssociation ? name : '$name $surname', // Adjust based on user type
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87),
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
        padding: const EdgeInsets.all(1.0),
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
      leading: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color for the icon
          shape: BoxShape.circle, // Circle shape for depth effect
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 6), // Slight shadow offset
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Padding around the icon
          child: Icon(icon, color: AppColors.orange), // Your icon
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold, // Set title to bold
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }



  Widget _buildProfileContent(BuildContext context, String name, String surname, String userId, {bool isAssociation = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfilePicture(userId),
          SizedBox(height: 20),
          _buildUserInfo(name, isAssociation ? '' : surname, isAssociation: isAssociation), // Adjust user info display
          SizedBox(height: 20),
          Divider(thickness: 2, color: Colors.grey[300]),
          SizedBox(height: 20),
          _buildProfileMenu(context),
        ],
      ),
    );
  }
}
