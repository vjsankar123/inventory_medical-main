import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';


class ProductDetailsPage extends StatefulWidget {
  final String productId; // Accept productId to fetch the product details
ProductDetailsPage({required this.productId, required Map<String, dynamic> product});


  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Map<String, dynamic>? product;
  bool isLoading = true;
  bool isError = false;
  final ApiService apiService = ApiService();


String formatDate(String? date) {
  if (date == null || date.isEmpty) return 'N/A'; // Handle null or empty dates
  try {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  } catch (e) {
    return 'Invalid Date'; // Handle parsing errors
  }
}

  @override
  void initState() {
    super.initState();
    fetchProductDetails(); // Fetch the product details when the page is initialized
  }

  // Function to fetch product details from the backend API
  Future<void> fetchProductDetails() async {
    try {
      // Use the apiService.ViewProducts method to fetch product data
     final fetchedProduct = await apiService.ViewProducts(widget.productId);


      if (fetchedProduct != null) {
        setState(() {
         product = fetchedProduct;
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
      print('Error fetching product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
        centerTitle: true,
        backgroundColor: Color(0xFF028090),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : isError
              ? Center(child: Text('Error fetching product details')) // Show error message
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 5,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Name', product!['product_name']),
                              _buildDetailRow('Brand Name', product!['brand_name']),
                              _buildDetailRow('Category', product!['product_category']),
                              _buildDetailRow('Generic Name', product!['generic_name']),
                              _buildDetailRow('Batch No', product!['product_batch_no']),
                              _buildDetailRow('MRP Price', product!['product_price']),
                              _buildDetailRow('Supplier Price', product!['supplier_price']),
                              _buildDetailRow('Description', product!['product_description']),
                              _buildDetailRow('Discount Percentage', product!['product_discount']),
                              _buildDetailRow('Selling Price', product!['selling_price']),
                              _buildDetailRow('Supplier Name', product!['supplier_name']),
                              _buildDetailRow('Mfg Date', formatDate(product!['MFD'])),
                             _buildDetailRow('Expiry Date', formatDate(product!['expiry_date'])),
                              _buildDetailRow('GST %', product!['GST']),
                              _buildDetailRow('Availability Status', product!['stock_status']),
                              _buildDetailRow('Quantity', product!['product_quantity']),
                              SizedBox(height: 20),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the page
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF028090),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

 Widget _buildDetailRow(String title, dynamic value) {
  // Ensure the value is treated as a string (convert integers to strings)
  String displayValue = value != null ? value.toString() : 'N/A';

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            displayValue,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    ),
  );
}

}
