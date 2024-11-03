import 'package:flutter/material.dart';
import 'dart:math';

class MemberedSocietiesScreen extends StatelessWidget {
  // Mock data for membered societies with image URLs
  final List<Map<String, String>> societies = [
    {
      'name': 'Environmental Society',
      'description': 'Focuses on promoting sustainability and eco-friendliness.',
      'image': 'https://i.pinimg.com/564x/d0/3a/c4/d03ac4890025efb6335ee2fdbcc57906.jpg',
    },
    {
      'name': 'Animal Rights Group',
      'description': 'Advocates for the welfare of animals and their rights.',
      'image': 'https://i.pinimg.com/564x/63/15/0a/63150ac4cb4815bf8af9299ecc313a77.jpg',
    },
    {
      'name': 'Community Helpers',
      'description': 'Engages in various community service projects.',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSO5AyvJwwjl-i-Gjs6xkpkTFBhvvsZFj-Ulw&s',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Membered Societies")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: societies.length,
          itemBuilder: (context, index) {
            return SocietyCard(
              name: societies[index]['name']!,
              description: societies[index]['description']!,
              imageUrl: societies[index]['image']!,
            );
          },
        ),
      ),
    );
  }
}

class SocietyCard extends StatefulWidget {
  final String name;
  final String description;
  final String imageUrl;

  SocietyCard({required this.name, required this.description, required this.imageUrl});

  @override
  _SocietyCardState createState() => _SocietyCardState();
}

class _SocietyCardState extends State<SocietyCard> {
  String? persistentDate;

  // Generate a random date
  void generateRandomDate() {
    final random = Random();
    final year = 2023 + random.nextInt(2); // Random year in 2023 or 2024
    final month = 1 + random.nextInt(12);
    final day = 1 + random.nextInt(28);

    setState(() {
      persistentDate = "$day/${month.toString().padLeft(2, '0')}/$year";
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (persistentDate == null) {
          generateRandomDate(); // Generate date only if it hasn't been generated before
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  if (persistentDate != null) // Display the date if generated
                    Text(
                      "Joined on: $persistentDate",
                      style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
