import 'package:flutter/material.dart';
import 'package:menu_project/AddMealPage/addMeal.dart';
import 'package:menu_project/HomePage/homePage.dart';

class CustomNavigationBar extends StatefulWidget {
  final int selectedIndex;

  const CustomNavigationBar({super.key, required this.selectedIndex});

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddMeal()),
        );
        break;
      case 2:
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.08,
        decoration: BoxDecoration(
          color: Color(0xFFDCDCDC),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_filled, 0, "Home"),
            _buildNavItem(Icons.add, 1, "New"),
            _buildNavItem(Icons.access_time, 2, "History"),
            _buildNavItem(Icons.person_outlined, 3, "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: _selectedIndex == index ? 100 : 40,
        height: 50,
        decoration: BoxDecoration(
          color: _selectedIndex == index ? Colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Wrap(
            spacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _selectedIndex == index ? Colors.red : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              Icon(
                icon,
                color:
                    _selectedIndex == index ? Colors.white : Color(0xFF02197D),
              ),
              if (_selectedIndex == index)
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
