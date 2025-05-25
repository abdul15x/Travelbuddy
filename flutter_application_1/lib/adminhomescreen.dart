import 'package:flutter/material.dart';
import 'package:flutter_application_1/tour_list_screen.dart'; // Import the new tour list screen
import 'package:flutter_application_1/add_new_tour_screen.dart'; // Import Add New Tour Screen

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
        backgroundColor: Colors.blue.shade800,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings (optional)
              print("Settings button pressed");
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to the Admin Dashboard!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                // Card for "View Tours" Button
                _buildAdminCard(
                  context,
                  label: 'View Tours',
                  icon: Icons.list_alt,
                  colorStart: Colors.blue.shade600,
                  colorEnd: Colors.blue.shade400,
                  onPressed: () {
                    // Navigate to the Tour List Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TourListScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Card for "Add New Tour" Button
                _buildAdminCard(
                  context,
                  label: 'Add New Tour',
                  icon: Icons.add_circle_outline,
                  colorStart: Colors.green.shade600,
                  colorEnd: Colors.green.shade400,
                  onPressed: () {
                    // Navigate to the Add New Tour Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddNewTourScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom method to build each card with animated effect
  Widget _buildAdminCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color colorStart,
    required Color colorEnd,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorStart, colorEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: colorStart.withOpacity(0.4),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centering the content
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center, // Centering the text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
