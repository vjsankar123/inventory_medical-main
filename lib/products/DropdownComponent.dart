import 'package:flutter/material.dart';

class DropdownComponent extends StatelessWidget {
  final List<String> items;
  final String label;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  DropdownComponent({
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    // required String label,
     required this.label,
    required String? Function(dynamic value) validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: items.contains(selectedValue) ? selectedValue : null,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        // contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        // labelText: '',
          labelText: label, // Set label text dynamically
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
      dropdownColor: Colors.white,
    );
  }
}

class GSTDropdownField extends StatelessWidget {
  final List<String> items;
   final String label;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  GSTDropdownField({
    required this.items,
    required this.selectedValue,
     required this.label,
    required this.onChanged,
    // required String label,
    required String? Function(dynamic value) validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: items.contains(selectedValue) ? selectedValue : null,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        // contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
         labelText: label, // Set label text dynamically
        labelStyle: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        // labelStyle: TextStyle(
        //   fontSize: 18.0,
        //   fontWeight: FontWeight.w600,
        //   color: Colors.black,
        // ),
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
      dropdownColor: Colors.white,
    );
  }
}
class SupplierDropdownField extends StatelessWidget {
  final List<String> items;
  final String? selectedValue;
  final String label;
  final ValueChanged<String?> onChanged;

  SupplierDropdownField({
    required this.items,
    required this.label,
    required this.selectedValue,
    required this.onChanged, required String? Function(dynamic value) validator,
  });

  @override
  Widget build(BuildContext context) {
    // Remove duplicates to ensure there is only one unique 'company_name' in the list
    List<String> uniqueItems = items.toSet().toList();

    return DropdownButtonFormField<String>(
      value: uniqueItems.contains(selectedValue) ? selectedValue : null, // Ensure valid value
      onChanged: onChanged,
      items: uniqueItems.map((supplier) {
        return DropdownMenuItem<String>(
          value: supplier,
          child: Text(
            supplier,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
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
      dropdownColor: Colors.white,
    );
  }
}
