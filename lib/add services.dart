import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:homepage/add%20newservice.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homepage/color.dart'; // Assuming this file contains your color constants

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<dynamic> items = [];
  String? _parlourId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getParlourId();
    if (_parlourId != null) {
      await fetchServicesByParlourId();
    }
  }

  Future<void> getParlourId() async {
    final prefs = await SharedPreferences.getInstance();
    dynamic fetchedParlourId = prefs.get('parlourId');

    if (fetchedParlourId != null) {
      _parlourId = fetchedParlourId.toString();
      setState(() {});
    }
  }

  Future<void> fetchServicesByParlourId() async {
    if (_parlourId == null) return;

    final url = Uri.parse('http://192.168.1.34:8086/api/Items/itemByParlourId?parlourId=$_parlourId');
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          items = jsonResponse.map((service) {
            return {
              'id': service['id'],
              'itemName': service['itemName'] ?? 'No Name',
              'price': service['price'] ?? 0.0,
              'categoryName': service['categoryName'] ?? 'No Category',
              'subCategoryName': service['subCategoryName'] ?? 'No SubCategory',
              'subSubCategoryName': service['subSubCategoryName'] ?? 'No SubSubCategory',
              'availability': service['availability'] ?? false,
              'serviceTime': service['serviceTime'] ?? '00:00:00',
              'image': service['itemImage'], // Use correct key
            };
          }).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching services: $e')),
      );
    }
  }

  Uint8List? decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      if (base64String.contains(",")) {
        base64String = base64String.split(",").last;
      }
      return base64Decode(base64.normalize(base64String));
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  Future<void> deleteService(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are not logged in!')),
      );
      return;
    }

    final url = Uri.parse('http://192.168.1.16:8086/api/Items/delete?itemId=$itemId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item deleted successfully!')),
        );
        await fetchServicesByParlourId();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting service: $e')),
      );
    }
  }

  Future<void> showConfirmationDialog(String itemId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete this service? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: AppColors.kPrimary)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                deleteService(itemId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: Text("Services List"),
        backgroundColor: AppColors.kPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: items.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];

                  var itemName = item['itemName'];
                  var price = item['price'];
                  var categoryName = item['categoryName'];
                  var subCategoryName = item['subCategoryName'];
                  var subSubCategoryName = item['subSubCategoryName'];
                  var availability = item['availability'] ? "Available" : "Not Available";
                  var serviceTime = item['serviceTime'];
                  Uint8List? imageBytes = decodeBase64Image(item['image']);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: imageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                imageBytes,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.image, size: 40, color: Colors.grey[600]),
                            ),
                      title: Text(itemName, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.kPrimary)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text('Category: $categoryName', style: TextStyle(color: Colors.black54)),
                          Text('SubCategory: $subCategoryName', style: TextStyle(color: Colors.black54)),
                          Text('Sub SubCategory: $subSubCategoryName', style: TextStyle(color: Colors.black54)),
                          Text('Price: \$${price.toStringAsFixed(2)}', style: TextStyle(color: Colors.black87)),
                          Text('Service Time: $serviceTime', style: TextStyle(color: Colors.black54)),
                          Text('Availability: $availability', style: TextStyle(color: availability == "Available" ? Colors.green : Colors.red)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showConfirmationDialog(item['id'].toString());
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddServicePage()),
          );
        },
        tooltip: 'Add New Service',
        backgroundColor: AppColors.kPrimary,
        child: Icon(Icons.add),
      ),
    );
  }
}