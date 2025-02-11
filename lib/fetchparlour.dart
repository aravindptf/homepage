import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class ParlourDetailsPage extends StatefulWidget {
  @override
  _ParlourDetailsPageState createState() => _ParlourDetailsPageState();
}

class _ParlourDetailsPageState extends State<ParlourDetailsPage> {
  Future<Parlour>? parlour;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController(); 
  bool _isEditing = false;
  bool _isInitialized = false;

  Future<int> getParlourId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('parlourId') ?? 0;
  }

  Future<String> getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') ?? '';
  }

  Future<Parlour> fetchParlourDetails(int parlourId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.11:8086/api/parlour/id?id=$parlourId'),
      headers: {
        'Cookie': 'JSESSIONID=ACF91BC7C0410372B5E2DF5E978E186B',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        return Parlour.fromJson(data);
      } else if (data is List && data.isNotEmpty) {
        return Parlour.fromJson(data[0]);
      } else {
        throw Exception('Unexpected data format');
      }
    } else {
      throw Exception('Failed to load parlour details');
    }
  }

  Future<void> saveChanges(int parlourId) async {
  final token = await getAuthToken(); // Get the token
  print('Token: $token'); // Debugging line

  final response = await http.put(
    Uri.parse('http://192.168.1.11:8086/api/parlour/update'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Include the token in the headers
      'Cookie': 'JSESSIONID=ACF91BC7C0410372B5E2DF5E978E186B',
    },
    body: json.encode({
      'id': parlourId,
      'parlourName': _nameController.text,
      'phoneNumber': _phoneController.text,
      'email': _emailController.text,
      // You can add other fields here if needed
    }),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Changes saved successfully')),
    );
  } else {
    print('Response body: ${response.body}'); // Debugging line
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save changes: ${response.body}')),
    );
  }
}
  @override
  void initState() {
    super.initState();
    parlour = getParlourId().then((parlourId) => fetchParlourDetails(parlourId));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initializeControllers(Parlour parlourData) {
    if (!_isInitialized) {
      _nameController.text = parlourData.parlourName;
      _phoneController.text = parlourData.phoneNumber;
      _emailController.text = parlourData.email;
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parlour Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              setState(() {
                if (_isEditing) {
                  if (_formKey.currentState!.validate()) {
                    getParlourId().then((parlourId) {
                      saveChanges(parlourId); // Call the saveChanges function
                    });
                  }
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Parlour>(
        future: parlour,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final parlourData = snapshot.data!;
            
            _initializeControllers(parlourData);

            Uint8List? decodedImage;
            if (parlourData.image.isNotEmpty) {
              try {
                decodedImage = base64Decode(parlourData.image);
              } catch (e) {
                print('Error decoding image: $e');
              }
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: decodedImage != null
                                  ? Image.memory(
                                      decodedImage,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.store, size: 60),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                radius: 18,
                                child: IconButton(
                                  icon: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                  onPressed: () {
                                    // Implement image picker
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Parlour Name',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.store, color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter parlour name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone, color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email, color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        enabled: _isEditing,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }
}

class Parlour {
  final String parlourName;
  final String phoneNumber;
  final String email;
  final String image;

  Parlour({
    required this.parlourName,
    required this.phoneNumber,
    required this.email,
    required this.image,
  });

  factory Parlour.fromJson(Map<String, dynamic> json) {
    return Parlour(
      parlourName: json['parlourName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      image: json['image'],
    );
  }
}
