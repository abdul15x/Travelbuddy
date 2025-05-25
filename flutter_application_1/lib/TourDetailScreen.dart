import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/edit_tour_screen.dart';

class TourDetailScreen extends StatefulWidget {
  final String tourId; // The ID of the tour document in Firestore

  const TourDetailScreen({super.key, required this.tourId});

  @override
  _TourDetailScreenState createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  late Future<DocumentSnapshot> _tourDetails;

  @override
  void initState() {
    super.initState();
    print("Fetching tour with ID: ${widget.tourId}"); // Debugging log

    // Fetch the tour document from Firestore
    _tourDetails = FirebaseFirestore.instance
        .collection('tours')
        .doc(widget.tourId) // Use the tourId passed in
        .get(); // Fetch the document
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Details'),
        backgroundColor: Colors.teal,
        elevation: 4.0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 44, 138, 210),
                Color.fromARGB(255, 86, 174, 229)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _tourDetails,
        builder: (context, snapshot) {
          // While data is loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If there's an error fetching data
          if (snapshot.hasError) {
            print("Error fetching data: ${snapshot.error}"); // Debugging log
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If there's no data or the document does not exist
          if (!snapshot.hasData || !snapshot.data!.exists) {
            print("Document not found or does not exist."); // Debugging log
            return const Center(child: Text('No tour details found.'));
          }

          // Get the data from the snapshot
          var tourData = snapshot.data!.data() as Map<String, dynamic>;

          print("Tour Data: $tourData"); // Debugging log

          // Safely access and assign default values if data is missing
          String name = tourData['name'] ?? 'Unnamed Tour';
          String description = tourData['description'] ?? 'No description available.';
          String imageUrl = tourData['imageUrl'] ?? 'https://via.placeholder.com/400x200';
          double cost = tourData['cost'] ?? 0.0;
          double fare = tourData['fare'] ?? 0.0;
          int availableSeats = tourData['availableSeats'] ?? 0;
          String startDate = tourData['startDate'] ?? 'Not available';
          int duration = tourData['duration'] ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center all content
                children: [
                  // Tour Image with a smooth border radius
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    child: Image.network(
                      imageUrl,
                      height: MediaQuery.of(context).size.height * 0.3, // Responsive height
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Tour Name (Centered)
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.07, // Responsive font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center, // Center the title
                  ),
                  const SizedBox(height: 8.0),

                  // Tour Details Section
                  _buildDetailRow('Cost', '\$$cost'),
                  _buildDetailRow('Fare', '\$$fare per person'),
                  _buildDetailRow('Available Seats', '$availableSeats'),
                  _buildDetailRow('Start Date', startDate),
                  _buildDetailRow('Duration', '$duration days'),
                  _buildDetailRow('Description', description),
                  const SizedBox(height: 20.0),

                  // Edit and Delete Buttons with symmetric spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
                    children: [
                      // Edit Button
                      _buildActionButton(
                        label: 'Edit Tour',
                        color: const Color.fromARGB(255, 44, 138, 210),
                        textColor: Colors.white,
                        onPressed: () {
                          // Navigate to the Edit Tour screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTourScreen(
                                tourId: widget.tourId,
                                tourData: tourData,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16.0), // Add space between buttons

                      // Delete Button
                      _buildActionButton(
                        label: 'Delete Tour',
                        color: const Color.fromARGB(255, 234, 67, 53),
                        textColor: Colors.white,
                        onPressed: () async {
                          // Delete the tour from Firestore
                          try {
                            await FirebaseFirestore.instance
                                .collection('tours')
                                .doc(widget.tourId)
                                .delete();

                            // Show a confirmation snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tour deleted successfully!')),
                            );

                            // Navigate back to the previous screen after deletion
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error deleting tour: $e')),
                            );
                          }
                        },
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

  // Helper method to create rows for tour details
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the row
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.05, // Responsive font size
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05, // Responsive font size
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis, // Handles overflow for long texts
              maxLines: 2, // Limit lines to 2 for long texts
              textAlign: TextAlign.center, // Center the text
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for creating styled buttons with custom text color
  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Use the button color
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.02, // Responsive vertical padding
          horizontal: MediaQuery.of(context).size.width * 0.1, // Responsive horizontal padding
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5, // Add shadow for a more prominent look
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.05, // Responsive font size
          fontWeight: FontWeight.bold,
          color: textColor, // White text color
        ),
      ),
    );
  }
}
