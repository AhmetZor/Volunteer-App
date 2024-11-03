import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'RootScreen.dart';
import '../Constant/colors.dart';
import 'VideoScreen.dart'; // Import the VideoScreen for animation

class LoginRegisterScreen extends StatefulWidget {
  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool isLogin = true; // Toggle between login and registration
  int selectedUserType = 0; // 0 for Individual, 1 for Association

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController associationNameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void toggleView() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void selectUserType(int index) {
    setState(() {
      selectedUserType = index;
    });
  }

  Future<void> handleSubmit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();
    final surname = surnameController.text.trim();
    final ageStr = ageController.text.trim(); // Keep it as string for validation
    final associationName = associationNameController.text.trim();

    if (email.isEmpty || password.isEmpty ||
        (!isLogin && selectedUserType == 1 && associationName.isEmpty) ||
        (!isLogin && selectedUserType == 0 && (name.isEmpty || surname.isEmpty || ageStr.isEmpty))) {
      showError('Please fill in all fields');
      return;
    }

    try {
      UserCredential userCredential;
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Convert age from String to int
        int age = int.tryParse(ageStr) ?? 0; // Default to 0 if parsing fails

        // Store user data in Firestore based on user type
        if (selectedUserType == 0) {
          await storeIndividualData(userCredential.user, name, surname, age);
        } else {
          await storeAssociationData(userCredential.user, associationName);
        }
      }

      // Show looping animation on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VideoScreen(nextScreen: RootScreen()),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = getFriendlyErrorMessage(e);
      showError(errorMessage);
    } catch (e) {
      showError('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> storeIndividualData(User? user, String name, String surname, int age) async {
    if (user != null) {
      CollectionReference users = FirebaseFirestore.instance.collection('individuals');
      await users.doc(user.uid).set({
        'email': user.email,
        'uid': user.uid,
        'name': name,
        'surname': surname,
        'age': age, // Now stored as an integer
        'createdAt': FieldValue.serverTimestamp(), // Optional: Timestamp for creation time
        'profilePicture': null, // Initially set to null
      });
    }
  }

  Future<void> storeAssociationData(User? user, String associationName) async {
    if (user != null) {
      CollectionReference associations = FirebaseFirestore.instance.collection('associations');
      await associations.doc(user.uid).set({
        'email': user.email,
        'uid': user.uid,
        'associationName': associationName,
        'createdAt': FieldValue.serverTimestamp(), // Optional: Timestamp for creation time
        'profilePicture': null, // Initially set to null
      });
    }
  }

  String getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password provided.';
      case 'email-already-in-use':
        return 'The email is already registered.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'An unexpected error occurred. Please try again later.';
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://picsum.photos/seed/picsum/800/600',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: AppColors.white.withOpacity(0.75),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLogin ? 'Welcome to Volunteered' : 'Register',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.orange,
                          fontFamily: 'Euclid-Circular-A-Bold',
                        ),
                      ),
                      SizedBox(height: 20),
                      if (!isLogin) ...[
                        ToggleButtons(
                          isSelected: [selectedUserType == 0, selectedUserType == 1],
                          onPressed: (int index) {
                            selectUserType(index);
                          },
                          borderColor: AppColors.orange,
                          selectedBorderColor: AppColors.orange,
                          selectedColor: Colors.white,
                          color: Colors.black,
                          fillColor: AppColors.orange,
                          borderRadius: BorderRadius.circular(12),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Individual'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Association'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                      if (!isLogin && selectedUserType == 0) ...[
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: AppColors.grey.withOpacity(0.4), fontFamily: "Euclid-Circular-A-Regular"),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.orange),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: surnameController,
                          decoration: InputDecoration(
                            labelText: 'Surname',
                            labelStyle: TextStyle(color: AppColors.grey.withOpacity(0.4), fontFamily: "Euclid-Circular-A-Regular"),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.orange),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: ageController,
                          decoration: InputDecoration(
                            labelText: 'Age',
                            labelStyle: TextStyle(color: AppColors.grey.withOpacity(0.4), fontFamily: "Euclid-Circular-A-Regular"),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.orange),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ] else if (!isLogin && selectedUserType == 1) ...[
                        TextField(
                          controller: associationNameController,
                          decoration: InputDecoration(
                            labelText: 'Association Name',
                            labelStyle: TextStyle(color: AppColors.grey.withOpacity(0.4), fontFamily: "Euclid-Circular-A-Regular"),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.orange),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: AppColors.grey.withOpacity(0.4), fontFamily: "Euclid-Circular-A-Regular"),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.orange),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: AppColors.grey.withOpacity(0.4), fontFamily: "Euclid-Circular-A-Regular"),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.orange),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: handleSubmit,
                        child: Text(isLogin ? 'Login' : 'Register'),
                      ),
                      TextButton(
                        onPressed: toggleView,
                        child: Text(isLogin ? 'Don\'t have an account? Register' : 'Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
