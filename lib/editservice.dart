import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; 
import 'package:path/path.dart';

class EditServicePage extends StatefulWidget {
  final int itemId;
  final String token;

  EditServicePage({required this.itemId, required this.token});

  @override
  _EditServicePageState createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryIdController = TextEditingController();
  final TextEditingController _subCategoryIdController = TextEditingController();
  final TextEditingController _subSubCategoryIdController = TextEditingController();
  final TextEditingController _parlourIdController = TextEditingController();
  final TextEditingController _serviceTimeController = TextEditingController();

  bool availability = true;
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateService() async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('http://192.168.1.20/api/Items/update?itemId'),
      );

       
      request.fields['itemName'] = _itemNameController.text;
      request.fields['price'] = _priceController.text;  
      request.fields['categoryId'] = _categoryIdController.text;
      request.fields['subCategoryId'] = _subCategoryIdController.text;
      request.fields['subSubCategoryId'] = _subSubCategoryIdController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['availability'] = availability.toString();
      request.fields['parlourId'] = _parlourIdController.text;
      request.fields['serviceTime'] = _serviceTimeController.text;  

      if (_selectedImage != null) {
        request.files.add(    
          await http.MultipartFile.fromPath(
            'itemImage',   
            _selectedImage!.path,
            filename: basename(_selectedImage!.path),
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        print("Service updated successfully");
      } else {
        print("Failed to update service. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Service')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _itemNameController, decoration: InputDecoration(labelText: 'Item Name')),
            TextField(controller: _priceController, decoration: InputDecoration(labelText: 'Price')),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Description')),
            TextField(controller: _categoryIdController, decoration: InputDecoration(labelText: 'Category ID')),
            TextField(controller: _subCategoryIdController, decoration: InputDecoration(labelText: 'Sub Category ID')),
            TextField(controller: _subSubCategoryIdController, decoration: InputDecoration(labelText: 'Sub Sub Category ID')),
            TextField(controller: _parlourIdController, decoration: InputDecoration(labelText: 'Parlour ID')),
            TextField(controller: _serviceTimeController, decoration: InputDecoration(labelText: 'Service Time (HH:MM:SS)')),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Availability"),
                Switch(value: availability, onChanged: (val) => setState(() => availability = val)),
              ],
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Select Image"),
            ),
            _selectedImage != null ? Image.file(_selectedImage!, height: 100) : Container(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateService,
              child: Text("Update Service"),
            ),
          ],
        ),
      ),
    );
  }
}
