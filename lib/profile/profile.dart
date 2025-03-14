import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/dashboard/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ProfilePage());
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShopDetailsScreen(),
    );
  }
}

class ShopDetailsScreen extends StatefulWidget {
  @override
  _ShopDetailsScreenState createState() => _ShopDetailsScreenState();
}

final ApiService apiService = ApiService();

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  List<Map<String, String>> profileList = [];
  //  List<Map<String, dynamic>> profileList = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  String shopId = "";
  String shopName = "";
  String description = "";
  String gstNumber = "";
  String address = "";
  String pinCode = "";
  String phoneNumber = "";
  bool isGovernmentRegistered = false;

  @override
  void initState() {
    super.initState();
    fetchAndDisplayProfile();
    // _scrollController.addListener(() {
    //   setState(() {
    //     isScrolled =
    //         _scrollController.offset > 10; // Adjust threshold as needed
    //   });
    // });
  }

  Future<void> fetchAndDisplayProfile() async {
    final token = await apiService.getTokenFromStorage();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You are not logged in. Please log in first.')),
      );
      return;
    }

    try {
      final fetchedProfiles = await apiService.fetchShops();
      if (fetchedProfiles.isNotEmpty) {
        setState(() {
          final profile = fetchedProfiles.first;
          shopId = profile["shop_id"] ?? "";
          shopName = profile["pharmacy_name"] ?? "";
          description = profile["description"] ?? "";
          gstNumber = profile["owner_GST_number"] ?? "";
          pinCode = profile["pincode"] ?? "";
          address = profile["pharmacy_address"] ?? "";
          isGovernmentRegistered =
              profile["allow_registration"] == "Registered";
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No shops found.')),
        );
      }
    } catch (e) {
      print('Error fetching shops: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to fetch profile. Please try again later.')),
      );
    }
  }

  void _updateShopDetails({
    required String updatedShopName,
    required String updatedGstNumber,
    required String updatedAddress,
    required String updatedPinCode,
    required String updatedDescription,
    required bool updatedIsGovernmentRegistered,
  }) {
    setState(() {
      shopName = updatedShopName;
      gstNumber = updatedGstNumber;
      address = updatedAddress;
      pinCode = updatedPinCode;
      description = updatedDescription;
      isGovernmentRegistered = updatedIsGovernmentRegistered;
    });
  }

  // Function to show the delete confirmation dialog
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Delete Shop'),
          content: Text('Are you sure you want to delete this shop details?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Handle the delete action here
                // For example, navigate back or show a snackbar confirming deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Shop details deleted successfully')),
                );
                // You can also navigate to a different screen if required
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => PersistentBottomNavBar(),
                ));
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
void _showEmailSupport() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Email Support',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'For support, contact us at:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'pharmasupport@evvisolutions.com',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch email client.')),
                  );
                }
              },
              child: const Text(
                'pharmasupport@evvisolutions.com',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    },
  );
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
            "Shop Details",
            style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          // elevation: 4.0,
        ),
        backgroundColor: Colors.white,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.black, width: 2.0),
                      ),
                      color: Colors.white,
                      elevation: 5.0,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border(
                            top: BorderSide(color: Colors.black, width: 2.0),
                            left: BorderSide(color: Colors.black, width: 2.0),
                            right: BorderSide(color: Colors.black, width: 2.0),
                            bottom: BorderSide(color: Colors.black, width: 5.0),
                          ),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            detailRow("Shop Name", shopName, isHeader: true),
                            const Divider(),
                            detailRow("GST Number", gstNumber),
                            // detailRow("dfg", shopId),
                            detailRow("Description", description),
                            detailRow("PIN", pinCode),
                            detailRow("Address", address),
                            detailRow(
                              "Government Registered",
                              isGovernmentRegistered
                                  ? "Registered"
                                  : "Not Registered",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              backgroundColor: Colors.white,
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20.0),
                                ),
                              ),
                              builder: (context) {
                                return EditShopForm(
                                  shopId: shopId,
                                  shopName: shopName,
                                  gstNumber: gstNumber,
                                  address: address,
                                  pinCode: pinCode,
                                  description: description,
                                  isGovernmentRegistered:
                                      isGovernmentRegistered,
                                  onSave: _updateShopDetails,
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 24.0),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            "Edit",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        ),
                        // ElevatedButton.icon(
                        //   onPressed:
                        //       _showDeleteConfirmationDialog, // Call the delete confirmation dialog
                        //   style: ElevatedButton.styleFrom(
                        //     padding: const EdgeInsets.symmetric(
                        //         vertical: 12.0, horizontal: 24.0),
                        //     backgroundColor: Colors.red,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(10.0),
                        //     ),
                        //   ),
                        //   icon: const Icon(Icons.delete, color: Colors.white),
                        //   label: const Text(
                        //     "Delete",
                        //     style: TextStyle(color: Colors.white, fontSize: 16.0),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showEmailSupport,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.email, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  Widget detailRow(String label, String value, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
              fontSize: isHeader ? 18.0 : 16.0,
              color: isHeader ? Colors.black : Colors.black87,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isHeader ? 18.0 : 16.0,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? Color(0xFF028090) : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditShopForm extends StatefulWidget {
  final String shopName;
  final String shopId;
  final String gstNumber;
  final String address;
  final String pinCode;
  final String description;
  final bool isGovernmentRegistered;
  final Function({
    required String updatedShopName,
    required String updatedGstNumber,
    required String updatedAddress,
    required String updatedPinCode,
    required String updatedDescription,
    required bool updatedIsGovernmentRegistered,
  }) onSave;

  const EditShopForm({
    super.key,
    required this.shopName,
    required this.shopId,
    required this.gstNumber,
    required this.address,
    required this.pinCode,
    required this.description,
    required this.isGovernmentRegistered,
    required this.onSave,
  });

  @override
  _EditShopFormState createState() => _EditShopFormState();
}

