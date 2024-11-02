import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img; // Import the image package
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart'; // Import this for loading asset images
import 'dart:typed_data';
import '../../Constant/colors.dart'; // Ensure this file includes your AppColors class.

class EventMap extends StatefulWidget {
  @override
  _EventMapState createState() => _EventMapState();
}

class _EventMapState extends State<EventMap> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  late Position currentPosition;

  // Sample voluntary work event names
  final List<String> eventNames = [
    "Beach Cleanup",
    "Tree Planting",
    "Park Beautification",
    "Community Gardening",
    "Animal Shelter Volunteering",
    "Food Bank Assistance",
    "Recycling Drive",
    "Youth Mentorship",
    "School Supply Drive",
    "Neighborhood Litter Patrol"
  ];

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    // Get current location and move the camera to it
    currentPosition = await _getCurrentPosition();
    LatLng userLocation = LatLng(currentPosition.latitude, currentPosition.longitude);
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: userLocation,
          zoom: 14,
        ),
      ),
    );

    // Add a marker for the current location
    _addMarker(userLocation, "My Location", "This is where you are", AppColors.orange); // Set marker color to orange

    // Add mock voluntary work event markers nearby
    _addMockEventMarkers(userLocation);
  }

  void _addMockEventMarkers(LatLng userLocation) {
    int numberOfEvents = 10;
    double maxDistanceInMeters = 2000; // max radius for random markers

    for (int i = 0; i < numberOfEvents; i++) {
      LatLng randomPosition = _generateRandomLocation(userLocation, maxDistanceInMeters);
      String eventName = eventNames[i % eventNames.length]; // Cycle through event names

      // Calculate distance from the user's current location
      double distance = _calculateDistance(userLocation, randomPosition);

      _addMarker(randomPosition, eventName, 'Join us for $eventName\nDistance: ${distance.toStringAsFixed(2)} meters', AppColors.orange); // Use AppColors.orange
    }
  }

  Future<void> _addMarker(LatLng position, String title, String snippet, Color color) async {
    final markerIcon = await _getMarkerIcon(); // Get the custom marker icon from asset
    final marker = Marker(
      markerId: MarkerId(title),
      position: position,
      infoWindow: InfoWindow(title: title, snippet: snippet),
      icon: markerIcon, // Use the custom icon
      onTap: () => _showEventDetails(title, snippet),
    );

    _markers.add(marker);
    setState(() {});
  }

  Future<BitmapDescriptor> _getMarkerIcon() async {
    // Load the image as a ByteData object
    final byteData = await rootBundle.load('lib/assets/images/Maps.png');
    // Convert the ByteData to a Uint8List
    final Uint8List imageData = byteData.buffer.asUint8List();

    // Decode the image and resize it
    img.Image originalImage = img.decodeImage(imageData)!;
    img.Image resizedImage = img.copyResize(originalImage, width: 130); // Resize to desired width

    // Convert the resized image back to Uint8List
    Uint8List resizedImageData = Uint8List.fromList(img.encodePng(resizedImage));

    // Create a BitmapDescriptor from the resized image data
    return BitmapDescriptor.fromBytes(resizedImageData);
  }

  double _calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(from.latitude, from.longitude, to.latitude, to.longitude);
  }

  void _showEventDetails(String title, String snippet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 250, // Adjust height as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  snippet,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEventList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 400, // Adjust height as needed
            child: ListView.builder(
              itemCount: _markers.length,
              itemBuilder: (context, index) {
                // Convert the markers set to a list for safe indexing
                final markerList = _markers.toList();
                final marker = markerList[index];

                // Safely extract distance from the snippet
                String? distance;
                if (marker.infoWindow.snippet != null) {
                  List<String> snippetLines = marker.infoWindow.snippet!.split('\n');
                  if (snippetLines.length > 1) {
                    distance = snippetLines[1]; // Get the distance line
                  }
                }

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(marker.infoWindow.title ?? ''),
                    subtitle: Text('${marker.infoWindow.snippet?.split('\n')[0] ?? ''}\n$distance'),
                    onTap: () {
                      Navigator.of(context).pop(); // Close the list
                      _showEventDetails(marker.infoWindow.title ?? '', marker.infoWindow.snippet ?? '');
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  LatLng _generateRandomLocation(LatLng location, double distance) {
    final random = Random();
    double radiusInDegrees = distance / 111320;

    double u = random.nextDouble();
    double v = random.nextDouble();
    double w = radiusInDegrees * sqrt(u);
    double t = 2 * pi * v;
    double newLat = location.latitude + w * cos(t);
    double newLng = location.longitude + w * sin(t) / cos(location.latitude * pi / 180);

    return LatLng(newLat, newLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Viewer Map')),
      body: GoogleMap(
        myLocationEnabled: true,
        onMapCreated: _onMapCreated,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(40.7128, -74.0060), // Default starting location
          zoom: 12,
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30.0, bottom: 80.0), // Adjust padding as needed
        child: Align(
          alignment: Alignment.bottomLeft,
          child: FloatingActionButton(
            backgroundColor: AppColors.orange,
            onPressed: _showEventList,
            child: Icon(Icons.list, color: AppColors.white),
            tooltip: 'Show Events',
          ),
        ),
      ),
    );
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
}
