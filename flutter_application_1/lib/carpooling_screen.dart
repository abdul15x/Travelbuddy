import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'book_seat_screen.dart'; // Import the booking screen

class CarpoolingScreen extends StatefulWidget {
  const CarpoolingScreen({super.key});

  @override
  _CarpoolingScreenState createState() => _CarpoolingScreenState();
}

class _CarpoolingScreenState extends State<CarpoolingScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _fareController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverContactController = TextEditingController();

  DateTime? _selectedDate; // For date selection
  TimeOfDay? _selectedTime; // For time selection

  // Function to select the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Function to select the time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Function to add a new carpool ride
  Future<void> _addCarpool() async {
    if (_fromController.text.isEmpty ||
        _toController.text.isEmpty ||
        _seatsController.text.isEmpty ||
        _fareController.text.isEmpty ||
        _driverNameController.text.isEmpty ||
        _driverContactController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      // Convert the selected date to Firestore Timestamp
      Timestamp timestamp = Timestamp.fromDate(_selectedDate!);

      // Ensure seats and fare are valid
      int seats = int.tryParse(_seatsController.text) ?? 0;
      double fare = double.tryParse(_fareController.text) ?? 0.0;

      // Add carpool ride to Firestore
      await FirebaseFirestore.instance.collection('carpooling').add({
        'from': _fromController.text,
        'to': _toController.text,
        'seats': seats,
        'fare': fare,
        'driverName': _driverNameController.text,
        'driverContact': _driverContactController.text,
        'date': timestamp, // Firestore Timestamp
        'time': _selectedTime?.format(context), // Store time as string
        'createdAt': FieldValue.serverTimestamp(), // Timestamp when created
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carpooling ride added!')),
      );

      // Clear the form fields after successful submission
      _fromController.clear();
      _toController.clear();
      _seatsController.clear();
      _fareController.clear();
      _driverNameController.clear();
      _driverContactController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding carpool: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            'Available Carpool Rides',
            style: GoogleFonts.pacifico(color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Add Carpool Ride Form
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _fromController,
                    decoration: const InputDecoration(labelText: 'From (Pickup Location)'),
                  ),
                  TextField(
                    controller: _toController,
                    decoration: const InputDecoration(labelText: 'To (Drop-off Location)'),
                  ),
                  TextField(
                    controller: _seatsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Seats Available'),
                  ),
                  TextField(
                    controller: _fareController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Fare per Seat'),
                  ),
                  TextField(
                    controller: _driverNameController,
                    decoration: const InputDecoration(labelText: 'Driver Name'),
                  ),
                  TextField(
                    controller: _driverContactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Driver Contact Number'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('Pick Date'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedTime == null
                              ? 'Select Time'
                              : 'Time: ${_selectedTime!.format(context)}',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectTime(context),
                        child: const Text('Pick Time'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addCarpool,
                    child: const Text('Add Carpooling Ride'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Display Carpool Rides
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('carpooling')
                  .orderBy('createdAt', descending: true) // Order by creation date
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No rides available.'));
                }

                final carpoolRides = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: carpoolRides.length,
                  itemBuilder: (context, index) {
                    final data = carpoolRides[index].data() as Map<String, dynamic>;
                    final from = data['from'] ?? 'Unknown';
                    final to = data['to'] ?? 'Unknown';
                    final seats = data['seats'] ?? 0;
                    final fare = data['fare'] != null
                        ? (data['fare'] as num).toDouble()
                        : 0.0;
                    final driverName = data['driverName'] ?? 'Unknown';
                    final driverContact = data['driverContact'] ?? 'Unknown';
                    final rideDate = data['date'] != null ? (data['date'] as Timestamp).toDate() : null;
                    final rideTime = data['time'] ?? 'Unknown';

                    return Card(
                      elevation: 8,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$from to $to',
                                      style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Seats Available: $seats',
                                      style: GoogleFonts.lato(fontSize: 14, color: const Color.fromARGB(255, 73, 118, 240)),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Fare per Seat: RS${fare.toStringAsFixed(2)}',
                                      style: GoogleFonts.lato(fontSize: 14, color: const Color.fromARGB(255, 73, 118, 240)),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Driver: $driverName',
                                      style: GoogleFonts.lato(fontSize: 14, color: const Color.fromARGB(255, 73, 118, 240)),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Contact: $driverContact',
                                      style: GoogleFonts.lato(fontSize: 14, color: const Color.fromARGB(255, 73, 118, 240)),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Date: ${rideDate != null ? DateFormat.yMMMd().format(rideDate) : 'Unknown'}',
                                      style: GoogleFonts.lato(fontSize: 14, color: const Color.fromARGB(255, 73, 118, 240)),
                                    ),
                                    Text(
                                      'Time: $rideTime',
                                      style: GoogleFonts.lato(fontSize: 14, color: const Color.fromARGB(255, 73, 118, 240)),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 73, 118, 240)),
                                      ),
                                      onPressed: () {
                                        if (seats > 0) {
                                          // Update seats in Firestore
                                          FirebaseFirestore.instance.collection('carpooling').doc(carpoolRides[index].id).update({
                                            'seats': seats - 1, // Decrease the available seats
                                          });

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BookSeatScreen(
                                                rideData: carpoolRides[index],
                                                fare: fare,
                                                carpoolId: carpoolRides[index].id, // Pass the carpool document ID
                                                docId: carpoolRides[index].id, // Assuming docId is the same as carpoolId
                                                from: from, // Get 'from' location
                                                to: to, // Get 'to' location
                                                availableSeats: seats ?? 0, // Pass available seats, default to 0 if null
                                                driverName: driverName, // Pass driver name
                                                driverContact: driverContact, // Pass driver contact
                                                date: rideDate != null ? DateFormat.yMMMd().format(rideDate) : '', // Format date if available
                                                time: rideTime, // Pass ride time
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Show message if no seats are available
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('No seats available.')),
                                          );
                                        }
                                      },
                                     child: const Text('Book a Seat',style: TextStyle(color: Colors.white), // Set the text color to white
                                     ),

                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
