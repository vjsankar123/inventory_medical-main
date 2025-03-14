import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/bottom_items/staff_page.dart';
import 'package:flutter_application_1/dashboard/persistent_bottom_nav_bar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deleted Products Table',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BinPage(),
    );
  }
}

class BinPage extends StatefulWidget {
  @override
  _BinPageState createState() => _BinPageState();
}

class _BinPageState extends State<BinPage> {
  // Sample list of deleted products
  int _currentPage = 1;
  int _limit = 10;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  int _totalPages = 1;
  List<Map<String, String>> deletedProducts = [];
  ApiService apiService = ApiService();

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
    } catch (e) {
      print('Error formatting date: $e');
      return date;
    }
  }

  void initState() {
    super.initState();
    fetchAndDisplayDeleted();
  }

  Future<void> fetchAndDisplayDeleted({bool isLoadMore = false}) async {
    if (_isFetchingMore || !_hasMore) return;

    setState(() => _isFetchingMore = true);

    try {
      final fetchedProducts = await apiService.fetchedDeletedProduct(
          page: _currentPage, limit: _limit);

      setState(() {
        if (isLoadMore) {
          deletedProducts.addAll(fetchedProducts);
        } else {
          deletedProducts = fetchedProducts;
        }

        _isFetchingMore = false;
        _hasMore = _currentPage < _totalPages;
      });
    } catch (e) {
      print('Error fetching deleted products: $e');
      setState(() => _isFetchingMore = false);
    }
  }

  void _loadMore() {
    if (_hasMore && !_isFetchingMore) {
      _currentPage++;
      fetchAndDisplayDeleted(isLoadMore: true);
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


 Future<void> restoreProduct(int index) async {
  final productId = deletedProducts[index]['id'];
  print('Restoring product with ID: $productId');

  if (productId == null) {
    _showSnackBar('Invalid product ID.', isSuccess: false);
    return;
  }

  try {
    bool isRestored = await apiService.restoreDeletedProduct(productId);
    if (isRestored) {
      setState(() {
        deletedProducts.removeAt(index);
      });

      _showSnackBar('Product restored successfully.', isSuccess: true);

      fetchAndDisplayDeleted(); // Refresh deleted products list
    } else {
      _showSnackBar('Failed to restore product.', isSuccess: false);
    }
  } catch (e) {
    print('Error restoring product: $e');
    _showSnackBar('Error restoring product.', isSuccess: false);
  }
}

void deleteProduct(int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Confirm Permanent Deletion'),
        content: Text('Are you sure you want to permanently delete this product?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog

              final productId = deletedProducts[index]['id'];
              if (productId == null) {
                _showSnackBar('Invalid product ID.', isSuccess: false);
                return;
              }

              try {
                bool isDeleted = await apiService.permanentlyDeleteProduct(productId);
                if (isDeleted) {
                  setState(() {
                    deletedProducts.removeAt(index); // Remove from UI
                  });
                  _showSnackBar('Product permanently deleted.', isSuccess: true);
                } else {
                  _showSnackBar('Failed to delete product.', isSuccess: false);
                }
              } catch (e) {
                print('Error: $e');
                _showSnackBar('Error deleting product.', isSuccess: false);
              }
            },
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
            title: Text(
              'Deleted Products',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Color(0xFF028090),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => PersistentBottomNavBar(),
                ));
              },
            ),
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      border: TableBorder.all(
                        color: Colors.black, // Table cell borders
                        width: 1.0,
                      ),
                      columns: const <DataColumn>[
                        DataColumn(
                            label: Text('S.No',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))),
                        DataColumn(
                          label: Text(
                            'Product ID',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Medicine Name',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Supplier Name',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Category Name',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Brand Name',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Created Date',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Deleted Date',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Actions',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ],
                      rows: deletedProducts.asMap().entries.map((entry) {
                        int index = entry.key;
                        var product = entry.value;

                        return DataRow(cells: [
                        DataCell(Text('${(_currentPage - 1) * _limit + index + 1}')),
                        DataCell(Text(product['id'] ?? '')),
                        DataCell(Text(product['product_name'] ?? '')),
                        DataCell(Text(product['supplier_name'] ?? '')),
                        DataCell(Text(product['product_category'] ?? '')),
                        DataCell(Text(product['brand_name'] ?? '')),
                        DataCell(Text(_formatDate(product['created_at']))),
                        DataCell(Text(_formatDate(product['deleted_at']))),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.restore, color: Colors.blue),
                              onPressed: () => restoreProduct(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteProduct(index),
                            ),
                          ],
                        )),
                      ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
               Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: _currentPage > 1 ? Colors.blue : Colors.grey),
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                            deletedProducts
                                .clear(); // Clear old data to avoid duplicates
                          });
                          fetchAndDisplayDeleted();
                        }
                      : null,
                ),
                Text("Page $_currentPage",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.arrow_forward,
                      color: _hasMore ? Colors.blue : Colors.grey),
                  onPressed: _hasMore
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                          fetchAndDisplayDeleted(isLoadMore: false);
                        }
                      : null,
                ),
              ],
            )
            ]),
          ),
        ));
  }
}
