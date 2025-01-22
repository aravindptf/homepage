import 'package:flutter/material.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  String _selectedFilter = 'Daily'; // Default filter is 'Daily'

  // Static data for demonstration purposes
  final List<Map<String, String>> allAppointments = [
    {"time": "10:00 AM", "customer": "John Doe", "service": "Haircut", "filter": "Daily", "status": "Pending"},
    {"time": "11:00 AM", "customer": "Alice Johnson", "service": "Hair Spa", "filter": "Daily", "status": "On Progress"},
    {"time": "12:00 PM", "customer": "Jane Smith", "service": "Manicure", "filter": "Weekly", "status": "Pending"},
    {"time": "01:00 PM", "customer": "Michael Lee", "service": "Facial", "filter": "Monthly", "status": "On Progress"},
    {"time": "03:00 PM", "customer": "Sarah Brown", "service": "Pedicure", "filter": "Weekly", "status": "Pending"},
    {"time": "04:00 PM", "customer": "David White", "service": "Haircut", "filter": "Monthly", "status": "On Progress"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments ($_selectedFilter)'), // Display selected filter here
        backgroundColor: Colors.black26,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value; // Update the selected filter
              });
            },
            itemBuilder: (BuildContext context) {
              return ['Daily', 'Weekly', 'Monthly'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _buildAppointmentsList(),
    );
  }

  // Build the filtered list of appointments
  Widget _buildAppointmentsList() {
    // Define filter priority
    final filterPriority = {
      'Daily': 1,
      'Weekly': 2,
      'Monthly': 3,
    };

    // Filter appointments based on the selected filter
    final filteredAppointments = allAppointments
        .where((appointment) =>
            filterPriority[appointment['filter']]! <= filterPriority[_selectedFilter]!)
        .toList();

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Text(
          'No Appointments for $_selectedFilter',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text('${appointment['customer']} - ${appointment['service']}'),
            subtitle: Text('Time: ${appointment['time']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appointment['status']!,
                  style: TextStyle(
                    color: appointment['status'] == 'Pending'
                        ? Colors.red
                        : appointment['status'] == 'On Progress'
                            ? Colors.blue
                            : Colors.green,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      appointment['status'] = 'Completed';
                    });
                  },
                  child: Text('Complete'),
                ),
              ],
            ),
            onTap: () {
              // Handle tap if needed (e.g., show details of the appointment)
            },
          ),
        );
      },
    );
  }
}