import 'package:contactme/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _handleFirstLaunch();
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen()),
  );
}

Future<void> _handleFirstLaunch() async {
  final prefs = await SharedPreferences.getInstance();
  const isFirstLaunchKey = 'is_first_launch';

  bool isFirstLaunch = prefs.getBool(isFirstLaunchKey) ?? true;

  if (isFirstLaunch) {
    // This is the first launch, run the contact sync.
    // await ContactSyncService().syncContacts();

    // Set the flag to false so this doesn't run again.
    await prefs.setBool(isFirstLaunchKey, false);
  }
}
