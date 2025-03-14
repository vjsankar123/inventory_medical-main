import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:flutter_application_1/dashboard/persistent_bottom_nav_bar.dart';
import 'package:flutter_application_1/network_file/network_listener.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late StreamSubscription<ConnectivityResult> _subscription;
  bool isConnected = true;

  final NetworkListener _networkListener = NetworkListener();

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    // Define a tween for vertical movement
    _animation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation
    _animationController.forward();

    // Start network listener
    _networkListener.startListening(context);

    // Check internet connection
    _checkInternet();

    // Navigate to the next page after a delay
    _navigateToLandingPages();
  }

  Future<void> _checkInternet() async {
    var result = await Connectivity().checkConnectivity();
    setState(() {
      isConnected = result != ConnectivityResult.none;
    });
  }

  _navigateToLandingPages() async {
    await Future.delayed(Duration(seconds: 9));
    if (isConnected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Screenpages()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _networkListener.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isConnected
          ? Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/image/evvi.gif',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            )
          : const Center(
              child: Text(
                "Internet Disconnected",
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),
    );
  }
}