import 'package:flutter/material.dart';
import 'package:flutter_application_1/Drawer/bin_page.dart';
import 'package:flutter_application_1/Drawer/category_page.dart';
import 'package:flutter_application_1/Drawer/expense_page.dart';
import 'package:flutter_application_1/Drawer/income_page.dart';
import 'package:flutter_application_1/Drawer/invoice_page.dart';
import 'package:flutter_application_1/Drawer/return_page.dart';
import 'package:flutter_application_1/Drawer/sales_report_page.dart';
import 'package:flutter_application_1/Drawer/stock_report_page.dart';
import 'package:flutter_application_1/Drawer/supplier_page.dart';

class CustomDrawer extends StatefulWidget {
  final Function(int) onTap;

  CustomDrawer({required this.onTap});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int _selectedDrawerIndex = 5; // Track the selected index

  // Method to handle drawer item tap
  void _onDrawerItemTap(int index) {
    setState(() {
      _selectedDrawerIndex = index;
    });

    // Navigate to different pages based on index
    switch (index) {
      case 5:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                CategoryPage())); // Replace with your actual page
        break;
      case 6:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                SupplierPage())); // Replace with your actual page
        break;
      case 7:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                ReturnPage())); // Replace with your actual page
        break;
      case 8:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                IncomePage())); // Replace with your actual page
        break;
      case 9:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                ExpenseTrackerApp())); // Replace with your actual page
        break;
      case 10:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                InvoiceList())); // Replace with your actual page
        break;
      case 11:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                SalesReportScreen())); // Replace with your actual page
        break;
      case 12:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                StockReportPage())); // Replace with your actual page
        break;
      case 13:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => BinPage())); // Replace with your actual page
        break;
      default:
        // Handle default case if necessary
        break;
    }
  }

  Widget _buildCustomListTile({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24),
          child: Divider(color: Colors.white24, height: 1),
        ),
        Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              width: _selectedDrawerIndex == index ? 288 : 0,
              height: 56,
              left: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF028090),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: Icon(
                  icon,
                  color: _selectedDrawerIndex == index
                      ? Colors.white
                      : Colors.black,
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    color: _selectedDrawerIndex == index
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                onTap: () => _onDrawerItemTap(index),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Transform(
        transform: Matrix4.identity()..rotateY(0.05), // Add 3D rotation
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            // Drawer Header (Fixed at the top)
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF028090),
              ),
              child: Container(
                width: 300, // Set the width here
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.local_pharmacy,
                          size: 40, color: Colors.blue),
                    ),
                    SizedBox(height: 10),
                    Text("Welcome 😊",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text("Your health is our priority—let’s get started!",
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),

            // Scrollable list items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCustomListTile(
                        icon: Icons.category, title: 'Category', index: 5),
                    _buildCustomListTile(
                        icon: Icons.manage_accounts,
                        title: 'Supplier',
                        index: 6),
                    _buildCustomListTile(
                        icon: Icons.keyboard_return, title: 'Return', index: 7),

                    // Finance section with sublist
                    ExpansionTile(
                      title: Text('Finance'),
                      leading: Icon(Icons.account_balance_wallet),
                      children: [
                        _buildCustomListTile(
                            icon: Icons.trending_up, title: 'Income', index: 8),
                        _buildCustomListTile(
                            icon: Icons.sentiment_very_satisfied,
                            title: 'Expense',
                            index: 9),
                        _buildCustomListTile(
                            icon: Icons.graphic_eq,
                            title: 'Invoice',
                            index: 10),
                      ],
                    ),

                    // Report section with sublist
                    ExpansionTile(
                      title: Text('Report'),
                      leading: Icon(Icons.bar_chart),
                      children: [
                        _buildCustomListTile(
                            icon: Icons.swipe_up,
                            title: 'Sales Report',
                            index: 11),
                        _buildCustomListTile(
                            icon: Icons.swipe_down,
                            title: 'Stock Report',
                            index: 12),
                      ],
                    ),

                    _buildCustomListTile(
                        icon: Icons.delete, title: 'Bin', index: 13),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
