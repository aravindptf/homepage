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

    final url = Uri.parse('http://192.168.1.11:8086/api/Items/itemByParlourId?parlourId=$_parlourId');
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
              'image': service['itemImage'],
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

    final url = Uri.parse('http://192.168.1.11:8086/api/Items/delete?itemId=$itemId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service deleted successfully!')),
        );
        fetchServicesByParlourId();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting service')),
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
          title: Text('Are you sure?'),
          content: Text('Do you want to delete this service?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.black54)),
              onPressed: () => Navigator.of(context).pop(),
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Services List", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: items.isEmpty
          ? Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                var item = items[index];
                Uint8List? imageBytes = decodeBase64Image(item['image']);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                      ),
                      child: imageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(imageBytes, fit: BoxFit.cover),
                            )
                          : Icon(Icons.image, size: 40, color: Colors.grey.shade600),
                    ),
                    title: Text(item['itemName'], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${item['categoryName']}'),
                        Text('SubCategory: ${item['subCategoryName']}'),
                        Text('Price: ₹${item['price']}'),
                        Text('Availability: ${item['availability'] ? "Available" : "Not Available"}',
                            style: TextStyle(color: item['availability'] ? Colors.green : Colors.red)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => showConfirmationDialog(item['id'].toString()),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddServicePage())),
        backgroundColor: Color(0xFF1E88E5),
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
