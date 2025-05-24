
import 'package:flutter/material.dart';
class Choosecategory extends StatefulWidget {
  final Function(String?) onChanged;
  
  const Choosecategory({super.key, required this.onChanged});

  @override
  State<Choosecategory> createState() => _ChoosecategoryState();
}

class _ChoosecategoryState extends State<Choosecategory> {
  String? selectedTime;
  final List<String> times = ["starter","main", "dessert"]; 

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.width * 0.14,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: DropdownButton<String>(
          icon: const SizedBox.shrink(),
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(20),
          value: selectedTime,
          hint: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Choose category", style: TextStyle(fontSize: 12)),
                Icon(Icons.arrow_drop_down, color: Colors.black),
              ],
            ),
          ),
          items: times.map((String time) => DropdownMenuItem<String>(
            value: time,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                time[0].toUpperCase() + time.substring(1), // Capitalize first letter
                style: const TextStyle(
                  color: Color(0xFF02197D),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedTime = newValue;
            });
            widget.onChanged(newValue);
          },
        ),
      ),
    );
  }
}