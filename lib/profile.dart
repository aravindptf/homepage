import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(260),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          toolbarHeight: 200,
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 65,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1760&q=80',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'John Doe',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Senior Developer',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileOption(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'View and edit your personal details',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              subtitle: 'Control your privacy settings',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out from your account',
              onTap: () {},
              showDivider: false,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade800,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            color: Colors.grey[200],
            thickness: 1,
            indent: 70,
            endIndent: 20,
          ),
      ],
    );
  }
}
