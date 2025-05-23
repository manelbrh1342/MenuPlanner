import 'package:flutter/material.dart';

class CategoryDropDown extends StatefulWidget {
  const CategoryDropDown({super.key});

  @override
  State<CategoryDropDown> createState() => _CategoryDropDownState();
}

class _CategoryDropDownState extends State<CategoryDropDown> {
  String? selectedCategory;

  final List<String> categories = ["Starter", "Main ", "Dessert"];
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
          value: selectedCategory,
          hint: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("choose category", style: TextStyle(fontSize: 12)),
                Image.asset("assets/Icons/ArrowDown.png"),
              ],
            ),
          ),

          items:
              categories
                  .map(
                    (String category) => DropdownMenuItem<String>(
                      value: category,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Color(0xFF02197D),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedCategory = newValue!;
            });
          },
        ),
      ),
    );
  }
}
