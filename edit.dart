import 'package:flutter/material.dart';
import 'package:menu_project/widget/category.dart';
import 'package:menu_project/widget/chooseTime.dart';
import 'package:menu_project/widget/dateButtons.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color(0xFFECECEC),
            borderRadius: BorderRadius.circular(15),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.close, color: Colors.yellow, size: 24),
                  ),
                ),
                Text(
                  "Edit Meal",
                  style: TextStyle(
                    color: Color(0xFF02197D),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(width: 100, height: 2, color: Color(0xFF02197D)),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.010),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: MediaQuery.of(context).size.height * 0.18,
                      decoration: BoxDecoration(
                        color: Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xFFFFAC06),
                          width: 1.0,
                        ),
                      ),
                      child: Icon(Icons.photo, color: Colors.black),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "select the days (you can \nchoose multiple):",
                          style: TextStyle(
                            color: Color(0xFF9D9B9B),
                            fontSize: 12,
                          ),
                        ),
                        Datebuttons(),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.sizeOf(context).height * 0.010),
                Text(
                  "select category and time:",
                  style: TextStyle(color: Color(0xFF9D9B9B), fontSize: 12),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [CategoryDropDown(), Choosetime()],
                ),
                SizedBox(height: 10),
                Text(
                  "Name",
                  style: TextStyle(color: Color(0xFFFFAC06), fontSize: 16),
                ),
                TextField(
                  style: TextStyle(color: Color(0xFF9D9B9B)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFFFAC06),
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Description",
                  style: TextStyle(color: Color(0xFFFFAC06), fontSize: 16),
                ),
                TextField(
                  style: TextStyle(color: Color(0xFF9D9B9B)),
                  maxLines: 3,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFFFAC06),
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
