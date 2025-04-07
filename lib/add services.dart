import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:homepage/add%20newservice.dart';
import 'package:homepage/editservice.dart';
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

    final url = Uri.parse('http://192.168.1.20:8086/api/Items/itemByParlourId?parlourId=$_parlourId');
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

    final url = Uri.parse('http://192.168.1.20:8086/api/Items/delete?itemId=$itemId');
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


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.kBackground,
    body: Stack(
      children: [
        Column(
          children: [
            // Premium Header with gradient similar to HomePage
            Container(
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
              decoration: BoxDecoration(
               gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.deepPurple.shade50,
                        Colors.deepPurple.shade800,
                      ],
                    ),
                borderRadius: const BorderRadius.only(

                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.kShadow,
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button with premium styling
                      GestureDetector(
                        onTap: () => Navigator.pop(context, items.length),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.kPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                      // Page title
                      const Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      // Refresh button with premium styling
                      GestureDetector(
                        onTap: _initializeData,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: AppColors.kPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Services stats card
                  // Container(
                  //   padding: const EdgeInsets.all(15),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.kCardBackground,
                  //     borderRadius: BorderRadius.circular(20),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.08),
                  //         blurRadius: 15,
                  //         offset: const Offset(0, 8),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Container(
                  //         padding: const EdgeInsets.all(12),
                  //         decoration: BoxDecoration(
                  //           color: AppColors.kPrimary.withOpacity(0.12),
                  //           borderRadius: BorderRadius.circular(12),
                  //         ),
                  //         child: Icon(
                  //           Icons.spa_rounded,
                  //           color: AppColors.kPrimary,
                  //           size: 24,
                  //         ),
                  //       ),
                  //       const SizedBox(width: 15),
                  //       Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text(
                  //             'Total Services',
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               fontWeight: FontWeight.w500,
                  //               color: AppColors.kTextMedium,
                  //             ),
                  //           ),
                  //           Text(
                  //             '${items.length} Services',
                  //             style: TextStyle(
                  //               fontSize: 18,
                  //               fontWeight: FontWeight.bold,
                  //               color: AppColors.kTextDark,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
            
            // Services List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Service List',
                    //   style: TextStyle(
                    //     fontSize: 20,
                    //     fontWeight: FontWeight.bold,
                    //     color: AppColors.kTextDark,
                    //     letterSpacing: 0.5,
                    //   ),
                    // ),
                    
                Expanded(
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      var item = items[index];
      var itemName = item['itemName'];
      var price = item['price'];
      var categoryName = item['categoryName'];
      var subCategoryName = item['subCategoryName'];
      var availability = item['availability'] ? "Available" : "Not Available";
      var serviceTime = item['serviceTime'];
      Uint8List? imageBytes = decodeBase64Image(item['image']);
      
      // Premium styled service card
      return Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: AppColors.kCardBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.kShadow,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Service image with premium styling
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.withOpacity(0.2),
                      child: Icon(
                        Icons.spa_rounded,
                        size: 30,
                        color: AppColors.kTextLight,
                      ),
                    ),
              ),
              const SizedBox(width: 15),
              // Service details in rows
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kAccentError1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${categoryName} > ${subCategoryName}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.kTextMedium,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.kPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.kAccentSuccess,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item['availability'] ? AppColors.kAccentSuccess.withOpacity(0.1) : AppColors.kAccentError.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            availability,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: item['availability'] ? AppColors.kAccentSuccess : AppColors.kAccentError,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time_rounded, 
                          size: 12, 
                          color: AppColors.kTextLight
                        ),
                        const SizedBox(width: 3),
                        Text(
                          serviceTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.kTextLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Delete button with premium styling
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColors.kAccentError.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.kAccentError,
                    size: 20,
                  ),
                  onPressed: () {
                    showConfirmationDialog(item['id'].toString());
                  },
                ),
              ),
              // Inside the ListView.builder, replace the delete button section with this:
Container(
  height: 36,
  width: 36,
  decoration: BoxDecoration(
    color: AppColors.kAccentError.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: IconButton(
    padding: EdgeInsets.zero,
    icon: Icon(
      Icons.edit, // Change to edit icon
      color: AppColors.kAccentError,
      size: 20,
    ),
   onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? ''; 
      // Navigate to EditServicePage with the service details
      Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditServicePage(itemId: 1, token: token),
  ),
);

    },
  ),
),
            ],
          ),
        ),
      );
    },
  ),
),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
    // Premium styled floating action button
    floatingActionButton: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.deepPurple.shade50,
                        Colors.white,
                      ],
                    ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.kPrimary.withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddServicePage()),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(Icons.add, size: 28),
      ),
    ),
  );
}
// Updated confirmation dialog with premium styling
Future<void> showConfirmationDialog(String itemId) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Confirm Deletion', 
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.kTextDark,
          )
        ),
        content: Text(
          'Are you sure you want to delete this service? This action cannot be undone.',
          style: TextStyle(
            color: AppColors.kTextMedium,
            fontSize: 14,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel', 
              style: TextStyle(
                color: AppColors.kTextMedium,
                fontWeight: FontWeight.w600,
              )
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.kAccentError,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              child: Text(
                'Delete', 
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                )
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deleteService(itemId);
              },
            ),
          ),
        ],
      );
    },
  );
}
}
  