import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottom_items/staff_page.dart';
import 'package:flutter_application_1/dashboard/persistent_bottom_nav_bar.dart';
import 'package:flutter_application_1/products/view_product.dart';
import 'package:flutter_application_1/staff/staff_dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl = 'http://192.168.20.4:3002'; // Replace with actual IP

  String? _authToken;

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('token', token);
    final success = await prefs.setString('token', token);
    print("Token has been set: $success"); // Debugging purpose
  }

  // Method to get the token from memory or SharedPreferences
  Future<String?> getTokenFromStorage() async {
    if (_authToken != null) {
      // print("Token retrieved from memory: $_authToken");
      return _authToken;
    }
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('token');
    // print("Token retrieved from SharedPreferences: $_authToken");
    return _authToken;
  }

  Future<http.Response> _makeRequest(
    String url,
    String method, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final token = await getTokenFromStorage();
      final defaultHeaders = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': '$token',
      };

      // print('Making $method request to: $url');
      // print('Body: ${body != null ? jsonEncode(body) : "No Body"}');

      // If DELETE and body is not null, convert body to query params
      if (method.toUpperCase() == 'DELETE' && body != null) {
        final queryString = Uri(queryParameters: body).query;
        url = '$url?$queryString';
      }

      final uri = Uri.parse(url);

      final requestMethods = {
        'POST': () =>
            http.post(uri, headers: defaultHeaders, body: jsonEncode(body)),
        'GET': () => http.get(uri, headers: defaultHeaders),
        'PUT': () =>
            http.put(uri, headers: defaultHeaders, body: jsonEncode(body)),
        'DELETE': () => http.delete(uri, headers: defaultHeaders),
      };

      final requestFunction = requestMethods[method.toUpperCase()];
      if (requestFunction != null) {
        return await requestFunction();
      } else {
        print('Error: Unsupported HTTP method: $method');
        throw Exception('Invalid HTTP method: $method');
      }
    } catch (e) {
      if (e is SocketException) {
        print(e);
        print("No internet connection.");
        throw Exception("No internet connection.");
      } else {
        print("Error during request: $e");
        throw Exception("Something went wrong.");
      }
    }
  }

// Login page of Admin//
  Future<Map<String, dynamic>?> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    final url = '$baseUrl/admin/login';

    final body = {'email': email, 'password': password};
    print('Request Body: $body');

    try {
      final response = await _makeRequest(url, 'POST', body: body);

      print('Response Status Codessss: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Decoded Data: $data');

        final token = data['token'];
        final userId = data['id']; // Retrieve user ID

        if (token != null) {
          await setAuthToken(token);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Login successful')),
          // );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PersistentBottomNavBar()),
          );
          return {
            'success': true,
            'message': 'Login successful',
            'token': token,
            'id': userId
          };
        } else {
          return {'success': false, 'message': 'No token received'};
        }
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      print('wdgwdgwgd: $e');
      print('Error during login: $e');
      if (e.toString().contains('Connection refused')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Connection refused. Please check your server.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again later.')),
        );
      }
      return {
        'success': false,
        'message': 'An error occurred. Please try again.'
      };
    }
  }

