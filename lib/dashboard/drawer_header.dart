import 'package:flutter/material.dart';

class DrawerHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Color(0xFF028090),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.blue),
          ),
          SizedBox(height: 10),
          // Text("Sankar", style: TextStyle(color: Colors.white, fontSize: 18)),
          Text("sankar@gmail.com", style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}
