import 'package:flutter/material.dart';
import 'dart:ui'; // Import for ImageFilter
import 'RootScreen.dart'; // Ensure this import is correct
import '../Constant/colors.dart';

class LoginRegisterScreen extends StatefulWidget {
  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool isLogin = true; // Toggle between login and registration

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void toggleView() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void handleSubmit() {
    final email = emailController.text;
    final password = passwordController.text;

    // Basic validation (you can enhance this)
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Simulating login/registration process
    if (isLogin) {
      print('Logging in with $email and $password');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RootScreen()),
      );
    } else {
      print('Registering with $email and $password');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RootScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              'https://picsum.photos/seed/picsum/800/600', // Adjusted size for better resolution
              fit: BoxFit.cover,
            ),
          ),
          // Blur effect on the background image
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Apply blur
              child: Container(
                color: AppColors.white.withOpacity(0.75), // Dark overlay for contrast
              ),
            ),
          ),
          // Main content
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
                        isLogin ? 'Welcome to Volunteered' : 'Register', textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.orange,
                          fontFamily: 'Euclid-Circular-A-Bold',
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: AppColors.grey.withOpacity(0.4),fontFamily: "Euclid-Circular-A-Regular"),
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
                          labelStyle: TextStyle(color: AppColors.grey.withOpacity(0.4),fontFamily: "Euclid-Circular-A-Regular"),
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
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: AppColors.orange, // Button color
                        ),
                        child: Text(
                          isLogin ? 'Login' : 'Register',
                          style: TextStyle(fontSize: 18, color: Colors.white,fontFamily: 'Euclid Circular A'),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: toggleView,
                        child: Text(
                          isLogin ? 'Don\'t have an account? Register' : 'Already have an account? Login',
                          style: TextStyle(color: AppColors.grey.withOpacity(0.65)),
                        ),
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
