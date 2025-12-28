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
//         return {
//           'displayName': contact.displayName,
//           'givenName': contact.givenName,
//           'middleName': contact.middleName,
//           'familyName': contact.familyName,
//           'prefix': contact.prefix,
//           'suffix': contact.suffix,
//           'company': contact.company,
//           'jobTitle': contact.jobTitle,
//           'emails': contact.emails?.map((e) => {'label': e.label, 'value': e.value}).toList(),
//           'phones': contact.phones?.map((p) => {'label': p.label, 'value': p.value}).toList(),
//           'postalAddresses': contact.postalAddresses?.map((a) => {
//             'label': a.label,
//             'street': a.street,
//             'city': a.city,
//             'postcode': a.postcode,
//             'region': a.region,
//             'country': a.country
//           }).toList(),
//           'avatar': contact.avatar,
//         };
//       }).toList();

//       // Get the directory to save the file
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/contacts.json');

//       // Write the file
//       await file.writeAsString(jsonEncode(contactsJson));
//     }
//   }
// }
