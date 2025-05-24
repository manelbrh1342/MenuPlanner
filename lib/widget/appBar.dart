import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const CustomAppBar({super.key, required this.title, required this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF02197D), // Blue text color
            fontSize: 24, // Larger text size
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent app bar background
        elevation: 0, // Remove shadow
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color(0xFF02197D), // Blue icons
        ),
      );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100.0);
}