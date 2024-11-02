import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Import path_provider

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadLocalProfileImage(); // Load the profile image when the screen is initialized
  }

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
      body: FutureBuilder<User?>(
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

  void _loadLocalProfileImage() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagePath = '${appDir.path}/$userId.jpg';

      final File localImageFile = File(imagePath);
      if (await localImageFile.exists()) {
        setState(() {
          _profileImage = localImageFile; // Load the local image into the state
        });
      }
    }
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

        // Save to local storage
        String localPath = await _saveImageLocally(_profileImage!, _auth.currentUser!.uid);
        if (localPath.isNotEmpty) {
          showSnackbar(context, "Profile Image Saved.");
        }
      }
    }
  }

  Future<String> _saveImageLocally(File imageFile, String userId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagePath = '${appDir.path}/$userId.jpg'; // Use user ID as filename
      final File localImageFile = await imageFile.copy(imagePath);
      return localImageFile.path; // Return local image path
    } catch (e) {
      showSnackbar(context, "Error Saving Image: ${e.toString()}");
      return '';
    }
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