// user login//

  Future<Map<String, dynamic>?> staffLogin(
    BuildContext context,
    String email,
    String password,
  ) async {
    final url = '$baseUrl/staff/login';

    final body = {'email': email, 'password': password};
    print('Staff Login Request Body: $body');

    try {
      final response = await _makeRequest(url, 'POST', body: body);

      print('Staff Login Response Status: ${response.statusCode}');
      print('Staff Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Decoded Staff Login Data: $data');

        final token = data['token'];
        final userId = data['id']; // Retrieve staff ID

        if (token != null) {
          await setAuthToken(token);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Staff login successful')),
          );

          // Navigate to Staff Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StaffDashboard()),
          );

          return {
            'success': true,
            'message': 'Staff login successful',
            'token': token,
            'id': userId
          };
        } else {
          return {'success': false, 'message': 'No token received'};
        }
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Staff login failed'
        };
      }
    } catch (e) {
      print('Error during staff login: $e');

      if (e.toString().contains('Connection refused')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Connection refused. Please check your server.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'An error occurred during staff login. Please try again.')),
        );
      }

      return {
        'success': false,
        'message': 'An error occurred during staff login. Please try again.'
      };
    }
  }
  // create user of admin//

  Future<bool> createUser(Map<String, dynamic> userData) async {
    final url = '$baseUrl/staff/register';
    final body = userData;
    print('Requegfhfst Body: $body');

    try {
      final response = await _makeRequest(url, 'POST', body: body);

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // get all users list//
  Future<List<Map<String, String>>> fetchUsers(
      {int page = 1, int limit = 10}) async {
    final url = '$baseUrl/staff/users?page=$page&limit=$limit';
    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('asd: $data');
        final users = data['users'] as List;
        print("Fetched Users: $users");

        return users.map((user) {
          return {
            "id": user["id"].toString(),
            "name": user["username"]?.toString() ?? "Unknown",
            "email": user["email"]?.toString() ?? "No Email",
            "contact": user["contact_number"]?.toString() ?? "No Contact",
            "address": user["address_details"]?.toString() ?? "No Address",
            "aadhar": user["user_id_proof"]?.toString() ?? "No AADhar",
            "role": user["role"]?.toString() ?? "User",
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  Future<bool> updateUser(
      String userId, Map<String, dynamic> updatedstaff) async {
    final Uri url =
        Uri.parse('$baseUrl/staff/user/$userId'); // Include userId in the URL
    print("Updated Task Data: $updatedstaff");

    try {
      final response = await _makeRequest(
        url.toString(),
        'PUT', // Use 'PUT' or 'PATCH' based on your API
        body: updatedstaff, // Send the body as JSON
      );

      if (response.statusCode == 200) {
        return true; // Successfully updated
      } else {
        print(
            'Failed to update user: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  Future<void> deleteUserFromApi(String staffId, VoidCallback onDelete) async {
    final Uri url = Uri.parse('$baseUrl/staff/user/$staffId');
    print('asd:$staffId');
    try {
      final response =
          await _makeRequest(url.toString(), "DELETE"); // Direct delete request

      if (response.statusCode == 200) {
        print('Staff deleted successfully.');
        onDelete(); // Notify UI update
      } else {
        final data = jsonDecode(response.body);
        throw Exception(
            'Error deleting staff: ${data['message'] ?? response.body}');
      }
    } catch (e) {
      print('Error during staff deletion: $e');
      rethrow;
    }
  }

  int totalPages = 1; // Store total pages globally
  Future<List<Map<String, String>>> fetchcategory(
      {int page = 1, int limit = 10}) async {
    final url =
        '$baseUrl/pro_category/all_category_pagination?page=$page&limit=$limit';
    print('Fetching: $url');

    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        totalPages = data["totalPages"]; // Update total pages

        final category = data["data"] as List;
        return category.map((cat) {
          return {
            "id": cat["id"]?.toString() ?? "0",
            "category_name": cat["category_name"]?.toString() ?? "",
            "description": cat["description"]?.toString() ?? "",
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch categories: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

// category count page //


  Future<int> fetchTotalCategories() async {
    final url = '$baseUrl/pro_category/all_category_pagination?page=1&limit=10';
    print('Fetching: \$url');

    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["totalCategories"] ?? 0;
      } else {
        throw Exception('Failed to fetch categories: \${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching categories: \$e");
      return 0;
    }
  }

  // fetch total invoice count//
  Future<int> fetchTotalInvoice() async {
    final url = '$baseUrl/invoice/invoiceall_pagination?page=1&limit=10';
    print('Fetching: \$url');

    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["total_invoice"] ?? 0;
      } else {
        throw Exception('Failed to fetch categories: \${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching categories: \$e");
      return 0;
    }
  }
  // create category //
  Future<bool> createCategory(Map<String, dynamic> categorydata) async {
    final url = '$baseUrl/pro_category/insert_category';
    final body = categorydata;
    print('Requegfhfst Body: $body');

    try {
      final response = await _makeRequest(url, 'POST', body: body);

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // // update category//
  Future<bool> updateCategory(
      String CategoryId, Map<String, dynamic> updatedCategory) async {
    final url =
        '$baseUrl/pro_category/update_category/$CategoryId'; // Include userId in the URL
    print("Updated Task Data: $updatedCategory");

    try {
      final response = await _makeRequest(
        url.toString(),
        'PUT', // Use 'PUT' or 'PATCH' based on your API
        body: updatedCategory, // Send the body as JSON
      );

      if (response.statusCode == 200) {
        return true; // Successfully updated
      } else {
        print(
            'Failed to update user: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Delete category//

  Future<void> deleteCatgeoryFromApi(
      String categoryId, VoidCallback onDelete) async {
    final Uri url = Uri.parse('$baseUrl/pro_category/del_category/$categoryId');

    try {
      final response = await _makeRequest(url.toString(), "DELETE");

      if (response.statusCode == 200) {
        print('Category deleted successfully.');
        onDelete(); // Update UI after deletion
      } else {
        final data = jsonDecode(response.body);
        throw Exception(
            'Error deleting Category: ${data['message'] ?? response.body}');
      }
    } catch (e) {
      print('Error during Category deletion: $e');
      rethrow;
    }
  }

//  int totalPages = 1; // Store total pages globally
  Future<List<Map<String, dynamic>>> fetchsupplier(
      {int page = 1, int limit = 10}) async {
    final url = '$baseUrl/supplier/sup_all_pagination?page=$page&limit=$limit';
    // print('dfg: supplier');
    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('asd: $data');
        // totalPages = data["totalPages"];
        final supplier = data["data"] as List;
        print("Fetched Users: $supplier");

        return supplier.map((supplier) {
          return {
            "supplier_id": supplier["supplier_id"]?.toString(),
            "company_name": supplier["company_name"] ?? "Unknown",
            "phone_number":
                supplier["phone_number"]?.toString() ?? "No Contact",
            "email": supplier["email"]?.toString() ?? "No Email",
            "address": supplier["address"] ?? "No Address",
            "supplier_gst_number":
                supplier["supplier_gst_number"]?.toString() ?? "No GST",
            "postal_code":
                supplier["postal_code"]?.toString() ?? "No Postal Code",
            "country": supplier["country"]?.toString() ?? "No Country",
            "state": supplier["state"]?.toString() ?? "No State",
            "city": supplier["city"]?.toString() ?? "No City",
            "status": supplier["status"]?.toString() ?? "Inactive",
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  // create supplier//
  Future<bool> createSupplier(Map<String, dynamic> supplierData) async {
    final url = '$baseUrl/supplier/sup_insert';
    final body = supplierData;

    try {
      final response = await _makeRequest(url, 'POST', body: body);

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> updateSupplier(
      String supplier_id, Map<String, dynamic> updatedSupplier) async {
    final url = '$baseUrl/supplier/sup_update/$supplier_id';

    print("Updating supplier ID: $supplier_id");
    print("Request URL: $url");
    print("Updated Data: $updatedSupplier");

    try {
      final response = await _makeRequest(
        url.toString(),
        'PUT',
        body: updatedSupplier,
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update supplier: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating supplier: $e');
      return false;
    }
  }

  // delete supplier//
  Future<void> deleteSupplierFromApi(
      String supplier_id, VoidCallback onDelete) async {
    final Uri url = Uri.parse('$baseUrl/supplier/sup_del/$supplier_id');

    try {
      final response =
          await _makeRequest(url.toString(), "DELETE"); // Direct delete request

      if (response.statusCode == 200) {
        print('Supplier deleted successfully.');
        onDelete(); // Update UI after deletion
      } else {
        final data = jsonDecode(response.body);
        throw Exception(
            'Error deleting supplier: ${data['message'] ?? response.body}');
      }
    } catch (e) {
      print('Error during supplier deletion: $e');
      throw e; // Rethrow for handling in UI
    }
  }

// product list//
  Future<List<Map<String, dynamic>>> fetchProducts(
      {int page = 1, int limit = 10}) async {
    final url = '$baseUrl/products/Allpro_pagination?page=$page&limit=$limit';
    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('asd: $data');
        final productList = data["data"] as List;
        return productList.map((product) {
          return {
            "id": product["id"].toString(),
            "product_name": product["product_name"] ?? "Unknown",
            "brand_name": product["brand_name"] ?? "No Brand",
            "product_category": product["product_category"] ?? "No Category",
            "expiry_date": product["expiry_date"] ?? "No Expiry Date",
            "product_quantity": product["product_quantity"].toString(),
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch products: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

// create product //

  Future<bool> createProduct(Map<String, dynamic> productData) async {
    final url = '$baseUrl/products/inproduct';
    final body = productData;
    print('Requt Body: $body');

    try {
      final response = await _makeRequest(url, 'POST', body: body);

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // Fetch Supplier Names
  Future<List<String>> fetchSupplierNames() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/products/Allpro_list'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['data'].map((s) => s['supplier']));
      } else {
        throw Exception('Failed to load supplier names');
      }
    } catch (e) {
      print("Error fetching suppliers: $e");
      return [];
    }
  }

// supplier name only list page //
  Future<List<Map<String, dynamic>>> fetchsuppliers() async {
    final url = '$baseUrl/supplier/sup_all'; // Ensure the correct URL is used
    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final supplierList = data as List; // Ensure this is a list
        print("Fetched Suppliers: $supplierList");

        // Ensure the data is structured correctly before mapping
        return supplierList.map((supplier) {
          return {
            "supplier_id": supplier["supplier_id"]?.toString() ?? "0",
            "company_name": supplier["company_name"]
                .toString(), // Handle missing company names
            "phone_number": supplier["phone_number"] ?? "No Contact",
            "email": supplier["email"] ?? "No Email",
            "address": supplier["address"] ?? "No Address",
            "supplier_gst_number": supplier["supplier_gst_number"] ?? "No GST",
            "status": supplier["status"] ?? "Inactive",
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch suppliers: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching ddsuppliers: $e");
      return [];
    }
  }

//categroy only list page //
  Future<List<Map<String, String>>> fetchCategories() async {
    final url =
        '$baseUrl/pro_category/all_category'; // Fetch all categories (no pagination)
    print('Fetching: $url');

    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final category = data as List;
        return category.map((cat) {
          return {
            "id": cat["id"]?.toString() ?? "0",
            "category_name": cat["category_name"]?.toString() ?? "",
            "description": cat["description"]?.toString() ?? "",
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch categories: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> ViewProducts(String productId) async {
    final url =
        '$baseUrl/products/proByid/$productId'; // Replace with your actual API URL
    print('url: $url');

    try {
      final response = await _makeRequest(url, 'GET');

      if (response.statusCode == 200) {
        print('Product fetched successfully');
        return json.decode(response.body)['data']; // Return the product data
      } else {
        print(
            'Failed to fetch product: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  Future<bool> updateProducts(
      String productId, Map<String, dynamic> data) async {
    final url = '$baseUrl/products/productput/$productId';

    try {
      final response = await _makeRequest(
        url.toString(),
        'PUT',
        body: data,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Failed to update product: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> uploadProductFile(String filePath) async {
    final url = '$baseUrl/products/import';
    try {
      final token = await getTokenFromStorage();
      var request = http.MultipartRequest('POST', Uri.parse(url));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType('application',
            'vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
      ));

      print('Uploading file: $filePath');
      print('Request headers: ${request.headers}');

      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to upload product file: ${response.body}');
      }
    } catch (e) {
      print('Error during file upload: $e');
      throw Exception('Error during file upload: $e');
    }
  }

  // delete products //
  // delete supplier//
  Future<void> deleteProductsFromApi(
      String product_id, VoidCallback onDelete) async {
    final Uri url = Uri.parse('$baseUrl/products/soft-delete/$product_id');

    try {
      final response =
          await _makeRequest(url.toString(), "DELETE"); // Direct delete request

      if (response.statusCode == 200) {
        print('Supplier deleted successfully.');
        onDelete(); // Update UI after deletion
      } else {
        final data = jsonDecode(response.body);
        throw Exception(
            'Error deleting supplier: ${data['message'] ?? response.body}');
      }
    } catch (e) {
      print('Error during supplier deletion: $e');
      throw e; // Rethrow for handling in UI
    }
  }

  Future<List<Map<String, dynamic>>> fetchShops() async {
    final url = '$baseUrl/shop/getAll/';
    print('Fetching from: $url');

    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Ensure we get the correct list from the API response
        if (data is Map<String, dynamic> && data.containsKey('shops')) {
          final List<dynamic> shopList = data['shops'];
          print('vbn:$shopList');
          return shopList.map((shop) {
            return {
              "shop_id": shop["shop_id"]?.toString() ?? "0",
              "pharmacy_name": shop["pharmacy_name"] ?? "No Name",
              "description": shop["description"] ?? "No Description",
              "pincode": shop["pincode"] ?? "No Pincode",
              "pharmacy_address": shop["pharmacy_address"] ?? "No Address",
              "owner_GST_number": shop["owner_GST_number"] ?? "No GST",
              "allow_registration":
                  shop["allow_registration"] ?? "Not Registered",
            };
          }).toList();
        } else {
          print('Unexpected API response structure');
          return [];
        }
      } else {
        throw Exception('Failed to fetch Profile: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching Profile: $e");
      return [];
    }
  }

  Future<bool> updateprofile(
      String shopId, Map<String, dynamic> updatedProfile) async {
    print('hjl:$updatedProfile');
    final url =
        '$baseUrl/shop/update/$shopId'; // Ensure shopId is passed in URL
    print("Updating shop with data: $shopId");

    try {
      final response = await _makeRequest(
        url.toString(),
        'PUT', // or 'PATCH' based on API
        body: updatedProfile,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Failed to update shop: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating shop: $e');
      return false;
    }
  }

// expense page list//
  Future<List<Map<String, dynamic>>> fetchExpense(
      {int page = 1, int limit = 10}) async {
    final url =
        '$baseUrl/expense/pagination_expence?page=$page&limit=$limit'; // Fetch all expenses
    print('Fetching: $url');

    try {
      final response = await _makeRequest(url, 'GET');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          totalPages = data['total_page'] ?? 1;
          return (data['data'] as List).map((exp) {
            return {
              "id": exp["id"]?.toString() ?? "0",
              "category": exp["category"] ?? "",
              "amount": exp["amount"] ?? 0,
              "date": exp["date"] ?? "",
              "description": exp["description"] ?? "",
            };
          }).toList();
        } else {
          throw Exception('Invalid data format received');
        }
      } else {
        throw Exception('Failed to fetch expenses: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching expenses: $e");
      return [];
    }
  }

// expense create//
  Future<bool> createExpense(Map<String, dynamic> expensedata) async {
    final url = '$baseUrl/expense/expensesinsert';
    final body = expensedata;
    print('Requegfhfst Body: $body');

    try {
      final response = await _makeRequest(url, 'POST', body: body);

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

// Future<bool> updateExpense(
//       String expenseId, Map<String, dynamic> updatedexpense) async {
//     final Uri url = Uri.parse(
//         '$baseUrl/expense/expensesedit/$expenseId'); // Include userId in the URL
//     print("Updated Task Data: $updatedexpense");

//     try {
//       final response = await _makeRequest(
//         url.toString(),
//         'PUT', // Use 'PUT' or 'PATCH' based on your API
//         body: updatedexpense, // Send the body as JSON
//       );

//       if (response.statusCode == 200) {
//         return true; // Successfully updated
//       } else {
//         print(
//             'Failed to update user: ${response.statusCode}, ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       print('Error updating user: $e');
//       return false;
//     }
//   }

//   Future<void> deleteExpense(
//       String expenseId, VoidCallback onDelete) async {
//     final url = ('$baseUrl/shop/del_category/$expenseId');

//     try {
//       final response = await _makeRequest(url.toString(), "DELETE");

//       if (response.statusCode == 200) {
//         print('expense deleted successfully.');
//         onDelete(); // Update UI after deletion
//       } else {
//         final data = jsonDecode(response.body);
//         throw Exception(
//             'Error deleting expense: ${data['message'] ?? response.body}');
//       }
//     } catch (e) {
//       print('Error during expense deletion: $e');
//       rethrow;
//     }
//   }

// Invoice list page //
  Future<List<Map<String, dynamic>>> fetchInvoices(
      {int page = 1, int limit = 10}) async {
    final url =
        '$baseUrl/invoice/invoiceall_pagination?page=$page&limit=$limit';
    print('Fetching: $url');

    try {
      final response = await _makeRequest(url, 'GET');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          // Update total pages in ApiService
          totalPages = data['total_page'] ?? 1;

          return (data['data'] as List).map((inv) {
            return {
              "id": inv["id"]?.toString() ?? "0",
              "invoice_number": inv["invoice_number"] ?? "",
              "invoice_created_at": inv["invoice_created_at"] ?? "",
              "total_price": inv["total_price"]?.toString() ?? "0.0",
              "payment_status": inv["payment_status"] ?? "Unknown",
              "payment_method": inv["payment_method"]?? "Unknown",
              "customer_name": inv["customer_name"] ?? "N/A",
              "totalGST": inv["totalGST"]?.toString() ?? "0.0",
              "products": inv["products"]?.toString() ?? "No products",
              "customer_id": inv["customer_id"]?.toString() ?? "N/A",
              "finalPriceWithGST":
                  inv["finalPriceWithGST"]?.toString() ?? "0.0",
              "final_price": inv["final_price"]?.toString() ?? "0.0",
              "discount": inv["discount"]?.toString() ?? "0.0",
              "product_id": inv["product_id"]?.toString() ?? "N/A",
              "quantity": inv["quantity"]?.toString() ?? "0",
            };
          }).toList();
        } else {
          throw Exception('Invalid data format received');
        }
      } else {
        throw Exception('Failed to fetch Invoices: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching invoices: $e");
      return [];
    }
  }

// billing search query //
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final url = "$baseUrl/products/filter_pro?search=$query";
    try {
      final response = await _makeRequest(url, 'GET');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final billingList = data["data"] as List;
        print('jkl:$billingList');
        return billingList.map((product) {
          return {
            'id': product['id'], // Ensure 'id' exists
            'name': product["product_name"]?.toString() ?? "Unknown",
            'quantity': product["product_quantity"]?.toString() ?? "0",
            'batchNo': product["product_batch_no"]?.toString() ?? "N/A",
            'expiryDate':
                product["expiry_date"]?.toString() ?? "No Expiry Date",
            'mrp': double.tryParse(product["product_price"].toString()) ?? 0.0,
            'gst': double.tryParse(product["GST"]?.toString() ?? "0.0") ??
                0.0, // Fix GST parsing
            'sellingPrice':
                double.tryParse(product["selling_price"].toString()) ?? 0.0,
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

// invoice create //
  Future<bool> createInvoice(Map<String, dynamic> invoiceData) async {
    final url = '$baseUrl/invoice/invoicesin';
    final body = invoiceData;

    try {
      final response = await _makeRequest(url, 'POST', body: body);

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSupplierInvoices({
    required String supplierId,
    int page = 1,
    int limit = 10,
  }) async {
    if (supplierId.isEmpty) {
      print("Error: supplierId is missing!");
      return [];
    }

    final url =
        '$baseUrl/supplier_invoice/$supplierId/invoices?page=$page&limit=$limit';
    print('Fetching invoices for supplier: $supplierId');
    print('URL: $url');

    try {
      final response = await _makeRequest(url, 'GET');

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          totalPages = data['pagination']['total_pages'] ?? 1;

          return (data['data'] as List).map((sinv) {
            return {
              "supplier_id": sinv["supplier_id"]?.toString() ?? "0",
              "invoice_id": sinv["invoice_id"]?.toString() ?? "0",
              "supplier_bill_no": sinv["supplier_bill_no"] ?? "",
              "invoice_bill_date": sinv["invoice_bill_date"] ?? "",
              "bill_amount": sinv["bill_amount"]?.toString() ?? "0.0",
              "balance_bill_amount": sinv["balance_bill_amount"] ?? "Unknown",
              "due_date": sinv["due_date"] ?? "N/A",
              "created_at": sinv["created_at"]?.toString() ?? "0.0",
              "status": sinv["status"]?.toString() ?? "No Status",
            };
          }).toList();
        } else {
          throw Exception('Invalid data format received');
        }
      } else if (response.statusCode == 404) {
        print('No invoices found for this supplier.');
        return [];
      } else {
        throw Exception(
            'Failed to fetch Invoices: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print("Error fetching invoices: $e");
      return [];
    }
  }

// create supplier invoice//
  Future<String?> supplierInvoice(
      Map<String, dynamic> invoicesupplierdata) async {
    final url = '$baseUrl/supplier_invoice/invoices';
    try {
      final response =
          await _makeRequest(url, 'POST', body: invoicesupplierdata);

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Ensure correct type handling
        final invoiceId = responseData['invoiceId'];
        if (invoiceId != null) {
          return invoiceId.toString(); // Ensure String type
        }
      }

      print("Failed: ${response.body}");
      return null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<bool> addPayment(Map<String, dynamic> paymentData) async {
    final url = '$baseUrl/supplier_invoice/payments';
    try {
      final response = await _makeRequest(url, 'POST', body: paymentData);

      if (response.statusCode == 201) {
        return true;
      }

      print("Payment Failed: ${response.body}");
      return false;
    } catch (e) {
      print("Error adding payment: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMostSoldMedicines({
    // required String startDate,
    // required String endDate,
    String period = 'week',
  }) async {
    final queryParams = {
      'period': period,
      // 'start_date': startDate,
      // 'end_date': endDate,
    };

    final url = Uri.parse('$baseUrl/invoice/most_sold_details')
        .replace(queryParameters: queryParams);

    print("Making GET request to: $url");

    try {
      final response = await _makeRequest(url.toString(), 'GET');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Response Data: $responseData');

        if (responseData.containsKey('data') && responseData['data'] is List) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          throw Exception("Invalid response format: Missing 'data' field");
        }
      } else {
        print("Request failed with status: \${response.statusCode}");
        print("Response body: \${response.body}");
        throw Exception("Failed to fetch most sold medicines");
      }
    } catch (e) {
      print("Error occurred: \$e");
      throw Exception("Error hhhhhh most sold medicines");
    }
  }
// most sold medicine table//

  Future<List<Map<String, dynamic>>> fetchSalesByDate({
    required String fromDate,
    required String toDate,
      String? search,
    String? productName,
    // String? categoryName,
    int page = 1,
    int limit = 10,
  }) async {
    final url = '$baseUrl/invoice/pagination_sales?'
        'startDate=$fromDate&endDate=$toDate'
        '&productName=${productName ?? ""}'
        // '&categoryName=${categoryName ?? ""}'
        '&page=$page&limit=$limit';
    print("GET Request: $url");

    try {
        final Map<String, String> queryParams = {};
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(responseData['data']);
      } else {
        throw Exception("Failed to fetch sales data");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error fetching sales data");
    }
  }
  
Future<Map<String, dynamic>?> createBill(Map<String, dynamic> payload) async {
  final url = '$baseUrl/invoice/invoicesin';
  print("Making POST request to: $url");

  try {
    final response = await _makeRequest(url, 'POST', body: payload);

    if (response.statusCode == 201) {
      print("Invoice created: ${response.body}");
      return jsonDecode(response.body); // Return full response
    } else {
      print("Failed: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error: $e");
    return null;
  }
}

// return create //
  Future<bool> createReturn(Map<String, dynamic> returnData) async {
    final url = '$baseUrl/return/return_product';
    print('Sending data: $returnData');

    try {
      final response = await _makeRequest(url, 'POST', body: returnData);
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Return created successfully');
        return true;
      } else {
        print('Failed to create return: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during return creation: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getProductsByInvoice(
      String invoiceNumber) async {
    final url = '$baseUrl/invoice/invoice/$invoiceNumber';
    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        print('API Response: $decodedData');

        if (decodedData is Map<String, dynamic> &&
            decodedData.containsKey('products') &&
            decodedData.containsKey('invoice_id')) {
          return {
            'invoice_id': decodedData['invoice_id'].toString(),
            'products': (decodedData['products'] as List<dynamic>).map((item) {
              return {
                'product_id': item['product_id']?.toString() ?? "0",
                'product_name': item['product_name'] ?? "Unknown Product",
                'quantity': item['quantity'] ?? 0,
              };
            }).toList(),
          };
        }

        print('Unexpected response structure: $decodedData');
        return {};
      } else {
        print('Failed to fetch products: ${response.body}');
        return {};
      }
    } catch (e) {
      print('Error fetching products: $e');
      return {};
    }
  }

  // csv and pdf file download //
Future<void> exportCSVReport(String fromDate, String toDate) async {
  final url = '$baseUrl/invoice/sales-report/csv?startDate=$fromDate&endDate=$toDate';
    try {
      final response = await _makeRequest(
        url,
        'GET',
      );

      await _saveAndOpenFile(response.bodyBytes, 'sales_report.csv');
    } catch (e) {
      print("Error exporting CSV: $e");
      rethrow;
    }
  }

  Future<void> exportPDFReport(String fromDate, String toDate) async {
    final url = '$baseUrl/invoice/sales-report/pdf?startDate=$fromDate&endDate=$toDate';
    try {
      final response = await _makeRequest(
        url,
        'GET',
      );

      await _saveAndOpenFile(response.bodyBytes, 'sales_report.pdf');
    } catch (e) {
      print("Error exporting PDF: $e");
      rethrow;
    }
  }

  Future<void> _saveAndOpenFile(List<int> bytes, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);

    await file.writeAsBytes(bytes);
    print('File saved to: $filePath');

    OpenFile.open(filePath); // Automatically open the file
  }

  // return list page //
  Future<List<Map<String, dynamic>>> fetchReturns(
      {int page = 1, int limit = 10}) async {
    final url =
        '$baseUrl/return/getAll_rejectedInvoices?page=$page&limit=$limit';
    print('Fetching: $url');

    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          totalPages = data['total_page'] ?? 1;
          return (data['data'] as List).map((ret) {
            return {
              "invoice_id": ret["invoice_id"]?.toString() ?? "0",
              "product_name": ret["product_name"] ?? "",
              "quantity": ret["quantity"]?.toString() ?? "0",
              // "return_date": ret["return_date"] ?? "",
              "return_reason": ret["return_reason"] ?? "",
            };
          }).toList();
        } else {
          throw Exception('Invalid data format received');
        }
      } else {
        throw Exception('Failed to fetch returns: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching returns: $e");
      return [];
    }
  }

  // income page list //
  Future<Map<String, dynamic>?> fetchIncomeData(String period) async {
    try {
      final url = '$baseUrl/report/income-report?interval=$period';
      final response = await _makeRequest(url, 'GET');
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] is Map<String, dynamic>) {
        return data['data'];
      } else {
        print('API Error (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      print('API Exception: $e');
      return null;
    }
  }

  // invoice print page//
  Future<Map<String, dynamic>?> fetchInvoicePrint(String invoiceId) async {
    final url = '$baseUrl/invoice/invoicebyid/pdfdownload/$invoiceId';
    print('Fetching invoice data: $url');

    try {
      final response = await _makeRequest(url, 'GET');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('API Error (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      print('API Exception: $e');
      return null;
    }
  }

Future<List<Map<String, dynamic>>> stockProducts({
  String? status,
  String? search,
}) async {
  try {
    final Map<String, String> queryParams = {};

    if (status != null && status != 'All') {
      queryParams['status'] = status;
    }

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final Uri url = Uri.parse('$baseUrl/products/stock_list_product')
        .replace(queryParameters: queryParams);

    print("Requesting URL: $url"); // Debugging: Check the full URL

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['data'] == null) return [];

      final productList = data['data'] as List;

      print("Fetched Products: $productList"); // Debugging output

      return productList.map((product) {
        return {
          "id": product["id"].toString(),
          "product_name": product["product_name"] ?? "Unknown",
          "stock_status": product["stock_status"] ?? "No Status",
          "product_category": product["product_category"] ?? "No Category",
          "expiry_date": product["expiry_date"] ?? "No Expiry Date",
          "product_quantity": product["product_quantity"].toString(),
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch products: ${response.reasonPhrase}');
    }
  } catch (e) {
    print("Error fetching products: $e");
    return [];
  }
}


// fetched deleted products//
  int pages = 1;
  int _totalPages = 10; // Define _totalPages
  Future<List<Map<String, String>>> fetchedDeletedProduct(
      {int page = 1, int limit = 10}) async {
    final url = '$baseUrl/products/list-soft-deleted?page=$page&limit=$limit';
    try {
      final response = await _makeRequest(url, 'GET');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _totalPages = data["totalPages"];

        return (data["data"] as List).map((del) {
          return {
            "id": del["id"]?.toString() ?? "",
            "product_name": del["product_name"]?.toString() ?? "",
            "product_category": del["product_category"]?.toString() ?? "",
            "supplier_name": del["supplier_name"]?.toString() ?? "",
            "brand_name": del["brand_name"]?.toString() ?? "",
            "created_at": del["created_at"]?.toString() ?? "",
            "deleted_at": del["deleted_at"]?.toString() ?? "",
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch deleted products');
      }
    } catch (e) {
      print("Error fetching deleted products: $e");
      return [];
    }
  }

  Future<bool> restoreDeletedProduct(String productId) async {
    final url = '$baseUrl/products/restore/$productId';
    try {
      print('Restoring deleted product: $url');
      final response = await _makeRequest(url, 'PUT',
          body: {}); // Use POST and pass an empty body
      print('Restore Response: ${response.body}');

      if (response.statusCode == 200) {
        print('Product restored successfully');
        return true;
      } else {
        print('Failed to restore product: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error restoring product: $e');
      return false;
    }
  }

// permaanently delete product//
  Future<bool> permanentlyDeleteProduct(String productId) async {
    final url = '$baseUrl/products/permanent-delete/$productId';

    try {
      print('Deleting product permanently: $url');
      final response = await _makeRequest(url, 'DELETE');
      print('Delete Response: ${response.body}');

      if (response.statusCode == 200) {
        print('Product deleted permanently successfully');
        return true;
      } else {
        print('Failed to delete product permanently: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting product permanently: $e');
      return false;
    }
  }
// Fetch the invoice PDF from the server
Future<File?> fetchInvoicePrints(String invoiceId) async {
  final url = '$baseUrl/invoice/invoicebyid/pdfdownload/$invoiceId';
  print('📄 Fetching invoice PDF from: $url');

  try {
    final response = await _makeRequest(url, 'GET');

    if (response.statusCode == 200) {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/invoice_$invoiceId.pdf");
      await file.writeAsBytes(response.bodyBytes);
      print('✅ PDF saved to: ${file.path}');
      return file;
    } else {
      print('❌ API Error (${response.statusCode}): ${response.body}');
      return null;
    }
  } catch (e) {
    print('❌ API Exception: $e');
    return null;
  }
}

  // stock report//
  
Future<void> exportedCSVReport(String status) async {
  final url = '$baseUrl/products/downloadStockCSV?status=$status&downloadStockCSV=true';
  try {
    final response = await _makeRequest(url, 'GET');
    await _saveAndOpenFiles(response.bodyBytes, 'stock_report.csv');
  } catch (e) {
    print("Error exporting CSV: $e");
    rethrow;
  }
}

Future<void> exportedPDFReport(String status) async {
  final url = '$baseUrl/products/downloadStockPDF?status=$status&downloadStockPDF=true';
  try {
    final response = await _makeRequest(url, 'GET');
    await _saveAndOpenFiles(response.bodyBytes, 'stock_report.pdf');
  } catch (e) {
    print("Error exporting PDF: $e");
    rethrow;
  }
}

Future<void> _saveAndOpenFiles(List<int> bytes, String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$filename';
  final file = File(filePath);

  await file.writeAsBytes(bytes);
  print('File saved to: $filePath');

  OpenFile.open(filePath); // Automatically open the file
}


// view category//
Future<Map<String, dynamic>?> ViewCategory(String categoryId) async {
  final url = '$baseUrl/pro_category/id_category/$categoryId';
  print('URL: $url');

  try {
     final response = await _makeRequest(
        url,
        'GET',
      );

    if (response.statusCode == 200) {
      print('Category fetched successfully');
      return json.decode(response.body); // Ensure 'data' is returned
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error fetching category: $e');
    return null;
  }
}   
   
//search category//
Future<List<Map<String, dynamic>>> searchCategory(String query) async {
  final url = "$baseUrl/pro_category/categories?search=$query";
  try {
    final response = await _makeRequest(url, 'GET');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final categoryList = data["data"] as List;
      print('jkl:$categoryList');
      return categoryList.map((category) {
        return {
          'id': category['id'], // Ensure 'id' exists
          'category_name': category["category_name"]?.toString() ?? "Unknown",
          'description': category["description"]?.toString() ?? "",
        };
      }).toList();
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }

}
// sales amount //
Future<Map<String, dynamic>?> getTotalInvoiceAmount(String period) async {
    try {
      final url = '$baseUrl/invoice/invoice_total_amount';
      final response = await _makeRequest(url, 'GET');
      final data = jsonDecode(response.body);
      if (data['success'] == true && data is Map<String, dynamic>) {
        return data;
      } else {
        print('API Error (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      print('API Exception: $e');
      return null;
    }
  }

// customer count//
Future<Map<String, dynamic>?> getTotalCustomerCount(String period) async {
  try {
    final url = '$baseUrl/customer/cus_total_count';
    final response = await _makeRequest(url, 'GET');
    final data = jsonDecode(response.body);

    print('API Response: $data'); // Debugging the response

    // ✅ Ensure the response is valid and contains the expected key
    if (data != null && data is Map<String, dynamic> && data.containsKey('total_customers')) {
      return data; // Return valid data
    } else {
      print('Unexpected API Response: $data'); // Log unexpected responses
      return null;
    }
  } catch (e) {
    print('API Exception: $e');
    return null;
  }
}




}