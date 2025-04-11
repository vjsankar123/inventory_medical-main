import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateUserButton extends StatefulWidget {
  @override
  _CreateUserButtonState createState() => _CreateUserButtonState();
}

class _CreateUserButtonState extends State<CreateUserButton> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();
  String _selectedRole = 'staff';

 final ApiService _apiService = ApiService();



void _registerUser() async {
  Map<String, dynamic> userData = {
    "username": _nameController.text,
    "email": _emailController.text,
    "password": _passwordController.text,
    "confirm_password": _passwordConfirmationController.text,
    "role": _selectedRole,
    "contact_number": _contactController.text,
    "address_details": _addressController.text,
    "user_id_proof": _aadhaarController.text,
  };

  bool success = await _apiService.createUser(userData);

  if (success) {
    // Show success message using _showSnackBar
    _showSnackBar('User created successfully!', isSuccess: true);
    Navigator.pop(context); // Close modal
  } else {
    // Show failure message using _showSnackBar
    _showSnackBar('Failed to create user.', isSuccess: false);
  }
}



void _showSnackBar(String message, {bool isSuccess = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.greenAccent : Colors.redAccent,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isSuccess ? Color(0xFF00796B) : Color(0xFFD32F2F),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: Duration(seconds: 3),
      elevation: 10,
    ),
  );
}
  void _showCreateUserModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Create User', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                _buildTextField('Name', _nameController),
                SizedBox(height: 10),
                _buildTextField('Contact Number', _contactController),
                SizedBox(height: 10),
                _buildTextField('Email', _emailController),
                SizedBox(height: 10),
                _buildTextField('Password', _passwordController,),
                SizedBox(height: 10),
                _buildTextField('Confirm Password', _passwordConfirmationController,),
                SizedBox(height: 10),
                _buildTextField('Aadhaar ID', _aadhaarController),
                SizedBox(height: 20),
                _buildDropdown(),
                SizedBox(height: 20),
                _buildTextArea('Address', _addressController),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF028090)),
                  child: Text('Submit', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String title, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: title,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Color(0xFF028090), width: 2.0)),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
      cursorColor: Color(0xFF028090),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        hintText: 'Select Role',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Color(0xFF028090), width: 2.0)),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
      items: [
        DropdownMenuItem(child: Text('Admin'), value: 'admin'),
        DropdownMenuItem(child: Text('Staff'), value: 'staff'),
      ],
      onChanged: (value) {
        setState(() {
          _selectedRole = value!;
        });
      },
    );
  }

  Widget _buildTextArea(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: title,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Color(0xFF028090), width: 2.0)),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
      cursorColor: Color(0xFF028090),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: _showCreateUserModal,
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF028090), shape: CircleBorder(), padding: EdgeInsets.all(10)),
        child: Icon(Icons.person_add, color: Colors.white, size: 24),
      ),
    );
  }
}
