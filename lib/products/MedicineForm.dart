import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/bottom_items/staff_page.dart';
import 'package:flutter_application_1/products/create_product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'DropdownComponent.dart';
import 'DateFieldComponent.dart';

class MedicineForm extends StatefulWidget {
  final Function(Map<String, String>) onAddProduct;

  MedicineForm(
      {required this.onAddProduct, required Map<String, String> product});

  @override
  _MedicineFormState createState() => _MedicineFormState();
}

final ApiService _apiService = ApiService();

class _MedicineFormState extends State<MedicineForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> _supplierList = [];
  String? _selectedSupplier;

  List<Map<String, dynamic>> supplierList = []; // Added this
  bool _isLoading = false;
  bool _isFetchingMore = false;

  String? _selectedCategory;
  String? _availabilityStatus;
  final TextEditingController _expiryDateController = TextEditingController();

  final TextEditingController _mfdDateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _genericNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _mrpPriceController = TextEditingController();
  final TextEditingController _supplierPriceController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _discountPercentageController =
      TextEditingController();
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _batchnoNameController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final List<Map<String, String>> products = [];
  List<String> supplierNames = [];
  List<Map<String, String>> categorylist = [];
  List<String> dropdownItems = [];
  String? _selectedGST;

  @override
  void initState() {
    super.initState();
    _availabilityStatus = 'Available';
    fetchAndDisplaysupplier();
    fetchAndDisplayCategory();
  }

  Future<void> fetchAndDisplaysupplier() async {
    final token = await _apiService.getTokenFromStorage();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are not logged in. Please log in first.'),
        ),
      );
      return;
    }

    try {
      final fetchedSuppliers =
          await _apiService.fetchsuppliers(); // Fetch all suppliers
      setState(() {
        supplierList = fetchedSuppliers;
        _supplierList = supplierList
            .map((supplier) => supplier['company_name'].toString())
            .toList();

        // ✅ Auto-set _selectedSupplier to a valid ID if not already set
        if (_selectedSupplier == null && supplierList.isNotEmpty) {
          _selectedSupplier = supplierList.first['supplier_id'].toString();
        }
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch suppliers. Please try again later.'),
        ),
      );
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

  Future<void> fetchAndDisplayCategory() async {
    if (_isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    try {
      final fetchedCategory = await _apiService
          .fetchCategories(); // Fetch all categories without pagination

      setState(() {
        categorylist = fetchedCategory; // Store the full category data
        dropdownItems = categorylist
            .map((cat) => cat["category_name"].toString())
            .toList(); // Store just the names of categories

        // Optionally, set a default category if required
        // if (_selectedCategory == null && dropdownItems.isNotEmpty) {
        //   _selectedCategory = dropdownItems[0]; // Default selection
        // }

        _isFetchingMore = false;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _isFetchingMore = false;
      });
    }
  }


  
Future<void> _submitForm() async {
  Map<String, dynamic> productData = {
    'product_name': _nameController.text,
    'brand_name': _brandController.text,
    'generic_name': _genericNameController.text,
    'product_batch_no': _batchnoNameController.text,
    'product_price': _mrpPriceController.text,
    'selling_price': _sellingPriceController.text,
    'product_description': _descriptionController.text,
    'product_quantity': _quantityController.text,
    'product_discount': _discountPercentageController.text,
    'supplier_price': _supplierPriceController.text,
    'GST': _selectedGST,
    'supplier': _selectedSupplier, // Ensure this is an ID, not null
    'expiry_date': _expiryDateController.text, // Already in YYYY-MM-DD
    'MFD': _mfdDateController.text, // Already in YYYY-MM-DD
    'product_category': _selectedCategory,
    'stock_status': _availabilityStatus,
  };

  bool success = await _apiService.createProduct(productData);

  if (success) {
    _showSnackBar('Product created successfully!', isSuccess: true);
    Navigator.pop(context); // Close modal
  } else {
    _showSnackBar('Failed to create product.', isSuccess: false);
  }
}


  Future<void> _loadSuppliers() async {
    List<String> suppliers = await _apiService.fetchSupplierNames();
    setState(() {
      _supplierList = suppliers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF028090),
        title: Text('Add Product',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFieldComponent(
                label: 'Product Name',
                controller: _nameController,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a name'
                    : null,
              ),
              TextFieldComponent(
                label: 'Brand Name',
                controller: _brandController,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a brand name'
                    : null,
              ),
              TextFieldComponent(
                label: 'Generic Name',
                controller: _genericNameController,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a generic name'
                    : null,
              ),
              NumberComponent(
                label: 'Batch No',
                keyboardType: TextInputType.number,
                controller: _batchnoNameController,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a Batch No'
                    : null,
              ),
              NumberComponent(
                label: 'Quantity',
                controller: _quantityController,
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a quantity'
                    : null,
              ),
              //      Text('Select Category',style: TextStyle(fontSize: 18,
              // fontWeight: FontWeight.bold,),),
              SizedBox(
                height: 10,
              ),
              DropdownComponent(
                label: 'Category',
                items: categorylist
                    .map((cat) => cat["category_name"].toString())
                    .toList(),
                selectedValue: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = categorylist
                        .firstWhere(
                          (cat) => cat["category_name"] == value,
                          orElse: () => {},
                        )['id']
                        ?.toString(); // Store Category ID instead of Name
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),

              SizedBox(
                height: 10,
              ),
              NumberComponent(
                label: 'MRP Price',
                controller: _mrpPriceController,
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter MRP price'
                    : null,
              ),
              NumberComponent(
                label: 'Supplier Price',
                controller: _supplierPriceController,
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter supplier price'
                    : null,
              ),
              NumberComponent(
                label: 'Selling Price',
                controller: _sellingPriceController,
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter selling price'
                    : null,
              ),
              TextFieldComponent(
                label: 'Description',
                controller: _descriptionController,
                keyboardType: TextInputType.text,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              NumberComponent(
                label: 'Discount Percentage',
                controller: _discountPercentageController,
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter discount percentage'
                    : null,
              ),
              MFDDateFieldComponent(
                controller: _mfdDateController,
                label: 'MFD Date',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a Manufacturing Date';
                  }
                  return null;
                },
              ),
              DateFieldComponent(
                controller: _expiryDateController,
                label: 'Expiry Date',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an Expiry Date';
                  }
                  return null;
                },
              ),

              DropdownComponent(
                label: 'Select Supplier',
                items: supplierList
                    .map((supplier) => supplier['company_name'].toString())
                    .toList(),
                selectedValue: _selectedSupplier,
                onChanged: (value) {
                  setState(() {
                    _selectedSupplier = supplierList
                        .firstWhere(
                          (supplier) => supplier['company_name'] == value,
                          orElse: () => {},
                        )['supplier_id']
                        ?.toString(); // Ensure it's an ID
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a Supplier' : null,
              ),

              SizedBox(height: 16),
              GSTDropdownField(
                label: 'GST Number',
                items: ['0%', '5%', '12%', '18%', '28%'],
                selectedValue:
                    _selectedGST, // Use _selectedGST instead of _gstController
                onChanged: (value) {
                  setState(() {
                    _selectedGST = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a GST Value' : null,
              ),

              SizedBox(height: 16),
              DropdownComponent(
                label: 'Availability Status',
                items: ['Available',],
                selectedValue: _availabilityStatus,
                onChanged: (value) {
                  setState(() {
                    _availabilityStatus = value;
                  });
                },
                validator: (value) => value == null
                    ? 'Please select an availability status'
                    : null,
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ElevatedButton(
                  //     onPressed: () => _formKey.currentState!.reset(),
                  //     style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.grey),
                  //     child: Text('Cancel',
                  //         style: TextStyle(color: const Color.fromARGB(255, 94, 91, 91)))),
                  ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF028090)),
                      child: Text('Submit',
                          style: TextStyle(color: Colors.white))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
