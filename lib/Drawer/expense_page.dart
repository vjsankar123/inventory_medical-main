import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/dashboard/persistent_bottom_nav_bar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExpenseTrackerScreen(),
    );
  }
}

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({Key? key}) : super(key: key);

  @override
  _ExpenseTrackerScreenState createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  List<Map<String, dynamic>> expenses = [];
  ApiService apiService = ApiService();
  List<Map<String, String>> expense = [];
  final TextEditingController _idController = TextEditingController();
  List<Map<String, String>> filteredexpense = [];
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  bool isScrolled = false;
  bool _isFetchingMore = false;
  int _currentPage = 1;
  final int _limit = 10; // Number of items per page
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          setState(() {
            _currentPage++;
          });
          _loadExpenses(isLoadMore: true);
        }
      }
    });
  }

  void filterExpense(String query) {
    setState(() {
      filteredexpense = expense
          .where((category) =>
              category['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _loadExpenses({bool isLoadMore = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final fetchedExpenses =
          await apiService.fetchExpense(page: _currentPage, limit: _limit);
      setState(() {
        if (isLoadMore) {
          expenses.addAll(fetchedExpenses);
        } else {
          expenses = fetchedExpenses;
        }
        _isLoading = false;
        _isFetchingMore = false;
        _hasMore = fetchedExpenses.length == _limit;
      });
    } catch (e) {
      print('Error fetching invoices: $e');
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  void addExpense(
      String category, String amount, String description, String date) async {
    Map<String, dynamic> expensedata = {
      "category": category,
      "amount": amount,
      "description": description,
      "date": date,
    };

    bool success = await apiService.createExpense(expensedata);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Expense created successfully!'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Close modal
      _loadExpenses(); // Refresh the list after creation
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to create expense.'),
            backgroundColor: Colors.red),
      );
    }
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
          backgroundColor: const Color(0xFF028090),
          title: _isSearching
              ? Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterExpense,
                    decoration: const InputDecoration(
                      hintText: 'Search Category...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                    cursorColor: Color(0xFF028090),
                  ),
                )
              : const Text(
                  'Expense Details',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                    filterExpense('');
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
                          border: TableBorder.all(color: Colors.black),
                          columnSpacing: 20,
                          headingRowHeight: 56,
                          dataRowHeight: 56,
                          columns:  [
                            DataColumn(
                                  label: Text('S.No',
                                      )),
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Description')),
                            DataColumn(label: Text('Date')),
                          ],
                          rows: expenses.map((expense) {
                            int index = expenses.indexOf(expense);
                            return DataRow(cells: [
                               DataCell(Text('${(_currentPage - 1) * _limit + index + 1}')),  // Cor
                              DataCell(Text(expense['id'].toString())),
                              DataCell(Text(expense['category'])),
                              DataCell(Text(expense['amount'].toString())),
                              DataCell(SizedBox(
                                width: 150,
                                child: Text(expense['description'] ?? 'N/A',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2),
                              )),
                              DataCell(Text(
                                expense['date'] != null
                                    ? DateFormat('dd-MM-yyyy')
                                        .format(DateTime.parse(expense['date']))
                                    : 'N/A',
                              )),
                            ]);
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
                              _loadExpenses();
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
                              _loadExpenses();
                            }
                          : null,
                    ),
                  ],
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Show the bottom sheet when the button is pressed
            showModalBottomSheet(
              backgroundColor: Colors.white,
              context: context,
              isScrollControlled: true, // Allow scrolling in bottom sheet
              builder: (context) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add New Expense',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        TextField(
                          controller: _categoryController,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Color(0xFF028090),
                                width: 2.0,
                              ),
                            ),
                          ),
                          cursorColor: Color(0xFF028090),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            labelStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Color(0xFF028090),
                                width: 2.0,
                              ),
                            ),
                          ),
                          cursorColor: Color(0xFF028090),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Color(0xFF028090),
                                width: 2.0,
                              ),
                            ),
                          ),
                          cursorColor: Color(0xFF028090),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Color(0xFF028090),
                                          onPrimary: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (pickedDate != null) {
                                  // Format date to DD-MM-YYYY
                                  _dateController.text =
                                      DateFormat('dd-MM-yyyy')
                                          .format(pickedDate);
                                }
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Color(0xFF028090),
                                width: 2.0,
                              ),
                            ),
                            hintText: 'DD-MM-YYYY',
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            addExpense(
                              _categoryController.text,
                              _amountController.text,
                              _descriptionController.text,
                              _dateController.text,
                            );

                            _categoryController.clear();
                            _amountController.clear();
                            _descriptionController.clear();
                            _dateController.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF028090),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            'Add Expense',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Icon(Icons.add, color: Colors.white, size: 30),
          elevation: 30.0,
          backgroundColor: Color(0xFF028090),
          tooltip: 'Add Expense',
        ),
      ),
    );
  }
}
