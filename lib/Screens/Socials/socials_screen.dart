import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SocialsScreen extends StatelessWidget {
  // Mock data for volunteer opportunities with complete profile details
  final List<Map<String, dynamic>> volunteerOpportunities = [
    {
      'description': 'Join us in planting trees to make our community greener.',
      'images': [
        'https://images.pexels.com/photos/1390371/pexels-photo-1390371.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', // Replace with your custom image URLs
        'https://images.pexels.com/photos/1072824/pexels-photo-1072824.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
        'https://images.pexels.com/photos/7538366/pexels-photo-7538366.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      ],
      'username': 'Ömer Faruk Öztürk',
      'profileImage': 'https://images.unsplash.com/photo-1534564533601-4d3e3d9fd229?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    },
    {
      'description': 'Assist in collecting and distributing food to families in need.',
      'images': [
        'https://caritaspenang.com/wp-content/uploads/2021/08/poor2.jpeg',
        'https://caritaspenang.com/wp-content/uploads/2021/08/whiteflag3-768x1024.jpeg',
        'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjUF9rlPzBqq6Gvm-1NChoKY8ASXBZAmu52w5tjlwsWRrdPLlU_gDRs_8nipgm2tGLvTWMLQBw5dYidcD-MbcP3Lb6kBGf9lBTbJEbPYg79MdCd1dcx-ucsJSRZTrX77F_LVcgbdzugPn8/s1600/IMG_0493.JPG',
      ],
      'username': 'Ümit Tavus',
      'profileImage': 'https://plus.unsplash.com/premium_photo-1671656349322-41de944d259b?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    },
    {
      'description': 'Support seniors by providing companionship and assistance.',
      'images': [
        'https://www.fote.org.uk/wp-content/uploads/2017/03/about-us-2-1600x573.jpg',
        'https://www.whiddon.com.au/yourlife/wp-content/uploads/sites/2/2019/12/kw19whid_0685sm-1200x690.jpg',
        'https://images.squarespace-cdn.com/content/v1/5aa96c579772aea9adaa2ef7/1620932242788-3AZG03GCC07TX2SWTSEB/ChallengesinCaringforTheElderly_521.jpg?format=1500w',
      ],
      'username': 'eecem82',
      'profileImage': 'https://images.unsplash.com/photo-1557053908-94f31a224f8f?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    },
    {
      'description': 'Coordinate volunteers to spend time at local animal shelters, providing companionship for animals, assisting with feeding, cleaning, or even organizing adoption events to help the animals find homes.',
      'images': [
        'https://images.squarespace-cdn.com/content/v1/6699d82698eb7d78c61487c0/1721358375364-I9CJPOGSOGWUEE756NAD/1.png',
        'https://dv9b2v6p3dpu5.cloudfront.net/transforms/general/9394/Volunteer_Intro_6c0c164bd2b597ee32b68b8b5755bd2e.jpg',
        'https://www.rocklinranchvet.com/blog/wp-content/uploads/2015/04/Rocklin_iStock_000039989498_Large.jpg',
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
                    data['profileImage'] ?? 'https://your-image-url.com/default_profile.jpg',
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
