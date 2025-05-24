import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:menu_planner/models/daily_menu.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:menu_planner/models/weekly_menu.dart';
import 'package:intl/intl.dart';

class MenuService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MenuService() 
    : _firestore = FirebaseFirestore.instance,
      _auth = FirebaseAuth.instance;

  CollectionReference _weeklyMenusRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('weeklyMenus');

  CollectionReference _dailyMenusRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('dailyMenus');

  Future<DailyMenu> getDailyMenu(DateTime date, String userId) async {
    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      debugPrint('Getting daily menu for date: $dateKey, user: $userId');
      
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_menus')
          .doc(dateKey);
      
      final doc = await docRef.get();
      
      if (!doc.exists) {
        debugPrint('No menu found for date: $dateKey, creating empty menu');
        return DailyMenu(
          id: dateKey,
          date: date,
          lunch: [],
          dinner: [],
        );
      }
      
      final data = doc.data() as Map<String, dynamic>;
      debugPrint('Found menu data for date: $dateKey');
      debugPrint('Lunch meals: ${(data['lunch'] as List<dynamic>).length}');
      debugPrint('Dinner meals: ${(data['dinner'] as List<dynamic>).length}');
      
      final menu = DailyMenu.fromMap(data);
      debugPrint('Created DailyMenu object with ${menu.lunch.length} lunch and ${menu.dinner.length} dinner meals');
      
      return menu;
    } catch (e) {
      debugPrint('Error getting daily menu: $e');
      throw Exception('Failed to get daily menu: $e');
    }
  }

  Future<Map<String, DailyMenu>> fetchWeeklyMenu() async {
    try {
      Map<String, DailyMenu> menu = {};
      
      // Get the current user ID
      final userId = _getCurrentUserId();
      if (userId == null) {
        debugPrint('No user logged in');
        return {};
      }
      
      // Get the current week's start date (Monday)
      DateTime now = DateTime.now();
      DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
      
      // Fetch daily menus for the current week
      for (int i = 0; i < 7; i++) {
        DateTime currentDate = weekStart.add(Duration(days: i));
        String dateKey = _formatDate(currentDate);
        
        // Get the daily menu for this date
        DailyMenu dailyMenu = await getDailyMenu(currentDate, userId);
        menu[dateKey] = dailyMenu;
        
        debugPrint('Fetched menu for $dateKey: ${dailyMenu.lunch.length} lunch, ${dailyMenu.dinner.length} dinner');
      }
      
      return menu;
    } catch (e) {
      debugPrint('Error fetching weekly menu: $e');
      return {};
    }
  }

  Future<WeeklyMenu> getWeeklyMenu(DateTime startDate, String userId) async {
    try {
      final endDate = startDate.add(const Duration(days: 6));
      final weekId = '${_formatDate(startDate)}_${_formatDate(endDate)}';

      final doc = await _weeklyMenusRef(userId).doc(weekId).get();

      if (doc.exists) {
        return WeeklyMenu.fromJson(doc.data() as Map<String, dynamic>);
      }

      // Create new week if doesn't exist
      final days = <DailyMenu>[];
      for (var i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        days.add(await getDailyMenu(date, userId));
      }

      return WeeklyMenu(
        id: weekId,
        startDate: startDate,
        endDate: endDate,
        days: days,
      );
    } catch (e) {
      throw Exception('Failed to get weekly menu: $e');
    }
  }

  Future<void> saveDailyMenu(DailyMenu menu, String userId) async {
    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(menu.date);
      debugPrint('Saving daily menu for date: $dateKey, user: $userId');
      debugPrint('Menu contains ${menu.lunch.length} lunch and ${menu.dinner.length} dinner meals');
      
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_menus')
          .doc(dateKey);
      
      final menuData = menu.toMap();
      debugPrint('Converting menu to map data');
      debugPrint('Lunch meals in map: ${(menuData['lunch'] as List<dynamic>).length}');
      debugPrint('Dinner meals in map: ${(menuData['dinner'] as List<dynamic>).length}');
      
      await docRef.set(menuData);
      debugPrint('Successfully saved menu to Firestore');
      
      // Verify the save by reading it back
      final savedDoc = await docRef.get();
      if (savedDoc.exists) {
        final savedData = savedDoc.data() as Map<String, dynamic>;
        debugPrint('Verified save - Menu contains:');
        debugPrint('Lunch meals: ${(savedData['lunch'] as List<dynamic>).length}');
        debugPrint('Dinner meals: ${(savedData['dinner'] as List<dynamic>).length}');
      } else {
        debugPrint('Warning: Could not verify save - Document not found after save');
      }
    } catch (e) {
      debugPrint('Error saving daily menu: $e');
      throw Exception('Failed to save daily menu: $e');
    }
  }

  Future<void> saveWeeklyMenu(WeeklyMenu menu, String userId) async {
    try {
      await _weeklyMenusRef(userId).doc(menu.id).set(menu.toJson());
    } catch (e) {
      throw Exception('Failed to save weekly menu: $e');
    }
  }

  Future<void> copyMealToDays(Meal meal, List<DateTime> selectedDays,
      String mealTime, String userId) async {
    try {
      final batch = _firestore.batch();

      for (final date in selectedDays) {
        if (date.isBefore(DateTime.now())) {
          continue;
        }

        final dailyMenu = await getDailyMenu(date, userId);
        dailyMenu.addMeal(meal, mealTime);

        batch.set(
          _dailyMenusRef(userId).doc(dailyMenu.id),
          dailyMenu.toMap(),
        );
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to copy meal to days: $e');
    }
  }

  Future<void> addMealToDays({
    required String mealId,
    required List<DateTime> days,
    required String mealTime,
    required String userId,
  }) async {
    try {
      final batch = _firestore.batch();

      // First, get the meal details
      final mealDoc = await _firestore.collection('meals').doc(mealId).get();
      if (!mealDoc.exists) {
        throw Exception('Meal not found');
      }
      
      final meal = Meal.fromMap(mealDoc.data() as Map<String, dynamic>);

      for (final day in days) {
        final dailyMenu = await getDailyMenu(day, userId);
        dailyMenu.addMeal(meal, mealTime);

        batch.set(
          _dailyMenusRef(userId).doc(dailyMenu.id),
          dailyMenu.toMap(),
        );
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add meal to days: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String? _getCurrentUserId() {
    final user = _auth.currentUser;
    return user?.uid;
  }
}
