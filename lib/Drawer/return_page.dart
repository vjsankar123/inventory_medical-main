import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/bottom_items/staff_page.dart';
import 'package:flutter_application_1/dashboard/persistent_bottom_nav_bar.dart';

void main() {
  runApp(MaterialApp(
    home: ReturnPage(),
  ));
}

class ReturnPage extends StatefulWidget {
  @override
  _ReturnPageState createState() => _ReturnPageState();
}

final ApiService apiService = ApiService();

class _ReturnPageState extends State<ReturnPage> {
  // Data for the return table
   List<Map<String, dynamic>> returnData = [];
  final List<Map<String, dynamic>> returnDataList = [];

  List<Map<String, dynamic>> productList = [];
  String? selectedProductId;

  // Controllers for adding new return data
  final TextEditingController invoiceIdController = TextEditingController();
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController searchProductController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _productFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
 int _currentPage = 1;
  bool _isFetchingMore = false;
  final int _limit = 10; // Number of items per page
  bool _hasMore = true; // Track if there are more pages

  bool _isSearching = false;
  bool isScrolled = false;
  bool _isLoading = true;



 Future<void> fetchAllReturns({bool isLoadMore = false}) async {
     if (_isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    try {
      final returns = await apiService.fetchReturns(page: _currentPage, limit: _limit);
      setState(() {
        if (isLoadMore) {
          returnData.addAll(returns);
        } else {
          returnData = returns;
        }

        _isFetchingMore = false;
        _hasMore =
            _currentPage < apiService.totalPages; // Ensure this is updated
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

Future<void> fetchProductsByInvoice(String invoiceId) async {
  try {
    final response = await apiService.getProductsByInvoice(invoiceId);

    if (response.isNotEmpty) {
      setState(() {
        productList = response['products'];
        invoiceIdController.text = response['invoice_id']; // ✅ Update invoice_id
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No products found for this invoice')));
    }
  } catch (e) {
    print('Error fetching products: $e');
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Failed to fetch products')));
  }
}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (invoiceIdController.text.isNotEmpty) {
        fetchProductsByInvoice(invoiceIdController.text.trim());
      }
    });
     fetchAllReturns();

      _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_hasMore && !_isFetchingMore) {
          setState(() {
            _currentPage++;
          });
          fetchAllReturns(isLoadMore: true);
        }
      }
    });
  }

 void openProductSearchForm() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String? localSelectedProductId = selectedProductId;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          // Ensure unique product list
          final uniqueProducts = {
            for (var product in productList) product['product_id']: product
          }.values.toList();

          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Search Product'),
            content: SingleChildScrollView(
              child: Form(
                key: _productFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: localSelectedProductId,
                      hint: Text('Select Product'),
                      items: uniqueProducts.map((product) {
                        return DropdownMenuItem<String>(
                          value: product['product_id'].toString(),
                          child: Text(product['product_name'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          localSelectedProductId = value;
                        });

                        if (value != null) {
                          final selected = uniqueProducts.firstWhere(
                              (product) =>
                                  product['product_id'].toString() == value);

                          setState(() {
                            selectedProductId = value;
                          });

                          // Populate the controllers
                          productIdController.text =
                              selected['product_id'].toString();
                          productNameController.text =
                              selected['product_name'];
                          quantityController.text =
                              selected['quantity'].toString();
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a product';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      dropdownColor: Colors.white,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Return Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a return description';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (_productFormKey.currentState!.validate()) {
                    Navigator.pop(context);
                    submitReturn();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF028090),
                ),
                child: Text('Return', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    },
  );
}

void submitReturn() async {
  if (selectedProductId == null ||
      quantityController.text.isEmpty ||
      reasonController.text.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Please fill all fields')));
    return;
  }

  final newReturn = {
    "invoice_id": invoiceIdController.text.trim(),
    "returnedProducts": [
      {
        "product_id": int.parse(productIdController.text.trim()),
        "quantity": int.parse(quantityController.text.trim()),
        "return_reason": reasonController.text.trim(),
      }
    ]
  };

  bool isSuccess = await apiService.createReturn(newReturn);

  if (isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Return successfully processed')));

    // Add the new return data to the table immediately
    setState(() {
      returnData.insert(0, {
        'invoice_id': invoiceIdController.text.trim(),
        'product_name': productNameController.text,
        'quantity': int.parse(quantityController.text.trim()),
        'return_reason': reasonController.text.trim(),
      });
    });

    clearFields();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process return. Try again.')));
  }
}

void clearFields() {
  invoiceIdController.clear();
  productIdController.clear();
  productNameController.clear();
  quantityController.clear();
  reasonController.clear();
  selectedProductId = null;
  setState(() {});
}


  void addNewReturn() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Return'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: invoiceIdController,
              decoration: InputDecoration(labelText: 'Invoice ID'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Enter Invoice ID' : null,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // 🟢 Trigger product fetch (Like useEffect dependency in React)
                  await fetchProductsByInvoice(invoiceIdController.text.trim());

                  // 🟢 Open product search form after data is fetched
                  Navigator.pop(context);
                  openProductSearchForm();
                }
              },
              child: Text('Get Product'),
            ),
          ],
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
            title: Text('Return Page',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            backgroundColor: Color(0xFF028090),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => PersistentBottomNavBar()),
                );
              },
            ),
            actions: [],
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Button at the top-left
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: addNewReturn,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF028090),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          elevation: 10),
                      child: Text('Add New Return',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
                SizedBox(height: 16), // Space between the button and table

                // Scrollable Table inside a bordered box
                 Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 20,
                            headingRowHeight: 56,
                            dataRowHeight: 56,
                            border: TableBorder.all(color: Colors.black,width: 1),
                            columns: [
                              DataColumn(
                                  label: Text('S.No',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Invoice No',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Product Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Quantity',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Reason For Return',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),

                            ],
                            rows: returnData.map((returnItem) {
                              int index = returnData.indexOf(returnItem);
                              return DataRow(
                                cells: [
                                 DataCell(Text('${(_currentPage - 1) * _limit + index + 1}')),  // Cor
                                  DataCell(
                                     Text(returnItem['invoice_id'] ?? ''),),
                                 DataCell(Text(returnItem['product_name'] ?? ''),),

                                  DataCell(Text(returnItem['quantity']?.toString() ?? ''),
),
                                  DataCell(
                                      Text(returnItem['return_reason'] ?? ''),),
                                 
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: _currentPage > 1 ? Colors.blue : Colors.grey),
                      onPressed: _currentPage > 1 && !_isLoading
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                              fetchAllReturns();
                            }
                          : null,
                    ),
                    Text("Page $_currentPage",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.arrow_forward,
                          color: _hasMore ? Colors.blue : Colors.grey),
                      onPressed: _hasMore && !_isLoading
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                              fetchAllReturns();
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
