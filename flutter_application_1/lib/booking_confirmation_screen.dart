import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingConfirmationScreen extends StatefulWidget {
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
  final int seatsBooked;
  final int bookedSeats;
  final String name;
  final String phone;

  const BookingConfirmationScreen({
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
    required this.fare,
    required this.seatsBooked,
    required this.bookedSeats,
    required this.name,
    required this.phone,
  });

  @override
  _BookingConfirmationScreenState createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Function to handle the confirmation of booking
  void _confirmBooking() async {
    final String name = _nameController.text;
    final String phone = _phoneController.text;

    // Validation for name and phone
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and phone number')),
      );
      return;
    }

    try {
      // Reference to the carpool document in Firestore
      final docRef = FirebaseFirestore.instance.collection('carpooling').doc(widget.docId);

      // Check if the document exists
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // If the document doesn't exist, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carpool document not found. Please try again later.')),
        );
        return;
      }

      // Proceed with updating the booking details and the user data
      await FirebaseFirestore.instance.collection('bookings').add({
        'carpoolId': widget.carpoolId,
        'docId': widget.docId,
        'from': widget.from,
        'to': widget.to,
        'date': widget.date,
        'time': widget.time,
        'fare': widget.fare,
        'seatsBooked': widget.seatsBooked,
        'bookedSeats': widget.bookedSeats,
        'name': name,
        'phone': phone,
        'driverName': widget.driverName,
        'driverContact': widget.driverContact,
      });

      // Reduce available seats in the carpool document
      await docRef.update({
        'seats': widget.availableSeats - widget.seatsBooked,
      });

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed!')),
      );

      // Optionally, navigate to a different screen or show a success dialog
      Navigator.pop(context); // Close the booking screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error confirming booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Information
            Text(
              'Carpool from: ${widget.from} to: ${widget.to}',
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
            Text(
              'Driver: ${widget.driverName}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Available Seats: ${widget.availableSeats}',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            Text(
              'Fare per Seat: ₹${widget.fare}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Seats Booked: ${widget.seatsBooked}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Total Booked Seats: ${widget.bookedSeats}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // User details form with improved design
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Confirm Booking Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue.shade600, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _confirmBooking,
                child: const Text(
                  'Confirm Booking',
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
