import 'package:flutter/material.dart';

class Datebuttons extends StatefulWidget {
  const Datebuttons({super.key});

  @override
  State<Datebuttons> createState() => _DatebuttonsState();
}

class _DatebuttonsState extends State<Datebuttons> {
  final List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  final Set<String> selectedDays = {};
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
        });
      },
      child: Container(
        width: 50,
        height: 30,
        alignment: Alignment.center,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFFFF1D4) : Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Color(0xFFFFAA01) : Color(0xFF010F7E),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
