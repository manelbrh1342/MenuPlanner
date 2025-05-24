import 'meal.dart';

class DailyMenu {
  final String id;
  final DateTime date;
  List<Meal> lunch;
  List<Meal> dinner;

  Meal? get lunchStarter => _getMealByCategory(lunch, 'starter');
  Meal? get lunchMain => _getMealByCategory(lunch, 'main');
  Meal? get lunchDessert => _getMealByCategory(lunch, 'dessert');
  Meal? get dinnerStarter => _getMealByCategory(dinner, 'starter');
  Meal? get dinnerMain => _getMealByCategory(dinner, 'main');
  Meal? get dinnerDessert => _getMealByCategory(dinner, 'dessert');

  DailyMenu({
    String? id,
    DateTime? date,
    List<Meal>? lunch,
    List<Meal>? dinner,
  })  : id = id ?? DateTime.now().toIso8601String(),
        date = date ?? DateTime.now(),
        lunch = lunch ?? [],
        dinner = dinner ?? [];

  factory DailyMenu.fromJson(Map<String, dynamic> json) {
    return DailyMenu(
      id: json['id'] ?? '',
      date: json['date']?.toDate() ?? DateTime.now(),
      lunch: (json['lunch'] as List<dynamic>?)
              ?.map((item) => Meal.fromJson(item))
              .toList() ??
          [],
      dinner: (json['dinner'] as List<dynamic>?)
              ?.map((item) => Meal.fromJson(item))
              .toList() ??
          [],
    );
  }

  factory DailyMenu.fromMap(Map<String, dynamic> data) {
    return DailyMenu(
      id: data['id'] ?? '',
      date: data['date']?.toDate() ?? DateTime.now(),
      lunch: (data['lunch'] as List<dynamic>?)
              ?.map((item) => Meal.fromMap(item))
              .toList() ??
          [],
      dinner: (data['dinner'] as List<dynamic>?)
              ?.map((item) => Meal.fromMap(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'lunch': lunch.map((meal) => meal.toJson()).toList(),
      'dinner': dinner.map((meal) => meal.toJson()).toList(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'lunch': lunch.map((meal) => meal.toMap()).toList(),
      'dinner': dinner.map((meal) => meal.toMap()).toList(),
    };
  }

  // Helper method to safely get meal by category
  Meal? _getMealByCategory(List<Meal> meals, String category) {
    try {
      return meals.firstWhere((meal) => meal.category == category);
    } catch (_) {
      return null;
    }
  }

  // Helper to get all meals in this daily menu
  List<Meal> get allMeals => [...lunch, ...dinner];

  // Get meals by type (starter, main, dessert) for a specific time (lunch/dinner)
  List<Meal> getMealsByType(String mealTime, String category) {
    final meals = mealTime == 'lunch' ? lunch : dinner;
    return meals.where((meal) => meal.category == category).toList();
  }

  // Add a meal to lunch or dinner
  void addMeal(Meal meal, String mealTime) {
    setMealByType(mealTime, meal);
  }

  // Set a meal by type (lunch/dinner) and category
  void setMealByType(String mealTime, Meal meal) {
    final targetList = mealTime.toLowerCase() == 'lunch' ? lunch : dinner;
    
    // Remove any existing meal of the same category
    targetList.removeWhere((existingMeal) => existingMeal.category == meal.category);
    
    // Add the new meal
    targetList.add(meal);
    
    // Sort meals by category (starter, main, dessert)
    targetList.sort((a, b) {
      final categoryOrder = {'starter': 0, 'main': 1, 'dessert': 2};
      return (categoryOrder[a.category] ?? 0).compareTo(categoryOrder[b.category] ?? 0);
    });
  }

  // Remove a meal
  void removeMeal(Meal meal) {
    lunch.remove(meal);
    dinner.remove(meal);
  }

  // Check if any meal slot is empty
  bool hasEmptySlots() {
    return lunch.isEmpty || dinner.isEmpty;
  }

  // Copy with method
  DailyMenu copyWith({
    String? id,
    DateTime? date,
    List<Meal>? lunch,
    List<Meal>? dinner,
  }) {
    return DailyMenu(
      id: id ?? this.id,
      date: date ?? this.date,
      lunch: lunch ?? List<Meal>.from(this.lunch),
      dinner: dinner ?? List<Meal>.from(this.dinner),
    );
  }

  // Formatted date string
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Day name
  String get dayName {
    return [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ][date.weekday - 1];
  }

  // Get meals count for UI purposes
  int get mealCount => lunch.length + dinner.length;

  // Helper to check if contains a specific meal
  bool containsMeal(Meal meal) {
    return lunch.contains(meal) || dinner.contains(meal);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyMenu &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date == other.date &&
          lunch.equals(other.lunch) &&
          dinner.equals(other.dinner);

  @override
  int get hashCode =>
      id.hashCode ^ date.hashCode ^ lunch.hashCode ^ dinner.hashCode;
}

// Helper extension for list equality comparison
extension ListEquals<T> on List<T> {
  bool equals(List<T> other) {
    if (length != other.length) return false;
    for (var i = 0; i < length; i++) {
      if (this[i] != other[i]) return false;
    }
    return true;
  }
}
