import 'package:flutter/material.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:menu_planner/models/daily_menu.dart';
import 'package:menu_planner/providers/menu_provider.dart';
import 'package:menu_planner/widget/appBar.dart';
import 'package:menu_planner/widget/appBarButtons.dart';
import 'package:menu_planner/widget/meal.dart';
import 'package:menu_planner/widget/scrollbuttons.dart';
import 'package:menu_planner/pages/exportPage.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  late DateTime selectedDate;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await Provider.of<MenuProvider>(context, listen: false).fetchWeeklyMenu();
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void updateSelectedDay(String dayShort) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final now = DateTime.now();
        print("Current date: $now");
        final weekday = {
          "Sun": DateTime.sunday,
          "Mon": DateTime.monday,
          "Tue": DateTime.tuesday,
          "Wed": DateTime.wednesday,
          "Thu": DateTime.thursday,
          "Fri": DateTime.friday,
          "Sat": DateTime.saturday,
        }[dayShort]!;
        print("Selected weekday: $weekday ($dayShort)");

        int diff = now.weekday - weekday;
        print("Day difference: $diff");

        selectedDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: diff));

        print("Final selected date: $selectedDate");
      });
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final menuProvider = Provider.of<MenuProvider>(context);
    final dateKey = _formatDate(selectedDate);
    final dailyMenu = menuProvider.weeklyMenu[dateKey];

    print("Selected Date: $selectedDate"); // Add this line for debugging
    print("Date Key: $dateKey"); // Add this line to verify the date formatting
    print(
        "Daily Menu: $dailyMenu"); // Verify if the data for the selected date exists

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFECECEC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFECECEC),
        toolbarHeight: MediaQuery.of(context).size.height * 0.15,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Expanded(
              child: Text(
                "Welcome, Back!",
                style: TextStyle(
                  color: Color(0xFF02197D),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          appBarButton(
            imagePath: "assets/Icons/upload.png",
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => const Exportpage(),
              );
            },
          ),
          const SizedBox(width: 10),
          appBarButton(
            imagePath: "assets/Icons/share.png",
            onTap: () async {
              final menuProvider =
                  Provider.of<MenuProvider>(context, listen: false);
              final dateKey = _formatDate(selectedDate);
              final dailyMenu = menuProvider.weeklyMenu[dateKey];

              if (dailyMenu != null && dailyMenu.mealCount > 0) {
                final bool? shouldReplace = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFFECECEC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Replace Existing Meals?',
                            style: TextStyle(
                              color: Color(0xFF02197D),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(false),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        'This will replace all existing meals with random ones. Do you want to continue?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                      actions: [
                        _dialogActionButton(
                          text: 'Cancel',
                          onPressed: () => Navigator.of(context).pop(false),
                          textColor: const Color(0xFF02197D),
                        ),
                        _dialogActionButton(
                          text: 'Replace',
                          onPressed: () => Navigator.of(context).pop(true),
                          backgroundColor: const Color(0xFFFFAA01),
                          textColor: Colors.black,
                        ),
                      ],
                    );
                  },
                );

                if (shouldReplace != true) return;
              }

              try {
                await menuProvider.generateRandomMeals(selectedDate);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Random meals generated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error generating random meals: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: menuProvider.isLoading || _isRefreshing
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF02197D)),
              ),
            )
          : menuProvider.hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Error loading menu",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _refreshData();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Scrollbuttons(
                          onDaySelected: updateSelectedDay,
                        ),
                        const SizedBox(height: 16),
                        buildMealSection(
                          "Lunch",
                          dailyMenu?.lunch ?? [],
                        ),
                        const SizedBox(height: 24),
                        buildMealSection(
                          "Dinner",
                          dailyMenu?.dinner ?? [],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                    padding: const EdgeInsets.only(bottom: 100),
                  ),
                ),
    );
  }

  @override
  bool get wantKeepAlive => true;
  Widget _dialogActionButton({
    required String text,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.transparent,
    Color textColor = Colors.black,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }

  Widget buildMealSection(String title, List<Meal> meals) {
    final uniqueMeals = meals.fold<List<Meal>>([], (list, meal) {
      if (!list.any((m) => m.id == meal.id)) {
        list.add(meal);
      }
      return list;
    });

    uniqueMeals.sort((a, b) {
      final categoryOrder = {'starter': 0, 'main': 1, 'dessert': 2};
      return (categoryOrder[a.category] ?? 0)
          .compareTo(categoryOrder[b.category] ?? 0);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: uniqueMeals.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final meal = uniqueMeals[index];
              final imagePath = meal.imageUrl ?? "";

              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: MealItem(
                  meal: meal,
                  imagePath: imagePath,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
