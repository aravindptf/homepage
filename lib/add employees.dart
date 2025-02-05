import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:homepage/add%20NEW%20employees.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddEmployees extends StatefulWidget {
  const AddEmployees({super.key});

  @override
  _AddEmployeesState createState() => _AddEmployeesState();
}

class _AddEmployeesState extends State<AddEmployees> {
  List<Map<String, dynamic>> employees = [];
  bool isLoading = true;
  String? _token;
  String? _parlourId;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // Initialize the app by loading token and parlourId
  Future<void> _initializeApp() async {
    await _loadToken();
    await _loadParlourId(); // Load the parlour ID separately after token
    if (_parlourId != null) {
      await fetchEmployees(); // Fetch employees if parlourId is valid
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parlour ID is not available. Please log in again.')),
      );
    }
  }

  // Load the authentication token from SharedPreferences
  Future<void> _loadToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      
      print('Retrieved authToken: $token');
      
      if (token?.isNotEmpty == true) {
        setState(() {
          _token = token;
        });
      } else {
        throw Exception('Authentication token is missing. Please log in.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading authentication data: $e')),
      );
    }
  }

  // Load the parlourId from SharedPreferences
  Future<void> _loadParlourId() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final parlourId = prefs.getInt('parlourId'); // Fetch parlourId as integer

      print('Retrieved parlourId: $parlourId');

      if (parlourId != null) {
        setState(() {
          _parlourId = parlourId.toString(); // Convert parlourId to string for consistency
        });
      } else {
        throw Exception('Parlour ID is missing.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading parlour ID: $e')),
      );
    }
  }

  // Function to fetch employees based on parlourId
  Future<void> fetchEmployees() async {
    try {
      if (_parlourId == null || _parlourId!.isEmpty) {
        throw Exception("Parlour ID is missing.");
      }

      final url =
          'http://192.168.1.49:8080/employees/by-parlourId?parlourId=$_parlourId'; // Add parlourId as query parameter
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Ensure correct authentication token
        },
      );

      // Checking Response Status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          employees = jsonResponse.map((employee) {
            return {
              'id': employee['id'],
              'employeeName': employee['employeeName'],
              'isAvailable': employee['isAvailable'] ?? false,
              'image': employee['image'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load employees. Status: ${response.statusCode}. Body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching employees: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching employees: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading once the request completes
      });
    }
  }

  // Delete an Employee
  Future<void> deleteEmployee(int id) async {
    try {
      if (_token == null || _token!.isEmpty) {
        throw Exception('Authentication token is unavailable.');
      }

      final url = 'http://192.168.1.38:8080/employees/delete/$id';
      final confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Delete Employee"),
          content: const Text("Are you sure you want to delete this employee?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        ),
      );

      if (confirmDelete == true) {
        final response = await http.delete(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            employees.removeWhere((employee) => employee['id'] == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Employee deleted successfully.")),
          );
        } else if (response.statusCode == 403) {
          throw Exception("Permission denied to delete the employee.");
        } else {
          throw Exception("Failed to delete employee. (Status: ${response.statusCode})");
        }
      }
    } catch (e) {
      print("Error deleting employee: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Navigate to AddEmployee Page
  void navigateToAddEmployee() async {
    final newEmployee = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEmployeePage()),
    );
    if (newEmployee != null && newEmployee is Map<String, dynamic>) {
      setState(() {
        employees.add(newEmployee);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employees"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: navigateToAddEmployee,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : employees.isEmpty
              ? const Center(child: Text("No employees added."))
              : ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    final image = employee['imageData'];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: image != null
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(image),
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                        title: Text(employee['employeeName'] ?? 'No Name'),
                        subtitle: Text(
                          "Availability: ${employee['isAvailable'] == true ? "Available" : "Not Available"}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteEmployee(employee['id']),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddEmployee,
        child: const Icon(Icons.add),
      ),
    );
  }
}
