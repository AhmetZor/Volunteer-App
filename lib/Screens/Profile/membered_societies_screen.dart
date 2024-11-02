import 'package:flutter/material.dart';

class MemberedSocietiesScreen extends StatelessWidget {
  // Mock data for membered societies
  final List<Map<String, String>> societies = [
    {
      'name': 'Environmental Society',
      'description': 'Focuses on promoting sustainability and eco-friendliness.',
    },
    {
      'name': 'Animal Rights Group',
      'description': 'Advocates for the welfare of animals and their rights.',
    },
    {
      'name': 'Community Helpers',
      'description': 'Engages in various community service projects.',
    },
    {
      'name': 'Literature Club',
      'description': 'Encourages reading and discussion of literary works.',
    },
    {
      'name': 'Tech Innovators',
      'description': 'Explores new technologies and promotes innovation.',
    },
    {
      'name': 'Art and Culture Society',
      'description': 'Promotes local art and cultural heritage.',
    },
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

  SocietyCard({required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
