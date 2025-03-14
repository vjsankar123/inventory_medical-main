import 'package:flutter/material.dart';
import 'persistent_bottom_nav_bar.dart'; // Import the PersistentBottomNavBar widget

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: PersistentBottomNavBar(),
    );
  }
}
