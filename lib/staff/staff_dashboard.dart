import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Billing/pnarmacy_invoice.dart';
import 'package:flutter_application_1/Drawer/invoice_page.dart';
import 'package:flutter_application_1/Drawer/sales_report_page.dart';
import 'package:flutter_application_1/bottom_items/home_page.dart';
import 'package:flutter_application_1/components/screen.dart';
import 'package:flutter_application_1/products/product_list.dart';

class StaffDashboard extends StatefulWidget {
  @override
  _StaffDashboardState createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  final _controller = NotchBottomBarController(index: 0);

  final List<Widget> _pages = [
    Homepage(),
    ProductList(),
    PharmacyInvoiceScreen(),
    InvoiceList(),
    SalesReportScreen(),
  ];

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Log Out'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF028090),
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Logging out...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
                await Future.delayed(Duration(seconds: 2));
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Screenpages(),
                ));
              },
              child: Text('OK', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(2, 116, 131, 1),
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'HealthPlus Pharmacy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.red,
              size: 25.0,
            ),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _pages[_controller.index],
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        onTap: (index) {
          setState(() {
            _controller.index = index.clamp(0, 4);
          });
        },
        kIconSize: 24,
        kBottomRadius: 30,
        notchColor: Color.fromRGBO(2, 116, 131, 1),
        bottomBarItems: [
          BottomBarItem(
            inActiveItem: Icon(Icons.home, color: Colors.black),
            activeItem: Center(
              child: Icon(Icons.home_outlined, color: Colors.white, size: 25),
            ),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem:
                Icon(Icons.production_quantity_limits, color: Colors.black),
            activeItem: Center(
              child: Icon(Icons.production_quantity_limits,
                  color: Colors.white, size: 25),
            ),
            itemLabel: 'Product',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.currency_rupee, color: Colors.black),
            activeItem: Center(
              child: Icon(Icons.currency_rupee, color: Colors.white, size: 25),
            ),
            itemLabel: 'Billing',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.graphic_eq, color: Colors.black),
            activeItem: Center(
              child: Icon(Icons.graphic_eq, color: Colors.white, size: 25),
            ),
            itemLabel: 'Invoice',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.swipe_up, color: Colors.black),
            activeItem: Center(
              child: Icon(Icons.swipe_up, color: Colors.white, size: 25),
            ),
            itemLabel: 'Sales Report',
          ),
        ],
        showLabel: true,
      ),
    );
  }
}
