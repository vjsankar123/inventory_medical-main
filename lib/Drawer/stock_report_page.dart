import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/bottom_items/staff_page.dart';
import 'package:flutter_application_1/dashboard/persistent_bottom_nav_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class StockReportPage extends StatefulWidget {
  const StockReportPage({super.key});

  @override
  State<StockReportPage> createState() => _StockReportPageState();
}

class _StockReportPageState extends State<StockReportPage> {
  TextEditingController searchController = TextEditingController();
  String selectedStatus = 'All';
  bool _isSearching = false;
  bool _isLoading = true;
  bool _hasMoreProducts = true;
  List<Map<String, dynamic>> _stockData = [];
  List<ChartData> _chartData = [];
  List<String> _productSuggestions = [];
  final ApiService apiService = ApiService();

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }


  void exportToCSV(String status) async {
    try {
      await apiService.exportedCSVReport(status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CSV Report Downloaded Successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download CSV: $e")),
      );
    }
  }

  void exportToPDF(String status) async {
    try {
      await apiService.exportedPDFReport(status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF Report Downloaded Successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download PDF: $e")),
      );
    }
  }

 Future<void> _fetchProducts() async {
  try {
    final fetchedProducts = await apiService.stockProducts(
      status: selectedStatus == 'All' ? null : selectedStatus,
      search: searchController.text.isNotEmpty ? searchController.text : null,
    );

    setState(() {
      _stockData = fetchedProducts; // Ensure empty array if null
    });

    if (_stockData.isEmpty) {
      print("No products found.");
    }
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
        _productSuggestions = fetchedProducts
            .map<String>((product) => product['product_name'].toString())
            .toList();
      });
    } catch (e) {
      print("Error fetching suggestions: $e");
    }
  }

   Color _getStatusColor(String status) {
    switch (status) {
      case 'OutofStock':
        return Colors.red;
      case 'Available':
        return Colors.green;
      case 'LowStock':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => PersistentBottomNavBar()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF028090),
          title: _isSearching
              ? Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    border: Border.all(
                        color: Colors.grey, width: 1), // Border color
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: _fetchProductSuggestions,
                    onSubmitted: (_) => _fetchProducts(),
                    decoration: InputDecoration(
                      hintText: 'Search Product...',
                      prefixIcon: const Icon(Icons.search),
                      // suffixIcon: searchController.text.isNotEmpty
                      //     ? IconButton(
                      //         icon: const Icon(Icons.clear),
                      //         onPressed: () {
                      //           searchController.clear();
                      //           _fetchProducts();
                      //         },
                      //       )
                      //     : null,
                    ),
                    style: TextStyle(color: Colors.black),
                    cursorColor: Color(0xFF028090),
                  ),
                )
              : const Text(
                  'Stock Report',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
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
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.cancel : Icons.search,
                  color: Colors.black),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) searchController.clear();
                  _fetchProducts();
                });
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(15.0),
                // child: Text(
                //   'Stock Report',
                //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                // ),
              ),
              //    SizedBox(
              //   height: 400,
              //   child: SfCircularChart(
              //     legend: Legend(
              //       isVisible: true,
              //       overflowMode: LegendItemOverflowMode.wrap,
              //     ),
              //     tooltipBehavior: TooltipBehavior(enable: true),
              //     series: <CircularSeries<ChartData, String>>[
              //       PieSeries<ChartData, String>(
              //         dataSource: _chartData,
              //         pointColorMapper: (ChartData data, _) => data.color,
              //         xValueMapper: (ChartData data, _) => data.x,
              //         yValueMapper: (ChartData data, _) => data.y,
              //         dataLabelSettings: const DataLabelSettings(isVisible: true),
              //       ),
              //     ],
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                       child: DropdownButton<String>(
                        value: selectedStatus,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedStatus = newValue!;
                            _fetchProducts(); // Fetch with new status
                          });
                        },
                         items: ['All', 'Available', 'Low Stock', 'Out of Stock']
                            .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(value),
                                      ),
                                    ))
                            .toList(),
                        dropdownColor: Colors.white,
                        underline: SizedBox(),
                      ),
                    ),
                    Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.download, color: Colors.black),
                      onSelected: (value) {
                        const String status =
                            "Available"; // Set status dynamically if needed
                        if (value == "csv") {
                          exportToCSV(status);
                        } else if (value == "pdf") {
                          exportToPDF(status);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: "csv",
                          child: Text("Export to CSV"),
                        ),
                        PopupMenuItem<String>(
                          value: "pdf",
                          child: Text("Export to PDF"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder.all(color: Colors.black, width: 1),
                    columnSpacing: 20.0,
                    columns: const [
                      DataColumn(
                          label: Text('S.No',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Medicine',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Category',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Quantity',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Expiry',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Status',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: _stockData.map((stock) {
                      final index = _stockData.indexOf(stock);
                      return DataRow(cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(stock['product_name'] ?? ' ')),
                        DataCell(Text(stock['product_category'] ?? ' ')),
                        DataCell(Text(stock['product_quantity'].toString())),
                        DataCell(Text(formatDate(stock['expiry_date'] ?? ''))),
                        DataCell(Text(
                          stock['stock_status'] ?? '',
                          style: TextStyle(
                              color:
                                  _getStatusColor(stock['stock_status'] ?? '')),
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}

class StockData {
  StockData(this.medicine, this.category, this.stock, this.expiry, this.status);
  final String medicine;
  final String category;
  final String stock;
  final String expiry;
  final String status;
}

void main() => runApp(const MaterialApp(home: StockReportPage()));
