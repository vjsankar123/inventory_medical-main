import 'package:flutter/material.dart';

class TextFieldComponent extends StatelessWidget {
  final String label;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  TextFieldComponent({
    required this.label,
    this.keyboardType = TextInputType.text,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   label,
        //   style: TextStyle(
        //     fontSize: 18,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        SizedBox(height: 8),
        TextFormField(
         decoration: InputDecoration(
        labelText: label, // Set label text dynamically
          // contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        labelStyle: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF028090),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
          cursorColor: Color(0xFF028090),
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
        ),
        SizedBox(height: 16),
      ],
    );
  }
}



class NumberComponent extends StatelessWidget {
  final String label;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  NumberComponent({
    required this.label,
    this.keyboardType = TextInputType.number,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   label,
        //   style: TextStyle(
        //     fontSize: 18,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        SizedBox(height: 8),
        TextFormField(
         decoration: InputDecoration(
        labelText: label, // Set label text dynamically
          // contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        labelStyle: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF028090),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
          cursorColor: Color(0xFF028090),
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
