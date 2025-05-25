import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/TourDetailScreen.dart';

class TourListScreen extends StatefulWidget {
  const TourListScreen({super.key});

  @override
  _TourListScreenState createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _tours = [];

  // Fetch tours from Firestore
  Future<void> _fetchTours() async {
    setState(() {
      _isLoading = true;
      _tours = [];
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('tours').get();

      final fetchedData = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'tourId': doc.id, // Store the Firestore document ID
              'name': data['name'] ?? 'Unnamed Tour',
              'cost': _parseDouble(data['cost']),
              'fare': _parseDouble(data['fare']),
              'availableSeats': _parseInt(data['availableSeats']),
              'startDate': data['startDate'] ?? 'N/A',
              'duration': _parseInt(data['duration']),
              'imageUrl': data['imageUrl'] ?? 'https://via.placeholder.com/400x200',
            };
          })
          .toList();

      setState(() {
        _tours = fetchedData;
      });
    } catch (e) {
      print('Error fetching tours: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tours: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTours(); // Fetch tours when the screen loads
  }

  // Helper function to safely parse a double
  double _parseDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value.replaceAll(",", "")) ?? 0.0; // Remove commas and try parsing
    } else if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else {
      return 0.0;
    }
  }

  // Helper function to safely parse an integer
  int _parseInt(dynamic value) {
    if (value is String) {
      return int.tryParse(value) ?? 0; // Return 0 if it can't be parsed
    } else if (value is int) {
      return value;
    } else {
      return 0;
    }
  }

  // Reusable button style function (same as used in AdminLoginScreen)
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 50, 142, 240), // Button color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Tours'),
        backgroundColor: Colors.teal,
        elevation: 5,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 44, 138, 210), Color.fromARGB(255, 86, 174, 229)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tours.isEmpty
              ? const Center(child: Text('No tours available.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _tours.length,
                  itemBuilder: (context, index) {
                    final tour = _tours[index];
                    return _buildTourCard(tour);
                  },
                ),
    );
  }

  // Tour Card Widget
  Widget _buildTourCard(Map<String, dynamic> tour) {
    return GestureDetector(
      onTap: () {
        // Optionally, you could add a functionality for tapping on the card.
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: 6.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center content symmetrically
          children: [
            // Tour Image with Gradient Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0),
                  ),
                  child: Image.network(
                    tour['imageUrl'],
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0), // Balanced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center text symmetrically
                children: [
                  // Tour Name
                  Text(
                    tour['name'],
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center, // Center aligned text
                  ),
                  const SizedBox(height: 8.0), 

                  // Tour Details (all aligned symmetrically)
                  Text(
                    'Cost: \$${tour['cost']}',
                    style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Fare: \$${tour['fare']} per person',
                    style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Available Seats: ${tour['availableSeats']}',
                    style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Start Date: ${tour['startDate']}',
                    style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Duration: ${tour['duration']} days',
                    style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12.0),

                  // View Details Button (Center aligned)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TourDetailScreen(
                            tourId: tour['tourId'],
                          ),
                        ),
                      );
                    },
                    style: _buttonStyle(), // Use the reusable button style here
                    child: const Text(
                      'View Details',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
