import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/Drawer/edit_supplier.dart';
import 'package:flutter_application_1/Drawer/supplier_invoice.dart';
import 'package:flutter_application_1/bottom_items/staff_page.dart';
import 'package:flutter_application_1/dashboard/persistent_bottom_nav_bar.dart';
import 'supplier_form.dart';

// import 'edit_supplier_form.dart'; // Add this line to import the EditSupplierForm

class SupplierPage extends StatefulWidget {
  @override
  _SupplierPageState createState() => _SupplierPageState();
}

final ApiService apiService = ApiService();

class _SupplierPageState extends State<SupplierPage> {
  List<Map<String, dynamic>> supplierList = [];

  List<Map<String, dynamic>> filteredData = [];
  bool isSearching = false;
  bool _isLoading = true;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  final int _pageSize = 10;

  // TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool isScrolled = false;

  Future<void> fetchAndDisplaysupplier({int page = 1, int limit = 10}) async {
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
      final fetchedSuppliers =
          await apiService.fetchsupplier(page: page, limit: limit);
      setState(() {
        if (page == 1) {
          supplierList = fetchedSuppliers; // First page, replace list
          print('cvbn:$supplierList');
        } else {
          supplierList.addAll(fetchedSuppliers); // Append more data
        }
        filteredData = supplierList;
        _isLoading = false;
        _isFetchingMore = false; // Reset loading state
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

  // To track whether the header needs a shadow

  @override
  void initState() {
    super.initState();
    fetchAndDisplaysupplier();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreData();
      }
    });
  }

  //   @override
  // void initState() {
  //   super.initState();
  //   fetchAndDisplaysupplier();
  //   _scrollController.addListener(() {
  //     setState(() {
  //       isScrolled = _scrollController.offset > 10; // Adjust threshold as needed
  //     });
  //   });
  // }

  void _loadMoreData() {
    if (_isFetchingMore) return; // Prevent multiple calls

    setState(() {
      _isFetchingMore = true;
    });

    _currentPage++;
    fetchAndDisplaysupplier(page: _currentPage, limit: _pageSize);
  }

  void searchSuppliers(String query) {
    final results = supplierList.where((item) {
      final name = item['company_name']?.toLowerCase() ?? '';
      final phone = item['phone_number']?.toLowerCase() ?? '';
      final email = item['email']?.toLowerCase() ?? '';
      final input = query.toLowerCase();
      return name.contains(input) ||
          phone.contains(input) ||
          email.contains(input);
    }).toList();

    setState(() {
      filteredData = results;
    });
  }

  void addNewSupplier() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true, // Ensures it takes full height when needed
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7, // Adjust as needed
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SupplierForm(
                onAddSupplier: (newSupplier) {
                  setState(() {
                    supplierList.add(newSupplier);
                    filteredData = supplierList;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  void editSupplier(Map<String, dynamic> supplier) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return EditSupplierForm(
          supplierData: Map<String, dynamic>.from(supplier), // Ensure full data
          onSave: (editedSupplier) {
            setState(() {
              int index = supplierList.indexOf(supplier);
              if (index != -1) {
                supplierList[index] = editedSupplier;
                filteredData = supplierList;
              }
            });
          },
        );
      },
    );
  }

  void deleteSupplier(Map<String, dynamic> supplier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this supplier?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without deleting
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog before API call

                final supplierId =
                    supplier['supplier_id'].toString(); // Get supplier ID
                try {
                  await apiService.deleteSupplierFromApi(supplierId, () {
                    setState(() {
                      supplierList.removeWhere(
                          (item) => item['supplier_id'] == supplierId);
                      filteredData = List.from(supplierList);
                    });
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete supplier: $e')),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void viewSupplierDetails(Map<String, String> supplier, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SupplierInvoiceList(supplierId: supplier['supplier_id'] ?? ''),
      ),
    );
  }

  Widget _buildDetailText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to the PersistentBottomNavBar with the Home tab selected
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => PersistentBottomNavBar(),
        ));
        return false; // Prevent the default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Supplier List',
            style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFF028090),
           centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => PersistentBottomNavBar()),
            );
          },
        ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              // child: TextField(
              //   decoration: InputDecoration(
              //     hintText: 'Search suppliers...',
              //     prefixIcon: const Icon(Icons.search),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(20.0),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(20.0),
              //       borderSide: BorderSide(
              //         color: Color(0xFF028090),
              //         width: 2.0,
              //       ),
              //     ),
              //   ),
              //   cursorColor: Color(0xFF028090),
              //   onChanged: searchSuppliers,
              // ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount:
                    filteredData.length + 1, // Extra item for loading indicator
                itemBuilder: (context, index) {
                  if (index == filteredData.length) {
                    return _isFetchingMore
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                  color: Color(0xFF028090)),
                            ),
                          )
                        : SizedBox(); // Don't show anything if not loading
                  }

                  final item = filteredData[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                    margin: const EdgeInsets.all(10),
                    child: Container(
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
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.store,
                                        size: 24, color: Color(0xFF028090)),
                                    const SizedBox(width: 10),
                                    Text(
                                      item['company_name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.phone,
                                        size: 20, color: Color(0xFF028090)),
                                    const SizedBox(width: 10),
                                    Text(" ${item['phone_number']}"),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.email,
                                        size: 20, color: Color(0xFF028090)),
                                    const SizedBox(width: 10),
                                    Text(" ${item['email']}"),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 20, color: Color(0xFF028090)),
                                    const SizedBox(width: 10),
                                    Text(" ${item['address']}"),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.receipt,
                                        size: 20, color: Color(0xFF028090)),
                                    const SizedBox(width: 10),
                                    Text(" ${item['supplier_gst_number']}"),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Status: ${item['status']}",
                                  style: TextStyle(
                                    color: item['Status'] == "Active"
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'Edit') {
                                editSupplier(item);
                              } else if (value == 'See All') {
                                viewSupplierDetails(
                                  item.map((key, value) => MapEntry(
                                      key.toString(), value.toString())),
                                  context,
                                );
                              } else if (value == 'Delete') {
                                deleteSupplier(item);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'See All',
                                child: ListTile(
                                  leading: const Icon(Icons.visibility,
                                      color: Color(0xFF028090)),
                                  title: const Text('See All'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'Edit',
                                child: ListTile(
                                  leading: const Icon(Icons.edit_square,
                                      color: Colors.orange),
                                  title: const Text('Edit'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'Delete',
                                child: ListTile(
                                  leading: const Icon(Icons.auto_delete,
                                      color: Colors.red),
                                  title: const Text('Delete'),
                                ),
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: addNewSupplier,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
          elevation: 30.0,
          backgroundColor: Color(0xFF028090),
          tooltip: 'Add Supplier',
        ),
      ),
    );
  }
}
