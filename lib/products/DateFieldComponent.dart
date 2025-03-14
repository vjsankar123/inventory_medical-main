import 'package:flutter/material.dart';

// DateFieldComponent (For Expiry Date)
class DateFieldComponent extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  DateFieldComponent({
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(), // Prevent past dates
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Color(0xFF028090),
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null) {
                  // Ensure local time zone and correct date
                  controller.text = _formatDate(pickedDate);
                }
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Color(0xFF028090),
                width: 2.0,
              ),
            ),
            hintText: 'YYYY-MM-DD',
          ),
          controller: controller,
          validator: validator,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  // Ensure correct date format (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    DateTime localDate = date.toLocal();
    return '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';
  }
}

// MFDDateFieldComponent (For Manufacturing Date)
class MFDDateFieldComponent extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  MFDDateFieldComponent({
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000), // Allow past dates for MFD
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Color(0xFF028090),
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null) {
                  // Ensure local time zone and correct date
                  controller.text = _formatDate(pickedDate);
                }
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Color(0xFF028090),
                width: 2.0,
              ),
            ),
            hintText: 'YYYY-MM-DD',
          ),
          controller: controller,
          validator: validator,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  // Ensure correct date format (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    DateTime localDate = date.toLocal();
    return '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';
  }
}
