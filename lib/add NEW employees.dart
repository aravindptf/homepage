import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _parlourIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _selectedImage;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken');
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  bool _validateFields() {
    if (_nameController.text.isEmpty) {
      _showError('Employee Name is required');
      return false;
    }
    if (_parlourIdController.text.isEmpty) {
      _showError('Parlour ID is required');
      return false;
    }
    if (_selectedImage == null) {
      _showError('Please select an employee photo');
      return false;
    }
    return true;
  }

 Future<void> _saveEmployeeToBackend() async {
  if (!_validateFields()) return;

  final url = Uri.parse('http://192.168.1.11:8086/api/employees/addEmployee');
  if (_token == null) {
    _showError('Token is not available. Please log in again.');
    return;
  }

  try {
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $_token';

    request.fields['employeeName'] = _nameController.text;
    request.fields['parlourId'] = _parlourIdController.text;
    request.fields['phone'] = _phoneController.text;

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'employeeImage',
        _selectedImage!.path,
        filename: 'employeeImage.jpg',
      ));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print('Response Code: ${response.statusCode}');
    print('Response Body: $responseBody');  // Debugging

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Employee added successfully'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _resetForm();
    } else {
      _showError('Failed to add employee: $responseBody');
    }
  } catch (e) {
    _showError('Error: $e');
  }
}


  void _resetForm() {
    setState(() {
      _nameController.clear();
      _parlourIdController.clear();
      _phoneController.clear();
      _selectedImage = null;
    });
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.grey.shade800),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: Color(0xFF1E88E5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add New Employee',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 15,
                        spreadRadius: 5,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF1E88E5),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Color(0xFF1E88E5),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(
                                        color: Color(0xFF1E88E5),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildInputField(
                        controller: _nameController,
                        label: 'Employee Name',
                        icon: Icons.person,
                        keyboardType: TextInputType.name,
                      ),
                      _buildInputField(
                        controller: _parlourIdController,
                        label: 'Parlour ID',
                        icon: Icons.store,
                        keyboardType: TextInputType.number,
                      ),
                     
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _saveEmployeeToBackend,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1E88E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Save Employee',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}