import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/dashboard/persistent_bottom_nav_bar.dart';
import 'package:flutter_application_1/staff/staff_dashboard.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(SalesReportPage());
}

class SalesReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SalesReportScreen(),
    );
  }
}

class SalesReportScreen extends StatefulWidget {
  @override
  _SalesReportScreenState createState() => _SalesReportScreenState();
}

final ApiService apiService = ApiService();

class _SalesReportScreenState extends State<SalesReportScreen> {
  String dropdownValue = "Last 7 Days";
  // DateTime startDate = DateTime(2025, 1, 30);
  // DateTime endDate = DateTime(2025, 2, 1);
  List<dynamic> mostSoldMedicines = [];
  bool _isLoading = false;
  bool _isSearching = false;
  // TextEditingController searchController = TextEditingController();
  DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime endDate = DateTime.now();
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> salesData = [];

  // Ensure progressData is defined correctly
  final Map<String, List<Map<String, dynamic>>> progressData = {};

  void exportToCSV() async {
    final fromDate = DateFormat('yyyy-MM-dd').format(startDate);
  final toDate = DateFormat('yyyy-MM-dd').format(endDate);
    try {
      await apiService.exportCSVReport(fromDate, toDate);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CSV Report Downloaded Successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download CSV: $e")),
      );
    }
  }

  void exportToPDF() async {
      final fromDate = DateFormat('yyyy-MM-dd').format(startDate);
  final toDate = DateFormat('yyyy-MM-dd').format(endDate);
    try {
      await apiService.exportPDFReport(fromDate, toDate);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF Report Downloaded Successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download PDF: $e")),
      );
    }
  }

  Future<void> fetchSalesData() async {
    setState(() => _isLoading = true);
    try {
      final fromDate = DateFormat('yyyy-MM-dd').format(startDate);
      final toDate = DateFormat('yyyy-MM-dd').format(endDate);
      final searchQuery = searchController.text.trim();

      final data = await apiService.fetchSalesByDate(
        fromDate: fromDate,
        toDate: toDate,
        productName: searchQuery,
        // categoryName: searchQuery,
      );

      // Remove duplicates by product_name
      final uniqueSalesData = <String, Map<String, dynamic>>{};
      for (var item in data) {
        uniqueSalesData[item['product_name']] = item;
      }

      setState(() {
        salesData = uniqueSalesData.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  void fetchAndSetMostSoldMedicines() async {
    final String period = mapPeriod(dropdownValue);
    try {
      final data = await apiService.fetchMostSoldMedicines(period: period);
      print('API Response: $data');

      setState(() {
        final limitedData = data.take(3).toList();

        while (limitedData.length < 3) {
          limitedData.add({
            "product_name": "N/A",
            "quantity_sold": 0,
          });
        }

        // Use a Set to track unique products
        final Set<String> productNames = {};

        progressData[dropdownValue] = limitedData
            .where((item) => productNames
                .add(item["product_name"] ?? "Unknown")) // Filters duplicates
            .map((item) {
          final int quantitySold =
              int.tryParse(item["quantity_sold"].toString()) ?? 0;

          return {
            "name": item["product_name"],
            "units": quantitySold,
            "color": _getColorForProduct(item["product_name"]),
            "value": _calculateProgressValue(quantitySold),
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching most sold medicines: $e");
    }
  }

  Color _getColorForProduct(String productName) {
    switch (productName) {
      case "Paracetamol":
        return Colors.blue;
      case "Amoxicillin":
        return Colors.green;
      case "Ibuprofen":
        return Colors.orange;
      case "Cough Syrup":
        return Colors.red;
      case "Vitamin C":
        return Colors.purple;
      case "Antacid":
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  double _calculateProgressValue(int saleQty) {
    return saleQty / 100.0;
  }

  @override
  void initState() {
    super.initState();
    fetchSalesData();

    fetchAndSetMostSoldMedicines();
  }

  String mapPeriod(String dropdownValue) {
    switch (dropdownValue) {
      case "Last 7 Days":
        return "1week";
      case "Last 14 Days":
        return "2week";
      case "Last 30 Days":
        return "1month";
      default:
        return "1week";
    }
  }

  Future<void> _selectSingleDate(BuildContext context, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2026, 12, 31),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
      fetchSalesData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PersistentBottomNavBar(),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF028090),
          centerTitle: true,
          title: Text(
            'Sales Report',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => PersistentBottomNavBar()),
              );
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Most Sold Medicines",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DropdownButton<String>(
                    value: dropdownValue,
                    items: ["Last 7 Days", "Last 14 Days", "Last 30 Days"]
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                        fetchAndSetMostSoldMedicines();
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Dynamic Progress Bars
              if (progressData.containsKey(dropdownValue))
                for (var data in progressData[dropdownValue]!)
                  _buildProgressBar(
                    data["name"],
                    data["units"],
                    data["color"],
                    data["value"],
                  ),
              SizedBox(height: 20),

              // Date range picker with aligned label
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sales Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "From Date",
                            labelStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
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
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: DateFormat('dd-MM-yyyy').format(startDate),
                          ),
                          onTap: () {
                            _selectSingleDate(context, true);
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "To Date",
                            labelStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
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
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: DateFormat('dd-MM-yyyy').format(endDate),
                          ),
                          onTap: () {
                            _selectSingleDate(context, false);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),
              // Search Box
              Row(
                children: [
                  Container(
                    width: 250,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Category...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                      ),
                      style: TextStyle(color: Colors.black),
                      cursorColor: Color(0xFF028090),
                      onChanged: (value) => fetchSalesData(),
                    ),
                  ),
                  SizedBox(width: 10),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.download, color: Colors.black),
                    onSelected: (value) {
                      if (value == "csv") {
                        exportToCSV();
                      } else if (value == "pdf") {
                        exportToPDF();
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
              SizedBox(height: 20),

              // Sales Details Table
              _buildSalesTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(String name, int units, Color color, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$name ($units units)", style: TextStyle(fontSize: 16)),
        SizedBox(height: 5),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[300],
          color: color,
          minHeight: 10,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSalesTable() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            border: TableBorder.all(color: Colors.black, width: 2),
            columnSpacing: 20.0,
            columns: [
              DataColumn(
                label: Text('Medicine Name',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Sale Amount',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Category',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Sales Qty',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
            rows: salesData.map((item) {
              return DataRow(cells: [
                DataCell(Text(item['product_name'] ?? 'N/A')),
                DataCell(Text("\₹${item['final_price']}")),
                DataCell(Text(item['category_name'] ?? 'N/A')),
                DataCell(Text(item['quantity_sold'].toString())),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String col1, String col2, String col3, String col4,
      {bool isHeader = false}) {
    return TableRow(
      children: [
        _buildTableCell(col1, isHeader),
        _buildTableCell(col2, isHeader),
        _buildTableCell(col3, isHeader),
        _buildTableCell(col4, isHeader),
      ],
    );
  }

  Widget _buildTableCell(String text, bool isHeader) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
        textAlign: TextAlign.center,
      ),
    );
  }
}
