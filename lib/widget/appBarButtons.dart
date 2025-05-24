import 'package:flutter/material.dart';

class appBarButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;

  const appBarButton({super.key, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: Image.asset(imagePath, width: 20, height: 20)),
      ),
    );
  }
}