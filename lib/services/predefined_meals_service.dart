import 'package:flutter/material.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:menu_planner/services/meal_service.dart';

class PredefinedMealsService {
  // Predefined starters
  static final List<Meal> starters = [
    Meal(
      id: 'predefined_starter_1',
      name: 'Caesar Salad',
      description: 'Fresh romaine lettuce with Caesar dressing, croutons, and parmesan cheese',
      category: 'starter',
      imageUrl: 'assets/images/predefined_meals/cesar_salad.png',
      creatorId: 'system',
    ),
    Meal(
      id: 'predefined_starter_2',
      name: 'Tomato Soup',
      description: 'Creamy tomato soup with fresh basil',
      category: 'starter',
      imageUrl: 'assets/images/predefined_meals/tomato_soup.png',
      creatorId: 'system',
    ),
    Meal(
      id: 'predefined_starter_3',
      name: 'Bruschetta',
      description: 'Toasted bread topped with tomatoes, garlic, and fresh basil',
      category: 'starter',
      imageUrl: 'assets/images/predefined_meals/Bruschetta.png',
      creatorId: 'system',
    ),
    Meal(
      id: 'predefined_starter_4',
      name: 'Garlic Bread',
      description: 'Toasted bread with garlic butter and herbs',
      category: 'starter',
      imageUrl: 'assets/images/predefined_meals/garlic_bread.png',
      creatorId: 'system',
    ),
    Meal(
      id: 'predefined_starter_5',
      name: 'Spring Rolls',
      description: 'Fresh vegetables wrapped in rice paper with dipping sauce',
      category: 'starter',
      imageUrl: 'assets/images/predefined_meals/spring_rolls.png',
      creatorId: 'system',
    ),
  ];

  // Predefined main courses
  static final List<Meal> mainCourses = [
    Meal(
      id: 'predefined_main_1',
      name: 'Grilled Chicken',
      description: 'Seasoned chicken breast grilled to perfection with vegetables',
      category: 'main',
      imageUrl: 'assets/images/predefined_meals/grilled_chicken.png',
      creatorId: 'system',
    ),
    Meal(
      id: 'predefined_main_2',
      name: 'Pasta Bolognese',
      description: 'Classic pasta with rich meat sauce and parmesan cheese',
      category: 'main',
      imageUrl: 'assets/images/predefined_meals/spaghetti_bolognese.png',
      creatorId: 'system',
    ),
    Meal(
      id: 'predefined_main_3',
      name: 'Beef Stir Fry',
      description: 'Tender beef strips with mixed vegetables in savory sauce',
      category: 'main',
      imageUrl: 'assets/images/predefined_meals/beef_stir_fry.png',
      creatorId: 'system',
    ),
    Meal(
      id: 'predefined_main_4',
      name: 'Salmon Fillet',
      description: 'Fresh salmon with lemon butter sauce ',
      category: 'main',
      imageUrl: 'assets/images/predefined_meals/salmon_fillet.png',
      creatorId: 'system',
    ),
    Meal(
      id: 'predefined_main_5',
      name: 'Vegetable Curry',
      description: 'Mixed vegetables in aromatic curry sauce with rice',
      category: 'main',
      imageUrl: 'assets/images/predefined_meals/vegetable_curry.png',
      creatorId: 'system',
    ),
  ];

  // Predefined desserts
  static final List<Meal> desserts = [
    Meal(
      id: 'predefined_dessert_1',
      name: 'Chocolate Cake',
      description: 'Rich chocolate cake with chocolate ganache',
      category: 'dessert',
      imageUrl: 'assets/images/predefined_meals/chocolate_cake.png',
      creatorId: 'system',
    ),
    Meal(
      id: 'predefined_dessert_2',
      name: 'Apple Pie',
      description: 'Classic apple pie with cinnamon and vanilla ice cream',
      category: 'dessert',
      imageUrl: 'assets/images/predefined_meals/apple_pie.png',
      creatorId: 'system',
    ),
    Meal(
      id: 'predefined_dessert_3',
      name: 'Tiramisu',
      description: 'Italian coffee-flavored dessert with mascarpone cream',
      category: 'dessert',
      imageUrl: 'assets/images/predefined_meals/tiramisu.png',
      creatorId: 'system',
    ),
    Meal(
      id: 'predefined_dessert_4',
      name: 'Fruit Salad',
      description: 'Fresh seasonal fruits with honey and mint',
      category: 'dessert',
      imageUrl: 'assets/images/predefined_meals/fruit_salad.png',
      creatorId: 'system',
    ),
    Meal(
      id: 'predefined_dessert_5',
      name: 'Cheesecake',
      description: 'Creamy cheesecake with berry compote',
      category: 'dessert',
      imageUrl: 'assets/images/predefined_meals/cheesecake.png',
      creatorId: 'system',
    ),
  ];

  // Get all predefined meals
  static List<Meal> getAllPredefinedMeals() {
    return [...starters, ...mainCourses, ...desserts];
  }

  // Get predefined meals by category
  static List<Meal> getPredefinedMealsByCategory(String category) {
    switch (category) {
      case 'starter':
        return starters;
      case 'main':
        return mainCourses;
      case 'dessert':
        return desserts;
      default:
        return [];
    }
  }
  static Future<void> ensurePredefinedMealsExist(MealService mealService) async {
    try {
      debugPrint('Ensuring predefined meals exist in Firebase...');
      final allPredefined = getAllPredefinedMeals();
      
      for (final meal in allPredefined) {
        await mealService.savePredefinedMeal(meal);
      }
      debugPrint('All predefined meals verified in Firebase');
    } catch (e) {
      debugPrint('Error ensuring predefined meals exist: $e');
      throw Exception('Failed to verify predefined meals: $e');
    }
  }
} 