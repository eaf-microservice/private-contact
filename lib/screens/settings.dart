import 'package:contactme/services/storage_service.dart';
import 'package:contactme/utils/validators.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final phone = await StorageService.loadPhone();
    _controller.text = phone ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (!Validators.isPossiblePhone(value)) {
      _showSnack(
        'Please enter a valid phone number (include country code if needed).',
        error: true,
      );
      return;
    }
    await StorageService.savePhone(value);
    _showSnack('Saved');
    if (mounted) Navigator.pop(context, value);
  }

  Future<void> _clear() async {
    await StorageService.clearPhone();
    _controller.clear();
    _showSnack('Cleared');
    if (mounted) Navigator.pop(context, '');
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Phone number',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '+212 645 994 904',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Save'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _clear,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Clear'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