class _EditShopFormState extends State<EditShopForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController shopNameController;
  late TextEditingController gstNumberController;
  late TextEditingController addressController;
  late TextEditingController descrptionController;
  late TextEditingController pinCodeController;
  late bool isGovernmentRegistered;

  @override
  void initState() {
    super.initState();
    // print("Received Staff Data: ${widget.p}");
    shopNameController = TextEditingController(text: widget.shopName);
    gstNumberController = TextEditingController(text: widget.gstNumber);
    addressController = TextEditingController(text: widget.address);
    pinCodeController = TextEditingController(text: widget.pinCode);
    descrptionController = TextEditingController(text: widget.description);

    isGovernmentRegistered = widget.isGovernmentRegistered;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text(
              "Edit Shop Details",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            buildTextField("Shop Name", shopNameController),
            buildTextField("GST Number", gstNumberController),
            buildTextField("Address", addressController),
            buildTextField("PIN Code", pinCodeController),
            buildTextField("Descrption", descrptionController),
            // buildTextField("Phone Number", phoneNumberController),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<bool>(
              value: isGovernmentRegistered,
              decoration: InputDecoration(
                labelText: "Government Registered",
                labelStyle: const TextStyle(
                  color: Colors.black,
                ),
                floatingLabelStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF028090),
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF028090),
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Colors.black38,
                    width: 1.0,
                  ),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: true,
                  child: Text("Registered"),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text("Not Registered"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  isGovernmentRegistered = value!;
                });
              },
              dropdownColor: Colors.white,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final updatedProfile = {
                    "pharmacy_name": shopNameController.text,
                    "owner_GST_number": gstNumberController.text,
                    "pharmacy_address": addressController.text,
                    "pincode": pinCodeController.text,
                    "description": descrptionController.text,
                    "allow_registration": isGovernmentRegistered
                        ? "Registered"
                        : "Not Registered",
                  };

                  bool success = await apiService.updateprofile(widget.shopId,
                      updatedProfile); // Replace with actual shop ID
                  if (success) {
                    widget.onSave(
                      updatedShopName: shopNameController.text,
                      updatedGstNumber: gstNumberController.text,
                      updatedAddress: addressController.text,
                      updatedPinCode: pinCodeController.text,
                      updatedDescription: descrptionController.text,
                      updatedIsGovernmentRegistered: isGovernmentRegistered,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Shop updated successfully'),
                          backgroundColor: Colors.green),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Failed to update shop'),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xFF028090)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black,
          ),
          floatingLabelStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
              color: Color(0xFF028090),
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
              color: Color(0xFF028090),
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(
              color: Colors.black38,
              width: 1.0,
            ),
          ),
        ),
        cursorColor: const Color(0xFF028090),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label cannot be empty";
          }
          return null;
        },
      ),
    );
  }
}
