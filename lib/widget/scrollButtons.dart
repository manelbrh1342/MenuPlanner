import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Scrollbuttons extends StatefulWidget {
  final Function(String) onDaySelected; // Callback function to notify HomePage

  const Scrollbuttons({
    super.key,
    required this.onDaySelected,
  });

  @override
  State<Scrollbuttons> createState() => _ScrollbuttonsState();
}

class _ScrollbuttonsState extends State<Scrollbuttons> {
  late List<Map<String, String>> dates;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeDates();
  }

  void _initializeDates() {
    final now = DateTime.now();
    // Generate dates for the entire week (Sunday to Saturday)
    dates = List.generate(7, (index) {
      final date = now.add(Duration(days: index - now.weekday));
      return {
        "day": date.day.toString(),
        "week": DateFormat('E').format(date),
      };
    });

    // Set the selected index to today's weekday
    _selectedIndex = now.weekday % 7; // Adjust for Sunday being 7

    // Notify HomePage of the selected day
    widget.onDaySelected(dates[_selectedIndex]['week']!);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Notify HomePage of the selected day (e.g., "Sun", "Mon", etc.)
    widget.onDaySelected(dates[index]['week']!);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.09,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 60,
              child: ElevatedButton(
                onPressed: () {
                  _onItemTapped(index);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedIndex == index
                      ? const Color(0xFFFFAC06) // Orange when selected
                      : const Color(0xFFE0E0E0), // Light gray when not selected
                  foregroundColor: _selectedIndex == index
                      ? const Color(0xFFFFFFFF) // White text when selected
                      : const Color(0xFF02197D), // Dark text when not selected
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      dates[index]['day']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(dates[index]['week']!,
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
