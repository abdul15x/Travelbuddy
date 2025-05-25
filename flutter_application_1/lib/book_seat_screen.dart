import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/booking_confirmation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookSeatScreen extends StatefulWidget {
  final String carpoolId;
  final String docId;
  final String from;
  final String to;
  final int availableSeats;
  final String driverName;
  final String driverContact;
  final String date;
  final String time;
  final double fare;

  const BookSeatScreen({
    super.key,
    required this.carpoolId,
    required this.docId,
    required this.from,
    required this.to,
    required this.availableSeats,
    required this.driverName,
    required this.driverContact,
    required this.date,
    required this.time,
    required this.fare, required QueryDocumentSnapshot<Object?> rideData,
  });

  @override
  _BookSeatScreenState createState() => _BookSeatScreenState();
}

class _BookSeatScreenState extends State<BookSeatScreen> {
  late int availableSeats;

  @override
  void initState() {
    super.initState();
    availableSeats = widget.availableSeats;
  }

  // Function to handle booking and update seat count in Firestore
  void bookSeat() async {
    if (availableSeats > 0) {
      // Decrease the available seats immediately in the UI
      setState(() {
        availableSeats -= 1;
      });

      try {
        // Reference to the correct carpooling document in Firestore
        final docRef = FirebaseFirestore.instance.collection('carpooling').doc(widget.docId);

        // Start a Firestore transaction to handle the seat update atomically
        FirebaseFirestore.instance.runTransaction((transaction) async {
          final docSnapshot = await transaction.get(docRef);

          if (!docSnapshot.exists) {
            // If the document doesn't exist, revert the available seats in the UI and show an error message
            setState(() {
              availableSeats += 1; // Revert the available seats in the UI
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Carpool document not found. Please try again later.')),
            );
            return;
          }

          // Check if there are enough available seats
          final currentSeats = docSnapshot['seats'];
          if (currentSeats <= 0) {
            // Revert available seats in UI and show a message
            setState(() {
              availableSeats += 1;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No seats available')),
            );
            return;
          }

          // Update the available seats in Firestore
          transaction.update(docRef, {'seats': currentSeats - 1});

          // After successful seat update, store the booking information
          final user = FirebaseAuth.instance.currentUser;
          final bookingData = {
            'userId': user?.uid,
            'rideId': widget.carpoolId,
            'seatsBooked': 1,  // Assuming the user is booking 1 seat
            'from': widget.from,
            'to': widget.to,
            'fare': widget.fare,
            'date': widget.date,
            'time': widget.time,
            'driverName': widget.driverName,
            'driverContact': widget.driverContact,
            'bookingTime': FieldValue.serverTimestamp(),  // Record the booking time
          };

          // Add booking to the 'bookings' collection
          await FirebaseFirestore.instance.collection('bookings').add(bookingData);

          // Navigate to the BookingConfirmationScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingConfirmationScreen(
                carpoolId: widget.carpoolId,
                docId: widget.docId,
                from: widget.from,
                to: widget.to,
                availableSeats: availableSeats,
                driverName: widget.driverName,
                driverContact: widget.driverContact,
                date: widget.date,
                time: widget.time,
                fare: widget.fare,
                seatsBooked: 1,  // Assuming the user is booking 1 seat
                bookedSeats: widget.availableSeats - availableSeats, // Total booked seats
                name: '',  // You can collect the name on the next screen
                phone: '',  // You can collect the phone number on the next screen
              ),
            ),
          );
        });
      } catch (e) {
        // In case of an error, revert the availableSeats and show a Snackbar with the error
        setState(() {
          availableSeats += 1; // Revert the availableSeats
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update available seats: $e')),
        );
      }
    } else {
      // Show an error if no seats are available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No seats available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Seat'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display carpooling details in a cleaner format
            Text(
              'From: ${widget.from}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'To: ${widget.to}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Available Seats: $availableSeats',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            Text(
              'Fare per Seat: ₹${widget.fare}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Driver: ${widget.driverName}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Contact: ${widget.driverContact}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Date: ${widget.date}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Time: ${widget.time}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Booking Button with a clear, prominent look
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue.shade600, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: bookSeat,
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
