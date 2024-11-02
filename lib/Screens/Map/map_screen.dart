import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import '../../Constant/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventMap extends StatefulWidget {
  @override
  _EventMapState createState() => _EventMapState();
}

class _EventMapState extends State<EventMap> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final List<Marker> _allMarkers = [];
  late Position currentPosition;



  String _searchQuery = "";
  bool _isSearchVisible = false; // State variable for search visibility

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    currentPosition = await _getCurrentPosition();
    LatLng userLocation = LatLng(currentPosition.latitude, currentPosition.longitude);

    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: userLocation, zoom: 14),
    ));

    await _fetchEvents(); // Fetch events on map creation
  }

  Future<void> _fetchEvents() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('events').get();
      List<QueryDocumentSnapshot> events = snapshot.docs;

      Set<Marker> markers = events.map((event) {
        GeoPoint location = event['location'];
        String title = event['title'];
        String description = event['description'];
        String eventId = event.id; // Get the event document ID

        return Marker(
          markerId: MarkerId(eventId), // Use event document ID as marker ID
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: title,
            snippet: description,
          ),
        );
      }).toSet();

      setState(() {
        _markers.clear();
        _markers.addAll(markers); // Update markers on the map
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load events: $e")));
    }
  }



  Future<BitmapDescriptor> _getMarkerIcon() async {
    final byteData = await rootBundle.load('lib/assets/images/Maps.png');
    final Uint8List imageData = byteData.buffer.asUint8List();

    img.Image originalImage = img.decodeImage(imageData)!;
    img.Image resizedImage = img.copyResize(originalImage, width: 130);
    Uint8List resizedImageData = Uint8List.fromList(img.encodePng(resizedImage));

    return BitmapDescriptor.fromBytes(resizedImageData);
  }


  Future<void> _addMarker(LatLng location, String title, String description, DateTime date, TimeOfDay time, int quota) async {
    final User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      // Prepare event data
      Map<String, dynamic> eventData = {
        'userId': user.uid,
        'title': title,
        'description': description,
        'location': GeoPoint(location.latitude, location.longitude), // Store the location as GeoPoint
        'date': Timestamp.fromDate(date), // Store date as Timestamp
        'time': '${time.hour}:${time.minute}', // Store time as String
        'quota': quota,
        'createdAt': FieldValue.serverTimestamp(), // Optional: Timestamp for creation
      };

      // Save to Firestore
      try {
        await FirebaseFirestore.instance.collection('events').add(eventData);
        // Optionally, show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Event registered successfully!")));
        await _fetchEvents(); // Fetch events on map creation
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to register event: $e")));
      }
    }
  }




