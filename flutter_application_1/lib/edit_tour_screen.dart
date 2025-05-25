import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTourScreen extends StatefulWidget {
  final String tourId;
  final Map<String, dynamic> tourData;

  const EditTourScreen({super.key, required this.tourId, required this.tourData});

  @override
  _EditTourScreenState createState() => _EditTourScreenState();
}

class _EditTourScreenState extends State<EditTourScreen> {
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _fareController = TextEditingController();
  final _seatsController = TextEditingController();
  final _startDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current tour data
    _nameController.text = widget.tourData['name'] ?? '';
    _costController.text = widget.tourData['cost'].toString();
    _durationController.text = widget.tourData['duration'].toString();
    _descriptionController.text = widget.tourData['description'] ?? '';
    _imageUrlController.text = widget.tourData['imageUrl'] ?? '';
    _fareController.text = widget.tourData['fare'].toString();
    _seatsController.text = widget.tourData['availableSeats'].toString();
    _startDateController.text = widget.tourData['startDate'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _fareController.dispose();
    _seatsController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (_nameController.text.isEmpty ||
        _costController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _seatsController.text.isEmpty ||
        _startDateController.text.isEmpty) {
      // Basic validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('tours').doc(widget.tourId).update({
        'name': _nameController.text,
        'cost': double.tryParse(_costController.text) ?? 0.0,
        'duration': int.tryParse(_durationController.text) ?? 0,
        'description': _descriptionController.text,
        'imageUrl': _imageUrlController.text,
        'fare': double.tryParse(_fareController.text) ?? 0.0,
        'availableSeats': int.tryParse(_seatsController.text) ?? 0,
        'startDate': _startDateController.text,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tour details updated successfully!')),
      );

      // Go back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving changes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tour'),
        backgroundColor: Colors.transparent, // Make AppBar background transparent
        elevation: 0, // Remove the shadow
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 44, 138, 210), // Lighter blue
                Color.fromARGB(255, 86, 174, 229), // Darker blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Tour Name
              _buildTextField(
                controller: _nameController,
                label: 'Tour Name',
                isRequired: true,
              ),
              // Cost
              _buildTextField(
                controller: _costController,
                label: 'Cost',
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              // Duration
              _buildTextField(
                controller: _durationController,
                label: 'Duration (Days)',
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
              ),
              // Image URL
              _buildTextField(
                controller: _imageUrlController,
                label: 'Image URL',
              ),
              // Fare
              _buildTextField(
                controller: _fareController,
                label: 'Fare',
                keyboardType: TextInputType.number,
              ),
              // Available Seats
              _buildTextField(
                controller: _seatsController,
                label: 'Available Seats',
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              // Start Date
              _buildTextField(
                controller: _startDateController,
                label: 'Start Date',
                isRequired: true,
              ),
              const SizedBox(height: 16.0),
              // Save Button
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 44, 138, 210), // Blue background color
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text color
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 5, // Shadow for the button
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create a styled TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0), // Blue label color
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 2),
          ),
          filled: true,
          fillColor: const Color.fromARGB(255, 244, 248, 255), // Light background color
          suffixIcon: isRequired && controller.text.isEmpty
              ? const Icon(Icons.warning, color: Colors.red)
              : null, // Show warning icon if required field is empty
        ),
      ),
    );
  }
}
