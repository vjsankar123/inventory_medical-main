import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/products/DateFieldComponent.dart';
import 'package:flutter_application_1/products/DropdownComponent.dart';
import 'package:flutter_application_1/products/create_product.dart';
import 'package:intl/intl.dart';

class Medicineedit extends StatefulWidget {
  final Map<String, dynamic> product;

  final Function(Map<String, dynamic>)
      onAddProduct; // Adding product to initialize the form with existing values

  Medicineedit({
    required this.product,
    required this.onAddProduct,
  });

  @override
  _MedicineeditState createState() => _MedicineeditState();
}

class _MedicineeditState extends State<Medicineedit> {
  final ApiService apiService = ApiService();

  List<String> _supplierList = [];
  String? _selectedSupplier;
  List<Map<String, dynamic>> supplierList = []; // Added this
  bool _isLoading = false;
  bool _isFetchingMore = false;

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _categoryController;
  late TextEditingController _expiryDateController;
  late TextEditingController _batchnoNameController;
  late TextEditingController _qtyController;
  late TextEditingController _genericNameController;
  late TextEditingController _mrpPriceController;
  late TextEditingController _supplierPriceController;
  late TextEditingController _mfdController; // Added MFD field
  late TextEditingController _descriptionController;
  late TextEditingController
      _sellingPriceController; // Added selling price field
  late TextEditingController _discountPercentageController;
  late TextEditingController _supplierNameController;
  late TextEditingController _gstController;
  late TextEditingController _availabilityStatusController;

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Added form key
  final List<Map<String, String>> products = [];
  List<String> supplierNames = [];
  List<Map<String, String>> categorylist = [];
  List<Map<String, String>> GSTList = [];
  List<String> dropdownItems = [];
  String? _selectedCategory;
  String? _selectedSupplierName;
  String? _availabilityStatus;
  String? _selectedGST;

  String formatDateToDisplay(String? inputDate) {
    if (inputDate == null || inputDate.isEmpty) return '';
    try {
      DateTime date = DateFormat('yyyy-MM-dd').parse(inputDate);
      return DateFormat('dd/MM/yyyy')
          .format(date); // Convert to display-friendly format
    } catch (e) {
      return inputDate; // If parsing fails, return the original
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers as empty initially
    _nameController = TextEditingController();
    _brandController = TextEditingController();
    _categoryController = TextEditingController();
    _expiryDateController = TextEditingController();
    _batchnoNameController = TextEditingController();
    _qtyController = TextEditingController();
    _genericNameController = TextEditingController();
    _mrpPriceController = TextEditingController();
    _supplierPriceController = TextEditingController();
    _mfdController = TextEditingController();
    _descriptionController = TextEditingController();
    _sellingPriceController = TextEditingController();
    _discountPercentageController = TextEditingController();
    _supplierNameController = TextEditingController();
    _gstController = TextEditingController();
    _availabilityStatusController = TextEditingController(
      text: widget.product['availability']?.toString() ?? '',
    );

    // Call ViewProducts API to fetch product data
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      _isLoading = true; // Show loading state
    });

