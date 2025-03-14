import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/dashboard/persistent_bottom_nav_bar.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InvoiceList(),
    );
  }
}

class InvoiceList extends StatefulWidget {
  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  List<Map<String, dynamic>> invoices = [];
  List<Map<String, String>> categories = [];
  late final String invoiceId;
  List<Map<String, String>> filteredinvoice = [];
  List<Map<String, String>> invoicelist = [];
  final ScrollController _scrollController = ScrollController();
  final ApiService apiService = ApiService();
  TextEditingController searchController = TextEditingController();
  bool _isFetchingMore = false;
  bool _isSearching = false;
  int _currentPage = 1;
  final int _limit = 10; // Number of items per page
  bool _isLoading = false;
  bool _hasMore = true; // Track if more data is available


  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  @override
  void initState() {
    super.initState();
    fetchInvoices();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          setState(() {
            _currentPage++;
          });
          fetchInvoices(isLoadMore: true);
        }
      }
    });
  }

  void filterCategories(String query) {
    setState(() {
      filteredinvoice = categories
          .where((category) =>
              category['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> fetchInvoices({bool isLoadMore = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedInvoices =
          await apiService.fetchInvoices(page: _currentPage, limit: _limit);

      setState(() {
        if (isLoadMore) {
          invoices.addAll(fetchedInvoices); // Add new invoices if loading more
        } else {
          invoices = fetchedInvoices; // Replace invoices if fetching new page
        }

        _isLoading = false;
        _isFetchingMore = false;
        _hasMore =
            fetchedInvoices.length == _limit; // Check if more data is available
      });
    } catch (e) {
      print('Error fetching invoices: $e');
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

void _handlePrint(BuildContext context, String? invoiceId) async {
  print('Printing invoice with ID: $invoiceId');
  if (invoiceId == null || invoiceId.isEmpty) {
    _showSnackBar(context, 'Error: Invoice ID is empty');
    return;
  }

  try {
    final pdfFile = await apiService.fetchInvoicePrints(invoiceId);
    if (pdfFile != null) {
      await Printing.sharePdf(bytes: await pdfFile.readAsBytes(), filename: 'invoice.pdf');
    } else {
      _showSnackBar(context, 'Failed to fetch invoice. Invalid ID.');
    }
  } catch (e) {
    print('Error: $e');
    _showSnackBar(context, 'Error: $e');
  }
}

  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
 

  void _showInvoiceDetails(BuildContext context, Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            'Invoice Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF028090),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildDetailRow('Invoice No:', invoice['invoice_number']),
              _buildDetailRow(
                  'Date:', formatDate(invoice['invoice_created_at'])),
              _buildDetailRow('Amount:', '\$${invoice['total_price']}'),
              _buildDetailRow('Status:', invoice['payment_status']),
              _buildDetailRow('Payment Method:', invoice['payment_method']),
              _buildDetailRow('Customer:', invoice['customer_name']),
              _buildDetailRow('Total GST:', '\$${invoice['totalGST']}'),
              _buildDetailRow('Products:', invoice['products']),
              _buildDetailRow('Customer ID:', invoice['customer_id']),
              _buildDetailRow(
                  'Final Price (GST):', '\$${invoice['finalPriceWithGST']}'),
              _buildDetailRow('Final Price:', '\$${invoice['final_price']}'),
              _buildDetailRow('Discount:', '\$${invoice['discount']}'),
              _buildDetailRow('Product ID:', invoice['product_id']),
              _buildDetailRow('Quantity:', invoice['quantity'].toString()),
            ],
          ),
          
        ),
        actions: [
          TextButton.icon(
             onPressed: () => _handlePrint(context, invoice['id'].toString()),
            icon: Icon(Icons.print, color: Color(0xFF028090)),
            label: Text('Print', style: TextStyle(color: Color(0xFF028090))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

// Helper widget to build styled rows
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value != null ? value.toString() : '-',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printInvoice(Map<String, dynamic> invoice) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Invoice Number: ${invoice['invoice_number']}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('Customer: ${invoice['customer_name'] ?? 'N/A'}'),
          pw.SizedBox(height: 10),
          pw.Text('Products:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...invoice['products']?.map<pw.Widget>((product) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(product['product_name'] ?? '-'),
                    pw.Text('Qty: ${product['product_quantity'] ?? '0'}'),
                    pw.Text('Price: \$${product['total_product_price'] ?? '0.00'}'),
                  ],
                );
              }).toList() ??
              [],
          pw.SizedBox(height: 10),
          pw.Text('GST: ${invoice['gst'] ?? 0.0}%'),
          pw.Text('Total Amount: \$${invoice['finalPriceWithGST'] ?? 0.0}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/invoice_${invoice['invoice_number']}.pdf");
  await file.writeAsBytes(await pdf.save());

  await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice.pdf');
}


  Color getStatusColor(String status) {
    return status.toLowerCase() == 'paid' ? Colors.green : Colors.red;
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
            backgroundColor: Color(0xFF028090),
            title: _isSearching
                ? Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                      border: Border.all(
                          color: Colors.grey, width: 1), // Border color
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: filterCategories,
                      decoration: InputDecoration(
                        hintText: 'Search Invoice...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                      ),
                      style: TextStyle(color: Colors.black),
                      cursorColor: Color(0xFF028090),
                    ),
                  )
                : Text(
                    'Invoice Details',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => PersistentBottomNavBar()),
                );
              },
            ),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.cancel : Icons.search,
                    color: Colors.black),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      searchController.clear();
                      filterCategories('');
                    }
                  });
                },
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 20,
                            headingRowHeight: 56,
                            dataRowHeight: 56,
                            border: TableBorder.all(color: Colors.black),
                            columns: [
                              DataColumn(
                                  label: Text('S.No',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Invoice No',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Date',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Amount',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Status',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                                           DataColumn(
                                  label: Text('Payment Method',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Action',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                            ],
                            rows: invoices.map((invoice) {
                              int index = invoices.indexOf(invoice);
                              return DataRow(
                                cells: [
                                  DataCell(Text(
                                      '${(_currentPage - 1) * _limit + index + 1}')), // Cor
                                  DataCell(
                                      Text(invoice['invoice_number'] ?? '')),
                                  DataCell(Text(formatDate(
                                      invoice['invoice_created_at']))),

                                  DataCell(Text('\$${invoice['total_price']}')),
                                  DataCell(Text(
                                    invoice['payment_status'] ?? '',
                                    style: TextStyle(
                                        color: getStatusColor(
                                            invoice['payment_status'])),
                                  )),
                                   DataCell(Text(
                                    invoice['payment_method'] ?? '',
                                    style: TextStyle(
                                      ),
                                  )),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.remove_red_eye),
                                      onPressed: () =>
                                          _showInvoiceDetails(context, invoice),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: _currentPage > 1 ? Colors.blue : Colors.grey),
                      onPressed: _currentPage > 1 && !_isLoading
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                              fetchInvoices();
                            }
                          : null,
                    ),
                    Text("Page $_currentPage",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.arrow_forward,
                          color: _hasMore ? Colors.blue : Colors.grey),
                      onPressed: _hasMore && !_isLoading
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                              fetchInvoices();
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
