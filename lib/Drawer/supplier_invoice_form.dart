import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottom_items/staff_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InvoiceForm extends StatefulWidget {
  final String supplierId;
  InvoiceForm({required this.supplierId});
  @override
  _InvoiceFormState createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController idController = TextEditingController();
  final TextEditingController billNoController = TextEditingController();
  final TextEditingController descrptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  InputDecoration customInputDecoration(String label, {Widget? suffixIcon}) {
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

  @override
  void initState() {
    super.initState();
    idController.text = widget.supplierId; // Autofill Supplier ID
  }

Future<void> _submitPayment(String invoiceId, String amount, String date) async {
  final paymentData = {
    "invoiceId": invoiceId,
    "paymentAmount": double.tryParse(amount) ?? 0.0,
    "paymentDate": date,
  };

  final success = await apiService.addPayment(paymentData);

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Payment added successfully" : "Failed to add payment")),
    );
  }
}

 void _openAmountDateForm(String invoiceId) {
  showDialog(
    context: context,
    builder: (context) {
      final TextEditingController newAmountController = TextEditingController();
      final TextEditingController newDateController = TextEditingController();

      return AlertDialog(
        title: Text("Enter Payment Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: newAmountController,
              decoration: customInputDecoration("Amount"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: newDateController,
              decoration: customInputDecoration(
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
              await _submitPayment(
                invoiceId,
                newAmountController.text,
                newDateController.text,
              );
              Navigator.pop(context);
            },
            child: Text("Submit"),
          ),
        ],
      );
    },
  );
}


void _submitInvoice() async {
  if (_formKey.currentState!.validate()) {
    final invoiceData = {
      "supplierId": widget.supplierId,
      "supplierBillNo": billNoController.text,
      "description": descrptionController.text,
      "totalAmount": double.tryParse(amountController.text) ?? 0.0,
      "invoiceDate": dateController.text,
      "dueDate": dueDateController.text,
    };

    final invoiceId = await apiService.supplierInvoice(invoiceData);

    if (invoiceId != null) {
      if (!mounted) return; // Ensure context is valid

      Navigator.pop(context); // Close invoice form
      _openAmountDateForm(invoiceId); // Open payment form
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit invoice")),
        );
      }
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create Invoice",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: idController,
              decoration: customInputDecoration("Supplier ID"),
              keyboardType: TextInputType.number,
              readOnly: true, // Make the Supplier ID field non-editable
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: billNoController,
              decoration: customInputDecoration("Bill No"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter Bill No";
                }
                return null;
              },
              cursorColor: Colors.black,
            ),
            SizedBox(height: 10),
            TextFormField(
              maxLines: 4,
              controller: descrptionController,
              decoration: customInputDecoration("Description"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter Description";
                }
                return null;
              },
              cursorColor: Colors.black,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: amountController,
              decoration: customInputDecoration("Total Bill Amount"),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter Amount";
                }
                return null;
              },
              cursorColor: Colors.black,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: dateController,
              decoration: customInputDecoration(
                "Bill Date",
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, dateController),
                ),
              ),
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter Bill Date";
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: dueDateController,
              decoration: customInputDecoration(
                "Due Date",
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, dueDateController),
                ),
              ),
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter Due Date";
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitInvoice,
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    idController.dispose();
    billNoController.dispose();
    amountController.dispose();
    dateController.dispose();
    dueDateController.dispose();
    super.dispose();
  }
}
