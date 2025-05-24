import 'package:menu_planner/models/meal.dart';
import 'package:menu_planner/models/daily_menu.dart';
import 'package:menu_planner/services/menu_service.dart';
import 'package:intl/intl.dart';

class HistoryService {
  final MenuService _menuService = MenuService();

  // Get meal history for a specific date
  Future<DailyMenu?> getMealHistoryForDate(DateTime date, String userId) async {
    try {
      print('HistoryService - Fetching menu for date: ${DateFormat('yyyy-MM-dd').format(date)}');
      final dailyMenu = await _menuService.getDailyMenu(date, userId);
      print('HistoryService - Fetched menu for ${DateFormat('yyyy-MM-dd').format(date)}: ${dailyMenu.lunch.length ?? 0} lunch, ${dailyMenu.dinner.length ?? 0} dinner');
      
      // Check if the menu has meals
      if (dailyMenu.mealCount > 0) {
        print('HistoryService - Menu has ${dailyMenu.mealCount} meals');
        return dailyMenu;
      } else {
        print('HistoryService - Menu has no meals, returning null');
        return null;
      }
    } catch (e) {
      print('Error fetching meal history for date: $e');
      return null;
    }
  }

  // Get meal history for a date range
  Future<Map<String, DailyMenu>> getMealHistoryForDateRange(
    DateTime startDate,
    DateTime endDate,
    String userId,
  ) async {
    final Map<String, DailyMenu> history = {};
    
    try {
      print('HistoryService - Fetching meal history from ${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}');
      
      // Iterate through each day in the range
      for (DateTime date = startDate; 
           date.isBefore(endDate.add(const Duration(days: 1))); 
           date = date.add(const Duration(days: 1))) {
        
        final dailyMenu = await _menuService.getDailyMenu(date, userId);
        // Only include menus that have meals
        if (dailyMenu.mealCount > 0) {
          final dateKey = DateFormat('yyyy-MM-dd').format(date);
          history[dateKey] = dailyMenu;
          print('HistoryService - Added menu for $dateKey: ${dailyMenu.lunch.length} lunch, ${dailyMenu.dinner.length} dinner');
        } else {
          print('HistoryService - Skipping date ${DateFormat('yyyy-MM-dd').format(date)} - no meals');
        }
      }
      
      print('HistoryService - Fetched ${history.length} days with meals');
      if (history.isNotEmpty) {
        print('HistoryService - Available dates:');
        history.forEach((date, menu) {
          print('  - $date: ${menu.lunch.length} lunch, ${menu.dinner.length} dinner');
        });
      }
      return history;
    } catch (e) {
      print('Error fetching meal history for date range: $e');
      return {};
    }
  }

  // Get meal history for the last N days
  Future<Map<String, DailyMenu>> getRecentMealHistory(int days, String userId) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    print('HistoryService - Getting recent meal history for the last $days days');
    return getMealHistoryForDateRange(startDate, endDate, userId);
  }

  // Get all meals from history
  Future<List<Meal>> getAllMealsFromHistory(Map<String, DailyMenu> history) async {
    final List<Meal> allMeals = [];
    
    history.forEach((dateKey, dailyMenu) {
      allMeals.addAll(dailyMenu.lunch);
      allMeals.addAll(dailyMenu.dinner);
    });
    
    // Sort by last used date (most recent first)
    allMeals.sort((a, b) {
      final aDate = a.lastUsed ?? a.createdAt;
      final bDate = b.lastUsed ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
    
    print('HistoryService - Found ${allMeals.length} total meals in history');
    return allMeals;
  }

  // Get meals by category from history
  Future<Map<String, List<Meal>>> getMealsByCategoryFromHistory(
    Map<String, DailyMenu> history,
  ) async {
    final Map<String, List<Meal>> mealsByCategory = {
      'starter': [],
      'main': [],
      'dessert': [],
    };
    
    history.forEach((dateKey, dailyMenu) {
      // Add lunch meals
      for (final meal in dailyMenu.lunch) {
        if (mealsByCategory.containsKey(meal.category)) {
          // Check if meal already exists in the list
          if (!mealsByCategory[meal.category]!.any((m) => m.id == meal.id)) {
            mealsByCategory[meal.category]!.add(meal);
          }
        }
      }
      
      // Add dinner meals
      for (final meal in dailyMenu.dinner) {
        if (mealsByCategory.containsKey(meal.category)) {
          // Check if meal already exists in the list
          if (!mealsByCategory[meal.category]!.any((m) => m.id == meal.id)) {
            mealsByCategory[meal.category]!.add(meal);
          }
        }
      }
    });
    
    // Sort each category by last used date (most recent first)
    mealsByCategory.forEach((category, meals) {
      meals.sort((a, b) {
        final aDate = a.lastUsed ?? a.createdAt;
        final bDate = b.lastUsed ?? b.createdAt;
        return bDate.compareTo(aDate);
      });
    });
    
    print('HistoryService - Meals by category:');
    mealsByCategory.forEach((category, meals) {
      print('  - $category: ${meals.length} meals');
    });
    
    return mealsByCategory;
  }
}
