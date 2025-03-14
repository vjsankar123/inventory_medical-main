import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';

class SupplierForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddSupplier;
  final Map<String, dynamic>? initialSupplier;

  SupplierForm({required this.onAddSupplier, this.initialSupplier});

  @override
  _SupplierFormState createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm> {
  final ApiService apiService = ApiService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();
  final _postalController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  String _status = 'Active';
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    if (widget.initialSupplier != null) {
      _nameController.text = widget.initialSupplier!['company_name'] ?? '';
      _phoneController.text = widget.initialSupplier!['phone_number'] ?? '';
      _emailController.text = widget.initialSupplier!['email'] ?? '';
      _addressController.text = widget.initialSupplier!['address'] ?? '';
      _gstController.text =
          widget.initialSupplier!['supplier_gst_number'] ?? '';
      _postalController.text = widget.initialSupplier!['postal_code'] ?? '';
      _cityController.text = widget.initialSupplier!['city'] ?? '';
      _stateController.text = widget.initialSupplier!['state'] ?? '';
      _countryController.text = widget.initialSupplier!['country'] ?? '';

      // Fix: Ensure _status is valid
      String initialStatus = widget.initialSupplier!['status'] ?? 'Active';
      if (['Active', 'Inactive'].contains(initialStatus)) {
        _status = initialStatus;
      } else {
        _status = 'Active'; // Default value to avoid errors
      }
    }
  }

  void _registersupplier() async {
    Map<String, dynamic> supplierData = {
      "company_name": _nameController.text,
      "email": _emailController.text,
      "phone_number": _phoneController.text,
      "address": _addressController.text,
      "supplier_gst_number": _gstController.text,
      "postal_code": _postalController.text,
      "city": _cityController.text,
      "state": _stateController.text,
      "country": _countryController.text,
      "status": _status,
    };

    bool success = await apiService.createSupplier(supplierData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('User created successfully!'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Close modal
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to create user.'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Supplier',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTextField(_nameController, 'Company Name'),
            _buildTextField(_phoneController, 'Phone No'),
            _buildTextField(_emailController, 'Email'),
            _buildTextField(_addressController, 'Address'),
            _buildTextField(_gstController, 'GST No'),
            _buildTextField(_postalController, 'Postal Code'),
            _buildTextField(_cityController, 'City'),
            _buildTextField(_stateController, 'State'),
            _buildTextField(_countryController, 'Country'),
            const SizedBox(height: 16),
            Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black),
              ),
              child: DropdownButton<String>(
                value: ['Active',].contains(_status)
                    ? _status
                    : 'Active', // Ensure a valid value
                onChanged: (newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
                isExpanded: true,
                underline: SizedBox(),
                items: ['Active', ]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(value),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _registersupplier,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF028090)),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text('Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
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
        ),
        cursorColor: Color(0xFF028090),
      ),
    );
  }
}
