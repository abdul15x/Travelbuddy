import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'TourDetailScreen.dart';  // Import the TourDetailScreen

class AddNewTourScreen extends StatefulWidget {
  const AddNewTourScreen({super.key});

  @override
  _AddNewTourScreenState createState() => _AddNewTourScreenState();
}

class _AddNewTourScreenState extends State<AddNewTourScreen> {
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _fareController = TextEditingController();
  final _seatsController = TextEditingController();
  final _startDateController = TextEditingController();

  bool _isLoading = false;

  // Function to add tour to Firestore
  Future<void> _addTour() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate the input fields
      if (_nameController.text.isEmpty ||
          _costController.text.isEmpty ||
          _durationController.text.isEmpty ||
          _descriptionController.text.isEmpty ||
          _imageUrlController.text.isEmpty ||
          _fareController.text.isEmpty ||
          _seatsController.text.isEmpty ||
          _startDateController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all the fields')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create tour data
      final newTour = {
        'name': _nameController.text,
        'cost': double.parse(_costController.text),
        'duration': int.parse(_durationController.text),
        'description': _descriptionController.text,
        'imageUrl': _imageUrlController.text,
        'fare': double.parse(_fareController.text),
        'availableSeats': int.parse(_seatsController.text),
        'startDate': _startDateController.text, // Store start date as a string for now
      };

      // Add the new tour to Firestore and get the document ID
      await FirebaseFirestore.instance.collection('tours').add(newTour).then((docRef) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tour added successfully!')),
        );

        // Pass the document ID to TourDetailScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourDetailScreen(tourId: docRef.id),
          ),
        );

        // Clear input fields
        _nameController.clear();
        _costController.clear();
        _durationController.clear();
        _descriptionController.clear();
        _imageUrlController.clear();
        _fareController.clear();
        _seatsController.clear();
        _startDateController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen size
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Tour'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Tour Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Tour Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tour Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Tour Cost
              TextField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Cost',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Tour Duration
              TextField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (days)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Tour Description
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),

              // Tour Image URL
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Tour Fare (per person)
              TextField(
                controller: _fareController,
                decoration: const InputDecoration(
                  labelText: 'Fare (per person)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Available Seats
              TextField(
                controller: _seatsController,
                decoration: const InputDecoration(
                  labelText: 'Available Seats',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Tour Start Date
              TextField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Add Tour Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: screenWidth * 0.8, // Adjust the width based on screen size
                      child: ElevatedButton(
                        onPressed: _addTour,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue.shade600, // Button text color (white)
                          textStyle: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 5, // Button shadow
                        ),
                        child: const Text('Add Tour'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
