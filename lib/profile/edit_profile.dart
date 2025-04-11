import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';

class EditShopForm extends StatefulWidget {
  final Map<String, String> profileData;
  final Function(Map<String, String>) onSave;

  const EditShopForm({Key? key, required this.profileData, required this.onSave}) : super(key: key);

  @override
  _EditShopFormState createState() => _EditShopFormState();
}

class _EditShopFormState extends State<EditShopForm> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController shopNameController;
  late TextEditingController gstNumberController;
  late TextEditingController addressController;
  late TextEditingController pinCodeController;
  late TextEditingController descriptionController;
  late bool isGovernmentRegistered;

  @override
void initState() {
  super.initState();
  
  shopNameController = TextEditingController(text: widget.profileData["pharmacy_name"] ?? '');
  gstNumberController = TextEditingController(text: widget.profileData["owner_GST_number"] ?? '');
  addressController = TextEditingController(text: widget.profileData["pharmacy_address"] ?? '');
  pinCodeController = TextEditingController(text: widget.profileData["pincode"] ?? '');
  descriptionController = TextEditingController(text: widget.profileData["description"] ?? '');
  isGovernmentRegistered = widget.profileData["allow_registration"] == "Registered";
}



  @override
  void dispose() {
    shopNameController.dispose();
    gstNumberController.dispose();
    addressController.dispose();
    pinCodeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

void _updateProfile() async {
  Map<String, String> updatedProfile = {
    "pharmacy_name": shopNameController.text,
    "owner_GST_number": gstNumberController.text,
    "pharmacy_address": addressController.text,
    "pincode": pinCodeController.text,
    "description": descriptionController.text,
    "allow_registration": isGovernmentRegistered ? "Registered" : "Not Registered",
  };

  bool success = await _apiService.updateprofile(
    widget.profileData['shop_id'] ?? "", // Ensure shop_id is provided
    updatedProfile,
  );

  if (success) {
    _showSnackBar('Profile updated successfully!', isSuccess: true);
    widget.onSave(updatedProfile);
    Navigator.pop(context);
  } else {
    _showSnackBar('Failed to update profile. Please try again.', isSuccess: false);
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

  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            buildTextField("Shop Name", shopNameController),
            buildTextField("GST Number", gstNumberController),
            ElevatedButton(onPressed: _updateProfile, child: const Text("Save")),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? "$label cannot be empty" : null,
    );
  }
}
