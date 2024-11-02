import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:volunteerfind/Screens/Camera/photo_gallery_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String? scannedBarcode;
  List<Map<String, dynamic>> activities = [];
  String? selectedActivityId;
  List<Map<String, dynamic>> attendedEvents = []; // List to hold attended events

  @override
  void initState() {
    super.initState();
    _fetchActivities();
    _fetchAttendedEvents();
  }

  Future<void> _fetchActivities() async {
    final User? user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('events') // Replace with your collection name
            .where('userId', isEqualTo: user.uid) // Match user ID
            .get();
        // Map the results to a list of activity data
        setState(() {
          activities = querySnapshot.docs.map((doc) {
            return {
              'id': doc.id,
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






  Future<void> _fetchAttendedEvents() async {
    final User? user = FirebaseAuth.instance.currentUser;

    // Print user ID for debugging purposes
    print('Attempting to fetch attended events for user: ${user?.uid}');

    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('attendance')
            .where('userId', isEqualTo: user.uid)
            .get();

        // Print the number of documents found in the query
        print('QuerySnapshot obtained: ${querySnapshot.docs.length} documents');

        setState(() {
          attendedEvents = querySnapshot.docs.map((doc) {
            var eventId = doc['eventId'];
            var timestamp = (doc['timestamp'] as Timestamp).toDate();

            // Print the entire document data for further inspection
            print('Document ID: ${doc.id}, Data: ${doc.data()}');

            // Print eventId and timestamp for each document
            print('Fetched eventId: $eventId, Timestamp: $timestamp');

            return {
              'eventId': eventId,
              'timestamp': timestamp,
            };
          }).toList();
        });

        // Print the final list of attended events for verification
        print('Attended events fetched successfully: $attendedEvents');

      } catch (e) {
        print('Error fetching attended events: $e');
      }
    } else {
      print('No user is currently logged in.'); // Print message if user is null
    }
  }



  Future<void> _scanQRCode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        setState(() {
          scannedBarcode = result.rawContent;
        });
        await _registerAttendance(scannedBarcode);
      } else {
        setState(() {
          scannedBarcode = null;
        });
      }
    } catch (e) {
      print('Error scanning barcode: $e');
    }
  }

  Future<void> _registerAttendance(String? activityId) async {
    if (activityId != null) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance.collection('attendance').add({
            'userId': user.uid,
            'eventId': activityId,
            'timestamp': FieldValue.serverTimestamp(),
          });
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PhotoGalleryScreen(eventId: activityId),
            ),
          );
        } catch (e) {
          print('Error recording attendance: $e');
        }
      }
    }
  }

  void _showActivitySelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select an Activity to Create QR Code',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          activities[index]['title'],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              activities[index]['description'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Date: ${activities[index]['date'].toString().split(' ')[0]}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Time: ${activities[index]['time']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.orange),
                        onTap: () {
                          setState(() {
                            selectedActivityId = activities[index]['id']; // Get the document ID here
                          });
                          _generateQRCode();
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

  void _generateQRCode() {
    if (selectedActivityId == null) {
      print('No activity selected to generate QR Code');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('QR Code'),
          content: SizedBox(
            width: 250, // Specify a width for the dialog
            child: SingleChildScrollView( // Allow scrolling if necessary
              child: Column(
                mainAxisSize: MainAxisSize.min, // Minimize the height based on children
                children: [
                  QrImageView(
                    data: selectedActivityId!,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  SizedBox(height: 20),
                  Text('Scan this QR code to join the event!'),
                  SizedBox(height: 10),
                  Text(
                    'Embedded Data: $selectedActivityId', // Display embedded data
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }



  void _showAttendedEvents() {
    _fetchAttendedEvents(); // Fetch attended events before displaying them
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attended Events',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: attendedEvents.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: attendedEvents[index]['eventId'] != null && attendedEvents[index]['eventId'].isNotEmpty
                          ? FirebaseFirestore.instance
                          .collection('events')
                          .doc(attendedEvents[index]['eventId'])
                          .get()
                          : Future.value(null),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return ListTile(title: Text('Error fetching event data'));
                        }
                        var eventData = snapshot.data?.data() as Map<String, dynamic>?; // Handle null safely
                        if (eventData == null || eventData.isEmpty || !eventData.containsKey('title')) {
                          return ListTile(title: Text('Event data not found'));
                        }
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              eventData['title'] as String,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            subtitle: Text(
                              eventData['description'] as String,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            onTap: () {
                              // Navigate to PhotoGalleryScreen with the eventId
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhotoGalleryScreen(eventId: attendedEvents[index]['eventId']),
                                ),
                              );
                            },
                          ),
                        );
                      },
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
              child: Text('Scan QR Code'),
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
              child: Text('Generate QR Code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAttendedEvents, // New button to view attended events
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
              child: Text('View Attended Events'),
            ),
          ],
        ),
      ),
    );
  }
}
