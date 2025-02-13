import 'dart:convert';
import 'dart:typed_data';
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

    final url = Uri.parse('http://192.168.1.26:8086/api/Items/itemByParlourId?parlourId=$_parlourId');
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

  /// **Decode Base64 Image to Uint8List**
  Uint8List? decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      // Remove the "data:image/png;base64," prefix if present
      if (base64String.contains(",")) {
        base64String = base64String.split(",").last;
      }
      // Normalize Base64 string and decode
      return base64Decode(base64.normalize(base64String));
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  // **Delete Service**
// **Delete Service**
Future<void> deleteService(String itemId) async {
  // Fetch the token from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('authToken');

  // Check if the token exists
  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You are not logged in!')),
    );
    return;
  }

  final url = Uri.parse('http://192.168.1.26:8086/api/Items/delete?itemId=$itemId');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token', // Include the token in the header
  };

  try {
    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item deleted successfully!')),
      );
      
      // Refresh the list by fetching the updated data from the server
      await fetchServicesByParlourId(); // Reload items from server

      // Optional: Pop the current screen if you want to navigate away immediately
      // Navigator.pop(context); // Uncomment this if you want to pop the screen after deletion
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


// **Confirmation Dialog before Delete**
Future<void> showConfirmationDialog(String itemId) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to delete this service?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              deleteService(itemId); // Proceed to delete the service
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
      appBar: AppBar(title: Text("Services List")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: ListTile(
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
                      title: Text(itemName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category: $categoryName'),
                          Text('SubCategory: $subCategoryName'),
                          Text('Sub SubCategory: $subSubCategoryName'),
                          Text('Price: \$${price.toString()}'),
                          Text('Service Time: $serviceTime'),
                          Text('Availability: $availability'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Show the confirmation dialog
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
        child: Icon(Icons.add),
        tooltip: 'Add New Service',
      ),
    );
  }
}
