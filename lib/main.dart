import 'package:flutter/material.dart';
import 'page/home_page.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "home": (context) {
          return HomePage();
        }
      },
      home: HomePage(),
    );
  }
}