// Helper function to format the snippet
  String _formatSnippet(String snippet, String date, String time, int quota) {
    return "$snippet\nDate: $date\nTime: $time\nQuota: $quota";
  }



  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permanently denied");
    }

    return await Geolocator.getCurrentPosition();
  }

  double _calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(from.latitude, from.longitude, to.latitude, to.longitude);
  }


  void _showEventDetails(String title, String snippet, LatLng location, DateTime dateTime) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 400, // Increased height for more content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                SizedBox(height: 8),

                // Snippet
                Text(
                  snippet,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 10),

                // Display Location
                Text(
                  "Location: (${location.latitude}, ${location.longitude})",
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),

                // Display Date and Time
                Text(
                  "Date: ${dateTime.toLocal().toString().split(' ')[0]}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  "Time: ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Implement the registration action here
                        Navigator.of(context).pop(); // Close modal
                        //_registerForEvent(title); // Call registration function
                      },
                      icon: Icon(Icons.check_circle),
                      label: Text('Register'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700], // Button background color
                        foregroundColor: Colors.white, // Button text color
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the modal
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300], // Button background color
                        foregroundColor: Colors.black, // Button text color
                      ),
                      child: Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }





  void _filterMarkers(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _markers.clear(); // Clear current markers to update with filtered results

      // Filter markers based on the search query
      for (var marker in _allMarkers) {
        // Ensure that title and snippet are not null before calling toLowerCase()
        final title = marker.infoWindow.title?.toLowerCase() ?? '';
        final snippet = marker.infoWindow.snippet?.toLowerCase() ?? '';

        // Check if the title or snippet contains the search query
        if (title.contains(_searchQuery) || snippet.contains(_searchQuery)) {
          _markers.add(marker); // Add marker if it matches
        }
      }
    });
  }


  void _toggleSearchVisibility() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
  }









  void _showEventRegistrationDialog() {
    String title = "";
    String description = "";
    LatLng? selectedLocation; // Variable to hold the selected location
    String buttonText = "Select Location"; // Variable to hold button text
    DateTime? selectedDate; // Variable for the selected date
    TimeOfDay? selectedTime; // Variable for the selected time
    String quota = ""; // Variable for quota

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  "Register New Event",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.orange[700],
                  ),
                ),
                content: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Event Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                          ),
                          onChanged: (value) {
                            title = value;
                          },
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Event Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            description = value;
                          },
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Quota',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            quota = value;
                          },
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate; // Update selected date
                              });
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            selectedDate == null ? "Select Date" : "Date Selected: ${selectedDate!.toLocal()}".split(' ')[0],
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedTime ?? TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                selectedTime = pickedTime; // Update selected time
                              });
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            selectedTime == null ? "Select Time" : "Time Selected: ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            _selectLocation((location) {
                              selectedLocation = location; // Set the selected location
                              buttonText = "Location Selected"; // Update button text

                              // Show snackbar for location selection
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Location selected at: ${location.latitude}, ${location.longitude}")),
                              );

                              // Call setState to update the button text and UI in the dialog
                              setState(() {}); // Update the dialog UI
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            buttonText,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(height: 10),
                        if (selectedLocation != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "Selected Location: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}",
                              style: TextStyle(color: Colors.green[700]),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      if (title.isNotEmpty &&
                          description.isNotEmpty &&
                          selectedLocation != null &&
                          selectedDate != null &&
                          selectedTime != null &&
                          quota.isNotEmpty) {
                        _addMarker(selectedLocation!, title, description, selectedDate!, selectedTime!, int.parse(quota)); // Updated method call
                        Navigator.of(context).pop(); // Close dialog after confirming
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please fill in all fields and select a location.")),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Confirm", style: TextStyle(fontSize: 18)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text("Cancel", style: TextStyle(color: Colors.orange[700])),
                  ),
                ],
              );
            },
          );
        });
  }







  void _selectLocation(Function(LatLng) onLocationSelected) {
    if (currentPosition == null) {
      // Show a message to the user if currentPosition is not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to get current location.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        LatLng? selectedPosition; // Declare as nullable
        Marker? temporaryMarker; // Variable for the temporary marker

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Select Location"),
              content: Container(
                height: 400,
                width: 300,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  markers: Set<Marker>.of(_markers..addAll(temporaryMarker != null ? [temporaryMarker!] : [])), // Add temporary marker
                  onTap: (LatLng position) {
                    // Update selected position and show temporary marker
                    selectedPosition = position;
                    temporaryMarker = Marker(
                      markerId: MarkerId("temporary_location"),
                      position: selectedPosition!,
                      infoWindow: InfoWindow(title: "Selected Location"),
                    );

                    setState(() {
                      // Markers are refreshed when the temporary marker is set
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentPosition.latitude, currentPosition.longitude),
                    zoom: 14,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selectedPosition != null) {
                      onLocationSelected(selectedPosition!); // Return the location back

                      // Remove the temporary marker from the set of markers
                      _markers.removeWhere((marker) => marker.markerId.value == "temporary_location");

                      Navigator.of(context).pop(); // Close the dialog
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select a location.")),
                      );
                    }
                  },
                  child: Text('Confirm'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }











  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Viewer Map')),
      body: Column(
        children: [
          if (_isSearchVisible) // Show search bar if visible
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search Events',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: _filterMarkers,
                autofocus: true, // Optional: Focus on the text field when opened
                onSubmitted: (_) => _toggleSearchVisibility(), // Hide search when submitted
              ),
            ),
          Expanded(
            child: GoogleMap(
              myLocationEnabled: true,
              onMapCreated: _onMapCreated,
              markers: _markers,
              initialCameraPosition: CameraPosition(
                target: LatLng(40.7128, -74.0060), // Default location (New York)
                zoom: 12,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        alignment: Alignment.bottomLeft, // Align buttons to the bottom left
        padding: EdgeInsets.only(left: 24.0, bottom: 16.0), // Adjust left padding for position
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'search_button', // Unique tag for the search button
              backgroundColor: AppColors.orange,
              onPressed: _toggleSearchVisibility, // Toggle search bar visibility
              child: Icon(Icons.search, color: AppColors.white),
              tooltip: 'Search Events',
            ),
            SizedBox(height: 16), // Space between buttons
            FloatingActionButton(
              heroTag: 'event_list_button', // Unique tag for the event list button
              backgroundColor: AppColors.orange,
              onPressed: _showEventList,
              child: Icon(Icons.list, color: AppColors.white),
              tooltip: 'Show Events',
            ),
            SizedBox(height: 16), // Space between buttons
            FloatingActionButton(
              heroTag: 'register_event_button', // Unique tag for the register event button
              backgroundColor: AppColors.orange,
              onPressed: _showEventRegistrationDialog, // Show event registration dialog
              child: Icon(Icons.add, color: AppColors.white),
              tooltip: 'Register Event',
            ),
          ],
        ),
      ),
    );
  }



  void _showEventList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Rounded top corners
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 400,
            child: Column(
              children: [
                Text(
                  "Event List",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                SizedBox(height: 16), // Space between title and list
                Expanded(
                  child: _markers.isNotEmpty
                      ? ListView.builder(
                    itemCount: _markers.length,
                    itemBuilder: (context, index) {
                      final markerList = _markers.toList(); // Convert Set to List
                      final marker = markerList[index]; // Access using index

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 4, // Slight elevation for depth
                        child: ListTile(
                          leading: Icon(Icons.event, size: 40, color: Colors.orange[700]), // Event icon
                          title: Text(
                            marker.infoWindow.title ?? 'No Title',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(marker.infoWindow.snippet ?? 'No Description'),
                          onTap: () {
                            Navigator.of(context).pop(); // Close the bottom sheet
                            // Pass position and date as well to the details function
                            _showEventDetails(
                                marker.infoWindow.title ?? '',
                                marker.infoWindow.snippet ?? '',
                                marker.position,
                                DateTime.now() // Or however you want to handle the date
                            );
                            _animateToMarker(marker.position); // Animate map to marker
                          },
                        ),
                      );
                    },
                  )
                      : Center(
                    child: Text(
                      "No events available",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }




  void _animateToMarker(LatLng position) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 14), // Adjust zoom level as needed
    ));
  }
}
