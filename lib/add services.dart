import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homepage/add%20newservice.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServicesPage extends StatefulWidget {
  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<dynamic> items = [];
  String? _parlourId;

  // Retrieve the parlourId from SharedPreferences (Handle it as an int)
  Future<void> getParlourId() async {
    final prefs = await SharedPreferences.getInstance();
    dynamic fetchedParlourId = prefs.get('parlourId');
    
    if (fetchedParlourId != null) {
      // Ensure parlourId is treated as a String even if it's stored as an int
      if (fetchedParlourId is int) {
        _parlourId = fetchedParlourId.toString();  // Convert to String
      } else if (fetchedParlourId is String) {
        _parlourId = fetchedParlourId;
      }
      
      setState(() {
        print('Retrieved Parlour ID: $_parlourId');
      });
    } else {
      print('Parlour ID not found in SharedPreferences');
    }
  }

  // Fetch services by parlourId (without token for authorization)
 Future<void> fetchServicesByParlourId() async {
  if (_parlourId == null) {
    print("Parlour ID is null. Please set the parlour ID.");
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  String? jsessionId = prefs.getString('JSESSIONID');

  if (jsessionId == null) {
    print("JSESSIONID is null. Please make sure the user is logged in.");
    return;
  }

  final url = Uri.parse('http://192.168.1.18:8086/api/Items/itemByParlourId?parlourId=$_parlourId');
  final headers = {
    'Content-Type': 'application/json',
    'Cookie': 'JSESSIONID=$jsessionId',
  };

  print('Sending request to: $url');
  print('With headers: $headers');

  try {
    final response = await http.get(url, headers: headers);
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          items = jsonResponse.map((service) {
            return {
              'id': service['id'],
              'itemName': service['itemName'], // Changed field from 'serviceName' to 'itemName'
              'price': service['price'],
              'categoryName': service['categoryName'],
              'subCategoryName': service['subCategoryName'],
              'subSubCategoryName': service['subSubCategoryName'], // Added 'subSubCategoryName'
              'availability': service['availability'],
              'serviceTime': service['serviceTime'],
            };
          }).toList();
        });
      } else {
        print('Failed to load services. Status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load services. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error fetching services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching services: $e')),
      );
    }
  }

  // Delete a service by serviceId (with token for authorization)
  Future<void> deleteService(int serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken'); // Get the token for authorization

    if (token == null) {
      print("Token is null. Please log in first.");
      return;
    }

    final url = Uri.parse('http://192.168.1.18:8086/api/services/delete?serviceId=$serviceId');
    final headers = {
      'Authorization': 'Bearer $token',  // Add token for the delete request
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Service deleted successfully');
        fetchServicesByParlourId(); // Refresh the list after deleting
      } else {
        print('Failed to delete service. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Use async initialization safely in initState
  @override
  void initState() {
    super.initState();
    _initializeData(); // Initialize parlourId
  }

  // A new function to initialize parlourId
  Future<void> _initializeData() async {
    try {
      await getParlourId();
      if (_parlourId != null) {
        await fetchServicesByParlourId(); // Fetch services after parlourId is available
      }
    } catch (e) {
      print('Error during initialization: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during initialization: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Services List"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: items.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];

                  // Extract the relevant data from the response
                  var itemName = item['itemName']; // Changed field name from 'serviceName' to 'itemName'
                  var price = item['price'];
                  var categoryName = item['categoryName'];
                  var subCategoryName = item['subCategoryName'];
                  var subSubCategoryName = item['subSubCategoryName']; // Added subSubCategoryName
                  var availability = item['availability'] ? "Available" : "Not Available";
                  var serviceTime = item['serviceTime'];

                  return ListTile(
                    title: Text(itemName ?? 'No Name'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: $categoryName'),
                        Text('SubCategory: $subCategoryName'),
                        Text('Sub SubCategory: $subSubCategoryName'), // Added display of subSubCategoryName
                        Text('Price: \$${price.toString()}'),
                        Text('Service Time: $serviceTime'),
                        Text('Availability: $availability'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteService(item['id']);  // Delete service using the token
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddNewServicePage when clicked
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddServicePage()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add New Service',
      ),
    );
  }
}
