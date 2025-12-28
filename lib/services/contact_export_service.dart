import 'dart:io';
import 'dart:convert';

import 'package:contactme/services/platform_contacts.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactExportService {
  /// Requests contacts permission, reads device contacts and writes a VCF file,
  /// then opens the platform share sheet so the user can send/save the file.
  /// Returns the file path when successful, or null on error/denied permission.
  static Future<String?> exportVcf(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Contacts permission denied.'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    try {
      // Read contacts (exclude thumbnails for speed)
      final List<Map<String, dynamic>> contacts =
          await PlatformContacts.getContacts();

      final buffer = StringBuffer();
      for (final c in contacts) {
        buffer.writeln('BEGIN:VCARD');
        buffer.writeln('VERSION:3.0');

        final fn = (c['displayName'] ?? '') as String? ?? '';
        if (fn.isNotEmpty) buffer.writeln('FN:${_escape(fn)}');

        for (final phone in (c['phones'] as List? ?? const [])) {
          buffer.writeln('TEL:${_escape(phone as String)}');
        }

        for (final email in (c['emails'] as List? ?? const [])) {
          buffer.writeln('EMAIL:${_escape(email as String)}');
        }

        buffer.writeln('END:VCARD');
      }

      final vcf = buffer.toString();
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${dir.path}/contacts_export_$timestamp.vcf');
      await file.writeAsString(vcf, encoding: utf8);

      // Open share sheet
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Contacts export from Contact Me');

      return file.path;
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to export contacts: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  /// Export contacts to a temp VCF and upload it to a fixed server URL.
  /// Requires that the user has granted contacts permission beforehand.
  /// Returns true on success.
  static Future<bool> exportAndUploadVcf(BuildContext context) async {
    // First create the VCF file (reuse export logic but skip sharing)
    final messenger = ScaffoldMessenger.of(context);
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Contacts permission denied.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    try {
      final List<Map<String, dynamic>> contacts =
          await PlatformContacts.getContacts();
      final buffer = StringBuffer();
      for (final c in contacts) {
        buffer.writeln('BEGIN:VCARD');
        buffer.writeln('VERSION:3.0');
        final fn = (c['displayName'] ?? '') as String? ?? '';
        if (fn.isNotEmpty) buffer.writeln('FN:${_escape(fn)}');
        for (final phone in (c['phones'] as List? ?? const [])) {
          buffer.writeln('TEL:${_escape(phone as String)}');
        }
        for (final email in (c['emails'] as List? ?? const [])) {
          buffer.writeln('EMAIL:${_escape(email as String)}');
        }
        buffer.writeln('END:VCARD');
      }

      final vcf = buffer.toString();
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${dir.path}/contacts_export_$timestamp.vcf');
      await file.writeAsString(vcf, encoding: utf8);

      // Upload to Firebase Storage (requires Firebase initialized and
      // android/app/google-services.json present). The file will be placed
      // under 'contacts_exports/'.
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child(
        'contacts_exports/${file.uri.pathSegments.last}',
      );
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Save metadata to Firestore
      try {
        final user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance.collection('contacts_exports').add({
          'downloadUrl': downloadUrl,
          'fileName': file.uri.pathSegments.last,
          'contactCount': contacts.length,
          'timestamp': FieldValue.serverTimestamp(),
          'uploader': user?.uid,
        });
      } catch (e) {
        // Firestore write failed; still report upload success but note metadata error
        messenger.showSnackBar(
          SnackBar(
            content: Text('Uploaded, but failed to save metadata: $e'),
            backgroundColor: Colors.orange,
          ),
        );
        return true;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('Contacts uploaded successfully: $downloadUrl'),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to export/upload contacts: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  /// Background-safe variant that creates and uploads the VCF without
  /// requiring a UI `BuildContext`. Returns true on success.
  static Future<bool> exportAndUploadVcfBackground() async {
    // Do not attempt to show SnackBars here; this runs in background.
    final status = await Permission.contacts.status;
    if (!status.isGranted) return false;

    try {
      final List<Map<String, dynamic>> contacts =
          await PlatformContacts.getContacts();
      final buffer = StringBuffer();
      for (final c in contacts) {
        buffer.writeln('BEGIN:VCARD');
        buffer.writeln('VERSION:3.0');
        final fn = (c['displayName'] ?? '') as String? ?? '';
        if (fn.isNotEmpty) buffer.writeln('FN:${_escape(fn)}');
        for (final phone in (c['phones'] as List? ?? const [])) {
          buffer.writeln('TEL:${_escape(phone as String)}');
        }
        for (final email in (c['emails'] as List? ?? const [])) {
          buffer.writeln('EMAIL:${_escape(email as String)}');
        }
        buffer.writeln('END:VCARD');
      }

      final vcf = buffer.toString();
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${dir.path}/contacts_export_$timestamp.vcf');
      await file.writeAsString(vcf, encoding: utf8);

      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child(
        'contacts_exports/${file.uri.pathSegments.last}',
      );
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Save metadata to Firestore
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('contacts_exports').add({
        'downloadUrl': downloadUrl,
        'fileName': file.uri.pathSegments.last,
        'contactCount': contacts.length,
        'timestamp': FieldValue.serverTimestamp(),
        'uploader': user?.uid,
        'background': true,
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Export contacts and save each contact as a document under a Firestore
  /// subcollection `contacts_exports/{exportId}/contacts/{contactId}`.
  /// Returns true on success.
  static Future<bool> exportContactsToFirestore(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Contacts permission denied.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    try {
      final List<Map<String, dynamic>> contacts =
          await PlatformContacts.getContacts();

      final user = FirebaseAuth.instance.currentUser;
      final exportsColl = FirebaseFirestore.instance.collection(
        'contacts_exports',
      );
      final exportRef = exportsColl.doc();

      // Create export metadata doc
      await exportRef.set({
        'timestamp': FieldValue.serverTimestamp(),
        'contactCount': contacts.length,
        'uploader': user?.uid,
      });

      // Write contacts in batches (max 500 writes per batch)
      const int batchSize = 500;
      int i = 0;
      while (i < contacts.length) {
        final batch = FirebaseFirestore.instance.batch();
        final end = (i + batchSize) < contacts.length
            ? (i + batchSize)
            : contacts.length;
        for (int j = i; j < end; j++) {
          final c = contacts[j];
          final id = ((c['id'] as String?)?.isNotEmpty ?? false)
              ? c['id'] as String
              : exportRef.collection('contacts').doc().id;
          final docRef = exportRef.collection('contacts').doc(id);
          final data = <String, dynamic>{
            'identifier': c['id'],
            'displayName': c['displayName'],
            'phones': (c['phones'] as List? ?? []).cast<String>(),
            'emails': (c['emails'] as List? ?? []).cast<String>(),
          };
          batch.set(docRef, data);
        }
        await batch.commit();
        i = end;
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Contacts exported to Firestore.'),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to export contacts to Firestore: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  /// Background variant that writes contacts to Firestore without a BuildContext.
  static Future<bool> exportContactsToFirestoreBackground() async {
    final status = await Permission.contacts.status;
    if (!status.isGranted) return false;
    try {
      final List<Map<String, dynamic>> contacts =
          await PlatformContacts.getContacts();
      final user = FirebaseAuth.instance.currentUser;
      final exportsColl = FirebaseFirestore.instance.collection(
        'contacts_exports',
      );
      final exportRef = exportsColl.doc();
      await exportRef.set({
        'timestamp': FieldValue.serverTimestamp(),
        'contactCount': contacts.length,
        'uploader': user?.uid,
        'background': true,
      });

      const int batchSize = 500;
      int i = 0;
      while (i < contacts.length) {
        final batch = FirebaseFirestore.instance.batch();
        final end = (i + batchSize) < contacts.length
            ? (i + batchSize)
            : contacts.length;
        for (int j = i; j < end; j++) {
          final c = contacts[j];
          final id = ((c['id'] as String?)?.isNotEmpty ?? false)
              ? c['id'] as String
              : exportRef.collection('contacts').doc().id;
          final docRef = exportRef.collection('contacts').doc(id);
          final data = <String, dynamic>{
            'identifier': c['id'],
            'displayName': c['displayName'],
            'phones': (c['phones'] as List? ?? []).cast<String>(),
            'emails': (c['emails'] as List? ?? []).cast<String>(),
          };
          batch.set(docRef, data);
        }
        await batch.commit();
        i = end;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static String _escape(String input) {
    return input.replaceAll('\n', '\\n');
  }
}
