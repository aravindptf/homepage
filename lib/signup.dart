import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homepage/Login.dart';
import 'package:homepage/homecontent.dart';
import 'package:homepage/homepage.dart';
import 'package:homepage/map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> registerParlour(Map<String, dynamic> parlourData, XFile? image,
    XFile? coverImage, XFile? licenseImage) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://192.168.1.150:8080/api/parlour/ParlourReg'),
  );

  // Add fields to the request
  request.fields['parlourName'] = parlourData['parlourName'].toString();
  request.fields['phoneNumber'] = parlourData['phoneNumber'];
  request.fields['password'] = parlourData['password'];
  request.fields['licenseNumber'] = parlourData['licenseNumber'];
  request.fields['ratings'] = parlourData['ratings'].toString();
  request.fields['location'] = parlourData['location'];
  request.fields['description'] = parlourData['description'];
  request.fields['email'] = parlourData['email'];
  request.fields['latitude'] = parlourData['latitude'].toString();
  request.fields['longitude'] = parlourData['longitude'].toString();

  // Add images to the request with error handling
  try {
    if (image != null && image.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
      ));
    }

    if (coverImage != null && coverImage.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'coverImage',
        coverImage.path,
      ));
    }

    if (licenseImage != null && licenseImage.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'licenseImage',
        licenseImage.path,
      ));
    }
  } catch (e) {
    print('Error adding files: $e');
    return false; // Indicate failure
  }

  // Send the request
var response = await request.send();

if (response.statusCode == 200 && response.statusCode < 300) {
  String responseBody = await response.stream.bytesToString();
  final parsedResponse = jsonDecode(responseBody);
  int parlourId = parsedResponse['id'];  // Ensure 'id' matches backend response key
  
  // Save parlourId in SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('parlourId', parlourId);

  print('Registration successful, parlour ID: $parlourId');
  return true;
} else {
  String responseBody = await response.stream.bytesToString();
  print('Registration failed: $responseBody');
  return false;
}
}

class Signup extends StatefulWidget {
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;

  const Signup({
    Key? key,
    this.validator,
    this.onSaved,
  }) : super(key: key);

  @override
  State<Signup> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _obscureText = true;
  String? _latitude; // Variable to hold the selected latitude
  String? _longitude; // Variable to hold the selected longitude

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image.asset(
          //   'assets/equipment-hairdresser-pink-background-space-text_136961-477.avif',
          //   fit: BoxFit.cover,
          // ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Parlour Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter parlour name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _parlourName = value;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _phoneNumber = value;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'License Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter license number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _licenseNumber = value;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'State',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _location = value;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(color: Colors.grey), // Border color
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 20),
                              child: Text(
                                _latitude != null && _longitude != null
                                    ? 'Lat: $_latitude, Lon: $_longitude' // Display latitude and longitude
                                    : 'Pick a Location', // Placeholder
                                style: TextStyle(
                                    color: Colors.black), // Text color
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.location_on,
                                color: Colors.black), // Location icon
                            onPressed: () async {
                              // Navigate to Mappage and wait for the result
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Mappage()),
                              );

                              // Check if the result is not null and update the latitude and longitude
                              if (result != null) {
                                setState(() {
                                  _latitude = result['latitude']
                                      .toString(); // Update latitude
                                  _longitude = result['longitude']
                                      .toString(); // Update longitude
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _description = value;
                      },
                      minLines: 3,
                      maxLines: 5,
                    ),
                    SizedBox(height: 20),
                    Text('Select Images', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => _pickImage('profile'),
                              child: Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: _image == null
                                    ? Icon(Icons.add_a_photo)
                                    : Image.file(File(_image!.path),
                                        fit: BoxFit.cover),
                              ),
                            ),
                            Text('Profile Image'),
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => _pickImage('cover'),
                              child: Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: _coverImage == null
                                    ? Icon(Icons.add_a_photo)
                                    : Image.file(File(_coverImage!.path),
                                        fit: BoxFit.cover),
                              ),
                            ),
                            Text('Cover Image'),
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => _pickImage('licence'),
                              child: Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: _licenseImage == null
                                    ? Icon(Icons.add_a_photo)
                                    : Image.file(File(_licenseImage!.path),
                                        fit: BoxFit.cover),
                              ),
                            ),
                            Text('License Image'),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            Map<String, dynamic> parlourData = {
                              'parlourName': _parlourName,
                              'email': _email,
                              'phoneNumber': _phoneNumber,
                              'password': _password,
                              'licenseNumber': _licenseNumber,
                              'location': _location,
                              'description': _description,
                              'ratings': 0, // Default rating
                              'latitude': _latitude,
                              'longitude': _longitude
                            };

                            bool success = await registerParlour(parlourData,
                                _image, _coverImage, _licenseImage);
                            if (success) {
                              // Navigate to the next page or show success message
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Homecontent()),
                              );
                            } else {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Registration failed. Please try again.')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black, // Text color
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15), // Padding
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(25), // Rounded corners
                          ),
                          elevation: 5, // Shadow effect
                        ),
                        child: Text('Register'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}