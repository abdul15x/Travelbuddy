import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TourDetailScreen extends StatefulWidget {
  final String tourId;

  const TourDetailScreen({super.key, required this.tourId});

  @override
  _TourDetailScreenState createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  late Future<DocumentSnapshot> _tourDetails;
  final _nameController = TextEditingController();
  final _seatsController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tourDetails = FirebaseFirestore.instance
        .collection('tours')
        .doc(widget.tourId)
        .get();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _seatsController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _bookSeat() async {
    if (_validateInputs()) {
      try {
        var tourSnapshot = await _tourDetails;
        var tourData = tourSnapshot.data() as Map<String, dynamic>;

        // Ensure that cost and availableSeats are properly parsed
        int availableSeats = _parseToInt(tourData['availableSeats']);
        int bookedSeats = int.tryParse(_seatsController.text) ?? 0;

        if (bookedSeats > availableSeats) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not enough seats available.')),
          );
          return;
        }

        // Save booking details in the "bookings" collection
        await FirebaseFirestore.instance.collection('bookings').add({
          'tourId': widget.tourId,
          'tourName': tourData['name'],
          'userName': _nameController.text,
          'userEmail': _emailController.text,
          'userPhone': _phoneController.text,
          'seatsBooked': bookedSeats,
          'specialNotes': _notesController.text,
          'bookingTime': Timestamp.now(), // Save the booking timestamp
        });

        // Update available seats in the "tours" collection
        await FirebaseFirestore.instance.collection('tours').doc(widget.tourId).update({
          'availableSeats': availableSeats - bookedSeats,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking successful!')),
        );

        // Clear input fields after booking
        _nameController.clear();
        _seatsController.clear();
        _emailController.clear();
        _phoneController.clear();
        _notesController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error booking tour: $e')),
        );
      }
    }
  }

  bool _validateInputs() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _seatsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return false;
    }

    // Check if the seats input is a valid number
    int bookedSeats = int.tryParse(_seatsController.text) ?? 0;
    if (bookedSeats <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of seats.')),
      );
      return false;
    }

    return true;
  }

  double _parseToDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0; // Parse string to double, default to 0.0 if invalid
    }
    return 0.0;
  }

  int _parseToInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value) ?? 0; // Parse string to int, default to 0 if invalid
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Details'),
        backgroundColor: const Color.fromARGB(255, 52, 142, 253),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _tourDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No tour details found.'));
          }

          var tourData = snapshot.data!.data() as Map<String, dynamic>;

          String name = tourData['name'] ?? 'Unnamed Tour';
          String description = tourData['description'] ?? 'No description available.';
          String imageUrl = tourData['imageUrl'] ?? 'https://via.placeholder.com/400x200';
          double cost = _parseToDouble(tourData['cost']);
          int availableSeats = _parseToInt(tourData['availableSeats']);
          String startDate = tourData['startDate'] ?? 'Not available';

          return SingleChildScrollView( // Wrap the content inside a SingleChildScrollView
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text('Cost: \$$cost'),
                  Text('Start Date: $startDate'),
                  Text('Available Seats: $availableSeats'),
                  const SizedBox(height: 16.0),
                  Text('Description: $description'),
                  const SizedBox(height: 16.0),

                  // Booking Form for Users
                  Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Your Name'),
                      ),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Your Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Your Phone Number'),
                        keyboardType: TextInputType.phone,
                      ),
                      TextField(
                        controller: _seatsController,
                        decoration: const InputDecoration(labelText: 'Number of Seats'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(labelText: 'Special Notes'),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _bookSeat,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue.shade600, // Text color
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Book Seat',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
