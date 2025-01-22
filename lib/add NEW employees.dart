import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEmployeePage extends StatefulWidget {
  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _parlourIdController = TextEditingController();
  File? _image; // Variable to hold the selected image
  String? _token; // Variable to hold the token

  @override
  void initState() {
    super.initState();
    _loadToken(); // Load the token when the page is initialized
  }

  Future<void> _loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken'); // Retrieve the token
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path); // Store the selected image
      });
    }
  }

  Future<void> _addEmployee() async {
    final String url = 'http://192.168.1.12:8080/employees/addEmployee'; // Ensure this is correct

    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Token is not available. Please log in again.')));
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $_token'; // Use the retrieved token

      // Add fields
      request.fields['employeeName'] = _employeeNameController.text;
      request.fields['parlourId'] = _parlourIdController.text;

      // Add image file if selected
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      }

      // Send the request with a timeout
      final response = await request.send().timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Handle success
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Employee added successfully!')));
      } else {
        // Handle error
        final responseData = await response.stream.bytesToString();
        print('Response status: ${response.statusCode}');
        print('Response body: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add employee: $responseData')));
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Add Employee'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _employeeNameController,
            decoration: InputDecoration(labelText: 'Employee Name'),
          ),
          TextField(
            controller: _parlourIdController,
            decoration: InputDecoration(labelText: 'Parlour ID'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick Image'),
          ),
          SizedBox(height: 20),
          _image != null
              ? Image.file(
                  _image!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'No Image Selected',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addEmployee,
            child: Text('Add Employee'),
          ),
        ],
      ),
    ),
  );
}
}