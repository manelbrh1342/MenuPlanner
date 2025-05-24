import 'package:menu_planner/models/meal.dart';

import 'daily_menu.dart';

class WeeklyMenu {
  String id;
  DateTime startDate;
  DateTime endDate;
  List<DailyMenu> days;

  WeeklyMenu({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  factory WeeklyMenu.fromJson(Map<String, dynamic> json) {
    return WeeklyMenu(
      id: json['id'] ?? '',
      startDate: json['startDate']?.toDate() ?? DateTime.now(),
      endDate: json['endDate']?.toDate() ?? DateTime.now().add(const Duration(days: 6)),
      days: (json['days'] as List<dynamic>?)
          ?.map((day) => DailyMenu.fromJson(day))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'days': days.map((day) => day.toJson()).toList(),
    };
  }

  // Fixed version of getDayByDate
  DailyMenu? getDayByDate(DateTime date) {
    try {
      return days.firstWhere(
        (day) => _isSameDate(day.date, date),
      );
    } catch (e) {
      return null; // Return null if no matching day found
    }
  }

  // Alternative implementation using orElse
  DailyMenu? getDayByDateAlternative(DateTime date) {
    return days.cast<DailyMenu?>().firstWhere(
      (day) => day != null && _isSameDate(day.date, date),
      orElse: () => null,
    );
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  List<Meal?> getAllMeals() {
    return days.expand((day) => day.allMeals).toList();
  }

  WeeklyMenu copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    List<DailyMenu>? days,
  }) {
    return WeeklyMenu(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      days: days ?? this.days,
    );
  }
}