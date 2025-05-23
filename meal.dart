import 'package:flutter/material.dart';
import 'package:menu_project/pages/delete.dart';
import 'package:menu_project/pages/edit.dart';

class MealItem extends StatefulWidget {
  final String mealType;
  final String title;
  final String description;
  final String imagePath;

  const MealItem({
    super.key,
    required this.title,
    required this.mealType,
    required this.description,
    required this.imagePath,
  });

  @override
  State<MealItem> createState() => _MealItemState();
}

class _MealItemState extends State<MealItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.8,
      height: MediaQuery.sizeOf(context).height,
      decoration: BoxDecoration(
        color: Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: const Color(0xffAAAAAA),
                    ),
                  ),

                  child: Padding(
                    padding: EdgeInsets.only(left: 10, top: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mealType,
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 10,
                            decoration: TextDecoration.none,
                          ),
                        ),

                        Text(
                          widget.title,
                          style: TextStyle(
                            color: Color(0xFF02197D),
                            fontSize: 20,
                            decoration: TextDecoration.none,
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(
                          width: constraints.maxWidth * 0.6,
                          child: Text(
                            widget.description,
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 8,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    widget.imagePath,
                    width: constraints.maxWidth * 0.3,
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Icon(
                        Icons.star_border,
                        size: 20,
                        color: Color(0xFFFFAA01),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return EditPage();
                          },
                        );
                      },
                      child: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Color(0xFFFFAA01),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DeletePage();
                          },
                        );
                      },
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFFFFAA01),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
