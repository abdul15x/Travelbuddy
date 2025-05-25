import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ride_detail_screen.dart'; // Import the new screen

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Ensure the user is logged in
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: const Center(
          child: Text('You are not logged in. Please log in first.'),
        ),
      );
    }

    // Debug: Print the current user's email and UID
    if (kDebugMode) {
      print("Current user's email: ${user.email}");
      print("Current user's UID: ${user.uid}");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!) 
                        : const AssetImage('assets/favicon.png') as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.displayName ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email ?? 'Email not available',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Bookings Section Title
            const Text(
              'Your Bookings:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Stream to fetch bookings for the current user using user.uid
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings') // Query the bookings collection
                    .where('userId', isEqualTo: user.uid) // Query by UID (assuming 'userId' stores the UID)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    // Debug: Log that no bookings were found
                    print("No bookings found for UID: ${user.uid}");
                    return const Center(child: Text('No bookings found.'));
                  }

                  final bookings = snapshot.data!.docs;
                  print("Found ${bookings.length} bookings.");

                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final bookingData = bookings[index].data() as Map<String, dynamic>;

                      // Debug: Log the booking data
                      print("Booking Data: $bookingData");

                      final rideId = bookingData['rideId'] ?? 'N/A'; // Assuming rideId is stored in the booking data

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            'Carpool Ride ID: $rideId',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Seats booked: ${bookingData['seatsBooked']}'),
                              Text('From: ${bookingData['from']}'),
                              Text('To: ${bookingData['to']}'),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white, backgroundColor: Colors.blue.shade600, // Text color to white
                                      textStyle: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      // Navigate to RideDetailScreen instead of BookingConfirmationScreen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RideDetailScreen(
                                            from: bookingData['from'] ?? 'N/A',
                                            to: bookingData['to'] ?? 'N/A',
                                            seatsBooked: bookingData['seatsBooked'] ?? 0,
                                            date: bookingData['date'] ?? '',
                                            time: bookingData['time'] ?? '',
                                            fare: bookingData['fare'] ?? 0.0,
                                            driverName: bookingData['driverName'] ?? 'N/A', // Assuming the driver info is in the booking data
                                            driverContact: bookingData['driverContact'] ?? 'N/A', // Assuming the driver contact is in the booking data
                                            carpoolId: rideId,
                                            docId: bookings[index].id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('See Details'),
                                  ),
                                  // Add more actions if needed here
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
