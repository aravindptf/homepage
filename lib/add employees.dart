import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homepage/add%20new%20employees.dart';
import 'package:homepage/color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

    class AddEmployees extends StatefulWidget {
  const AddEmployees({super.key}); 

  @override
  _AddEmployeesState createState() => _AddEmployeesState();
} 

class _AddEmployeesState extends State<AddEmployees> { 
  List<Map<String, dynamic>> employees = [];
  bool isLoading = true;
  String? _token;
  String? _parlourId;

  // Controllers for editing employee data
  late TextEditingController _nameController;
  bool _isAvailable = true;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _initializeApp(); 
  }

  Future<void> _initializeApp() async {
    await _loadToken();
    await _loadParlourId();
    if (_parlourId != null) {
      await fetchEmployees();
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Parlour ID is missing. Please log in again.')),
      );
    }
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    setState(() => _token = token);
  }

  Future<void> _loadParlourId() async {
    final prefs = await SharedPreferences.getInstance();
    final parlourId = prefs.getInt('parlourId');
    if (parlourId != null) {
      setState(() => _parlourId = parlourId.toString());
    }
  }

  Future<void> fetchEmployees() async {
    try {
      if (_parlourId == null) throw Exception("Parlour ID is missing.");

      final url =
          'http://192.168.1.14:8086/api/employees/by-parlourId?parlourId=$_parlourId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          employees = jsonResponse.map((employee) {
            return {
              'id': employee['id'],
              'employeeName': employee['employeeName'],
              'isAvailable': employee['isAvailable'] ?? true,
              'image': employee['image'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load employees.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveEmployee(int employeeId) async {
    final url =
        Uri.parse('http://192.168.1.14:8086/api/employees/updateEmployee');

    try {
      var request = http.MultipartRequest("PUT", url);
      request.headers.addAll({'Authorization': 'Bearer $_token'});

      // Ensure availability status is sent correctly
      request.fields['employeeId'] = employeeId.toString();
      request.fields['employeeName'] = _nameController.text;
      request.fields['isAvailable'] =
          _isAvailable ? "true" : "false"; // Convert boolean to string

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        // Refresh employee list after update
        await fetchEmployees();

        // Close only the edit dialog, not the whole page
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Employee updated successfully."),
              backgroundColor: Colors.green),
        );
      } else {
        throw Exception('Failed to update employee.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      if (_token == null || _token!.isEmpty) {
        throw Exception('Authentication token is unavailable.');
      }

      final url =
          'http://192.168.1.14:8086/api/employees/delete?employeeId=$id';
      final confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
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
          actions: [
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
         onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
          ],
        ),
      );
      if (confirmDelete == true) {
        final response = await http.delete(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            employees.removeWhere((employee) => employee['id'] == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Employee deleted successfully.")),
          );
        } else {
          throw Exception("Failed to delete employee.");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void navigateToEditEmployee(Map<String, dynamic> employee) {
    _nameController = TextEditingController(text: employee['employeeName']);
    _isAvailable =
        employee['isAvailable'] ?? true; // Ensure correct boolean value
    _imageFile = null; // Reset selected image

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Employee"),
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _pickImage((image) {
                            setDialogState(() {
                              _imageFile = image;
                            });
                          });
                        },
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF1E88E5), width: 3),
                            image: _imageFile != null
                                ? DecorationImage(
                                    image: FileImage(_imageFile!),
                                    fit: BoxFit.cover,
                                  )
                                : (employee['image'] != null &&
                                        employee['image'].isNotEmpty
                                    ? DecorationImage(
                                        image: employee['image']
                                                .startsWith('http')
                                            ? NetworkImage(employee['image'])
                                            : (employee['image']
                                                    .contains('/data/user')
                                                ? FileImage(
                                                    File(employee['image']))
                                                : MemoryImage(base64Decode(
                                                    employee['image']))),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                          ),
                          child: _imageFile == null &&
                                  (employee['image'] == null ||
                                      employee['image'].isEmpty)
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_a_photo,
                                        size: 40, color: Color(0xFF1E88E5)),
                                    SizedBox(height: 8),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(
                                          color: Color(0xFF1E88E5),
                                          fontWeight: FontWeight.w500),
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
                      SwitchListTile(
                        title: const Text("Availability"),
                        value: _isAvailable,
                        onChanged: (value) {
                          setDialogState(() {
                            _isAvailable = value; // Update switch in real-time
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _saveEmployee(employee['id']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage(Function(File) updateImage) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      updateImage(File(pickedFile.path));
    }
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
      body: Stack(
        children: [
          Column(
            children: [
              // Premium Header with gradient similar to HomePage
              Container(
                padding: const EdgeInsets.only(
                    top: 60, left: 20, right: 20, bottom: 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.deepPurple.shade50,
                      Colors.deepPurple.shade800,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                          onTap: () => Navigator.pop(context),
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
                              color: Colors.deepPurple,
                              size: 24,
                            ),
                          ),
                        ),
                        // Page title
                        const Text(
                          'Employees',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        // Refresh button with premium styling
                        GestureDetector(
                          onTap: fetchEmployees,
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
                              color: Colors.deepPurple,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Employees List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : employees.isEmpty
                          ? const Center(child: Text("No employees found."))
                          : ListView.builder(
                              padding: const EdgeInsets.all(10),
                              itemCount: employees.length,
                              itemBuilder: (context, index) {
                                final employee = employees[index];

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
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor:
                                          Colors.grey[300], // Placeholder color
                                      backgroundImage: employee['image'] !=
                                                  null &&
                                              employee['image'].isNotEmpty
                                          ? (employee['image'].startsWith(
                                                  'http') // Check if it's a URL
                                              ? NetworkImage(employee['image'])
                                              : (employee['image'].contains(
                                                      '/data/user') // Check if it's a file path
                                                  ? FileImage(File(
                                                          employee['image']))
                                                      as ImageProvider
                                                  : MemoryImage(base64Decode(
                                                      employee[
                                                          'image'])))) // Otherwise, decode Base64
                                          : const AssetImage(
                                                  'assets/placeholder.jpg')
                                              as ImageProvider, // Default Image
                                    ),
                                    title: Text(
                                        employee['employeeName'] ?? 'No Name',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                        "Availability: ${employee['isAvailable'] ? "Available" : "Not Available"}"),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () =>
                                                navigateToEditEmployee(
                                                    employee)),
                                        Container(
                                          height: 36,
                                          width: 36,
                                          decoration: BoxDecoration(
                                            color: AppColors.kAccentError
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                              Icons.delete_outline_rounded,
                                              color: AppColors.kAccentError,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              deleteEmployee(employee['id']);
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
              color: Colors.deepPurple.withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to add new employee page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddnewEmployeePage()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}
