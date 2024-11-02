import 'package:flutter/material.dart';
import 'dart:math'; // Import to use Random

class AttendedEventsScreen extends StatelessWidget {
  // Mock data for attended events
  final List<Map<String, String>> attendedEvents = [
    {
      'image': 'https://globalnomadic.com/wp-content/uploads/2024/02/AdobeStock_644054501.jpeg',
      'title': 'Community Clean-Up Day',
      'description': 'Participated in cleaning the local park and river.'
    },
    {
      'image': 'https://caritaspenang.com/wp-content/uploads/2021/08/whiteflag3-768x1024.jpeg',
      'title': 'Food Drive',
      'description': 'Helped collect food donations for families in need.'
    },
    {
      'image': 'https://images.pexels.com/photos/1072824/pexels-photo-1072824.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      'title': 'Tree Planting',
      'description': 'Joined the initiative to plant trees in the community.'
    },
    {
      'image': 'https://www.fote.org.uk/wp-content/uploads/2017/03/about-us-2-1600x573.jpg',
      'title': 'Senior Support Program',
      'description': 'Provided companionship to local seniors.'
    },
    {
      'image': 'https://dv9b2v6p3dpu5.cloudfront.net/transforms/general/9394/Volunteer_Intro_6c0c164bd2b597ee32b68b8b5755bd2e.jpg',
      'title': 'Animal Shelter Volunteer',
      'description': 'Volunteered at the local animal shelter to help care for pets.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attended Events")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: attendedEvents.length,
          itemBuilder: (context, index) {
            return EventCard(
              image: attendedEvents[index]['image']!,
              title: attendedEvents[index]['title']!,
              description: attendedEvents[index]['description']!,
            );
          },
        ),
      ),
    );
  }
}

class EventCard extends StatefulWidget {
  final String image;
  final String title;
  final String description;

  EventCard({required this.image, required this.title, required this.description});

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  String? randomDate;

  void generateRandomDate() {
    // Generate a random date
    final random = Random();
    final year = 2023 + random.nextInt(2); // Random year in 2023 or 2024
    final month = 1 + random.nextInt(12); // Random month
    final day = 1 + random.nextInt(28); // Random day (1-28)

    // Format the random date as a string
    setState(() {
      randomDate = "$day/${month.toString().padLeft(2, '0')}/$year"; // Format as dd/mm/yyyy
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (randomDate == null) {
          generateRandomDate(); // Generate date only if not already generated
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display event image
            Container(
              height: 100,
              child: Image.network(
                widget.image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Flexible( // Use Flexible to avoid overflow
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.description,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis, // Handle overflow
                  maxLines: 2, // Limit number of lines
                ),
              ),
            ),
            SizedBox(height: 8),
            if (randomDate != null) // Display the random date if generated
              Text(
                "Date: $randomDate",
                style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
