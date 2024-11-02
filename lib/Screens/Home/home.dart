import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  // Mock data to simulate volunteer opportunities
  final List<Map<String, String>> volunteerOpportunities = [
    {
      'title': 'Park Cleanup',
      'description': 'Help us clean and beautify the local park.',
    },
    {
      'title': 'Food Drive',
      'description': 'Assist in collecting and distributing food to families in need.',
    },
    {
      'title': 'Tree Planting',
      'description': 'Join us in planting trees to make our community greener.',
    },
    {
      'title': 'Elderly Assistance',
      'description': 'Support seniors by providing companionship and assistance.',
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

class VolunteerOpportunityCard extends StatelessWidget {
  final Map<String, String> data;

  VolunteerOpportunityCard({required this.data});

  String getImageUrl(String title) {
    // Generate URL with unique seed based on title
    final seed = title.replaceAll(' ', '_');
    return 'https://picsum.photos/seed/$seed/400/300';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Display volunteer work image with consistent seed-based random image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
            child: Image.network(
              getImageUrl(data['title'] ?? 'volunteer_opportunity'),
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
                  data['title'] ?? 'Volunteer Work',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  data['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12),
                Divider(color: Colors.grey[300]),
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
