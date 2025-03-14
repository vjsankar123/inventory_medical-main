import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';

void main() {
  runApp(Screenpages());
}

class Screenpages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: BackgroundWithGif(),
      ),
    );
  }
}

class BackgroundWithGif extends StatefulWidget {
  @override
  _BackgroundWithGifState createState() => _BackgroundWithGifState();
}

class _BackgroundWithGifState extends State<BackgroundWithGif> {
  bool _isNewPasswordVisible = false;
  String? _selectedRole;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  String _message = '';
   late ConfettiController _confettiController;
  bool _hasConfettiFired = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
     _confettiController = ConfettiController(duration: Duration(seconds: 3));
    _checkInternet();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

   // Check Internet Connectivity
  void _checkInternet() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _showNoInternetAlert();
      }
    });
  }

   // Show Alert Dialog for No Internet
  void _showNoInternetAlert() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No Internet Connection"),
          content: Text("Please check your internet or Wi-Fi connection."),
          actions: [
            TextButton(
              child: Text("Retry"),
              onPressed: () {
                Navigator.of(context).pop();
                _checkInternet();
              },
            ),
          ],
        );
      },
    );
  }


  void _attemptLogin() async {
  setState(() {
    _isLoading = true;
    _message = '';
  });

  final email = _emailController.text.trim();
  final password = _newPasswordController.text.trim();
  final role = _selectedRole;

  if (email.isEmpty) {
    _showSnackBar('Please enter your email.');
    _stopLoading();
    return;
  }

  if (!_isValidEmail(email)) {
    _showSnackBar('Please enter a valid email address.');
    _stopLoading();
    return;
  }

  if (password.isEmpty) {
    _showSnackBar('Please enter your password.');
    _stopLoading();
    return;
  }

  if (!_isValidPassword(password)) {
    _showSnackBar('Password must be exactly 8 characters Alphabetica & Numbers .');
    _stopLoading();
    return;
  }

  if (role == null || (role != 'Admin' && role != 'Staff')) {
    _showSnackBar('Please select a valid role (Admin or Staff).');
    _stopLoading();
    return;
  }

  try {
    if (role == 'Admin') {
      await _apiService.login(context, email, password);
    } else if (role == 'Staff') {
      await _apiService.staffLogin(context, email, password);
    }

    setState(() {
      _isLoading = false;
    });

    _showSnackBar('Login Successful!', isSuccess: true);

    // Navigate to dashboard after 3 seconds
    // Future.delayed(Duration(seconds: 3), () {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => PersistentBottomNavBar()),
    //   );
    // });

  } catch (e) {
    _showSnackBar('Login Failed. Please try again.');
    _stopLoading();
  }
}

bool _isValidEmail(String email) {
  final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}");
  return emailRegex.hasMatch(email);
}

bool _isValidPassword(String password) {
  final passwordRegex = RegExp(r"^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]{8}$");
  return passwordRegex.hasMatch(password);
}

void _showSnackBar(String message, {bool isSuccess = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.greenAccent : Colors.redAccent,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isSuccess ? Color(0xFF00796B) : Color(0xFFD32F2F),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: Duration(seconds: 3),
      elevation: 10,
    ),
  );
}





  void _stopLoading() {
    setState(() {
      _isLoading = false;
    });
  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return true to allow the app to close
        return true;
      },
      child: Stack(
        children: [
          // GIF Background
          Positioned.fill(
            child: Image.asset(
              'assets/image/medical.gif',
              fit: BoxFit.cover,
            ),
          ),
          // Blur Area in a Specific Box
          Center(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 10, sigmaY: 10), // Adjust blur intensity
                child: SingleChildScrollView(
                  child: Container(
                    width: 350, // Set your box width
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white, width: 1), // Optional border
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'WELCOME BACK!',
                              style: TextStyle(
                                fontSize: 25,
                                color: Color(0xFF028090),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                              text: 'Login to your account',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF028090),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            items: [
                              DropdownMenuItem(
                                value: 'Admin',
                                child: Text('Admin'),
                              ),
                              DropdownMenuItem(
                                value: 'Staff',
                                child: Text('Staff'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value;
                              });
                            },
                            dropdownColor: Colors.white,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color(0xFF028090), width: 2.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 16),
                              hintText: 'Select Role',
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            cursorColor: Color(0xFF028090),
                            decoration: InputDecoration(
                              hintText: 'Email',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color(0xFF028090), width: 2.0),
                              ),
                              prefixIcon: Icon(Icons.email,
                                  color: Colors.grey, size: 20),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: !_isNewPasswordVisible,
                            cursorColor: Color(0xFF028090),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color(0xFF028090), width: 2.0),
                              ),
                              prefixIcon: Icon(Icons.lock,
                                  color: Colors.grey, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isNewPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Color(0xFF028090),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isNewPasswordVisible =
                                        !_isNewPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ElevatedButton(
                              onPressed: _attemptLogin,
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      'Login',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                              style: ElevatedButton.styleFrom(
                                elevation: 20,
                                foregroundColor:
                                    Colors.white, // Button text color
                                backgroundColor: Color(0xFF028090),
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 70.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          if (_message.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _message,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: _message == 'Login Successful'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'poppins',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
