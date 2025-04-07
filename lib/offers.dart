import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Offers extends StatefulWidget {
  const Offers({super.key});

  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<Offers> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _offerNameController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  File? _image;
  int? parlourId;

  @override
  void initState() {
    super.initState();
    _loadParlourId();
  }

  Future<void> _loadParlourId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      parlourId = prefs.getInt("parlourId");
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _submitOffer() async {
    if (_formKey.currentState!.validate() && _image != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("authToken");

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Authentication failed! Please log in again.")));
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.14:8086/api/offer/add'),
      );  

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['typeId'] = "1";
      request.fields['offerName'] = _offerNameController.text;
      request.fields['discount'] = _discountController.text;
      request.fields['startDate'] = _startDateController.text;
      request.fields['endDate'] = _endDateController.text;
      request.fields['parlourId'] = "$parlourId";

      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Offer added successfully!")));
        _clearFields(); // Clear fields after success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to add offer")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all fields and select an image!")));
    }
  }

  // Function to clear fields
  void _clearFields() {
    setState(() {
      _offerNameController.clear();
      _discountController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _image = null;
    });
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isDateField = false, // New parameter for date selection
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: isDateField, // Prevents manual input for date fields
        onTap: isDateField ? () => _selectDate(controller) : null, // Opens date picker
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
        validator: (value) => value!.isEmpty ? "Required" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add New Offer',
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
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
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
                                // ignore: deprecated_member_use
                                color: Colors.blue.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                            image: _image != null
                                ? DecorationImage(
                                    image: FileImage(_image!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _image == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 40, color: Color(0xFF1E88E5)),
                                    SizedBox(height: 8),
                                    Text("Add Photo", style: TextStyle(color: Color(0xFF1E88E5))),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 32),
                      _buildInputField(controller: _offerNameController, label: 'Offer Name', icon: Icons.card_giftcard),
                      _buildInputField(controller: _discountController, label: 'Discount (%)', icon: Icons.percent, keyboardType: TextInputType.number),
                      _buildInputField(controller: _startDateController, label: 'Start Date', icon: Icons.date_range, isDateField: true),
                      _buildInputField(controller: _endDateController, label: 'End Date', icon: Icons.date_range, isDateField: true),
                      SizedBox(height: 32),
                      ElevatedButton(onPressed: _submitOffer, child: Text("Save Offer")),
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
