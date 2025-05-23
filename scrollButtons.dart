import 'package:flutter/material.dart';

class Scrollbuttons extends StatefulWidget {
  const Scrollbuttons({super.key});

  @override
  State<Scrollbuttons> createState() => _ScrollbuttonsState();
}

class _ScrollbuttonsState extends State<Scrollbuttons> {
  final List<Map<String, String>> dates = [
    {"day": "16", "week": "Sun"},
    {"day": "17", "week": "Mon"},
    {"day": "18", "week": "Tue"},
    {"day": "19", "week": "Wed"},
    {"day": "20", "week": "Thu"},
    {"day": "21", "week": "Fri"},
    {"day": "22", "week": "Sat"},
  ];
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.09,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        clipBehavior: Clip.none,
        itemCount: 7,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 60,

              child: ElevatedButton(
                onPressed: () {
                  _onItemTapped(index);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selectedIndex == index
                          ? Color(0xFFFFAC06)
                          : Color(0xFFE0E0E0),
                  foregroundColor:
                      _selectedIndex == index
                          ? Color(0xFFFFFFFF)
                          : Color(0xFF02197D),
                  padding: EdgeInsets.symmetric(vertical: 10),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(dates[index]['week']!, style: TextStyle(fontSize: 14)),
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
/*

   */