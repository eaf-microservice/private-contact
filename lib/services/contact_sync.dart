// Conditional export: use the real contact service on IO platforms,
// and a harmless stub on web/other platforms.
export 'contact_service_stub.dart'
    if (dart.library.io) 'contact_service.dart';
