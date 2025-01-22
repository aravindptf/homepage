import 'package:flutter/material.dart';
import 'package:homepage/add%20employees.dart';
import 'package:homepage/add%20services.dart';
import 'package:homepage/appoinments.dart';
import 'package:homepage/profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int activeIndex = 0;
  int newAppointmentsCount = 3;
  
   // Example count for demonstration

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade800, Colors.blue.shade400],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Beautiful!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Manage your salon with ease',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 35, color: Colors.blue),
                    ),
                  ],
                ),
              ),



              SizedBox(height: 120),

              // Main Content Area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text('See All'),
                            ),
                          ],
                        ),
                      ),
                      
                      // Quick Action Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickActionCard(
                              'Add\nEmployees',
                              Icons.person_add,
                              Colors.purple,
                              () => Navigator.push(context, 
                                MaterialPageRoute(builder: (context) => AddEmployees())
                              ),
                            ),
                            _buildQuickActionCard(
                              'Manage\nAppointments',
                              Icons.calendar_today,
                              Colors.orange,
                              () => Navigator.push(context,
                                MaterialPageRoute(builder: (context) => AppointmentsPage())
                              ),
                            ),
                            _buildQuickActionCard(
                              'Add\nServices',
                              Icons.spa,
                              Colors.green,
                              () => Navigator.push(context,
                                MaterialPageRoute(builder: (context) => ServicesPage())
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Upcoming Appointments Preview
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next Appointment',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.shade200,
                                    child: Text('SC'),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sarah Connor',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Hair Styling - 2:30 PM',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
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
  if (index == 2) { // Assuming index 2 is for the Profile button
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }      
},

          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
           
            BottomNavigationBarItem(icon: Icon(Icons.notifications_active), label: 'Notification'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.27,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}