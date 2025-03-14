import 'dart:convert';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/Billing/pnarmacy_invoice.dart';
import 'package:flutter_application_1/Drawer/category_page.dart';
import 'package:flutter_application_1/bottom_items/home_page.dart';
import 'package:flutter_application_1/bottom_items/staff_page.dart';
import 'package:flutter_application_1/components/screen.dart';
import 'package:flutter_application_1/dashboard/custom_drawer.dart';
import 'package:flutter_application_1/products/product_list.dart';
import 'package:flutter_application_1/profile/profile.dart';

class PersistentBottomNavBar extends StatefulWidget {
  @override
  _PersistentBottomNavBarState createState() => _PersistentBottomNavBarState();
}

class _PersistentBottomNavBarState extends State<PersistentBottomNavBar> {
  final _controller = NotchBottomBarController(index: 0);
  final ApiService apiService = ApiService();

  String pharmacyName = "HealthPlus Pharmacy";

  final List<Widget> _pages = [
    Homepage(),
    ProductList(),
    PharmacyInvoiceScreen(),
    StaffPage(),
    ShopDetailsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    fetchAndDisplayProfile();
  }

  Future<void> fetchAndDisplayProfile() async {
    final token = await apiService.getTokenFromStorage();
    if (token == null) return;

    try {
      final fetchedProfiles = await apiService.fetchShops();
      if (fetchedProfiles.isNotEmpty) {
        setState(() {
          pharmacyName = fetchedProfiles.first["pharmacy_name"] ?? "HealthPlus Pharmacy";
        });
      }
    } catch (e) {
      print('Error fetching shops: $e');
    }
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
            pharmacyName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red, size: 25.0),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      drawer: CustomDrawer(onTap: (index) {
        setState(() => _controller.index = index.clamp(0, 4));
      }),
      body: _pages[_controller.index],
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        onTap: (index) {
          setState(() => _controller.index = index.clamp(0, 4));
        },
        kIconSize: 24,
        kBottomRadius: 30,
        notchColor: Color.fromRGBO(2, 116, 131, 1),
        bottomBarItems: [
          BottomBarItem(
            inActiveItem: Icon(Icons.home, color: Colors.black),
            activeItem: Icon(Icons.home_outlined, color: Colors.white, size: 25),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.production_quantity_limits, color: Colors.black),
            activeItem: Icon(Icons.production_quantity_limits, color: Colors.white, size: 25),
            itemLabel: 'Product',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.currency_rupee, color: Colors.black),
            activeItem: Icon(Icons.currency_rupee, color: Colors.white, size: 25),
            itemLabel: 'Billing',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.diversity_3, color: Colors.black),
            activeItem: Icon(Icons.diversity_3, color: Colors.white, size: 25),
            itemLabel: 'Staff',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.account_circle, color: Colors.black),
            activeItem: Icon(Icons.account_circle, color: Colors.white, size: 25),
            itemLabel: 'Profile',
          ),
        ],
        showLabel: true,
      ),
    );
  }

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
}