import 'package:flutter/material.dart';
import 'package:homepage/homepage.dart';
import 'package:homepage/offers.dart';
import 'package:homepage/profile_1.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator

class Homecontent extends StatefulWidget {
  const Homecontent({super.key});

  @override
  State<Homecontent> createState() => _HomecontentState();
}

class _HomecontentState extends State<Homecontent> with WidgetsBindingObserver {
  int activeIndex = 0;

  // Define unique pages for navigation
  final List<Widget> pages = [
    HomePage(), // Main Home page
    Offers(), // Offers page
    Profile(), // Profile page
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Show confirmation dialog when back button is pressed
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit Application'),
            content: Text('Do you really want to exit the application?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // No
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Yes
                  SystemNavigator.pop(); // Exit the application
                },
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false; // Return false if the dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Set the onWillPop callback
      child: Scaffold(
        body: IndexedStack(
          index: activeIndex,
          children: pages, // Display the appropriate page based on activeIndex
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: activeIndex,
            onTap: (index) {
              setState(() {
                activeIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_active), label: 'Offers'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}