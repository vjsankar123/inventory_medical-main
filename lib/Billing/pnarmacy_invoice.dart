import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/dashboard/persistent_bottom_nav_bar.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:printing/printing.dart';

class PharmacyInvoiceScreen extends StatefulWidget {
  @override
  _PharmacyInvoiceScreenState createState() => _PharmacyInvoiceScreenState();
}

class _PharmacyInvoiceScreenState extends State<PharmacyInvoiceScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  ApiService apiService = ApiService();
  List<Map<String, dynamic>> _billingItems = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _filteredBillingItems = [];
  Timer? _debounce;
  bool _isPaid = false; // Add this inside your widget

  String _selectedPaymentMethod = 'Cash';

  final List<Map<String, dynamic>> billingList = [];

  @override
  void initState() {
    super.initState();
    _filteredBillingItems = List.from(_billingItems);
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return DateFormat('dd-MM-yyyy hh:mm a').format(now);
  }

  String formatExpiryDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date; // Return original if parsing fails
    }
  }

  void _addBillingItem(Map<String, dynamic> product) {
    setState(() {
      final expiryDate = product['expiryDate'];
      String formattedExpiryDate = 'N/A';

      if (expiryDate != null && expiryDate.isNotEmpty) {
        try {
          final parsedDate = DateTime.parse(expiryDate);
          formattedExpiryDate = DateFormat('dd-MM-yyyy').format(parsedDate);
        } catch (e) {
          print('Error parsing date: $e');
        }
      }

      final newItem = {
        'productId': product['id'] ?? product['productId'],
        'productName': product['name'],
        'batchNo': product['batchNo'] ?? 'N/A',
        'expiryDate': formattedExpiryDate, // ✅ Formatted date here
        'mrp': product['mrp'] ?? 0.0,
        'gst': product['gst'] ?? 0.0,
        'sellingPrice': product['sellingPrice'] ?? 0.0,
        'qty': 1,
        'amount': product['sellingPrice'] ?? 0.0,
      };

      print("✅ Added Item: $newItem");

      _billingItems.add(newItem);
      _filteredBillingItems = List.from(_billingItems);
      _searchResults.clear();
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _customerNameController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }void _updateAmount(int index, double qty) {
  setState(() {
    final item = _billingItems[index];
    final mrp = (item['sellingPrice'] ?? 0.0) as double; // Default to 0.0
    final gstPercentage = (item['gst'] ?? 0.0) as double; // Default to 0.0

    // Calculate selling price including GST
    final priceWithGST = qty * (mrp * (1 + gstPercentage / 100));

    // Update quantity and amount
    _billingItems[index]['qty'] = qty;
    _billingItems[index]['amount'] = priceWithGST;

    // Update filtered list
    _filteredBillingItems = List.from(_billingItems);
  });
}


  void _removeBillingItem(int index) {
    setState(() {
      _billingItems.removeAt(index);
      _filteredBillingItems = List.from(_billingItems);
    });
  }

  void _filterBillingItems(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        setState(() {
          _searchResults.clear();
        });
        return;
      }

      final results = await apiService.searchProducts(query);
      print("Search Results: $results"); // Debugging output

      setState(() {
        _searchResults = results;
      });
    });
  }
Future<void> submitInvoice() async {
  _isPaid = true; // Ensure Paid is always set

  final payload = {
    "customer_name": _customerNameController.text.trim(),
    "phone": _phoneNumberController.text.trim(),
    "payment_status": "Paid", // Always "Paid"
    "payment_method": _selectedPaymentMethod,
    "products": _billingItems.map((item) {
      return {
        "product_id": item["productId"],
        "quantity": item["qty"],
      };
    }).toList(),
  };

  print("Submitting invoice payload: $payload");

  final response = await apiService.createBill(payload);

  if (response != null &&
      response["invoice_details"] != null &&
      response["invoice_details"]["invoice_id"] != null) {
    String invoiceId = response["invoice_details"]["invoice_id"].toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invoice created successfully!')),
    );

    // Print invoice immediately
    _handlePrint(context, invoiceId);

    // Clear form
    _customerNameController.clear();
    _phoneNumberController.clear();
    _billingItems.clear();
    _selectedPaymentMethod = 'Cash'; // Reset payment method

    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create invoice.')),
    );
  }
}


