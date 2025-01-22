import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:homepage/add%20NEW%20employees.dart';
import 'dart:convert';
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

  void login(String token) {
    setState(() {
      _token = token;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadToken().then((_) => fetchEmployees());
  }

  Future<void> _loadToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token != null && token.isNotEmpty) {
        setState(() {
          _token = token;
        });
      } else {
        throw Exception('No auth token found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading authentication token: $e')),
      );
    }
  }

 Future<void> fetchEmployees() async {
  try {
    // Retrieve the `parlourId` from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final parlourId = prefs.getInt('parlourId');

    if (parlourId == null) {
      throw Exception('Parlour ID not found. Please log in again.');
    }

    if (_token == null) {
      throw Exception('Authentication token is not available');
    }

    // Include parlourId in the API URL
    final url = 'http://192.168.1.41:8080/employees/by-parlourId?parlourId=$parlourId';
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        setState(() {
          employees = [];
        });
        return;
      }

      final data = json.decode(response.body);
      if (data is List) {
        setState(() {
          employees = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception("Unexpected data format");
      }
    } else if (response.statusCode == 403) {
      throw Exception("Authentication failed. Please login again.");
    } else {
      throw Exception("Failed to load employees. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    setState(() {
      employees = [];
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  Future<void> deleteEmployee(int id) async {
    try {
      if (_token == null || _token!.isEmpty) {
        throw Exception('Authentication token is not available');
      }

      final bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Employee"),
            content: const Text("Are you sure you want to delete this employee?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes"),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        // Changed the URL to match the employees endpoint
        final url = 'http://192.168.1.41:8080/employees/delete/$id';
        
        final response = await http.delete(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
          },
        );

        print("Delete response status: ${response.statusCode}");
        print("Delete response body: ${response.body}");

        if (response.statusCode == 200) {
          setState(() {
            employees.removeWhere((employee) => employee["id"] == id);
          });  
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Employee deleted successfully!")),
          );
        } else if (response.statusCode == 403) {
          throw Exception("You don't have permission to delete this employee");
        } else {
          throw Exception("Failed to delete employee (Status: ${response.statusCode})");
        }
      }
    } catch (e) {
      print("Delete error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting employee: $e")),
      );
    }
  }

  void navigateToAddEmployee() async {
    final newEmployee = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddEmployeePage()));
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
                    final image = employee["image"];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        leading: image != null && image.isNotEmpty
                            ? CircleAvatar(
                                radius: 30,
                                backgroundImage: image.startsWith('data:image/')
                                    ? MemoryImage(base64Decode(image.split(',').last)) as ImageProvider
                                    : NetworkImage(image),
                                onBackgroundImageError: (exception, stackTrace) {
                                  print("Error loading image: $exception");
                                },
                              )
                            : const CircleAvatar(
                                radius: 30,
                                child: Icon(Icons.person, size: 30),
                              ),
                        title: Text(
                          employee["employeeName"] ?? "No Name",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Parlour ID: ${employee["parlourId"] ?? 'N/A'}"),
                            Text("Availability: ${employee["isAvailable"] != null ? (employee["isAvailable"] ? "Available" : "Not Available") : "N/A"}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteEmployee(employee["id"]),
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