import 'package:flutter/material.dart';

class MemberedSocietiesScreen extends StatelessWidget {
  // Mock data for membered societies with image URLs
  final List<Map<String, String>> societies = [
    {
      'name': 'Environmental Society',
      'description': 'Focuses on promoting sustainability and eco-friendliness.',
      'image': 'https://i.pinimg.com/564x/d0/3a/c4/d03ac4890025efb6335ee2fdbcc57906.jpg', // Replace with actual image URL
    },
    {
      'name': 'Animal Rights Group',
      'description': 'Advocates for the welfare of animals and their rights.',
      'image': 'https://i.pinimg.com/564x/63/15/0a/63150ac4cb4815bf8af9299ecc313a77.jpg', // Replace with actual image URL
    },
    {
      'name': 'Community Helpers',
      'description': 'Engages in various community service projects.',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSO5AyvJwwjl-i-Gjs6xkpkTFBhvvsZFj-Ulw&s', // Replace with actual image URL
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

class SocietyCard extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;

  SocietyCard({required this.name, required this.description, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display the society image
          Expanded(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    description,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
