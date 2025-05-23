import 'package:flutter/material.dart';
import 'package:menu_project/IntroSection/intro_screen.dart';
import 'package:menu_project/IntroSection/second_intro.dart';
import 'package:menu_project/IntroSection/third_intro.dart';

class Intro extends StatelessWidget {
  final PageController controller = PageController(initialPage: 0);

  Intro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: BouncingScrollPhysics(),
        children: [
          FirstInto(controller: controller),
          SecondIntro(controller: controller),
          ThirdIntro(controller: controller),
        ],
      ),
    );
  }
}
