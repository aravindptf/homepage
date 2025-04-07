import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Subcategory model
class Subcategory {
  final int id;
  final String name;
  final String image; // Add this field if you want to use the image later
  final int categoryId; // Add this field if you want to use the category ID
  final String subCategoryName; // Add this field if you want to use the subcategory name

  Subcategory({
    required this.id,
    required this.name,
    required this.image,
    required this.categoryId,
    required this.subCategoryName,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'],
      name: json['name'],
      image: json['image'], // Assuming this is a base64 string or URL
      categoryId: json['categoryId'],
      subCategoryName: json['subCategoryName'],
    );
  }
}

// Category model
class Category {
  final int id;
  final String name;
  final String image; // Optional, if you want to use the image later
  final String categoryName; // Optional, if you want to use the category name

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.categoryName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      image: json['image'], // Assuming this is a base64 string or URL
      categoryName: json['categoryName'],
    );
  }
}

// SubSubcategory model
class SubSubcategory {
  final int id;
  final String name;
  final String image; // Optional, if you want to use the image later
  final Subcategory subCategory; // The subcategory object

  SubSubcategory({
    required this.id,
    required this.name,
    required this.image,
    required this.subCategory,
  });

  factory SubSubcategory.fromJson(Map<String, dynamic> json) {
    return SubSubcategory(
      id: json['id'],
      name: json['name'],
      image: json['image'], // Assuming this is a base64 string or URL
      subCategory: Subcategory.fromJson(json['subCategory']),
    );
  }
}

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
  final TextEditingController subsubcategoryController = TextEditingController();

  bool isAvailable = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _token;
  int? _parlourId; // Store parlour ID

  List<Subcategory> _subcategories = [];
  Subcategory? _selectedSubcategory;

  List<Category> _categories = [];
  Category? _selectedCategory;

  List<SubSubcategory> _subSubcategories = [];
  SubSubcategory? _selectedSubSubcategory;

  @override
  void initState() {
    super.initState();
    _loadTokenAndParlourId();
    _fetchSubcategories(); // Fetch subcategories when the page loads
    _fetchCategories(); // Fetch categories when the page loads
    _fetchSubSubcategories(); // Fetch sub-subcategories when the page loads
  }

  Future<void> _loadTokenAndParlourId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken');
      _parlourId = prefs.getInt('parlourId'); // Load parlour ID
    });
  }

  Future<void> _fetchSubcategories() async {
    final url = Uri.parse('http://192.168.1.20:8086/api/SubCategory/all');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _subcategories = data.map((json) => Subcategory.fromJson(json)).toList();
          print('Fetched subcategories: $_subcategories'); // Debugging line
        });
      } else {
        _showError('Failed to load subcategories');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  Future<void> _fetchCategories() async {
    final url = Uri.parse('http://192.168.1.20:8086/api/Categories/all');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _categories = data.map((json) => Category.fromJson(json)).toList();
          print('Fetched categories: $_categories'); // Debugging line
        });
      } else {
        _showError('Failed to load categories');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  Future<void> _fetchSubSubcategories() async {
    final url = Uri.parse('http://192.168.1.20:8086/api/SubSubCategory/all');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _subSubcategories = data.map((json) => SubSubcategory.fromJson(json)).toList();
          print('Fetched sub-subcategories: $_subSubcategories'); // Debugging line
        });
      } else {
        _showError('Failed to load sub-subcategories');
      }
    } catch (e) {
      _showError('Error: $e');
    }
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

    if (_parlourId == null) {
      _showError('Parlour ID is not available. Please log in again.');
      return false;
    }

    final timePattern = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d$');
    if (!timePattern.hasMatch(timeController.text)) {
      _showError('Please enter a valid time in hh:mm:ss format');
      return false;
    }

    if (_selectedImage == null) {
      _showError('Please select an image');
      return false;
    }

    if (_selectedSubcategory == null) {
      _showError('Please select a subcategory');
      return false;
    }

    if (_selectedCategory == null) {
      _showError('Please select a gender');
      return false;
    }

    if (_selectedSubSubcategory == null) {
      _showError('Please select a sub-subcategory');
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
    final url = Uri.parse('http://192.168.1.20:8086/api/Items/AddItems');
    if (_token == null) {
      _showError('Token is not available. Please log in again.');
      return;
    }

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $_token';

      request.fields['itemName'] = serviceData['itemName'];
      request.fields['price'] = serviceData['price']; // Ensure this is a string
      request.fields['serviceTime'] = serviceData['serviceTime']; // Ensure this is in the correct format
      request.fields['categoryId'] = _selectedCategory!.id.toString(); // Use the selected category ID
      request.fields['subCategoryId'] = _selectedSubcategory!.id.toString(); // Use the selected subcategory ID
      request.fields['subSubCategoryId'] = _selectedSubSubcategory!.id.toString(); // Use the selected sub-subcategory ID
      request.fields['parlourId'] = _parlourId.toString(); // Use the loaded parlourId
      request.fields['description'] = serviceData['description'];
      request.fields['availability'] = serviceData['availability'] ? 'true' : 'false';

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'itemImage',
          _selectedImage!.path,
          filename: 'itemImage.jpg',
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Service added successfully'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        _showError('Failed to add service: $responseBody');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hint,
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
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
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
          'Add New Service',
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
                      Hero(
                        tag: 'serviceImage',
                        child: GestureDetector(
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
                      ),
                      const SizedBox(height: 32),
                      _buildInputField(
                        controller: nameController,
                        label: 'Service Name',
                        icon: Icons.spa,
                        hint: 'Enter service name',
                      ),
                      _buildInputField(
                        controller: priceController,
                        label: 'Price',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        hint: 'Enter price',
                      ),
                      _buildInputField(
                        controller: timeController,
                        label: 'Duration',
                        icon: Icons.access_time,
                        hint: 'hh:mm:ss',
                      ),
                      _buildInputField(
                        controller: descriptionController,
                        label: 'Description',
                        icon: Icons.description,
                        hint: 'Enter service description',
                      ),
                      // Dropdown for Category (Gender)
                      DropdownButtonFormField<Category>(
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        value: _selectedCategory,
                        items: _categories.map((Category category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (Category? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        hint: Text('Select a gender'),
                      ),
                      // Dropdown for Subcategory
                      DropdownButtonFormField<Subcategory>(
                        decoration: InputDecoration(
                          labelText: 'Subcategory',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        value: _selectedSubcategory,
                        items: _subcategories.map((Subcategory subcategory) {
                          return DropdownMenuItem<Subcategory>(
                            value: subcategory,
                            child: Text(subcategory.name),
                          );
                        }).toList(),
                        onChanged: (Subcategory? newValue) {
                          setState(() {
                            _selectedSubcategory = newValue;
                          });
                        },
                        hint: Text('Select a subcategory'),
                      ),
                      // Dropdown for SubSubcategory
                      DropdownButtonFormField<SubSubcategory>(
                        decoration: InputDecoration(
                          labelText: 'Sub-Subcategory',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        value: _selectedSubSubcategory,
                        items: _subSubcategories.map((SubSubcategory subSubcategory) {
                          return DropdownMenuItem<SubSubcategory>(
                            value: subSubcategory,
                            child: Text(subSubcategory.name),
                          );
                        }).toList(),
                        onChanged: (SubSubcategory? newValue) {
                          setState(() {
                            _selectedSubSubcategory = newValue;
                          });
                        },
                        hint: Text('Select a sub-subcategory'),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            'Available',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: isAvailable,
                          onChanged: (value) {
                            setState(() {
                              isAvailable = value;
                            });
                          },
                          activeColor: Color(0xFF1E88E5),
                          activeTrackColor: Colors.blue.shade100,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_validateFields()) {
                              final serviceData = {
                                'itemName': nameController.text,
                                'price': priceController.text,
                                'description': descriptionController.text,
                                'availability': isAvailable,
                                'itemImage': _selectedImage?.path,
                                'categoryId': _selectedCategory!.id.toString(), // Use the selected category ID
                                'subCategoryId': _selectedSubcategory!.id.toString(), // Use the selected subcategory ID
                                'subSubCategoryId': _selectedSubSubcategory!.id.toString(), // Use the selected sub-subcategory ID
                                'serviceTime': timeController.text,
                              };
                              _saveServiceToBackend(serviceData);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1E88E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Save Service',
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