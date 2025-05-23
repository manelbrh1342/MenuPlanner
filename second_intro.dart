import 'package:flutter/material.dart';
import 'package:menu_project/HomePage/homePage.dart';

class SecondIntro extends StatelessWidget {
  final PageController controller;

  const SecondIntro({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Image.asset(
              'assets/images/frame2.png',
              width: MediaQuery.of(context).size.width * 0.7,
              fit: BoxFit.contain,
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
            Text(
              "Add, edit, and rate your favorite \ndishes with just a tap",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF02197D),
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildIndicator(false),
                      SizedBox(width: 6),
                      _buildIndicator(true),
                      SizedBox(width: 6),
                      _buildIndicator(false),
                    ],
                  ),
                  Row(
                    children: [
                      _navButton(Icons.chevron_left, () {
                        controller.previousPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }),
                      SizedBox(width: 10),
                      _navButton(Icons.chevron_right, () {
                        controller.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }),
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

  Widget _buildIndicator(bool isActive) {
    return Container(
      width: isActive ? 14 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.amber : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Icon(icon, color: Color(0xFFFFAC06)),
      ),
    );
  }
}
