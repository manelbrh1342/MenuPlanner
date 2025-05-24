import 'package:flutter/material.dart';
import 'package:menu_planner/models/user.dart';
import 'package:menu_planner/pages/home_page.dart';
import 'package:menu_planner/pages/login.dart';
import 'package:menu_planner/pages/addmeal.dart';
import 'package:menu_planner/pages/history.dart';
import 'package:menu_planner/pages/profile_page.dart';
import 'package:menu_planner/widget/navigationBar.dart';
import 'package:menu_planner/services/auth.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: Auth().userStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const MainAppScaffold();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold({super.key});

  @override
  State<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const SizedBox(), // Placeholder for AddMeal (we'll handle it differently)
    const HistoryScreen(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Add this method for regular page navigation
  void _onItemTapped(int index) {
    if (index == 1) {
      // Handle AddMeal navigation separately
      _navigateToAddMeal();
    } else {
      setState(() {
        _selectedIndex = index;
      });
      _pageController.jumpToPage(index);
    }
  }

  // Add this method for page changes (from swipes if enabled)
  void _onPageChanged(int index) {
    if (index == 1) return; // Prevent landing on AddMeal placeholder
    setState(() {
      _selectedIndex = index;
    });
  }

  // Add this method for AddMeal navigation
  void _navigateToAddMeal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          extendBody: true,
          body: const AddMeal(),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: CustomNavigationBar(
              selectedIndex: 1, // Highlight AddMeal in nav bar
              onItemTapped: (index) {
                if (index == 1) return; // Already on AddMeal
                Navigator.pop(context); // Close AddMeal
                _onItemTapped(index); // Navigate to selected page
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages, // Disable swipe
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: CustomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}