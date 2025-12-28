import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:contactme/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase (requires google-services.json in android/app/)
  await Firebase.initializeApp();
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen()),
  );
}
