import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homepage/add%20employees.dart';
import 'package:homepage/appoinments.dart';
import 'package:homepage/add%20services.dart';
import 'package:homepage/color.dart';  // Assuming this file contains your color constants
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int activeEmployees = 0;  // To store active employee count
  int totalServices = 0;    // To store total service count

  @override
  void initState() {
    super.initState();
    _fetchEmployeeCount();  // Fetch the initial employee count when the page loads
    _fetchServiceCount();
  }

  Future<void> _fetchServiceCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final parlourId = prefs.getInt('parlourId')?.toString();
      
      final url = 'http://192.168.1.26:8086/api/Items/itemByParlourId?parlourId=$parlourId';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> Services = json.decode(response.body);
        setState(() {
          totalServices = Services.length;
        });
      } else {
        throw Exception('Failed to fetch Services count');
      }
    } catch (e) {
      _showError('Error fetching Services count: $e');
    }
  }

  // Fetch the employee count from the server
  Future<void> _fetchEmployeeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final parlourId = prefs.getInt('parlourId')?.toString();
      
      final url = 'http://192.168.1.26:8086/api/employees/by-parlourId?parlourId=$parlourId';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> employees = json.decode(response.body);
        setState(() {
          activeEmployees = employees.length;
        });
      } else {
        throw Exception('Failed to fetch employee count');
      }
    } catch (e) {
      _showError('Error fetching employee count: $e');
    }
  }

  // Show error messages using SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
    );
  }

  // Navigate to AddEmployeePage and update the employee count when a new employee is added
   Future<void> _navigateAndAddEmployee() async {
    final updatedEmployeeCount = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (context) => AddEmployees()),
    );

    if (updatedEmployeeCount != null) {
      setState(() {
        activeEmployees = updatedEmployeeCount;
      });
    }
  }

  // Navigate to ServicesPage and update the total number of services
  Future<void> _navigateAndFetchServices() async {
    final updatedServiceCount = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (context) => ServicesPage()),
    );

    if (updatedServiceCount != null) {
      setState(() {
        totalServices = updatedServiceCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Header Section
            Container(
              padding: EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
              decoration: BoxDecoration(
                color: AppColors.kPrimary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 14,
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Beauty Salon',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.kPrimary,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat('Today\'s\nAppointments', '12'),
                        // ignore: deprecated_member_use
                        Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.3)),
                        _buildStat('Active\nEmployees', '$activeEmployees'),
                        // ignore: deprecated_member_use
                        Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.3)),
                        _buildStat('Total\nServices', '$totalServices'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPremiumActionCard(
                        'Add\nEmployees',
                        Icons.person_add_rounded,
                        _navigateAndAddEmployee,
                      ),
                      _buildPremiumActionCard(
                        'Manage\nAppointments',
                        Icons.calendar_today_rounded,
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentsPage())),
                      ),
                      _buildPremiumActionCard(
                        'Add\nServices',
                        Icons.spa_rounded,
                        _navigateAndFetchServices,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Recent Activity Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildActivityCard(
                    'New Appointment',
                    'Sarah Johnson - Hair Styling',
                    '10:30 AM',
                    Icons.access_time_rounded,
                  ),
                  SizedBox(height: 15),
                  _buildActivityCard(
                    'Service Completed',
                    'Emma Davis - Manicure',
                    '09:15 AM',
                    Icons.check_circle_outline_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.kPrimary,
          ),
        ),
        SizedBox(height: 5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumActionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.27,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.kPrimary,
                size: 24,
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(String title, String subtitle, String time, IconData icon) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.kPrimary,
              size: 24,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
