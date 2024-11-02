import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SocialsScreen extends StatelessWidget {
  // Mock data for volunteer opportunities with complete profile details
  final List<Map<String, dynamic>> volunteerOpportunities = [
    {
      'description': 'Help us clean and beautify the local park.',
      'images': [
        'https://picsum.photos/seed/park_cleanup1/400/300',
        'https://picsum.photos/seed/park_cleanup2/400/300',
        'https://picsum.photos/seed/park_cleanup3/400/300',
      ],
      'username': 'JohnDoe',
      'profileImage': 'https://picsum.photos/seed/profile1/50/50',
    },
    {
      'description': 'Assist in collecting and distributing food to families in need.',
      'images': [
        'https://picsum.photos/seed/food_drive1/400/300',
        'https://picsum.photos/seed/food_drive2/400/300',
        'https://picsum.photos/seed/food_drive3/400/300',
      ],
      'username': 'JaneSmith',
      'profileImage': 'https://picsum.photos/seed/profile2/50/50',
    },
    {
      'description': 'Join us in planting trees to make our community greener.',
      'images': [
        'https://picsum.photos/seed/tree_planting1/400/300',
        'https://picsum.photos/seed/tree_planting2/400/300',
        'https://picsum.photos/seed/tree_planting3/400/300',
      ],
      'username': 'GreenThumb',
      'profileImage': 'https://picsum.photos/seed/profile3/50/50',
    },
    {
      'description': 'Support seniors by providing companionship and assistance.',
      'images': [
        'https://picsum.photos/seed/elderly_assistance1/400/300',
        'https://picsum.photos/seed/elderly_assistance2/400/300',
        'https://picsum.photos/seed/elderly_assistance3/400/300',
      ],
      // Username and profileImage left blank to trigger fallback values
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
  final Map<String, dynamic> data;

  VolunteerOpportunityCard({required this.data});

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
          // Image carousel for volunteer work images
          CarouselSlider.builder(
            itemCount: (data['images'] as List).length,
            itemBuilder: (context, index, realIdx) {
              return ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                child: Image.network(
                  data['images'][index],
                  fit: BoxFit.cover,
                  height: 220,
                  width: double.infinity,
                ),
              );
            },
            options: CarouselOptions(
              height: 220,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 5),
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                // Profile picture with a default image if none provided
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    data['profileImage'] ?? 'https://picsum.photos/seed/default_profile/50/50',
                  ),
                  radius: 20,
                ),
                SizedBox(width: 10),
                // Username with default value if none provided
                Text(
                  data['username'] ?? 'Anonymous',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                // Row for like and comment icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ActionButton(
                      icon: Icons.favorite_outline,
                      label: 'Like',
                      onTap: () {
                        // Logic to like the opportunity
                      },
                    ),
                    _ActionButton(
                      icon: Icons.comment_outlined,
                      label: 'Comment',
                      onTap: () {
                        // Logic to comment on the opportunity
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
