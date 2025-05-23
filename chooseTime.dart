import 'package:flutter/material.dart';

class Choosetime extends StatefulWidget {
  const Choosetime({super.key});

  @override
  State<Choosetime> createState() => _ChoosetimeState();
}

class _ChoosetimeState extends State<Choosetime> {
  String? selectedTime;
  final List<String> Times = ["Lunch", "Dinner"];
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
          icon: SizedBox.shrink(),
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(20),
          value: selectedTime,
          hint: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("choose time", style: TextStyle(fontSize: 12)),
                Image.asset("assets/Icons/ArrowDown.png"),
              ],
            ),
          ),
          items:
              Times.map(
                (String time) => DropdownMenuItem<String>(
                  value: time,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF02197D),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedTime = newValue!;
            });
          },
        ),
      ),
    );
  }
}
