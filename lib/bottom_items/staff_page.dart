import 'package:flutter/material.dart';
import 'package:flutter_application_1/API_Service/api_service.dart';
import 'package:flutter_application_1/dashboard/persistent_bottom_nav_bar.dart';
import 'staff_card.dart';
import 'search_widget.dart';
import 'create_user_button.dart';

class StaffPage extends StatefulWidget {
  @override
  _StaffPageState createState() => _StaffPageState();
}

final ApiService apiService = ApiService();

class _StaffPageState extends State<StaffPage> {
  List<Map<String, String>> staffList = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  final int _limit = 10; // Number of items per page
  bool _hasMore = true;

  Future<void> fetchAndDisplayTasks({bool isLoadMore = false}) async {
    final token = await apiService.getTokenFromStorage();
    if (_isFetchingMore || !_hasMore) return; // Avoid duplicate calls
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are not logged in. Please log in first.'),
        ),
      );
      return;
    }

    try {
      setState(() {
        _isFetchingMore = true; // Set loading state
      });

      final fetchedUsers =
          await apiService.fetchUsers(page: _currentPage, limit: _limit);

      setState(() {
        if (fetchedUsers.isNotEmpty) {
          staffList.addAll(fetchedUsers); // Append new users
          _currentPage++; // Next page
        }

        _hasMore = fetchedUsers.length == _limit; // If less, no more pages
        _isFetchingMore = false; // Stop loading state
        _isLoading = false; // Hide initial loader
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch staff. Please try again later.'),
        ),
      );
    }
  }

  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  ScrollController _scrollController = ScrollController();
  bool isScrolled = false; // To track whether the header needs a shadow

  @override
  void initState() {
    super.initState();
    fetchAndDisplayTasks();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchAndDisplayTasks(isLoadMore: true); // Load more when scrolled
      }
      setState(() {
        isScrolled = _scrollController.offset > 10; // Shadow control
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to the PersistentBottomNavBar with the Home tab selected
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => PersistentBottomNavBar(),
        ));
        return false; // Prevent the default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? SearchWidget(controller: _searchController)
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'User List', // Adjusted title for flexibility
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold, // Bold text for better visibility
                    ),
                  ),
                ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.cancel : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchController.clear();
                });
              },
            ),
            CreateUserButton(),
          ],
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                itemCount: staffList.length + 1,
                itemBuilder: (context, index) {
                  String query = _searchController.text.toLowerCase();
                  if (index == staffList.length) {
                    return _hasMore
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox.shrink();
                  }

                  if (query.isNotEmpty &&
                      !((staffList[index]['name'] ?? '')
                              .toLowerCase()
                              .contains(query) ||
                          (staffList[index]['phone'] ?? '')
                              .toLowerCase()
                              .contains(query) ||
                          (staffList[index]['email'] ?? '')
                              .toLowerCase()
                              .contains(query))) {
                    return Container(); // Hide items that do not match
                  }

                  return StaffCard(
                    staff: staffList[index],
                    onDelete: () {},
                  );
                },
              ),
      ),
    );
  }
}
