import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController controller;

  SearchWidget({required this.controller,});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, spreadRadius: 2)],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search Staff...',
          hintStyle: TextStyle(color: Colors.black),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.black),
          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0), // Adjust padding for alignment
        ),
        style: TextStyle(color: Colors.black),
        autofocus: true,
        cursorColor: Color(0xFF028090),
      ),
    );
  }
}
