import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String? scannedBarcode;
  final List<String> activities = [
    'Activity 1',
    'Activity 2',
    'Activity 3',
    'Activity 4',
  ]; // Mock activities

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
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select an Activity to Create QR Code',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(activities[index]),
                      onTap: () {
                        // Here you can create a QR code with the selected activity
                        String qrData = activities[index]; // Replace with QR data
                        print('QR Code Data: $qrData'); // Simulate QR code creation
                        Navigator.pop(context); // Close the bottom sheet
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
        width: double.infinity, // Ensure the container fills the width
        height: double.infinity, // Ensure the container fills the height
        color: Colors.white, // Set the background color to white
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
                backgroundColor: Colors.orange, // Button background color
                foregroundColor: Colors.white, // Button text color
                elevation: 5, // Shadow for depth
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Padding
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: Text('Start Scan'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showActivitySelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Same button background color
                foregroundColor: Colors.white, // Button text color
                elevation: 5, // Shadow for depth
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Padding
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
