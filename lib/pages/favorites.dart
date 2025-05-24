import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:menu_planner/widget/meal.dart';

class FavoritesPage extends StatelessWidget {
  final String userId;

  const FavoritesPage({super.key, required this.userId});

  Future<List<Meal>> _fetchFavorites() async {
    final favoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites');

    final snapshot = await favoritesRef.get();
    final mealIds = snapshot.docs.map((doc) => doc.id).toList();

    final meals = <Meal>[];
    for (final mealId in mealIds) {
      final mealDoc = await FirebaseFirestore.instance
          .collection('meals')
          .doc(mealId)
          .get();
      if (mealDoc.exists) {
        meals.add(Meal.fromMap(mealDoc.data()!));
      }
    }
    return meals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECECEC),
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(
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
      ),
      body: FutureBuilder<List<Meal>>(
        future: _fetchFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF02197D)),
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading favorites',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 16,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: const Color(0xFF888888).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No favorites added yet',
                    style: TextStyle(
                      color: Color(0xFF02197D), // Blue text
                      fontSize: 20, // Larger text
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          final meals = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: MealItem(
                  meal: meal,
                  imagePath: meal.imageUrl ?? "assets/default_images/meal.png",
                ),
              );
              const SizedBox(height: 100);
            },
            
          );
        },
        
      ),
      
    );
  }
}