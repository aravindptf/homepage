import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homepage/add%20employees.dart';
import 'package:homepage/add%20services.dart';

import 'package:homepage/appoinments.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Premium color palette for the beauty salon app
class AppColors {
  // Primary color - A rich purple that conveys luxury
  static const Color kPrimary = Color(0xFF8A2BE2); // Deep purple

  // Secondary color - Soft gold for an elegant accent
  static const Color kSecondary = Color(0xFFDAAA00);

  // Background color - Soft white for a clean look
  static const Color kBackground = Color(0xFFF9F6FF);

  // Card backgrounds - Pure white for contrast
  static const Color kCardBackground = Colors.white;

  // Text colors
  static const Color kTextDark = Color(0xFF2D2D3A); // Nearly black but softer
  static const Color kTextMedium = Color(0xFF6B6B7B); // Medium gray with slight purple tint
  static const Color kTextLight = Color(0xFF9E9EAF); // Light gray with slight purple tint

  // Accent colors for indicators and highlights
  static const Color kAccentSuccess = Color(0xFF4CAF84); // Emerald green
  static const Color kAccentWarning = Color(0xFFFFB74D); // Amber
  static const Color kAccentError = Color(0xFFE57373); // Coral red

  // Shadow color
  static const Color kShadow = Color(0x148A2BE2); // Primary color with low opacity for shadows
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int activeEmployees = 0; // To store active employee count
  int totalServices = 0; // To store total service count
  bool _isRefreshing = false; // To track if refresh is in progress

  @override
  void initState() {
    super.initState();
    _fetchEmployeeCount(); // Fetch the initial employee count when the page loads
    _fetchServiceCount();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true; // Start showing the circular indicator
    });

    try {
      // Fetch updated counts
      await _fetchEmployeeCount();
      await _fetchServiceCount();

      // Simulate a delay if no updates are found
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      _showSuccess('Updated successfully');
    } catch (e) {
      _showError('Error during refresh: $e');
    } finally {
      setState(() {
        _isRefreshing = false; // Hide the circular indicator
      });
    }
  }

  Future<void> _fetchServiceCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final parlourId = prefs.getInt('parlourId')?.toString();

      final url =
          'http://192.168.1.200:8086/api/Items/itemByParlourId?parlourId=$parlourId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final List services = json.decode(response.body);
        setState(() {
          totalServices = services.length;
        });
      } else {
        throw Exception('Failed to fetch Services count');
      }
    } catch (e) {
      _showError('Error fetching Services count: $e');
    }
  }

  Future<void> _fetchEmployeeCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final parlourId = prefs.getInt('parlourId')?.toString();

      final url =
          'http://192.168.1.200:8086/api/employees/by-parlourId?parlourId=$parlourId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final List employees = json.decode(response.body);
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.kAccentError,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.kAccentSuccess,
      ),
    );
  }

  Future<void> _navigateAndAddEmployee() async {
    try {
      final updatedEmployeeCount = await Navigator.push<int>(
        context,
        MaterialPageRoute(builder: (context) => AddEmployees()),
      );

      if (updatedEmployeeCount != null) {
        setState(() {
          activeEmployees = updatedEmployeeCount;
        });
      }
    } catch (e) {
      _showError('Error navigating to Add Employees: $e');
    }
  }

  Future<void> _navigateAndFetchServices() async {
    try {
      final updatedServiceCount = await Navigator.push<int>(
        context,
        MaterialPageRoute(builder: (context) => ServicesPage()),
      );

      if (updatedServiceCount != null) {
        setState(() {
          totalServices = updatedServiceCount;
        });
      }
    } catch (e) {
      _showError('Error navigating to Services Page: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header Section with updated design
                Container(
                  padding:
                      const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.kPrimary,
                        const Color(0xFF6A0DAD), // Darker variant of primary for gradient
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kShadow,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Beauty Salon',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _refreshData, // Refresh button
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
                                color: AppColors.kPrimary,
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Premium stats card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: AppColors.kCardBackground,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStat("Today's\nAppointments", '12'),
                            Container(
                                height: 45,
                                width: 1,
                                color: Colors.grey.withOpacity(0.2)),
                            _buildStat('Active\nEmployees', '$activeEmployees'),
                            Container(
                                height: 45,
                                width: 1,
                                color: Colors.grey.withOpacity(0.2)),
                            _buildStat('Total\nServices', '$totalServices'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick Actions Section with updated design
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kTextDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
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
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AppointmentsPage())),
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

                // Recent Activity Section with updated design
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kTextDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildActivityCard(
                        'New Appointment',
                        'Sarah Johnson - Hair Styling',
                        '10:30 AM',
                        Icons.access_time_rounded,
                      ),
                      const SizedBox(height: 15),
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

          // Circular Progress Indicator
          if (_isRefreshing)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.kPrimary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.kPrimary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.kTextMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumActionCard(
      String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.27,
        padding: const EdgeInsets.all(16),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kPrimary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.kPrimary,
                size: 24,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.kTextDark,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
      String title, String subtitle, String time, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.kPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.kPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kTextDark,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.kTextMedium,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.kTextLight,
            ),
          ),
        ],
      ),
    );
  }
}