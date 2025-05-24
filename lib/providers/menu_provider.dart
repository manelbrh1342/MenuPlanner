import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:menu_planner/models/daily_menu.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:menu_planner/services/meal_service.dart';
import 'package:menu_planner/services/menu_service.dart';
import 'package:menu_planner/services/predefined_meals_service.dart';
import 'package:menu_planner/services/history_service.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class MenuProvider with ChangeNotifier {
  final MealService _mealService = MealService();
  final MenuService _menuService = MenuService();
  final HistoryService _historyService = HistoryService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _userId;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  // History related properties
  Map<String, DailyMenu> _mealHistory = {};
  final Map<String, List<Meal>> _mealsByCategory = {
    'starter': [],
    'main': [],
    'dessert': [],
  };
  DateTime _selectedHistoryDate = DateTime.now();
  bool _isLoadingHistory = false;

  DailyMenu? _selectedDayMenu;
  Map<String, DailyMenu> weeklyMenu = {};
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  // History getters
  Map<String, DailyMenu> get mealHistory => _mealHistory;
  Map<String, List<Meal>> get mealsByCategory => _mealsByCategory;
  DateTime get selectedHistoryDate => _selectedHistoryDate;
  bool get isLoadingHistory => _isLoadingHistory;

  MenuProvider() {
    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _userId = user.uid;
        // Refresh the menu when user logs in
        fetchWeeklyMenu();
      } else {
        _userId = null;
        weeklyMenu = {};
        notifyListeners();
      }
    });
  }

  Future<void> fetchWeeklyMenu() async {
    if (_userId == null) throw Exception('User ID not set');

    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Fetching weekly menu for user: $_userId');

      // Get the current date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Create a map to store the daily menus
      final Map<String, DailyMenu> newWeeklyMenu = {};

      // Fetch menus for the entire week (including past dates)
      // Start from the beginning of the week (Monday)
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

      // Fetch 7 days (full week)
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        try {
          final dailyMenu = await _menuService.getDailyMenu(date, _userId!);
          newWeeklyMenu[dateKey] = dailyMenu;

          debugPrint(
              'Fetched menu for $dateKey: ${dailyMenu.lunch.length} lunch, ${dailyMenu.dinner.length} dinner');
        } catch (e) {
          debugPrint('Error fetching menu for $dateKey: $e');
          // Create an empty menu for this date
          newWeeklyMenu[dateKey] = DailyMenu(
            id: dateKey,
            date: date,
            lunch: [],
            dinner: [],
          );
        }
      }

      // Update the weekly menu
      weeklyMenu = newWeeklyMenu;

      // Log the fetched data
      debugPrint('Fetched weekly menu: ${weeklyMenu.length} days');
      weeklyMenu.forEach((date, menu) {
        debugPrint(
            'Date: $date, Meals: ${menu.lunch.length} lunch, ${menu.dinner.length} dinner');
      });

      _hasError = false;
    } catch (e) {
      debugPrint('Error fetching weekly menu: $e');
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUserId(String userId) {
    _userId = userId;
  }

  Future<void> updateDailyMenu(DailyMenu updatedMenu) async {
    if (_userId == null) throw Exception('User ID not set');

    try {
      await _menuService.saveDailyMenu(updatedMenu, _userId!);

      // Update the weeklyMenu map
      final dateKey = DateFormat('yyyy-MM-dd').format(updatedMenu.date);
      weeklyMenu[dateKey] = updatedMenu;

      _selectedDayMenu = updatedMenu;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update daily menu: $e');
    }
  }

  Future<void> addMealToDay(DateTime date, Meal meal, String mealType) async {
    if (_userId == null) throw Exception('User ID not set');

    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      DailyMenu? dailyMenu = weeklyMenu[dateKey];

      if (dailyMenu == null) {
        // Create a new DailyMenu with a valid ID
        dailyMenu = DailyMenu(
          id: dateKey, // Make sure this is not empty
          date: date,
          lunch: [],
          dinner: [],
        );
        debugPrint('Created new DailyMenu with ID: ${dailyMenu.id}');
      }

      // Use the addMeal method from DailyMenu
      dailyMenu.addMeal(meal, mealType);

      // Update Firestore
      await _menuService.saveDailyMenu(dailyMenu, _userId!);

      // Update local state
      weeklyMenu[dateKey] = dailyMenu;
      notifyListeners();

      debugPrint('Added meal to $dateKey ($mealType): ${meal.name}');
      debugPrint(
          'Updated menu for $dateKey: ${dailyMenu.lunch.length} lunch, ${dailyMenu.dinner.length} dinner');
    } catch (e) {
      debugPrint('Error adding meal to day: $e');
      throw Exception('Failed to add meal to day: $e');
    }
  }

  Future<void> addRating({
    required String mealId,
    required double rating,
    required String userId,
    String? comment,
  }) async {
    try {
      debugPrint('Adding rating for meal: $mealId');
      debugPrint('Rating: $rating, User: $userId, Comment: $comment');

      // Get all meals and find the specific one
      final meals = await _mealService.getMeals();
      final meal = meals.firstWhere((m) => m.id == mealId);

      debugPrint('Found meal: ${meal.name}');
      debugPrint('Current ratings count: ${meal.ratings.length}');

      // Update the rating
      meal.updateRating(rating, userId, comment: comment);

      debugPrint('Updated ratings count: ${meal.ratings.length}');
      debugPrint('New average rating: ${meal.averageRating}');

      // Save the updated meal
      await _mealService.updateMeal(meal);

      // Verify the update
      final updatedMeals = await _mealService.getMeals();
      final updatedMeal = updatedMeals.firstWhere((m) => m.id == mealId);
      debugPrint(
          'Verified update - Ratings count: ${updatedMeal.ratings.length}');
      debugPrint(
          'Verified update - Average rating: ${updatedMeal.averageRating}');

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding rating: $e');
      throw Exception('Failed to add rating: $e');
    }
  }

  Future<void> addCommentToRating({
    required String mealId,
    required String userId,
    required String comment,
  }) async {
    try {
      // Get all meals and find the specific one
      final meals = await _mealService.getMeals();
      final meal = meals.firstWhere((m) => m.id == mealId);

      // Get existing rating
      final existingRating = meal.getUserRating(userId);
      if (existingRating == null) {
        throw Exception('User has not rated this meal yet');
      }

      // Update with same rating but new comment
      meal.updateRating(existingRating, userId, comment: comment);
      await _mealService.updateMeal(meal);

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<double?> getUserRating(String mealId, String userId) async {
    try {
      final meals = await _mealService.getMeals();
      final meal = meals.firstWhere((m) => m.id == mealId);
      return meal.getUserRating(userId);
    } catch (e) {
      return null;
    }
  }

  void selectDayMenu(DailyMenu menu) {
    _selectedDayMenu = menu;
    notifyListeners();
  }

  // Refresh a specific day's menu
  Future<void> refreshDayMenu(DateTime date) async {
    if (_userId == null) throw Exception('User ID not set');

    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      debugPrint('Refreshing menu for $dateKey');

      // Get the daily menu from Firestore
      final dailyMenu = await _menuService.getDailyMenu(date, _userId!);

      // Update the local state
      weeklyMenu[dateKey] = dailyMenu;

      // Log the refreshed data
      debugPrint(
          'Refreshed menu for $dateKey: ${dailyMenu.lunch.length} lunch, ${dailyMenu.dinner.length} dinner');

      // Log the meal IDs in the refreshed menu
      for (final meal in dailyMenu.lunch) {
        debugPrint(
            'Lunch meal: ${meal.name} (ID: ${meal.id}, Image: ${meal.imageUrl?.substring(0, min(30, meal.imageUrl?.length ?? 0))}...)');
      }
      for (final meal in dailyMenu.dinner) {
        debugPrint(
            'Dinner meal: ${meal.name} (ID: ${meal.id}, Image: ${meal.imageUrl?.substring(0, min(30, meal.imageUrl?.length ?? 0))}...)');
      }

      // If this is the selected day menu, update it as well
      if (_selectedDayMenu?.id == dailyMenu.id) {
        _selectedDayMenu = dailyMenu;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing day menu: $e');
      throw Exception('Failed to refresh day menu: $e');
    }
  }

  Future<void> generateRandomMeals(DateTime date) async {
    if (_userId == null) throw Exception('User ID not set');

    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      debugPrint('Generating random meals for date: $dateKey');

      // 1. Ensure predefined meals exist in Firebase
      await PredefinedMealsService.ensurePredefinedMealsExist(_mealService);

      // 2. Get or create the daily menu
      DailyMenu dailyMenu = weeklyMenu[dateKey] ??
          DailyMenu(
            id: dateKey,
            date: date,
            lunch: [],
            dinner: [],
          );

      // 3. Clear existing meals
      dailyMenu.lunch.clear();
      dailyMenu.dinner.clear();

      // 4. Get all meals (now including predefined ones from Firebase)
      final allMeals = await _mealService.getMeals();
      debugPrint('Total meals available: ${allMeals.length}');

      // 5. Filter meals by category (with proper null checks)
      final starters =
          allMeals.where((m) => m.category.toLowerCase() == 'starter').toList();
      final mains = allMeals
          .where((m) => m.category.toLowerCase().contains('main'))
          .toList();
      final desserts =
          allMeals.where((m) => m.category.toLowerCase() == 'dessert').toList();

      debugPrint(
          'Available starters: ${starters.length}, mains: ${mains.length}, desserts: ${desserts.length}');

      // 6. Enhanced random meal selection with fallbacks
      Meal? getRandomMeal(List<Meal> meals, {String? mealType}) {
        if (meals.isEmpty) {
          debugPrint('No meals available for ${mealType ?? 'this category'}');
          return null;
        }

        final random = Random();
        // Prefer higher-rated meals (weighted by rating + 1 to avoid 0)
        final totalWeight =
            meals.fold(0.0, (sum, meal) => sum + (meal.averageRating + 1));
        var randomWeight = random.nextDouble() * totalWeight;

        for (final meal in meals) {
          randomWeight -= (meal.averageRating + 1);
          if (randomWeight <= 0) {
            debugPrint('Selected ${meal.name} for ${mealType ?? 'meal'}');
            return meal;
          }
        }

        return meals.last;
      }

      // 7. Function to add complete meal set (starter, main, dessert)
      void addCompleteMealSet(String mealType) {
        // Get random meals for each category
        final starter = getRandomMeal(starters, mealType: '$mealType starter');
        final main = getRandomMeal(mains, mealType: '$mealType main');
        final dessert = getRandomMeal(desserts, mealType: '$mealType dessert');

        // Add to menu if found
        if (starter != null) dailyMenu.addMeal(starter, mealType);
        if (main != null) dailyMenu.addMeal(main, mealType);
        if (dessert != null) dailyMenu.addMeal(dessert, mealType);
      }

      // 8. Generate for both lunch and dinner
      addCompleteMealSet('lunch');
      addCompleteMealSet('dinner');

      // 9. Save the daily menu
      await _menuService.saveDailyMenu(dailyMenu, _userId!);

      // 10. Update local state
      weeklyMenu[dateKey] = dailyMenu;
      notifyListeners();

      // Debug output
      debugPrint('Generated menu for $dateKey:');
      debugPrint(
          'Lunch: ${dailyMenu.lunch.map((m) => '${m.name} (${m.category})').join(', ')}');
      debugPrint(
          'Dinner: ${dailyMenu.dinner.map((m) => '${m.name} (${m.category})').join(', ')}');
    } catch (e) {
      debugPrint('Error generating random meals: $e');
      throw Exception('Failed to generate random meals: $e');
    }
  }

  Future<void> fetchRecentMealHistory(int days) async {
    if (_userId == null) return;

    _isLoadingHistory = true;
    _hasError = false;
    notifyListeners();

    try {
      print('MenuProvider - Fetching meal history for the last $days days');
      final history =
          await _historyService.getRecentMealHistory(days, _userId!);
      _mealHistory = history;

      print('MenuProvider - Fetched ${history.length} days with meals');
      if (history.isNotEmpty) {
        print('MenuProvider - Available dates:');
        history.forEach((date, menu) {
          print(
              '  - $date: ${menu.lunch.length} lunch, ${menu.dinner.length} dinner');
        });

        // Get the most recent date from the history
        final mostRecentDate = history.keys
            .map((dateStr) => DateTime.parse(dateStr))
            .reduce((a, b) => a.isAfter(b) ? a : b);

        print(
            'MenuProvider - Setting selected date to most recent date: ${DateFormat('yyyy-MM-dd').format(mostRecentDate)}');
        _selectedHistoryDate = mostRecentDate;
      } else {
        print(
            'MenuProvider - No meal history found, setting selected date to today');
        _selectedHistoryDate = DateTime.now();
      }

      _isLoadingHistory = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching meal history: $e');
      _hasError = true;
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // Set the selected history date
  void setSelectedHistoryDate(DateTime date) {
    print(
        'MenuProvider - Setting selected history date to: ${DateFormat('yyyy-MM-dd').format(date)}');
    _selectedHistoryDate = date;
    notifyListeners();
  }

  // Get meals for the selected history date
  DailyMenu? getMealsForSelectedHistoryDate() {
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedHistoryDate);
    final menu = _mealHistory[dateKey];
    print(
        'MenuProvider - Getting meals for date: $dateKey, found: ${menu != null}');
    if (menu != null) {
      print(
          'MenuProvider - Menu contains ${menu.lunch.length} lunch and ${menu.dinner.length} dinner meals');
    }
    return menu;
  }

  // Get meals by category for the selected history date
  Map<String, List<Meal>> getMealsByCategoryForSelectedDate() {
    final selectedDateStr =
        DateFormat('yyyy-MM-dd').format(selectedHistoryDate);
    final dailyMenu = mealHistory[selectedDateStr];
    print(
        'MenuProvider - Getting meals by category for date: $selectedDateStr');
    print('MenuProvider - Found daily menu: $dailyMenu');

    if (dailyMenu == null) {
      return {'starter': [], 'main': [], 'dessert': []};
    }

    final mealsByCategory = {
      'starter':
          dailyMenu.lunch.where((meal) => meal.category == 'starter').toList(),
      'main': dailyMenu.lunch.where((meal) => meal.category == 'main').toList(),
      'dessert':
          dailyMenu.lunch.where((meal) => meal.category == 'dessert').toList(),
    };

    print('MenuProvider - Meals by category: $mealsByCategory');
    return mealsByCategory;
  }

  Future<List<Meal>> getAllRatedMeals() async {
    if (_userId == null) throw Exception('User ID not set');

    try {
      debugPrint('Fetching all rated meals');
      // Get all meals
      final meals = await _mealService.getMeals();
      debugPrint('Total meals fetched: ${meals.length}');

      // Debug print each meal's ratings
      for (final meal in meals) {
        debugPrint('Meal: ${meal.name}');
        debugPrint('  Ratings count: ${meal.ratings.length}');
        debugPrint('  Average rating: ${meal.averageRating}');
        if (meal.ratings.isNotEmpty) {
          debugPrint('  Latest rating: ${meal.ratings.last}');
        }
      }

      // Filter to only meals with ratings and sort by average rating
      final ratedMeals = meals.where((meal) => meal.ratings.isNotEmpty).toList()
        ..sort((a, b) => b.averageRating.compareTo(a.averageRating));

      debugPrint('Found ${ratedMeals.length} rated meals');
      return ratedMeals;
    } catch (e) {
      debugPrint('Error getting rated meals: $e');
      throw Exception('Failed to get rated meals: $e');
    }
  }

  Future<void> addMealToFavorites(String mealId, String userId) async {
    try {
      final favoritesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites');

      // Check if the meal is already in favorites
      final doc = await favoritesRef.doc(mealId).get();
      if (doc.exists) {
        throw Exception('Meal is already in favorites');
      }

      // Add the meal to favorites
      await favoritesRef.doc(mealId).set({'mealId': mealId});
      debugPrint('Meal added to favorites: $mealId');
    } catch (e) {
      debugPrint('Error adding meal to favorites: $e');
      throw Exception('Failed to add meal to favorites: $e');
    }
  }

  Future<void> editReview({
    required String mealId,
    required String userId,
    required double newRating,
    String? newComment,
  }) async {
    try {
      final meals = await _mealService.getMeals();
      final meal = meals.firstWhere((m) => m.id == mealId);

      meal.editReview(userId, newRating, newComment: newComment);
      await _mealService.updateMeal(meal);

      // Notify listeners to update the UI
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to edit review: $e');
    }
  }

  Future<void> deleteReview({
    required String mealId,
    required String userId,
  }) async {
    try {
      final meals = await _mealService.getMeals();
      final meal = meals.firstWhere((m) => m.id == mealId);

      meal.deleteReview(userId);
      await _mealService.updateMeal(meal);

      // Notify listeners to update the UI
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}
