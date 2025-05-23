import 'package:flutter/material.dart';
import 'package:menu_project/pages/exportPage.dart';
import 'package:menu_project/widget/meal.dart';
import 'package:menu_project/widget/navigationBar.dart';
import 'package:menu_project/widget/scrollButtons.dart';
import 'package:menu_project/widget/appBar.dart';
import 'package:menu_project/widget/appBarButtons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Color(0xFFECECEC),
      appBar: CustomAppBar(
        title: "Welcome, Back!",
        actions: [
          appBarButton(
            imagePath: "assets/Icons/upload.png",
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Exportpage();
                },
              );
            },
          ),
          SizedBox(width: 10),
          appBarButton(imagePath: "assets/Icons/share.png", onTap: () {}),
          SizedBox(width: 10),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Color(0xFFECECEC),
        child: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Scrollbuttons(),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
              Text(
                "Lunch",
                style: TextStyle(
                  color: Color(0xFF02197D),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(width: 60, height: 2, color: Color(0xFF02197D)),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.23,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  clipBehavior: Clip.none,

                  children: [
                    MealItem(
                      mealType: "Starter",
                      title: "Tom Yum Soup",
                      description:
                          " A famous Thai hot and sour soup made with ingredients like mushrooms, tomatoes, lemongrass, kaffir lime leaves, galangal, chili, and cilantro.",
                      imagePath: "assets/images/meal1.png",
                    ),
                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.03),
                    MealItem(
                      mealType: "Main",
                      title: "broccoli salad",
                      description:
                          " Teriyaki chicken served with brown rice, stir-fried broccoli,carrots, and sesame seeds",
                      imagePath: "assets/images/meal2.png",
                    ),
                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.03),
                    MealItem(
                      mealType: "Starter",
                      title: "Tom Yum Soup",
                      description:
                          " A famous Thai hot and sour soup made with ingredients like mushrooms, tomatoes, lemongrass, kaffir lime leaves, galangal, chili, and cilantro.",
                      imagePath: "assets/images/meal1.png",
                    ),
                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.03),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
              Text(
                "Dinner",
                style: TextStyle(
                  color: Color(0xFF02197D),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(width: 60, height: 2, color: Color(0xFF02197D)),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.23,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  clipBehavior: Clip.none,

                  children: [
                    MealItem(
                      mealType: "Starter",
                      title: "Tom Yum Soup",
                      description:
                          " A famous Thai hot and sour soup made with ingredients like mushrooms, tomatoes, lemongrass, kaffir lime leaves, galangal, chili, and cilantro.",
                      imagePath: "assets/images/meal1.png",
                    ),
                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.03),
                    MealItem(
                      mealType: "Starter",
                      title: "Tom Yum Soup",
                      description:
                          " A famous Thai hot and sour soup made with ingredients like mushrooms, tomatoes, lemongrass, kaffir lime leaves, galangal, chili, and cilantro.",
                      imagePath: "assets/images/meal1.png",
                    ),
                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.03),
                    MealItem(
                      mealType: "Starter",
                      title: "Tom Yum Soup",
                      description:
                          " A famous Thai hot and sour soup made with ingredients like mushrooms, tomatoes, lemongrass, kaffir lime leaves, galangal, chili, and cilantro.",
                      imagePath: "assets/images/meal2.png",
                    ),
                    SizedBox(width: MediaQuery.sizeOf(context).width * 0.03),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(selectedIndex: 0),
    );
  }
}
