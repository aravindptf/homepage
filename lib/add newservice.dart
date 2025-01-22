import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController parlourIdController = TextEditingController();
  final TextEditingController categoryIdController = TextEditingController();
  final TextEditingController subcategoryController = TextEditingController();
  final TextEditingController subsubcategoryController = TextEditingController();

  bool isAvailable = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken(); // Load the token when the page is initialized
  }

  // Load the token from SharedPreferences
  Future<void> _loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken'); // Retrieve the token
    });
  }

  // Helper function to show error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateFields() {
    if (nameController.text.isEmpty) {
      _showError('Item Name is required');
      return false;
    }

    if (priceController.text.isEmpty || double.tryParse(priceController.text) == null) {
      _showError('Please enter a valid price');
      return false;
    }

    if (descriptionController.text.isEmpty) {
      _showError('Description is required');
      return false;
    }

    if (parlourIdController.text.isEmpty || int.tryParse(parlourIdController.text) == null) {
      _showError('Please enter a valid Parlour ID');
      return false;
    }

    if (categoryIdController.text.isEmpty || int.tryParse(categoryIdController.text) == null) {
      _showError('Please enter a valid Category ID');
      return false;
    }

    // Validate time format (hh:mm:ss)
    final timePattern = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d$');
    if (!timePattern.hasMatch(timeController.text)) {
      _showError('Please enter a valid time in hh:mm:ss format');
      return false;
    }

    if (_selectedImage == null) {
      _showError('Please select an image');
      return false;
    }

    return true;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveServiceToBackend(Map<String, dynamic> serviceData) async {
    final url = Uri.parse('http://192.168.1.41:8080/Items/AddItems');
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Token is not available. Please log in again.')));
      return;
    }

    try {
      // Create a multipart request (only declare it once)
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $_token';

      // Add the fields to the request
      request.fields['itemName'] = serviceData['itemName'];
      request.fields['price'] = serviceData['price'];
      request.fields['serviceTime'] = serviceData['serviceTime'];
      request.fields['categoryId'] = serviceData['categoryId'];
      request.fields['subCategoryId'] = serviceData['subCategoryId'];
      request.fields['subSubCategoryId'] = serviceData['subSubCategoryId'];
      request.fields['parlourId'] = serviceData['parlourId'];
      request.fields['description'] = serviceData['description'];
      request.fields['availability'] = serviceData['availability'] ? 'true' : 'false';

      // Add the image file if available
      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'itemImage',
          _selectedImage!.path,
          filename: 'itemImage.jpg',
        ));
      }

      // Send the request
      final response = await request.send();

      // Parse and handle the response
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        print('Service added successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service added successfully')),
        );
      } else {
        print('Failed to add service: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add service: $responseBody')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : null,
                child: _selectedImage == null
                    ? const Icon(Icons.add_a_photo, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time (hh:mm:ss)'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: parlourIdController,
              decoration: const InputDecoration(labelText: 'Parlour ID'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: categoryIdController,
              decoration: const InputDecoration(labelText: 'Category ID'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: subcategoryController,
              decoration: const InputDecoration(labelText: 'Subcategory'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: subsubcategoryController,
              decoration: const InputDecoration(labelText: 'Subsubcategory'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Available'),
              value: isAvailable,
              onChanged: (value) {
                setState(() {
                  isAvailable = value;
                });
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (_validateFields()) {
                  final serviceData = {
                    'itemName': nameController.text,
                    'price': priceController.text,
                    'description': descriptionController.text,
                    'parlourId': parlourIdController.text,
                    'availability': isAvailable,
                    'itemImage': _selectedImage?.path,
                    'categoryId': categoryIdController.text,
                    'subCategoryId': subcategoryController.text,
                    'subSubCategoryId': subsubcategoryController.text,
                    'serviceTime': timeController.text, // Add this line
                  };

                  _saveServiceToBackend(serviceData);
                }
              },
              child: const Text('Save Service'),
            ),
          ],
        ),
      ),
    );
  }
}
