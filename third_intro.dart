import 'package:flutter/material.dart';
import 'package:menu_project/HomePage/homePage.dart';

class ThirdIntro extends StatelessWidget {
  final PageController controller;

  const ThirdIntro({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/frame3.png',
              width: MediaQuery.of(context).size.width * 0.7,
              fit: BoxFit.contain,
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text(
                "Get Started",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
            Text(
              "Need inspiration ? Get random\n meal suggestions or check your history",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF02197D),
              ),
            ),

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
                      _buildIndicator(false),
                      SizedBox(width: 6),
                      _buildIndicator(true),
                    ],
                  ),
                  _navButton(Icons.chevron_left, () {
                    controller.previousPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }),
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
