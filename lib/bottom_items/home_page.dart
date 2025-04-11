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
  bool isSaleVisible = false;
  String saleAmount = 'Loading...';
  String categoryCount = 'Loading...';
  String invoiceCount = 'Loading...';
  String customerCount = 'Loading...';

  double dailyIncome = 0.0;
  double monthlyIncome = 0.0;
  double sixMonthIncome = 0.0;
  double yearlyIncome = 0.0;

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

  Future<void> fetchIncomeData() async {
    try {
      final dailyResponse = await apiService.fetchIncomeData('DAILY');
      final monthlyResponse = await apiService.fetchIncomeData('MONTHLY');
      final sixMonthResponse = await apiService.fetchIncomeData('6MONTH');
      final yearlyResponse = await apiService.fetchIncomeData('YEARLY');

      if (mounted) {
        setState(() {
          dailyIncome = double.tryParse(
                  dailyResponse?['total_income']?.toString() ?? '0.0') ??
              0.0;
          monthlyIncome = double.tryParse(
                  monthlyResponse?['total_income']?.toString() ?? '0.0') ??
              0.0;
          sixMonthIncome = double.tryParse(
                  sixMonthResponse?['total_income']?.toString() ?? '0.0') ??
              0.0;
          yearlyIncome = double.tryParse(
                  yearlyResponse?['total_income']?.toString() ?? '0.0') ??
              0.0;
        });
      }
    } catch (e) {
      print('Error fetching income data: $e');
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
      if (response != null && response.containsKey('total_customers')) {
        setState(() {
          customerCount = response['total_customers'].toString();
        });
      } else {
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
    _networkListener.startListening(context);
    fetchSaleAmount('week');
    fetchCategoryCount();
    fetchInvoiceCount();
    fetchCustomerCount('week');
    fetchIncomeData();
  }

  @override
  void dispose() {
    _networkListener.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: buildStatusCards(
        context,
        isSaleVisible,
        toggleVisibility,
        saleAmount,
        categoryCount,
        invoiceCount,
        customerCount,
        dailyIncome,
        monthlyIncome,
        sixMonthIncome,
        yearlyIncome,
      ),
    );
  }
}

class OverviewData {
  final String category;
  final double value;
  final Color color;

  OverviewData(this.category, this.value, this.color);
}

Widget buildStatusCards(
  BuildContext context,
  bool isSaleVisible,
  VoidCallback toggleVisibility,
  String saleAmount,
  String categoryCount,
  String invoiceCount,
  String customerCount,
  double dailyIncome,
  double monthlyIncome,
  double sixMonthIncome,
  double yearlyIncome,
) {
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
          SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Income Overview',
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
                  isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              tooltipBehavior:
                  TooltipBehavior(enable: true, format: 'point.x: point.y'),
              series: <RadialBarSeries<OverviewData, String>>[
                RadialBarSeries<OverviewData, String>(
                  dataSource: [
                    OverviewData('Daily', dailyIncome, Colors.blue),
                    OverviewData('Monthly', monthlyIncome, Colors.green),
                    OverviewData('6 Months', sixMonthIncome, Colors.orange),
                    OverviewData('Yearly', yearlyIncome, Colors.red),
                  ],
                  xValueMapper: (OverviewData data, _) => data.category,
                  yValueMapper: (OverviewData data, _) => data.value,
                  pointColorMapper: (OverviewData data, _) => data.color,
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                  trackColor: Colors.grey[200]!,
                  trackOpacity: 0.5,
                  radius: '90%',
                  innerRadius: '40%',
                  cornerStyle: CornerStyle.bothCurve,
                  gap: '8%', // **Set the gap between radial bars**
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
