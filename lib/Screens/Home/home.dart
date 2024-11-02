import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  // Mock data to simulate volunteer opportunities
  final List<Map<String, String>> volunteerOpportunities = [
    {
      'title': 'TEMA Domestic Tree Planting 2024',
      'description': 'We need volunteers to help us on the field!',
      'photoUrl': 'https://images.unsplash.com/photo-1637531347055-4fa8aa80c111?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'details': 'Join us for a day of planting trees to help restore our local environment. Supplies will be provided.',
      'time': '9:00 AM - 3:00 PM',
      'place': 'City Park, Çankaya/Ankara',
      'date': 'March 15, 2024',
      'quota': '50 volunteers'
    },
    {
      'title': 'Community Gardening for Fresh Produce',
      'description': 'We need volunteers who can grow fresh vegetables and herbs. The produce can be donated to local food banks or families in need, supporting food security in the area.',
      'photoUrl': 'https://images.unsplash.com/photo-1515150144380-bca9f1650ed9?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'details': 'Help us plant and maintain a community garden where we will grow fresh produce for those in need. No gardening experience necessary.',
      'time': '10:00 AM - 1:00 PM',
      'place': 'Community Garden, Çankaya/Ankara',
      'date': 'April 10, 2024',
      'quota': '30 volunteers'
    },
    {
      'title': 'Animal Shelter Support',
      'description': 'Join us in supporting our local animal shelter by helping care for the animals.',
      'photoUrl': 'https://images.unsplash.com/photo-1593991910379-b414c1e3bd74?q=80&w=2045&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'details': 'Assist with feeding, cleaning, and playing with animals at the shelter. This is a great opportunity for animal lovers!',
      'time': '11:00 AM - 4:00 PM',
      'place': 'Happy Paws Animal Shelter, Etlik/Ankara',
      'date': 'February 20, 2024',
      'quota': '20 volunteers'
    },
    {
      'title': 'Elderly Assistance',
      'description': 'Support seniors by providing companionship and assistance.',
      'photoUrl': 'https://images.unsplash.com/photo-1454875392665-2ac2c85e8d3e?q=80&w=1886&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'details': 'Join us in visiting seniors, providing companionship, and helping them with daily tasks. Your presence can make a big difference!',
      'time': '1:00 PM - 3:00 PM',
      'place': 'Senior Center, Etimesgut/Ankara',
      'date': 'January 5, 2024',
      'quota': '25 volunteers'
    },
  ];

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
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        itemCount: volunteerOpportunities.length,
        itemBuilder: (context, index) {
          final opportunity = volunteerOpportunities[index];
          return VolunteerOpportunityCard(data: opportunity);
        },
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}

class VolunteerOpportunityCard extends StatefulWidget {
  final Map<String, String> data;

  VolunteerOpportunityCard({required this.data});

  @override
  _VolunteerOpportunityCardState createState() => _VolunteerOpportunityCardState();
}

class _VolunteerOpportunityCardState extends State<VolunteerOpportunityCard> {
  bool _isExpanded = false; // State variable for expansion

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded; // Toggle expansion state
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display volunteer work image with the specified URL
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
              child: Image.network(
                widget.data['photoUrl'] ?? 'https://example.com/default.jpg',
                fit: BoxFit.cover,
                height: 220,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['title'] ?? 'Volunteer Work',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.data['description'] ?? 'No description available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Divider(color: Colors.grey[300]),
                  // Show additional details when expanded
                  if (_isExpanded) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('Date: ${widget.data['date'] ?? 'N/A'}', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 8),
                          Text('Time: ${widget.data['time'] ?? 'N/A'}', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 8),
                          Text('Place: ${widget.data['place'] ?? 'N/A'}', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 8),
                          Text('Quota: ${widget.data['quota'] ?? 'N/A'}', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 12),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ActionButton(
                        icon: Icons.check_circle_outline,
                        label: 'Attend',
                        onTap: () {
                          // Logic to attend the volunteer opportunity
                        },
                      ),
                      _ActionButton(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        onTap: () {
                          // Logic to share the opportunity
                        },
                      ),
                    ],
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

// Custom widget for action buttons
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 22),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}