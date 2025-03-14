import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/Drawer/supplier_invoice_form.dart';
import 'package:flutter_application_1/bottom_items/staff_page.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: (),
    );
  }
}

InputDecoration CustomInputDecoration(String label, {Widget? suffixIcon}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.black),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1.0),
      borderRadius: BorderRadius.circular(20.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1.0),
      borderRadius: BorderRadius.circular(20.0),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1.0),
      borderRadius: BorderRadius.circular(20.0),
    ),
    suffixIcon: suffixIcon,
  );
}

Future<void> _selectDate(
    BuildContext context, TextEditingController controller) async {
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Colors.blue,
          colorScheme: ColorScheme.light(primary: Colors.blue),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      );
    },
  );
  if (picked != null) {
    controller.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
  }
}

// Function to call the payment API
Future<void> submitPayment(String invoiceId, double paymentAmount, String paymentDate) async {
  try {
    final paymentData = {
      'invoiceId': invoiceId,
      'paymentAmount': paymentAmount,
      'paymentDate': paymentDate,
    };

    final success = await ApiService().addPayment(paymentData);

    if (success) {
      print('Payment added successfully');
    } else {
      print('Error adding payment');
    }
  } catch (e) {
    print('Exception during payment submission: $e');
  }
}

String formatDate(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    return DateFormat('dd-MM-yyyy').format(date);
  } catch (e) {
    return dateString; // Return original if parsing fails
  }
}



void _openAmountDateForm(BuildContext context, Map<String, dynamic> invoice, Function updateInvoice) {
  final TextEditingController newAmountController = TextEditingController();
  final TextEditingController newDateController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Enter Payment Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: newAmountController,
              decoration: CustomInputDecoration("Amount"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: newDateController,
              decoration: CustomInputDecoration(
                "Date",
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    await _selectDate(context, newDateController);
                  },
                ),
              ),
              readOnly: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              double enteredAmount = double.tryParse(newAmountController.text) ?? 0.0;
              double balance = invoice["balance"] ?? 0.0;

              if (enteredAmount > 0) {
                await submitPayment(invoice["invoice_id"].toString(), enteredAmount, newDateController.text);

                if (enteredAmount == balance) {
                  invoice["balance"] = 0.0;
                  invoice["status"] = "Paid";
                }

                updateInvoice();
                Navigator.pop(context);
              }
            },
            child: Text("Submit"),
          ),
        ],
      );
    },
  );
}


class SupplierInvoiceList extends StatefulWidget {
  final String supplierId;

  const SupplierInvoiceList({required this.supplierId, Key? key})
      : super(key: key);

  @override
  _SupplierInvoiceListState createState() => _SupplierInvoiceListState();
}

class _SupplierInvoiceListState extends State<SupplierInvoiceList> {
  List<Map<String, dynamic>> supplierInvoices = [];
  final ScrollController _scrollController = ScrollController();

  final ApiService apiService = ApiService();
  int _currentPage = 1;
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  void _updateInvoices() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchSupplierInvoices();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          setState(() {
            _currentPage++;
          });
          fetchSupplierInvoices(isLoadMore: true);
        }
      }
    });
  }

  Future<void> fetchSupplierInvoices({bool isLoadMore = false}) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final fetchedInvoices = await apiService.fetchSupplierInvoices(
        supplierId: widget.supplierId,
        page: _currentPage,
        limit: _limit,
      );

      setState(() {
        if (isLoadMore) {
          supplierInvoices.addAll(fetchedInvoices);
        } else {
          supplierInvoices = fetchedInvoices;
        }
        _isLoading = false;
        _hasMore = fetchedInvoices.length == _limit;
      });
    } catch (e) {
      print('Error fetching supplier invoices: $e');
      setState(() => _isLoading = false);
    }
  }

  void _loadMore() {
    if (_hasMore && !_isLoading) {
      setState(() => _currentPage++);
      fetchSupplierInvoices(isLoadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Invoice Details"), backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      content: Container(
                        width: double.maxFinite,
                        child: InvoiceForm(
                            supplierId:
                                widget.supplierId), // Pass supplierId here
                      ),
                    );
                  },
                );
              },
              child: Text("Create Invoice"),
              style: ElevatedButton.styleFrom(
                elevation: 5.0,
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder.all(color: Colors.black, width: 1),
                    columns: [
                      DataColumn(label: Text("Invoice ID")),
                      DataColumn(label: Text("Bill No")),
                      DataColumn(label: Text("Date")),
                      DataColumn(label: Text("Total Bill Amount")),
                      DataColumn(label: Text("Balance")),
                      DataColumn(label: Text("Due Date")),
                      DataColumn(label: Text("Payment Date")),
                      DataColumn(label: Text("Status")),
                    ],
                    rows: supplierInvoices.map((invoice) {
                      return DataRow(
                        cells: [
                          DataCell(Text(invoice["invoice_id"].toString())),
                          DataCell(Text(invoice["supplier_bill_no"] ?? "")),
DataCell(Text(formatDate(invoice["invoice_bill_date"] ?? ""))),
                          DataCell(Text(invoice["bill_amount"].toString())),
                          DataCell(
                              Text(invoice["balance_bill_amount"].toString())),
DataCell(Text(formatDate(invoice["due_date"] ?? ""))),
     DataCell(Text(formatDate(invoice["created_at"] ?? ""))),
                          DataCell(
                            GestureDetector(
                              onTap: () {
                                if (invoice["status"] == "Pending") {
                                  _openAmountDateForm(
                                      context, invoice, _updateInvoices);
                                }
                              },
                              child: Text(
                                invoice["status"],
                                style: TextStyle(
                                  color: invoice["status"] == "Pending"
                                      ? Colors.red
                                      : Colors.green,
                                  decoration: invoice["status"] == "Pending"
                                      ? TextDecoration.underline
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  )),
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
                          fetchSupplierInvoices();
                        }
                      : null,
                ),
                Text("Page $_currentPage",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.arrow_forward,
                      color: _hasMore ? Colors.blue : Colors.grey),
                  onPressed: _hasMore && !_isLoading
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                          fetchSupplierInvoices();
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
