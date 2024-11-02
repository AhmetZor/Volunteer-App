import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String? scannedBarcode;
  List<Map<String, dynamic>> activities = []; // List to hold fetched activities with more details

  @override
  void initState() {
    super.initState();
    _fetchActivities(); // Fetch activities when the screen is initialized
  }

  Future<void> _fetchActivities() async {
    final User? user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      print('Fetching activities for user ID: ${user.uid}'); // Debug print for user ID
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('events') // Replace with your collection name
            .where('userId', isEqualTo: user.uid) // Match user ID
            .get();

        print('Documents retrieved: ${querySnapshot.docs.length}'); // Print number of documents retrieved

        // Map the results to a list of activity data
        setState(() {
          activities = querySnapshot.docs.map((doc) {
            print('Document ID: ${doc.id}'); // Print document ID for each activity
            print('Document data: ${doc.data()}'); // Print each document's data
            return {
              'title': doc['title'] as String, // Event title
              'description': doc['description'] as String, // Event description
              'date': (doc['date'] as Timestamp).toDate(), // Convert Timestamp to DateTime
              'time': doc['time'] as String, // Event time as String
            };
          }).toList();
        });

        if (activities.isEmpty) {
          print('No activities found for user ID: ${user.uid}'); // Print if no activities are found
        }
      } catch (e) {
        print('Error fetching activities: $e'); // Print any errors
      }
    } else {
      print('No user is currently logged in.'); // Handle case where user is null
    }
  }

  Future<void> _scanQRCode() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        scannedBarcode = result.rawContent; // Get the scanned QR code value
      });
      print('Barcode found: $scannedBarcode');
    } catch (e) {
      print('Error scanning barcode: $e');
    }
  }

  void _showActivitySelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, // Set background color of bottom sheet
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Rounded top corners
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select an Activity to Create QR Code',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold), // Increased title font size
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8), // Margin between cards
                      elevation: 4, // Shadow effect
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16), // Padding inside the card
                        title: Text(
                          activities[index]['title'],
                          style: TextStyle(
                            fontSize: 22, // Further increased font size for title
                            fontWeight: FontWeight.bold, // Bold for better readability
                            color: Colors.orange, // Custom title color
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              activities[index]['description'],
                              style: TextStyle(
                                fontSize: 18, // Further increased font size for description
                                fontWeight: FontWeight.bold, // Bold for readability
                                color: Colors.grey[600], // Lighter description color
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Date: ${activities[index]['date'].toString().split(' ')[0]}',
                              style: TextStyle(
                                fontSize: 16, // Increased font size for date
                                fontWeight: FontWeight.bold, // Bold for readability
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Time: ${activities[index]['time']}',
                              style: TextStyle(
                                fontSize: 16, // Increased font size for time
                                fontWeight: FontWeight.bold, // Bold for readability
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.orange), // Trailing icon for navigation
                        onTap: () {
                          String qrData = activities[index]['title']; // QR data
                          print('QR Code Data: $qrData');
                          Navigator.pop(context); // Close the bottom sheet
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }




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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Colors.orange,
            ),
            SizedBox(height: 20),
            Text(
              scannedBarcode != null
                  ? 'Scanned: $scannedBarcode'
                  : 'Scan a QR code \nTo Join The Event',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _scanQRCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: Text('Start Scan'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showActivitySelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: Text('Create QR for Activity'),
            ),
          ],
        ),
      ),
    );
  }
}
