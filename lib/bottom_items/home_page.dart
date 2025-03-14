import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin-cards/home_cards.dart';
import 'package:flutter_application_1/bottom_items/staff_page.dart';
import 'package:flutter_application_1/network_file/network_listener.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final NetworkListener _networkListener = NetworkListener();
  bool isSaleVisible = false; // Track visibility of sale amount
  String saleAmount = 'Loading...';
  String categoryCount = 'Loading...';
  String invoiceCount = 'Loading...';
  String customerCount = 'Loading...';

  void toggleVisibility() {
    setState(() {
      isSaleVisible = !isSaleVisible;
    });
  }

  Future<void> fetchSaleAmount(String period) async {
    try {
      final response = await apiService.getTotalInvoiceAmount(period);
      setState(() {
        saleAmount = response?['totalFinalPrice']?.toString() ?? '0.00';
      });
    } catch (error) {
      print("Error fetching sale amount: $error");
      setState(() {
        saleAmount = 'Error';
      });
    }
  }

  Future<void> fetchCategoryCount() async {
    try {
      final totalCategories = await apiService.fetchTotalCategories();
      setState(() {
        categoryCount = totalCategories.toString();
      });
    } catch (error) {
      print("Error fetching category count: $error");
      setState(() {
        categoryCount = 'Error';
      });
    }
  }

  Future<void> fetchInvoiceCount() async {
    try {
      final totalInvoice = await apiService.fetchTotalInvoice();
      setState(() {
        invoiceCount = totalInvoice.toString();
      });
    } catch (error) {
      print("Error fetching invoice count: $error");
      setState(() {
        invoiceCount = 'Error';
      });
    }
  }

  Future<void> fetchCustomerCount(String period) async {
  try {
    final response = await apiService.getTotalCustomerCount(period);
    print("Customer API Response: $response"); // Debug log

    if (response != null && response.containsKey('total_customers')) {
      setState(() {
        customerCount = response['total_customers'].toString();
      });
    } else {
      print("Invalid customer count format: $response");
      setState(() {
        customerCount = 'Error';
      });
    }
  } catch (error) {
    print("Error fetching customer count: $error");
    setState(() {
      customerCount = 'Error';
    });
  }
}



  @override
  void initState() {
    super.initState();
    _networkListener.startListening(context); // Start listening for network changes
    fetchSaleAmount('week'); // Fetch sale amount (default to 'week')
    fetchCategoryCount(); // Fetch category count
    fetchInvoiceCount(); // Fetch invoice count
    fetchCustomerCount('week'); // Fetch customer count
  }

  @override
  void dispose() {
    _networkListener.stopListening(); // Stop listening when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: buildStatusCards(context, isSaleVisible, toggleVisibility, saleAmount, categoryCount, invoiceCount, customerCount),
    );
  }
}

class OverviewData {
  final String category;
  final double product;
  final double user;
  final double order;
  final double outOfStock;
  final Color color;

  OverviewData(this.category, this.product, this.user, this.order, this.outOfStock, this.color);
}

Widget buildStatusCards(BuildContext context, bool isSaleVisible, VoidCallback toggleVisibility, String saleAmount, String categoryCount, String invoiceCount, String customerCount) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CustomCard(
                  title: "Sale Amount",
                  data: saleAmount,
                  color: Color(0xFF30c67c),
                  icon: Icons.currency_rupee,
                  isVisible: isSaleVisible,
                  onToggle: toggleVisibility,
                ),
                CustomCard(
                  title: "Category",
                  data: categoryCount,
                  color: Color(0xFFff930f),
                  icon: Icons.shopping_cart,
                ),
                CustomCard(
                  title: "Invoice Count",
                  data: invoiceCount,
                  color: Color(0xFFf9655b),
                  icon: Icons.check_circle,
                ),
                CustomCard(
                  title: "Customer",
                  data: customerCount,
                  color: Color(0xFF456fe8),
                  icon: Icons.support_agent,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(width: 8),
            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              tooltipBehavior:
                  TooltipBehavior(enable: true, format: 'point.x: point.y'),
              series: <RadialBarSeries<OverviewData, String>>[
                RadialBarSeries<OverviewData, String>(
                  dataSource: [
                    OverviewData('Product', 40, 30, 20, 10, Colors.blue),
                    OverviewData('User', 400, 300, 200, 100, Colors.green),
                    OverviewData('Order', 600, 500, 400, 300, Colors.orange),
                    OverviewData('Out of Stock', 300, 200, 100, 50, Colors.red),
                  ],
                  trackColor: Colors.grey[200]!,
                  trackOpacity: 0.5,
                  maximumValue: 600,
                  radius: '90%',
                  innerRadius: '40%',
                  xValueMapper: (OverviewData data, _) => data.category,
                  yValueMapper: (OverviewData data, _) => data.product,
                  pointColorMapper: (OverviewData data, _) => data.color,
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                  cornerStyle: CornerStyle.bothCurve,
                  gap: '4%',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
