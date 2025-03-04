import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homepage/assets.dart';
import 'package:homepage/color.dart';
import 'package:homepage/login.dart';
import 'package:homepage/map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class Signup extends StatefulWidget {
  @override
  State<Signup> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _obscureText = true;
  String? _latitude;
  String? _longitude;

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _parlourName,
      _email,
      _phoneNumber,
      _password,
      _location,
      _description,
      _licenseNumber;

  XFile? _image;
  XFile? _coverImage;
  XFile? _licenseImage;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _pickImage(String type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (type == 'profile') {
        _image = pickedFile;
      } else if (type == 'cover') {
        _coverImage = pickedFile;
      } else if (type == 'licence') {
        _licenseImage = pickedFile;
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.200:8086/api/parlour/ParlourReg'), // Replace with your backend URL
      );

      // Add text fields
      request.fields['parlourName'] = _parlourName!;
      request.fields['phoneNumber'] = _phoneNumber!;
      request.fields['password'] = _password!;
      request.fields['email'] = _email!;
      request.fields['licenseNumber'] = _licenseNumber!;
      request.fields['ratings'] = "0"; // Assuming default rating is 0
      request.fields['location'] = _location!;
      request.fields['description'] = _description!;
      request.fields['latitude'] = _latitude!;
      request.fields['longitude'] = _longitude!;

      // Add images if they exist
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          contentType: MediaType('image', 'jpeg'), // Adjust based on your image type
        ));
      }
      if (_coverImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'coverImage',
          _coverImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }
      if (_licenseImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'licenseImage',
          _licenseImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      // Send the request
      final response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful: ${jsonResponse['parlourName']}')),
        );

        // Navigate to HomeContent page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Loginpage()), // Adjust based on your HomeContent class
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${response.reasonPhrase}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Image.asset(loginAssets.kLogoBlue),
                ),
                const SizedBox(height: 62),
                const Text('Register',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                const SizedBox(height: 10),
                const SizedBox(height: 24),

                // Form fields
                _buildTextField('Parlour Name', (value) {
                  _parlourName = value;
                }, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter parlour name';
                  }
                  return null;
                }),
                const SizedBox(height: 20),
                _buildTextField('Email', (value) {
                  _email = value;
                }, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                }),
                const SizedBox(height: 20),
                _buildTextField('Phone Number', (value) {
                  _phoneNumber = value;
                }, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                }),
                const SizedBox(height: 20),
                _buildPasswordField('Password', _passwordController, (value) {
                  _password = value;
                }),
                const SizedBox(height: 20),
                _buildPasswordField('Confirm Password', _confirmPasswordController, (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                }),
                const SizedBox(height: 20),
                _buildTextField('License Number', (value) {
                  _licenseNumber = value;
                }, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter license number';
                  }
                  return null;
                }),
                const SizedBox(height: 20),
                _buildTextField('Address', (value) {
                  _location = value;
                }, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                }),
                const SizedBox(height: 20),
                _buildLocationPicker(),
                const SizedBox(height: 20),
                _buildTextField('Description', (value) {
                  _description = value;
                }, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                }, minLines: 3, maxLines: 5),
                Text('Select Images', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildImagePicker('Profile Image', 'profile', _image),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildImagePicker('Cover Image', 'cover', _coverImage),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildImagePicker('License Image', 'licence', _licenseImage),
                    ),
                  ],
                ),
                SizedBox(height: 40,),
                Center(
                  child: PrimaryButton(
                    onTap: _register, // Call the register function
                    text: 'Register',
                    color: AppColors.kPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, Function(String?)? onSaved, String? Function(String?)? validator, {int minLines = 1, int maxLines = 1}) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      ),
      onSaved: onSaved,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController controller, Function(String?)? onSaved) {
    return TextFormField(
      controller: controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.black,
          ),
          onPressed: _togglePasswordVisibility,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      ),
      onSaved: onSaved,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $hint';
        }
        return null;
      },
    );
  }

  Widget _buildLocationPicker() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Text(
                _latitude != null && _longitude != null
                    ? 'Lat: $_latitude, Lon: $_longitude'
                    : 'Pick a Location',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.location_on, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Mappage()),
              );

              if (result != null) {
                setState(() {
                  _latitude = result['latitude'].toString();
                  _longitude = result['longitude'].toString();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(String label, String type, XFile? image) {
    return GestureDetector(
      onTap: () => _pickImage(type),
      child: Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: image == null
            ? Icon(Icons.add_a_photo)
            : Image.file(File(image.path), fit: BoxFit.cover),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color color;

  const PrimaryButton({
    Key? key,
    required this.onTap,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}