import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventMap extends StatefulWidget {
  @override
  _EventMapState createState() => _EventMapState();
}

class _EventMapState extends State<EventMap> {
  late GoogleMapController mapController;

  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // Add markers for your events
    _markers.add(Marker(
      markerId: MarkerId('event1'),
      position: LatLng(40.7128, -74.0060), // Example coordinates
      infoWindow: InfoWindow(title: 'Event 1', snippet: 'Details about Event 1'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Viewer Map')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(40.7128, -74.0060), // Center the map
          zoom: 12,
        ),
      ),
    );
  }
}
