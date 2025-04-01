import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
      decoration: BoxDecoration(
        color: Color(0xFFDCDCDC).withOpacity(0.9), // Ajout d'opacité pour l'intégration avec la page
        borderRadius: BorderRadius.circular(50),
        backgroundBlendMode: BlendMode.srcOver, // Permet de mieux fusionner avec le fond
      ),
      clipBehavior: Clip.hardEdge, // Empêche les débordements
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_filled, 0, "Home", context),
          _buildNavItem(Icons.add, 1, "New", context),
          _buildNavItem(Icons.access_time, 2, "History", context),
          _buildNavItem(Icons.person_outlined, 3, "Profile", context),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label, BuildContext context) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Color(0xFF02197D)),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  label,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}