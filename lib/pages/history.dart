import 'dart:io';
import 'package:flutter/material.dart';
import 'package:menu_planner/widget/meal.dart';
import 'package:menu_planner/providers/menu_provider.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMealHistory();
    });
  }

  Future<void> _fetchMealHistory() async {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    await menuProvider.fetchRecentMealHistory(30);
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFECECEC),
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF02197D),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF02197D)),
      ),
      body: Column(
        children: [
          _buildDateSelector(menuProvider),
          const SizedBox(height: 10),
          Expanded(child: _buildMealHistory(menuProvider)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDateSelector(MenuProvider menuProvider) {
    final now = DateTime.now();
    final selectedDate = menuProvider.selectedHistoryDate;
    final historyDates = menuProvider.mealHistory.keys
        .map((dateStr) => DateTime.parse(dateStr))
        .toList()
      ..sort((a, b) => a.compareTo(b));

    final dates = historyDates.isNotEmpty
        ? historyDates.take(6).toList()
        : List.generate(6, (index) => now.subtract(Duration(days: 5 - index)));

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          final hasMeals = menuProvider.mealHistory
              .containsKey(DateFormat('yyyy-MM-dd').format(date));

          return GestureDetector(
            onTap: hasMeals
                ? () => menuProvider.setSelectedHistoryDate(date)
                : null,
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.amber[600]
                    : const Color(0xFFBFC9E4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealHistory(MenuProvider menuProvider) {
    if (menuProvider.mealHistory.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF02197D),
        ),
      );
    }

    final selectedDateStr =
        DateFormat('yyyy-MM-dd').format(menuProvider.selectedHistoryDate);
    final mealsForDate = menuProvider.mealHistory[selectedDateStr];

    if (mealsForDate == null ||
        (mealsForDate.lunch.isEmpty && mealsForDate.dinner.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_meals, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No meals recorded for ${DateFormat('MMMM d').format(menuProvider.selectedHistoryDate)}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF02197D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            DateFormat('EEEE, MMMM d').format(menuProvider.selectedHistoryDate),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF02197D),
            ),
          ),
        ),
        if (mealsForDate.lunch.isNotEmpty)
          _buildMealTimeSection("Lunch", mealsForDate.lunch),
        if (mealsForDate.lunch.isNotEmpty && mealsForDate.dinner.isNotEmpty)
          const SizedBox(height: 24),
        if (mealsForDate.dinner.isNotEmpty)
          _buildMealTimeSection("Dinner", mealsForDate.dinner),
      ],
    );
  }

  Widget _buildMealTimeSection(String title, List<Meal> meals) {
    final sortedMeals = List<Meal>.from(meals);
    sortedMeals.sort((a, b) {
      final categoryOrder = {'starter': 0, 'main': 1, 'dessert': 2};
      return (categoryOrder[a.category.toLowerCase()] ?? 3)
          .compareTo(categoryOrder[b.category.toLowerCase()] ?? 3);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF02197D),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sortedMeals.length,
            itemBuilder: (context, index) {
              final meal = sortedMeals[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: MealItem(
                  meal: meal,
                  imagePath: _getImagePath(meal),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getImagePath(Meal meal) {
    return (meal.imageUrl != null && meal.imageUrl!.isNotEmpty)
        ? meal.imageUrl!
        : "assets/default_images/meal.png";
  }
}
