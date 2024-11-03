import 'package:flutter/material.dart';
import 'dart:math'; // Import to use Random

class LoyaltyBenefitsScreen extends StatelessWidget {
  // Mock data for discount coupons
  final List<Map<String, String>> coupons = [
    {
      'image': 'lib/assets/images/Gift Cards/Yemeksepeti_page-0001.jpg', // Replace with your coupon image path
      'title': 'Yemek Sepeti %15',
      'description': 'You earned this coupon by applying three TEMA activities voluntarily!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Loyalty Benefits")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: coupons.length,
          itemBuilder: (context, index) {
            return CouponCard(
              image: coupons[index]['image']!,
              title: coupons[index]['title']!,
              description: coupons[index]['description']!,
            );
          },
        ),
      ),
    );
  }
}

class CouponCard extends StatefulWidget {
  final String image;
  final String title;
  final String description;

  CouponCard({required this.image, required this.title, required this.description});

  @override
  _CouponCardState createState() => _CouponCardState();
}

class _CouponCardState extends State<CouponCard> {
  String? randomString;

  // Function to generate a random 10-character string
  String generateRandomString() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (randomString == null) { // Generate the string only if it's not already created
          setState(() {
            randomString = generateRandomString(); // Generate the string and update the state
          });
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display coupon image
            Image.asset(
              widget.image,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 8),
            Text(
              widget.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.description,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
            if (randomString != null) // Display the random string if it's generated
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  randomString!,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
