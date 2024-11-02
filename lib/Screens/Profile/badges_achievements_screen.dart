import 'package:flutter/material.dart';

class BadgesAchievementsScreen extends StatelessWidget {
  // Mock data for badges
  final List<Map<String, String>> badges = [
    {
      'image': 'lib/assets/images/badges/doyourfirstgreen.png',
      'name': 'Green First!',
      'description': 'Awarded for completing your first green activity.'
    },
    {
      'image': 'lib/assets/images/badges/ThreeJob.png',
      'name': 'Community Helper',
      'description': 'Awarded for helping the community 5 times.'
    },
    {
      'image': 'lib/assets/images/badges/YourFirstJob.png',
      'name': 'Eco Warrior',
      'description': 'Awarded for participating in environmental activities.'
    },
    {
      'image': 'lib/assets/images/badges/threejobinarow.png',
      'name': 'Senior Supporter',
      'description': 'Awarded for providing assistance to seniors.'
    },
    {
      'image': 'lib/assets/images/badges/fiveanimalshelter.png',
      'name': 'Food Drive Champion',
      'description': 'Awarded for organizing a food drive.'
    },
    {
      'image': 'lib/assets/images/badges/tengreenjob.png',
      'name': 'Ten Green Jobs',
      'description': 'Awarded for completing ten green jobs.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Badges & Achievements")),
      body: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          return BadgeCard(
            image: badges[index]['image']!,
            name: badges[index]['name']!,
            description: badges[index]['description']!,
          );
        },
      ),
    );
  }
}

class BadgeCard extends StatelessWidget {
  final String image;
  final String name;
  final String description;

  BadgeCard({required this.image, required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Container with BoxDecoration to add circular shadow
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orangeAccent.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 25,
                  offset: Offset(0, 4), // changes position of shadow
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                image,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
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
    );
  }
}
