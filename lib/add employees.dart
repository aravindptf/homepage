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

  Future<void> _initializeApp() async {
    await _loadToken();
    await _loadParlourId();
    if (_parlourId != null) {
      await fetchEmployees();
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parlour ID is not available. Please log in again.')),
      );
    }
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token?.isNotEmpty == true) {
      setState(() => _token = token);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token is missing. Please log in.')),
      );
    }
  }

  Future<void> _loadParlourId() async {
    final prefs = await SharedPreferences.getInstance();
    final parlourId = prefs.getInt('parlourId');

    if (parlourId != null) {
      setState(() => _parlourId = parlourId.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parlour ID is missing.')),
      );
    }
  }

  Future<void> fetchEmployees() async {
    try {
      if (_parlourId == null || _parlourId!.isEmpty) {
        throw Exception("Parlour ID is missing.");
      }

      final url = 'http://192.168.1.26:8086/api/employees/by-parlourId?parlourId=$_parlourId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          employees = jsonResponse.map((employee) {
            return {
              'id': employee['id'],
              'employeeName': employee['employeeName'],
              'isAvailable': employee['isAvailable'] ?? true,
              'image': decodeBase64Image(employee['image']),
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load employees.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching employees: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Uint8List? decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      if (_token == null || _token!.isEmpty) {
        throw Exception('Authentication token is unavailable.');
      }

      final url = 'http://192.168.1.26:8086/api/employees/delete?employeeId=$id';
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
        } else {
          throw Exception("Failed to delete employee.");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

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
        title: const Text("Employees", style: TextStyle(fontWeight: FontWeight.bold)),
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
              ? const Center(
                  child: Text("No employees added.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    final Uint8List? imageBytes = employee['image'];

                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                          child: imageBytes == null ? const Icon(Icons.person, size: 30) : null,
                        ),
                        title: Text(employee['employeeName'] ?? 'No Name',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "Availability: ${employee['isAvailable'] == true ? "Available" : "Not Available"}",
                          style: TextStyle(color: employee['isAvailable'] ? Colors.green : Colors.red),
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
        backgroundColor: Colors.purple,
      ),
    );
  }
}
