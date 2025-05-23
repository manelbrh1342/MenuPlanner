import 'package:flutter/material.dart';
import 'package:menu_project/HomePage/homePage.dart';
import 'package:menu_project/widget/appBar.dart';
import 'package:menu_project/widget/appBarButtons.dart';
import 'package:menu_project/widget/category.dart';
import 'package:menu_project/widget/chooseTime.dart';
import 'package:menu_project/widget/dateButtons.dart';
import 'package:menu_project/widget/navigationBar.dart';

class AddMeal extends StatefulWidget {
  const AddMeal({super.key});

  @override
  State<AddMeal> createState() => _AddmealState();
}

class _AddmealState extends State<AddMeal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      appBar: CustomAppBar(
        title: "What do you want to cook today?",

        actions: [
          appBarButton(imagePath: "assets/Icons/add.png", onTap: () {}),
          SizedBox(width: 10),
          appBarButton(
            imagePath: "assets/Icons/cancel.png",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: Color(0xFFECECEC),
          child: Padding(
            padding: EdgeInsets.all(20),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "select the category and time:",
                  style: TextStyle(color: Color(0xFF9D9B9B), fontSize: 12),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [CategoryDropDown(), Choosetime()],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.22,
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
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Datebuttons(),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Not sure what to cook?\n Generate a random dish!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF001A76),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.height * 0.08,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Generate meal",
                            style: TextStyle(
                              color: Color(0xFF9D9B9B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.09),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: CustomNavigationBar(selectedIndex: 1),
    );
  }
}
