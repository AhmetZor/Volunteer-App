import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class PhotoGalleryScreen extends StatelessWidget {
  final String eventId;

  PhotoGalleryScreen({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Private Album of',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _fetchEventData(eventId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.hasData && snapshot.data != null) {
              final eventData = snapshot.data!;
              final title = eventData['title'] as String? ?? 'Event';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('photos')
                          .where('eventId', isEqualTo: eventId)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                          return ListView(
                            children: snapshot.data!.docs.map((doc) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(doc['url']),
                              );
                            }).toList(),
                          );
                        }
                        // Centered message for no photos available
                        return Center(
                          child: Text(
                            'No photos available.',
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      },
                    ),
                  ),
                  // Centered button to take a photo
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: () => _takePhoto(context),
                        icon: Icon(Icons.camera),
                        label: Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, // Background color
                          foregroundColor: Colors.white, // Text color
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Text('No event data available.');
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchEventData(String eventId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching event data: $e');
    }
    return null;
  }

  Future<void> _takePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera); // Use the updated method

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      // Implement your upload logic here for imageFile.
      // For example, you can upload to Firebase Storage.
    } else {
      print('No image selected.');
    }
  }
}
