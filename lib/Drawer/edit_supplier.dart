import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';

class EditSupplierForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic> supplierData;

  EditSupplierForm({required this.onSave, required this.supplierData});

  @override
  _EditSupplierFormState createState() => _EditSupplierFormState();
}

class _EditSupplierFormState extends State<EditSupplierForm> {
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
    _nameController.text = widget.supplierData['company_name'] ?? '';
    _phoneController.text = widget.supplierData['phone_number'] ?? '';
    _emailController.text = widget.supplierData['email'] ?? '';
    _addressController.text = widget.supplierData['address'] ?? '';
    _gstController.text = widget.supplierData['supplier_gst_number'] ?? '';
    _postalController.text = widget.supplierData['postal_code'] ?? '';
    _cityController.text = widget.supplierData['city'] ?? '';
    _stateController.text = widget.supplierData['state'] ?? '';
    _countryController.text = widget.supplierData['country'] ?? '';

    // Normalize status value
    String statusValue = widget.supplierData['status']?.toString().trim() ?? 'Active';
    if (statusValue.toLowerCase() == 'active' || statusValue.toLowerCase() == 'inactive') {
      _status = statusValue[0].toUpperCase() + statusValue.substring(1).toLowerCase();
    } else {
      _status = 'Active'; // Default fallback
    }
  }


  @override
  void dispose(){
    super.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    _postalController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }


//   @override
// // void initState() {
// //   super.initState();
// //   print("Editing Supplier ID: ${widget.supplierData['id']}");
// // }


void _updateSupplier() async {
  final supplierId = widget.supplierData['supplier_id']?.toString();  // Ensure ID exists
  
  if (supplierId == null || supplierId.isEmpty) {
    print("Error: Supplier ID is missing!");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: Supplier ID is missing!'), backgroundColor: Colors.red),
    );
    return;
  }

  print("Updating supplier with ID: $supplierId");
  
  Map<String, dynamic> updatedData = {
    "supplier_id": supplierId, // ✅ Ensure ID is sent
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

  bool success = await apiService.updateSupplier(supplierId, updatedData);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Supplier updated successfully!'), backgroundColor: Colors.green),
    );
    widget.onSave(updatedData);
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update supplier.'), backgroundColor: Colors.red),
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
            const Text('Edit Supplier', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                value: _status,
                onChanged: (newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
                isExpanded: true,
                underline: SizedBox(),
                items: ['Active', 'Inactive']
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateSupplier,
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF028090)),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text('Update'),
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
