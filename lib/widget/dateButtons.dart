import 'package:flutter/material.dart';
class Datebuttons extends StatefulWidget {
  final Function(List<DateTime>) onDaysSelected;
  
  const Datebuttons({super.key, required this.onDaysSelected});

  @override
  State<Datebuttons> createState() => _DatebuttonsState();
}

class _DatebuttonsState extends State<Datebuttons> {
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat","Sun"];
  final Set<String> selectedDays = {};
  final List<DateTime> selectedDates = [];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.55,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: days.map((day) => _buildDateButton(day)).toList(),
      ),
    );
  }

  Widget _buildDateButton(String text) {
    bool isSelected = selectedDays.contains(text);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedDays.remove(text);
          } else {
            selectedDays.add(text);
          }
          _updateSelectedDates();
          widget.onDaysSelected(selectedDates);
        });
      },
      child: Container(
        width: 50,
        height: 30,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF1D4) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFFAA01) : const Color(0xFF010F7E),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _updateSelectedDates() {
    final today = DateTime.now();
    final currentWeekday = today.weekday;
    
    selectedDates.clear();
    
    for (final day in selectedDays) {
      final dayIndex = days.indexOf(day);
      if (dayIndex >= 0) {
        final daysToAdd = (dayIndex + 1) - currentWeekday;
        selectedDates.add(today.add(Duration(days: daysToAdd)));
      }
    }
  }
}