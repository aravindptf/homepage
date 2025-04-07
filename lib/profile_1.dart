import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homepage/Login.dart';
import 'package:homepage/fetchparlour.dart';
import 'package:homepage/homecontent.dart';
import 'package:homepage/offers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();
  String? _profileImagePath; // Stores the saved image path

  @override
  void initState() {
    super.initState();
  }

  /// Load saved profile image path from SharedPreferences
 

  /// Pick an image from gallery and save it
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 85,
    );

    if (image != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', image.path); // Save the path

      setState(() {
        _profileImagePath = image.path; // Update UI with new image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToHomePage(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Profile',
            style: GoogleFonts.adamina(color: Colors.deepPurple.shade800),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          
        ),
        body: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImagePath != null
                          ? FileImage(File(_profileImagePath!)) // Display saved image
                          : null,
                      child: _profileImagePath == null
                          ? Icon(Icons.person, size: 50) // Default placeholder
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade400,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt_outlined, size: 16),
                          color: Colors.white,
                          onPressed: _pickImage, // Open image picker
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 200,
              left: 16,
              right: 16,
              bottom: 0,
              child: ListView(
                children: [
                  ListTile(
                    leading:
                        Icon(Icons.person, color: Colors.deepPurple.shade800),
                    title: Text('Edit Profile',
                        style: TextStyle(color: Colors.deepPurple.shade800)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.deepPurple.shade800),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ParlourDetailsPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.history, color: Colors.deepPurple.shade800),
                    title: Text('Booking History',
                        style: TextStyle(color: Colors.deepPurple.shade800)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.deepPurple.shade800),
                    onTap: () {
                      // Navigate to Booking History Screen
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications,
                        color: Colors.deepPurple.shade800),
                    title: Text('Offers',
                        style: TextStyle(color: Colors.deepPurple.shade800)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.deepPurple.shade800),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Offers()),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.logout, color: Colors.deepPurple.shade800),
                    title: Text('Logout',
                        style: TextStyle(color: Colors.deepPurple.shade800)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.deepPurple.shade800),
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHomePage(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Homecontent()),
      (Route<dynamic> route) => false,
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('profileImagePath'); // Clear saved image
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged out successfully')),
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Loginpage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
