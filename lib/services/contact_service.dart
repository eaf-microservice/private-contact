// import 'dart:convert';
// import 'dart:io';

// import 'package:contacts_service/contacts_service.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class ContactSyncService {
//   Future<void> syncContacts() async {
//     if (await Permission.contacts.request().isGranted) {
//       // Get all contacts on device
//       List<Contact> contacts = await ContactsService.getContacts();

//       // Convert contacts to a map
//       List<Map<String, dynamic>> contactsJson = contacts.map((contact) {
// Lightweight mobile contact sync stub.
// The original implementation used `contacts_service`, which was removed
// from the project's dependencies to avoid Android build/plugin issues.
// If you add `contacts_service` back, replace this with the real impl.

class ContactSyncService {
  Future<void> syncContacts() async {
    // No-op placeholder for mobile platforms when the contacts plugin
    // is unavailable. Keeps first-launch flow safe.
    return;
  }
}

//             'label': a.label,
