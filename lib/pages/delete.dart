import 'package:flutter/material.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:menu_planner/services/meal_service.dart';
import 'package:menu_planner/providers/menu_provider.dart';
import 'package:provider/provider.dart';

class DeletePage extends StatelessWidget {
  final Meal meal;
  final _mealService = MealService();

  DeletePage({super.key, required this.meal});

  Future<void> _deleteMeal(BuildContext context) async {
    try {
      await _mealService.deleteMeal(meal.id);
      
      // Refresh the menu data
      if (context.mounted) {
        await Provider.of<MenuProvider>(context, listen: false).fetchWeeklyMenu();
      }

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting meal: $e')),
        );
      }
    }
  }
@override
Widget build(BuildContext context) {
  return Dialog(
    backgroundColor: const Color(0xFFECECEC), // Soft gray background
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16), // Optional, smooth edges for dialog
    ),
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Delete Meal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF02197D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to delete "${meal.name}"?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Smaller radius
                  ),
                  foregroundColor: const Color(0xFF02197D),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _deleteMeal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Smaller radius
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}