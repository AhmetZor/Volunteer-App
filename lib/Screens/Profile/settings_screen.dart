import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'lib/assets/images/hands.png', // Ensure this path is correct
          width: 80,
          alignment: Alignment.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<User?>( // Use a FutureBuilder to get the current user
        future: _getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user is currently logged in.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfilePicture(),
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

  Future<User?> _getCurrentUser() async {
    return _auth.currentUser; // Get the current authenticated user
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: () => _pickImage(),
      child: Container(
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
          child: _profileImage != null
              ? Image.file(
            _profileImage!,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          )
              : Icon(Icons.camera_alt, color: Colors.grey, size: 30),
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
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMenuItem(context, 'Change Password', Icons.lock, () => changePassword(context)),
            _buildMenuItem(context, 'Log Out', Icons.logout, () async {
              await _auth.signOut();
              Navigator.of(context).pushReplacementNamed('/login_register_screen');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Function onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal[600]),
      title: Text(title, style: TextStyle(color: Colors.black87, fontSize: 18)),
      onTap: () => onTap(),
    );
  }

  Future<void> changePassword(BuildContext context) async {
    String? newPassword = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String password = '';
        return AlertDialog(
          title: Text("Change Password"),
          content: TextField(
            onChanged: (value) {
              password = value;
            },
            decoration: InputDecoration(hintText: "Enter new password"),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(password);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );

    if (newPassword != null && newPassword.isNotEmpty) {
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          await user.updatePassword(newPassword);
          showSnackbar(context, "Password changed successfully!");
        }
      } catch (e) {
        showSnackbar(context, "Error changing password: ${e.toString()}");
      }
    }
  }

  Future<void> _pickImage() async {
    final action = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose an option'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, ImageSource.camera);
              },
              child: const Text('Camera'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, ImageSource.gallery);
              },
              child: const Text('Gallery'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context); // Cancel
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (action != null) {
      final pickedFile = await _picker.pickImage(source: action);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        // Upload to Firebase Storage and get the download URL
        String? downloadUrl = await _uploadImageToFirebase(_profileImage!);
        if (downloadUrl != null) {
          await _updateUserProfilePicture(downloadUrl);
          showSnackbar(context, "Profile image updated.");
        }
      }
    }
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      String filePath = 'profile_pictures/${_auth.currentUser!.uid}.jpg'; // Unique path for each user
      TaskSnapshot uploadTask = await _storage.ref(filePath).putFile(imageFile);
      String downloadUrl = await uploadTask.ref.getDownloadURL(); // Get the download URL
      return downloadUrl; // Return the URL
    } catch (e) {
      showSnackbar(context, "Error uploading image: ${e.toString()}");
      return null;
    }
  }

  Future<void> _updateUserProfilePicture(String url) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userType = await _getUserType(user.uid);
      CollectionReference userCollection = FirebaseFirestore.instance.collection(userType);

      // Check if document exists; create it if it does not
      DocumentSnapshot userDoc = await userCollection.doc(user.uid).get();
      if (!userDoc.exists) {
        await userCollection.doc(user.uid).set({
          'profilePicture': '', // Initialize with empty URL or any other default fields
        });
      }

      // Update profile picture URL
      await userCollection.doc(user.uid).update({
        'profilePicture': url,
      });
    }
  }

  Future<String> _getUserType(String uid) async {
    // Check which collection contains the user and return the correct type
    DocumentSnapshot individualDoc = await FirebaseFirestore.instance.collection('individuals').doc(uid).get();
    if (individualDoc.exists) {
      return 'individuals';
    }

    DocumentSnapshot associationDoc = await FirebaseFirestore.instance.collection('associations').doc(uid).get();
    if (associationDoc.exists) {
      return 'associations';
    }

    throw Exception('User type not found');
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Optional: implement any undo action if necessary
          },
        ),
      ),
    );
  }
}
