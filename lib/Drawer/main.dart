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
import 'package:flutter_application_1/dashboard/custom_drawer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      drawer: CustomDrawer(
        onTap: (index) {
          // Navigate based on the index passed
          Widget page;
          switch (index) {
            case 5:
              page = CategoryPage();
              break;
            case 6:
              page = SupplierPage();
              break;
            case 7:
              page = ReturnPage();
              break;
            case 8:
              page = IncomePage();
              break;
            case 9:
              page = ExpenseTrackerApp();
              break;
            case 10:
              page = InvoiceList();
              break;
            case 11:
              page = SalesReportScreen();
              break;
            case 12:
              page = StockReportPage();
              break;
            case 13:
              page = BinPage();
              break;
            default:
              return;
          }
          // Using pushReplacement to replace the current screen with the selected page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
      body: Center(child: Text('Welcome to the Home Page')),
    );
  }
}
