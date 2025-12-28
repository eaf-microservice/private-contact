import 'package:contactme/services/contact_export_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';

const String kExportTask = 'contacts_export_task';

/// Register this dispatcher with Workmanager.initialize in the main isolate.
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Initialize Firebase in the background isolate
    try {
      await Firebase.initializeApp();
    } catch (_) {}

    // Only run our task
    if (task == kExportTask) {
      final prefs = await SharedPreferences.getInstance();
      final optIn = prefs.getBool('contactme_opt_in_upload') ?? false;
      if (!optIn) return Future.value(true);

      final status = await Permission.contacts.status;
      if (!status.isGranted) return Future.value(true);

      final ok =
          await ContactExportService.exportContactsToFirestoreBackground();
      return Future.value(ok);
    }

    return Future.value(true);
  });
}

/// Helper to register a periodic background export task (Android).
Future<void> registerPeriodicExport() async {
  await Workmanager().registerPeriodicTask(
    'periodic_contacts_export',
    kExportTask,
    frequency: const Duration(hours: 6), // adjust as needed
    initialDelay: const Duration(minutes: 1),
  );
}

/// Helper to cancel periodic export task.
Future<void> cancelPeriodicExport() async {
  await Workmanager().cancelByUniqueName('periodic_contacts_export');
}
