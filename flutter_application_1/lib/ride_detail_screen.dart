import 'package:flutter/material.dart';

class RideDetailScreen extends StatelessWidget {
  final String from;
  final String to;
  final int seatsBooked;
  final String date;
  final String time;
  final double fare;
  final String driverName;
  final String driverContact;
  final String carpoolId;
  final String docId;

  const RideDetailScreen({
    super.key,
    required this.from,
    required this.to,
    required this.seatsBooked,
    required this.date,
    required this.time,
    required this.fare,
    required this.driverName,
    required this.driverContact,
    required this.carpoolId,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ride details
            Text(
              'Ride Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow('From:', from),
            _buildDetailRow('To:', to),
            _buildDetailRow('Seats Booked:', seatsBooked.toString()),
            _buildDetailRow('Date:', date),
            _buildDetailRow('Time:', time),
            _buildDetailRow('Fare:', '₹$fare'),
            const SizedBox(height: 20),

            // Driver details
            Text(
              'Driver Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow('Driver:', driverName),
            _buildDetailRow('Driver Contact:', driverContact),
            _buildDetailRow('Carpool ID:', carpoolId),
            _buildDetailRow('Document ID:', docId),
            const SizedBox(height: 30),

            // Back button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue.shade600, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Navigate back
                },
                child: const Text(
                  'Back',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create a detail row with label and value
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
