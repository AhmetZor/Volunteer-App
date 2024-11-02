import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Position> getLocation() async
{
  return Geolocator.getCurrentPosition();
}

class EventMap extends StatefulWidget {
  @override
  _EventMapState createState() => _EventMapState();
}

class _EventMapState extends State<EventMap> {

  late GoogleMapController mapController;

  final Set<Marker> _markers = {};



  void _onMapCreated(GoogleMapController controller) async {
    Position position = await getLocation();
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude))));

    // Add markers for your events
    _markers.add(Marker(
      markerId: MarkerId('event1'),
      position: LatLng(position.latitude, position.longitude), // Example coordinates
      infoWindow: InfoWindow(title: 'Event 1', snippet: 'Details about Event 1'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Viewer Map')),
      body: GoogleMap(
        myLocationButtonEnabled: false,
        onMapCreated: _onMapCreated,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(40.7128, -74.0060), // Center the map
          zoom: 12,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: (){},
        child: const Icon(Icons.my_location, size:30)
      ),
    );
  }
}

