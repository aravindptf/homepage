import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homepage/Login.dart';
import 'package:homepage/editprofile.dart';
import 'package:homepage/fetchparlour.dart';
import 'package:homepage/homepage.dart';
import 'package:homepage/notification.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage; // Holds the selected profile image

  Future<void> _pickImage() async {
    // Show options for picking image
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery, // or ImageSource.camera for camera
      maxWidth: 600,
      imageQuality: 85, // Adjust quality to save data
    );

    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToHomePage(context);
        return false; // Prevent default back button behavior
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.deepPurple.shade800),
            onPressed: () => _navigateToHomePage(context),
          ),
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
                      backgroundImage: _profileImage == null
                          ? NetworkImage(
                              'https://i0.wp.com/therighthairstyles.com/wp-content/uploads/2021/09/2-mens-undercut.jpg?resize=500%2C503',
                            )
                          : FileImage(File(_profileImage!.path))
                              as ImageProvider, // Show selected image
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
                        child: Center(
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt_outlined,
                              size: 16,
                            ),
                            color: Colors.white,
                            onPressed: _pickImage, // Open image picker
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Positioned name and email
            Positioned(
              top: 130,
              left: 60, // Adjust the left alignment to 0
              right: 0,
              child: Center(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center the text horizontally
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
                              builder: (context) => ParlourDetailsPage()));
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
                    title: Text('Notifications',
                        style: TextStyle(color: Colors.deepPurple.shade800)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.deepPurple.shade800),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationPage(
                                  
                                )),
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
      MaterialPageRoute(builder: (context) => HomePage()),
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
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Logged out successfully'),
                ));
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