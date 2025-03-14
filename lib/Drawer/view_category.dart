// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/API_Service/api_service.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// class ViewCategory extends StatefulWidget {
//   final String categoryId;
//   final Map<String, dynamic> categories;

//   ViewCategory({required this.categoryId, required this.categories});

//   @override
//   _ViewCategoryPageState createState() => _ViewCategoryPageState();
// }

// class _ViewCategoryPageState extends State<ViewCategory> {
//   Map<String, dynamic>? categories;
//   bool isLoading = true;
//   bool isError = false;
//   final ApiService apiService = ApiService();

//   @override
//   void initState() {
//     super.initState();
//     fetchCategoryDetails();
//   }

//   Future<void> fetchCategoryDetails() async {
//     try {
//       final fetchedCategory = await apiService.ViewCategory(widget.categoryId);

//       if (fetchedCategory != null) {
//         setState(() {
//           categories = fetchedCategory; // Update the category data
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isError = true;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isError = true;
//         isLoading = false;
//       });
//       print('Error fetching category: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Category Details'),
//         centerTitle: true,
//         backgroundColor: Color(0xFF028090),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : isError
//               ? Center(child: Text('Error fetching category details'))
//               : _buildCategoryDetails(),
//     );
//   }

//   Widget _buildCategoryDetails() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 5,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildDetailRow('ID', categories?['id']),
//                 _buildDetailRow('Category Name', categories?['category_name']),
//                 _buildDetailRow('Description', categories?['description']),
//                 SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF028090),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                     child: Text('Close'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String title, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$title:',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               value?.toString() ?? 'N/A',
//               style: TextStyle(fontSize: 18),
//               // overflow: TextOverflow.ellipsis,
//               maxLines: 2,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
