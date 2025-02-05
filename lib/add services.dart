import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homepage/add%20newservice.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServicesPage> {
  List<dynamic> services = [];
  String? _token;
  bool _isLoading = true; // A flag to show loading state

  @override
  void initState() {
    super.initState();
    _loadToken(); // Load the token when the page is initialized
  }

  // Load the token from SharedPreferences
  Future<void> _loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken');
    });
    print('Loaded token: $_token');  // Debugging line
    if (_token != null) {
      await _fetchServices(); // Fetch services after token is loaded
    }
  }

  // Fetch services from the backend API
  Future<void> _fetchServices() async {
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token is not available. Please log in again.')),
      );
      setState(() {
        _isLoading = false; // Stop loading if no token is found
      });
      return;
    }

    final url = Uri.parse('http://192.168.1.37:8080/Items/$services'); // Update this with your API endpoint

    try {
      print('Sending request with token: $_token');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      print('Fetch Services Response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> fetchedServices = json.decode(response.body);
        setState(() {
          services = fetchedServices.map((service) {
            service['id'] = (service['id'] is int) ? service['id'] : 0;
            return service;
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch services: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading after the request completes
      });
    }
  }

  // Delete service by ID
  Future<void> _deleteService(int serviceId) async {
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token is not available. Please log in again.')),
      );
      return;
    }

    final url = Uri.parse('http://192.168.1.37:8080/Items/delete/$serviceId'); // Update this with your API endpoint

    try {
      print('Sending DELETE request with token: $_token');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      print('Delete Service Response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          services.removeWhere((service) => service['id'] == serviceId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete service: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service List'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching services
          : services.isEmpty
              ? const Center(child: Text('No services available.')) // Show message if no services found
              : ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(service['itemName']),
                        subtitle: Text('Price: \$${service['price']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteService(service['id']);
                          },
                        ),
                      ),
                    );
                  },
                ),
                 floatingActionButton: FloatingActionButton(
      onPressed: () {
        // Navigate to the AddServicePage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddServicePage()),
        );
      },
      child: const Icon(Icons.add),
      tooltip: 'Add New Service',
    ),
  );
}   
  }