    try {
      final fetchedProduct = await apiService.ViewProducts(
          widget.product['id']); // Fetch product data

      if (fetchedProduct != null) {
        // Populate the form fields with the fetched product details
        setState(() {
          _nameController.text =
              fetchedProduct['product_name']?.toString() ?? '';
          _brandController.text =
              fetchedProduct['brand_name']?.toString() ?? '';
          _categoryController.text =
              fetchedProduct['product_category']?.toString() ?? '';
          _expiryDateController.text =
              formatDateToDisplay(fetchedProduct['expiry_date']?.toString());
          _batchnoNameController.text =
              fetchedProduct['product_batch_no']?.toString() ?? '';
          _qtyController.text =
              fetchedProduct['product_quantity']?.toString() ?? '';
          _genericNameController.text =
              fetchedProduct['generic_name']?.toString() ?? '';
          _mrpPriceController.text =
              fetchedProduct['product_price']?.toString() ?? '';
          _supplierPriceController.text =
              fetchedProduct['supplier_price']?.toString() ?? '';
          _mfdController.text =
              formatDateToDisplay(fetchedProduct['MFD']?.toString());
          _descriptionController.text =
              fetchedProduct['product_description']?.toString() ?? '';
          _sellingPriceController.text =
              fetchedProduct['selling_price']?.toString() ?? '';
          _discountPercentageController.text =
              fetchedProduct['product_discount']?.toString() ?? '';
          _supplierNameController.text =
              fetchedProduct['supplier_name']?.toString() ??
                  'xc'; // Set supplier
          _gstController.text =
              fetchedProduct['GST']?.toString() ?? ''; // Set GST
          _availabilityStatusController.text =
              fetchedProduct['availability']?.toString() ?? 'Available';

          _selectedCategory = fetchedProduct['product_category']?.toString();
          _selectedSupplier = fetchedProduct['supplier_name']?.toString();
          String fetchedGST = fetchedProduct['GST']?.toString() ?? '';
          print('Fetched GST from API: $fetchedGST');

          if (['0.00', '5.00', '12.00', '18.00', '28.00']
              .contains(fetchedGST)) {
            _selectedGST = '$fetchedGST%'; // Append % to match dropdown values
          } else {
            _selectedGST = null;
          }

          print('Final selected GST Value: $_selectedGST');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product not found')),
        );
      }
    } catch (e) {
      print('Error fetching product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load product details')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading state
      });
    }

    // Fetch suppliers and categories after product details
    fetchAndDisplaysupplier();
    fetchAndDisplayCategory();
  }

  Future<void> fetchAndDisplaysupplier() async {
    final token = await apiService.getTokenFromStorage();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are not logged in. Please log in first.'),
        ),
      );
      return;
    }

    try {
      final fetchedSuppliers = await apiService.fetchsuppliers();
      setState(() {
        supplierList = fetchedSuppliers;
        _supplierList = supplierList
            .map((supplier) => supplier['company_name'].toString())
            .toList();

        // ✅ Ensure supplier is selected properly
        // if (widget.product['supplier'] != null) {
        //   _selectedSupplier = supplierList
        //       .firstWhere(
        //         (supplier) =>
        //             supplier['company_name'] == widget.product['supplier'],
        //         orElse: () => {'supplier_id': null},
        //       )['supplier_id']
        //       ?.toString();
        // }
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

  Future<void> fetchAndDisplayCategory() async {
    if (_isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    try {
      final fetchedCategory = await apiService
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

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _expiryDateController.dispose();
    _batchnoNameController.dispose();
    _qtyController.dispose();
    _genericNameController.dispose();
    _mfdController.dispose();
    _mrpPriceController.dispose();
    _supplierPriceController.dispose();
    _sellingPriceController.dispose();
    _descriptionController.dispose();
    _discountPercentageController.dispose();
    _supplierNameController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      Map<String, dynamic> updatedProduct = {
        'id': widget.product['id'],
        'product_name': _nameController.text,
        'brand_name': _brandController.text,
        'product_category': _selectedCategory,
        'expiry_date': _expiryDateController.text,
        'MFD': _mfdController.text,
        'product_batch_no': _batchnoNameController.text,
        'product_quantity': _qtyController.text,
        'generic_name': _genericNameController.text,
        'product_price': _mrpPriceController.text,
        'supplier_price': _supplierPriceController.text,
        'selling_price': _sellingPriceController.text,
        'product_description': _descriptionController.text,
        'product_discount': _discountPercentageController.text,
        'supplier': _selectedSupplier,
        'GST': _selectedGST,
        'stock_status': _availabilityStatusController
            .text, // Use the controller's text here
      };

      bool success =
          await apiService.updateProducts(widget.product['id'], updatedProduct);

      if (success) {
        widget.onAddProduct(updatedProduct);
          ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product updated successfully!'), backgroundColor: Colors.green),
    );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update product'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF028090),
        title: Text(
          'Edit Product',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
              TextFieldComponent(
                label: 'Batch No',
                controller: _batchnoNameController,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a Batch No'
                    : null,
              ),
              NumberComponent(
                label: 'Quantity',
                controller: _qtyController,
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
                selectedValue:
                    _selectedCategory, // Ensure the selected category is updated correctly
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = categorylist
                        .firstWhere(
                            (cat) => cat["category_name"] == value)['id']
                        .toString();
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
                controller: _mfdController,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please select an MFD date';
                //   }
                //   final regex = RegExp(r'^\d{2}\/\d{2}\/\d{2}$');
                //   if (!regex.hasMatch(value)) {
                //     return 'Invalid MFD date format';
                //   }
                //   return null;
                // },
                validator: (value) {},
                label: 'MFD Date',
              ),
              DateFieldComponent(
                controller: _expiryDateController,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please select an expiry date';
                //   }
                //   final regex = RegExp(r'^\d{2}\/\d{2}\/\d{2}$');
                //   if (!regex.hasMatch(value)) {
                //     return 'Invalid expiry date format';
                //   }
                //   return null;
                // },
                validator: (value) {},
                label: 'Expiry Date',
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
                        .firstWhere((supplier) =>
                            supplier['company_name'] == value)['supplier_id']
                        .toString();
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),

              SizedBox(height: 16),
              GSTDropdownField(
                label: 'GST Number',
                items: ['0.00%', '5.00%', '12.00%', '18.00%', '28.00%'],
                selectedValue: _selectedGST, // Now matches dropdown format
                onChanged: (value) {
                  setState(() {
                    _selectedGST = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a GST value' : null,
              ),

              SizedBox(
                height: 16,
              ),
              //     Text('Availability Status',style: TextStyle(fontSize: 18,
              // fontWeight: FontWeight.bold,),),
              // SizedBox(
              //   height: 10,
              // ),
              DropdownComponent(
                label: 'Availability Status',
                items: ['Available', 'Unavailable'],
                selectedValue: _availabilityStatusController
                    .text, // Bind to the controller's text
                onChanged: (value) {
                  setState(() {
                    _availabilityStatusController.text = value!;
                  });
                },
                validator: (value) => value == null
                    ? 'Please select an availability status'
                    : null,
              ),

              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF028090),
                ),
                child: Text('Update', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
