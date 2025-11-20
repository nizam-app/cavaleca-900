import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  static String routeName = "/role-selection";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IBACOS'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo and Tagline
            Center(
              child: Column(
                children: [
                  Image.network(
                    'https://i.ibb.co/L1LqgGJ/logo.png',
                    width: 100,
                  ), // Replace with your logo path
                  SizedBox(height: 10),
                  Text(
                    'Field Service Management Platform',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),

            // Role selection
            Text(
              'Select Your Role',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Customer Role
            RoleCard(
              color: Colors.red,
              title: 'Customer',
              description: 'Book and manage service requests',
              icon: Icons.person,
              onTap: () {
                // Handle Customer Role selection
              },
            ),
            SizedBox(height: 16),

            // Freelancer Technician Role
            RoleCard(
              color: Colors.orange,
              title: 'Freelancer Technician',
              description: 'Accept jobs and earn commissions',
              icon: Icons.work,
              onTap: () {
                // Handle Freelancer Technician Role selection
              },
            ),
            SizedBox(height: 16),

            // Internal Technician Role
            RoleCard(
              color: Colors.blue,
              title: 'Internal Technician',
              description: 'Manage assigned jobs and schedule',
              icon: Icons.settings,
              onTap: () {
                // Handle Internal Technician Role selection
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final Color color;
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const RoleCard({
    required this.color,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
