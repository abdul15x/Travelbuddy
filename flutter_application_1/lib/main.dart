import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_screen.dart'; // Import the authentication screen
import 'home_screen.dart'; // Import the home screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the provided configuration
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyACVFx0AaJFbzhoc7_qfXbeea6fiVU5f_Y",
      authDomain: "mad-project-cab42.firebaseapp.com",
      projectId: "mad-project-cab42",
      storageBucket: "mad-project-cab42.appspot.com",
      messagingSenderId: "891621514637",
      appId: "1:891621514637:web:a1c31aa070572e40bef1c4",
      measurementId: "G-45DW4KDFRG",
    ),
  );

  // Optional: Test Firestore connection (for development)
  await _testFirestoreConnection();

  runApp(const MyApp());
}

Future<void> _testFirestoreConnection() async {
  try {
    await FirebaseFirestore.instance.collection('test').doc('connection_test').set({
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('Firestore connection successful!');
  } catch (e) {
    print('Firestore connection failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Buddy App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Conditionally navigate based on authentication state
      home: const AuthOrHomeScreen(),
    );
  }
}

class AuthOrHomeScreen extends StatelessWidget {
  const AuthOrHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          // User is logged in, navigate to HomeScreen
          return const HomeScreen();
        }
        // User is not logged in, navigate to AuthScreen
        return const AuthScreen();
      },
    );
  }
}
