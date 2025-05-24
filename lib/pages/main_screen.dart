import 'package:flutter/material.dart';
import 'package:menu_planner/pages/home_page.dart';
import 'package:menu_planner/pages/addmeal.dart';
import 'package:menu_planner/pages/history.dart';
import 'package:menu_planner/pages/profile_page.dart';
import 'package:menu_planner/widget/navigationBar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const AddMeal(),
    const HistoryScreen(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