void _handlePrint(BuildContext context, String? invoiceId) async {
  print('Printing invoice with ID: $invoiceId');
  if (invoiceId == null || invoiceId.isEmpty) {
    _showSnackBar(context, 'Error: Invoice ID is empty');
    return;
  }

  try {
    final pdfFile = await apiService.fetchInvoicePrints(invoiceId);
    if (pdfFile != null) {
      await Printing.sharePdf(bytes: await pdfFile.readAsBytes(), filename: 'invoice.pdf');
    } else {
      _showSnackBar(context, 'Failed to fetch invoice. Invalid ID.');
    }
  } catch (e) {
    print('Error: $e');
    _showSnackBar(context, 'Error: $e');
  }
}

  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
 

  void _showPreviewBottomSheet() {
    // String _selectedPaymentMethod = 'Cash';
    bool _isPaid = false;

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice Preview',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text('Customer Name: ${_customerNameController.text}'),
                        SizedBox(height: 5),
                        Text('Phone Number: ${_phoneNumberController.text}'),
                        SizedBox(height: 5),
                        Text('Date and Time: ${_getCurrentDateTime()}'),
                        SizedBox(height: 20),

                        if (_billingItems.isNotEmpty)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DataTable(
                                border: TableBorder.all(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                                columns: const [
                                  DataColumn(
                                      label: Text('Product Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18))),
                                  DataColumn(
                                      label: Text('Batch No',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18))),
                                  DataColumn(
                                      label: Text('Expiry Date',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18))),
                                  DataColumn(
                                      label: Text('MRP',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18))),
                                  DataColumn(
                                      label: Text('GST',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18))),
                                  DataColumn(
                                      label: Text('Selling Price',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18))),
                                  DataColumn(
                                      label: Text('Qty',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18))),
                                  DataColumn(
                                      label: Text('Amount',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18))),
                                ],
                                rows: _filteredBillingItems.map((item) {
                                  return DataRow(cells: [
                                    DataCell(
                                        Text(item['productName'] ?? 'N/A')),
                                    DataCell(Text(item['batchNo'] ?? 'N/A')),
                                    DataCell(Text(item['expiryDate'] ?? 'N/A')),
                                    DataCell(Text((item['mrp'] ?? 0.0)
                                        .toStringAsFixed(
                                            2))), // Ensure not null
                                    DataCell(Text((item['gst'] ?? 0.0)
                                        .toStringAsFixed(
                                            2))), // Ensure not null
                                    DataCell(Text((item['sellingPrice'] ?? 0.0)
                                        .toStringAsFixed(
                                            2))), // Fixed key and null check
                                    DataCell(
                                        Text((item['qty'] ?? 0).toString())),
                                    DataCell(Text((item['amount'] ?? 0.0)
                                        .toStringAsFixed(
                                            2))), // Ensure not null
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        SizedBox(height: 20),

                        // Payment Method Dropdown
                        // Payment Method Dropdown
                        Row(
                          children: [
                            Text("Payment Method: ",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            DropdownButton<String>(
                              value: _selectedPaymentMethod,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedPaymentMethod =
                                        value; // ✅ Updates main state
                                  });
                                }
                              },
                              items: ['Cash', 'UPI'].map((method) {
                                return DropdownMenuItem<String>(
                                  value: method,
                                  child: Text(method),
                                );
                              }).toList(),
                              dropdownColor: Colors.white,
                            ),
                          ],
                        ),

                        SizedBox(height: 5),

                        // Paid Radio Button (Toggle Between True and False)

                        Row(
                          children: [
                            Text("Status: ",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            Radio<bool>(
                              value: true, // Always "Paid"
                              groupValue: _isPaid,
                              onChanged: (value) {
                                setState(() {
                                  _isPaid = true; // Always sets to "Paid"
                                });
                              },
                              activeColor: Colors.green,
                            ),
                            Text("Paid"),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 24.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                textStyle: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              child: Text('Edit'),
                            ),
                            ElevatedButton(
                              onPressed: submitInvoice,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color.fromRGBO(2, 116, 131, 1),
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 24.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Submit Invoice'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => PersistentBottomNavBar(),
        ));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Pharmacy Invoice',
            style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Time with Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _getCurrentDateTime(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Phone Number Field
                Text('Phone Number',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                TextField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(2, 116, 131, 1), width: 2.0),
                    ),
                  ),
                  cursorColor: Color.fromRGBO(2, 116, 131, 1),
                ),
                const SizedBox(height: 16),

                // Customer Name Field
                Text('Customer Name',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                TextField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    hintText: 'Customer Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(2, 116, 131, 1), width: 2.0),
                    ),
                  ),
                  cursorColor: Color.fromRGBO(2, 116, 131, 1),
                ),
                const SizedBox(height: 16),

                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Add Product',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(2, 116, 131, 1), width: 2.0),
                    ),
                  ),
                  cursorColor: Color.fromRGBO(2, 116, 131, 1),
                  onChanged: _filterBillingItems, // Calls API on text change
                ),

                const SizedBox(height: 10),
                Container(
                  height: _searchResults.isNotEmpty ? 150 : 0,
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final product = _searchResults[index];
                      return ListTile(
                        title: Text(product['name']),
                        subtitle: Text(
                          'Expiry: ${formatExpiryDate(product['expiryDate'])}',
                          style: TextStyle(
                              color: Colors.red), // Expiry date in red
                        ),
                        trailing: Text('Quantity :${product['quantity']}'),
                        onTap: () => _addBillingItem(product),
                      );
                    },
                  ),
                ),

                // Billing Table
                if (_filteredBillingItems.isNotEmpty)
                  SizedBox(
                    height: 200, // Limit height to prevent infinite expansion
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        // decoration: BoxDecoration(
                        //   border: Border.all(color: Colors.black, width: 1.0),
                        //   borderRadius: BorderRadius.circular(12),
                        // ),
                        child: SingleChildScrollView(
                          scrollDirection:
                              Axis.vertical, // Enable vertical scrolling
                          child: DataTable(
                            border: TableBorder.all(
                              color: Colors.black,
                              width: 1.0,
                            ),
                            columns: const [
                              DataColumn(
                                  label: Text('Product Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18))),
                              DataColumn(
                                  label: Text('Batch No',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18))),
                              DataColumn(
                                  label: Text('Expiry Date',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18))),
                              DataColumn(
                                  label: Text('MRP',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18))),
                              DataColumn(
                                  label: Text('GST',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18))),
                              DataColumn(
                                  label: Text('Qty',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18))),
                              DataColumn(
                                  label: Text('Amount',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18))),
                              DataColumn(
                                  label: Text('Action',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18))),
                            ],
                            rows: _filteredBillingItems
                                .asMap()
                                .entries
                                .map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return DataRow(cells: [
                                DataCell(Text(item['productName'])),
                                DataCell(Text(item['batchNo'])),
                                DataCell(
                                    Text(formatExpiryDate(item['expiryDate']))),
                                DataCell(Text(
                                    (item['mrp'] as num).toStringAsFixed(2))),
                                DataCell(Text(item['gst'].toStringAsFixed(2))),
                                DataCell(TextFormField(
                                  initialValue: item['qty'].toString(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    _updateAmount(
                                        index, double.tryParse(value) ?? 0);
                                  },
                                  cursorColor: Color.fromRGBO(2, 116, 131, 1),
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                )),
                                DataCell(
                                    Text(item['amount'].toStringAsFixed(2))),
                                DataCell(
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _removeBillingItem(index);
                                    },
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 10),
                // Preview Button
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed:
                        _showPreviewBottomSheet, // Your existing preview logic
                    child:
                        Text('Preview', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(2, 116, 131, 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
