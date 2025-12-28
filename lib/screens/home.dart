import 'package:contactme/widgets/about.dart';
import 'package:contactme/screens/settings.dart';
import 'package:contactme/services/phone_service.dart';
import 'package:contactme/services/storage_service.dart';
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
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Go to Settings'),
            ),
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
            onPressed: () async {
              final updated = await Navigator.push<String?>(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              if (updated != null) setState(() => _phone = updated);
            },
          ),
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              () => AboutMe(
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
                    // OutlinedButton.icon(
                    //   onPressed: () async {
                    //     final updated = await Navigator.push<String?>(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => const SettingsScreen(),
                    //       ),
                    //     );
                    //     if (updated != null) setState(() => _phone = updated);
                    //   },
                    //   icon: const Icon(Icons.settings),
                    //   label: const Text('Settings'),
                    //   style: OutlinedButton.styleFrom(
                    //     padding: const EdgeInsets.symmetric(vertical: 15),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
    );
  }
}
