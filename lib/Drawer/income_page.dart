import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/Drawer/expense_page.dart';
import 'package:flutter_application_1/Drawer/income_cards.dart';
import 'package:flutter_application_1/dashboard/persistent_bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class IncomePage extends StatefulWidget {
  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final ApiService apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> invoices = [];
  bool isSaleVisible = false;
  bool _isFetchingMore = false;
  int _currentPage = 1;
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasMore = true;

  Map<String, String> incomeData = {
    'daily': '0',
    'monthly': '0',
    '6month': '0',
    'yearly': '0',
    'profit': '0', // Added for profit
    'expense': '0', // Added for expense
  };

  @override
  void initState() {
    super.initState();
    fetchIncomeData('DAILY');
    fetchIncomeData('MONTHLY');
    fetchIncomeData('6MONTH');
    fetchIncomeData('YEARLY');
    fetchInvoices();
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  Future<void> fetchInvoices({bool isLoadMore = false}) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final fetchedInvoices =
          await apiService.fetchInvoices(page: _currentPage, limit: _limit);

      setState(() {
        if (isLoadMore) {
          invoices.addAll(fetchedInvoices);
        } else {
          invoices = fetchedInvoices;
        }
        _isLoading = false;
        _hasMore = fetchedInvoices.length == _limit;
      });
    } catch (e) {
      print('Error fetching invoices: $e');
      setState(() => _isLoading = false);
    }
  }

  
Future<void> fetchIncomeData(String period) async {
  try {
    final response = await apiService.fetchIncomeData(period);
    if (response != null && mounted) {
      setState(() {
        incomeData[period.toLowerCase()] = response['total_income']?.toString() ?? '0';

        if (period == 'YEARLY') {
          incomeData['profit'] = response['total_profit']?.toString() ?? '0';
          incomeData['expense'] = response['expense']?.toString() ?? '0'; // Fix here
        }
      });
    }
  } catch (e) {
    print('Error fetching $period income: $e');
  }
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
            'Income Page',
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildStatusCards(context, incomeData,
                      isSaleVisible: false, toggleVisibility: () {}),
                  SizedBox(height: 20),
                  Text(
                    'Invoice List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  buildIncomeTable(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIncomeTable() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: ListView(
              controller: _scrollController,
              shrinkWrap: true, // ✅ Allow the list to size itself
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowHeight: 56,
                    dataRowHeight: 56,
                    border: TableBorder.all(color: Colors.black),
                    columns: [
                      DataColumn(
                          label: Text('S.No',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Invoice No',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Date',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Amount',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: invoices.map((invoice) {
                      int index = invoices.indexOf(invoice);
                      return DataRow(
                        cells: [
                          DataCell(Text(
                              '${(_currentPage - 1) * _limit + index + 1}')), // Fixed index
                          DataCell(Text(invoice['invoice_number'] ?? '')),
                          DataCell(
                              Text(formatDate(invoice['invoice_created_at']))),
                          DataCell(Text('\$${invoice['total_price']}')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
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
                        fetchInvoices();
                      }
                    : null,
              ),
              Text("Page $_currentPage",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.arrow_forward,
                    color: _hasMore ? Colors.blue : Colors.grey),
                onPressed: _hasMore && !_isLoading
                    ? () {
                        setState(() {
                          _currentPage++;
                        });
                        fetchInvoices();
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showIncomeDetails(BuildContext context, String period) async {
    try {
      final Map<String, dynamic>? incomeDetails =
          await apiService.fetchIncomeData(period.toUpperCase());

      if (incomeDetails != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("$period Income Details"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Income",
                      incomeDetails['total_income']?.toString() ?? "₹0.00"),
                  _buildDetailRow("Expense",
                      incomeDetails['expense']?.toString() ?? "₹0.00"),
                  _buildDetailRow("Supplier Cost",
                      incomeDetails['total_cost']?.toString() ?? "₹0.00"),
                  _buildDetailRow("Profit",
                      incomeDetails['total_profit']?.toString() ?? "₹0.00"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      } else {
        print("No data received for $period income.");
      }
    } catch (e) {
      print("Error fetching $period income details: $e");
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        "$label: $value",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  void _showInvoiceDetails(BuildContext context, Map<String, dynamic> invoice) {
    // Implement your invoice detail view logic
  }

  Widget buildStatusCards(BuildContext context, Map<String, dynamic> incomeData,
      {bool isSaleVisible = false, required VoidCallback toggleVisibility}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _showIncomeDetails(context, "DAILY"); // Call function dynamically
            },
            child: IncomeCards(
              title: "Today",
              data: incomeData['daily'] ?? "0",
              color: Color(0xFF00bbf9),
              icon: Icons.calendar_today,
              isVisible: isSaleVisible,
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              _showIncomeDetails(
                  context, "MONTHLY"); // Call function dynamically
            },
            child: IncomeCards(
              title: "This Month",
              data: incomeData['monthly'] ?? "0",
              color: Color(0xFFff9505),
              icon: Icons.view_week,
              isVisible: isSaleVisible,
            ),
          ),
          SizedBox(width: 8),
          IncomeCards(
            title: "Profit",
            data: incomeData['profit'] ??
                "0", // ✅ Shows total profit instead of 6-month income
            color: Color(0xFFf15bb5),
            icon: Icons.pie_chart,
            isVisible: isSaleVisible,
          ),
          GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExpenseTrackerScreen()), // Navigate to ExpensePage
    );
  },
        child:   IncomeCards(
            title: "Expense",
            data: incomeData['expense'] ??
                "0", // ✅ Shows total expense instead of yearly income
            color: Color(0xFF9b5de5),
            icon: Icons.moving,
            isVisible: isSaleVisible,
          ),
          )
        ],
      ),
    );
  }
}
