import 'dart:async';
import 'package:flutter/services.dart';

class PlatformContacts {
  static const _chan = MethodChannel('contactme/contacts');

  /// Returns a list of contacts, each as a Map with keys:
  /// `id`, `displayName`, `phones` (list of strings), `emails` (list of strings)
  static Future<List<Map<String, dynamic>>> getContacts() async {
    final res = await _chan.invokeMethod('getContacts');
    if (res is List) {
      return List<Map<String, dynamic>>.from(
        res.map((e) => Map<String, dynamic>.from(e)),
      );
    }
    return [];
  }
}
