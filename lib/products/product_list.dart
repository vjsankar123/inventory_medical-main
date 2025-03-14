import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/network_file/network_listener.dart';
import 'package:flutter_application_1/products/MedicineForm.dart';
import 'package:flutter_application_1/products/medicine_edit.dart';
import 'package:flutter_application_1/products/view_product.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_application_1/staff/staff_dashboard.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:ui';
import 'package:confetti/confetti.dart';
void main() {
  runApp(MaterialApp(
    home: ProductList(),
  ));
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

final ApiService apiService = ApiService();

class _ProductListState extends State<ProductList>
    with SingleTickerProviderStateMixin {
       final NetworkListener _networkListener = NetworkListener();
  final ApiService apiService = ApiService();

  List<Map<String, dynamic>> products = [];
  late List<Map<String, dynamic>> productList = [];
     List<String> _productSuggestions = [];
  List<Map<String, dynamic>> filteredData = [];
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
final int _limit = 10; // Items per page
bool _isPaginating = false;
bool _hasMoreProducts = true; // For checking end of the list
 late ConfettiController _confettiController;
  bool _hasConfettiFired = false;


  String formatExpiryDate(String? date) {
    if (date == null || date.isEmpty) return 'N/A';

    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy')
          .format(parsedDate); // Format to "day-month-year"
    } catch (e) {
      print("Error parsing expiry date: $e");
      return date; // Return original string if parsing fails
    }
  }

  // void _bulkInsert() {
  //   setState(() {
  //     products.addAll(List.generate(
  //         5,
  //         (index) => {
  //               'sno': (products.length + 1).toString(),
  //               'name': 'Bulk Name ${products.length + 1}',
  //               'brand': 'Bulk Brand ${products.length + 1}',
  //               'category': 'Bulk Category ${products.length + 1}',
  //               'expiryDate':
  //                   '2025-02-${(index + 1).toString().padLeft(2, '0')}',
  //               'qty': '${(index + 1) * 10}',
  //             }));
  //   });
  // }
Future<void> _uploadFile() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      String? filePath = result.files.single.path;
      String fileName = result.files.single.name;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading $fileName...')),
      );

      final response = await apiService.uploadProductFile(filePath!);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Products imported successfully!')),
        );
        _fetchProducts(); // Refresh product list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response['message']}')),
        );
      }
    } else {
      print('No file selected');
    }
  } catch (e) {
    print('File upload error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error uploading file: $e')),
    );
  }
}

  void _addProduct(Map<String, String> product) {
    setState(() {
      products.add(product);
    });
  }

  void _editProduct(Map<String, dynamic> product) async {
    try {
      final fetchedProduct = await apiService.ViewProducts(product['id']);

      if (fetchedProduct != null) {
        fetchedProduct.forEach((key, value) {
          if (value is int) {
            fetchedProduct[key] = value.toString();
          }
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Medicineedit(
              product: fetchedProduct,
              onAddProduct: (updatedProduct) {
                setState(() {
                  int index =
                      products.indexWhere((p) => p['id'] == product['id']);
                  if (index != -1) {
                    products[index] = updatedProduct;
                  }
                });
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch product details')),
        );
      }
    } catch (e) {
      print('Error fetching product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching product details')),
      );
    }
  }
//  @override
//   void initState() {
//     super.initState();
//    // Start listening for network changes
//   }

  // @override
  // void dispose() {
  // // Stop listening when the widget is disposed
  //   super.dispose();
  // }

  void initState() {
    super.initState();
    _fetchProducts();
      _confettiController = ConfettiController(duration: Duration(seconds: 3));
     _networkListener.startListening(context); 
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }








  Future<void> _fetchProducts() async {
    if (_isPaginating || !_hasMoreProducts) return; // Avoid duplicate calls
  setState(() => _isPaginating = true);
    try {
      List<Map<String, dynamic>> fetchedProducts =
          await apiService.fetchProducts(page: _currentPage, limit: _limit);
      setState(() {
        products = fetchedProducts;
        _isLoading = false;
         products.addAll(fetchedProducts);
      _isPaginating = false;
      _hasMoreProducts = fetchedProducts.length == _limit; // Check if more data exists
      _currentPage++; // Next page
      });
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }




  Future<void> _fetchedProducts() async {
    try {
      final fetchedProducts = await apiService.stockProducts(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      );

      setState(() {
        products = fetchedProducts;
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
  }
Future<void> _fetchProductSuggestions(String query) async {
  if (query.isEmpty) {
    setState(() => _productSuggestions = []);
    return;
  }

  try {
    final fetchedProducts = await apiService.stockProducts(search: query);
    setState(() {
      _productSuggestions = fetchedProducts.isEmpty
          ? ['No products found']
          : fetchedProducts
              .map<String>((product) => product['product_name'].toString())
              .toList();
    });
  } catch (e) {
    print("Error fetching suggestions: $e");
  }
}

  void _deleteProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final productId = product['id'].toString(); // Get supplier ID
                try {
                  await apiService.deleteProductsFromApi(productId, () {
                    setState(() {
                      productList
                          .removeWhere((item) => item['id'] == productId);
                      filteredData = List.from(productList);
                    });
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete supplier: $e')),
                  );
                }
                // _fetchProducts();
                // Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _viewProduct(Map<String, dynamic> product) {
    // Extract productId from the product map
    String productId =
        product['id']; // Assuming the product map contains the field 'id'

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(
          product: product,
          productId: productId, // Pass the actual productId
        ),
      ),
    );
  }
@override
void dispose() {
  _controller.dispose();
 
  super.dispose();
}

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => StaffDashboard(),
        ));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: _isSearching
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _fetchProductSuggestions,
                    onSubmitted: (_) => _fetchedProducts(),
                    autofocus: true,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 15.0),
                    ),
                    cursorColor: Color(0xFF028090),
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Product List', // Adjusted title for flexibility
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold, // Bold text for better visibility
                    ),
                  ),
                ),
          actions: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Colors.black,
              ),
                onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchController.clear();
                  _fetchedProducts();
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton.icon(
                onPressed: _uploadFile,
                icon: Icon(Icons.add_box, color: Colors.green),
                label: Text('Bulk Insert'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF028090),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                        child: NotificationListener<ScrollNotification>(
                             onNotification: (ScrollNotification scrollInfo) {
            if (!_isPaginating &&
                scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              _fetchProducts(); // Load next page
            }
            return true;
          },
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border(
                          top: BorderSide(color: Colors.black, width: 2.0),
                          left: BorderSide(color: Colors.black, width: 2.0),
                          right: BorderSide(color: Colors.black, width: 2.0),
                          bottom: BorderSide(color: Colors.black, width: 5.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${product['product_name'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Brand: ${product['brand_name'] ?? 'N/A'}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            Text(
                              'Category: ${product['product_category'] ?? 'N/A'}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            Text(
                              'Expiry Date: ${formatExpiryDate(product['expiry_date'])}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            Text(
                              'Quantity: ${product['product_quantity'] ?? '0'}',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            SizedBox(height: 10),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  icon: Icon(
                                    Icons.visibility,
                                    size: 24.0,
                                    color: Color(0xFF028090),
                                  ),
                                  label: Text(
                                    'View',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onPressed: () => _viewProduct(
                                      product), // Pass the entire product data
                                ),
                                TextButton.icon(
                                  icon: Icon(
                                    Icons.edit_note,
                                    color: Colors.orange,
                                    size: 24.0,
                                  ),
                                  label: Text('Edit',
                                      style: TextStyle(color: Colors.black)),
                                  onPressed: () => _editProduct(product),
                                ),
                                TextButton.icon(
                                  icon: Icon(Icons.delete_sweep,
                                      color: Colors.red, size: 24.0),
                                  label: Text('Delete',
                                      style: TextStyle(color: Colors.black)),
                                  onPressed: () => _deleteProduct(product),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        floatingActionButton: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicineForm(
                        onAddProduct: (newProduct) {
                          _fetchProducts();
                        },
                        product: {},
                      ),
                    ),
                  );
                },
                child: Icon(Icons.add, color: Colors.white, size: 30.0),
                backgroundColor: Color.fromRGBO(2, 116, 131, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}
