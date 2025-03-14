import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkListener {
  static final NetworkListener _instance = NetworkListener._internal();
  factory NetworkListener() => _instance;
  NetworkListener._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;

  void startListening(BuildContext context) {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        _showNoConnectionMessage(context);
      }
    });
  }

  void _showNoConnectionMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("No Internet Connection!"),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
      ),
    );
  }

  void stopListening() {
    _subscription?.cancel();
  }
}
