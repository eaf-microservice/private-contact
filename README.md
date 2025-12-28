# Contact Me
 
A tiny app that lets you save a phone number and quickly call or send a WhatsApp message to it.

**Status:** Prototype — supports mobile; web uses safe stubs for platform-only features.

**Quick Links:**
- **Run**: `flutter run -d chrome` or `flutter run` for device/emulator
- **Main entry**: [lib/main.dart](lib/main.dart)
- **Home screen**: [lib/screens/home.dart](lib/screens/home.dart)

**What it does**
- Saves a phone number in `SharedPreferences` and exposes actions to call or message it.
- On first launch the app attempts to sync device contacts (mobile only).

Prerequisites
- Flutter SDK (stable) installed and on PATH.
- For mobile: Android or iOS toolchains set up.

Run locally
1. Ensure dependencies are installed:

```bash
flutter pub get
```

2. For web (Chrome):

```bash
flutter run -d chrome
```

3. For Android/iOS device or emulator:

```bash
flutter run
```

Notes about web support
- The project includes mobile-only plugins (`contacts_service`, `path_provider`, `permission_handler`).
- To make the web build safe, the repo uses a conditional shim: [lib/services/contact_sync.dart](lib/services/contact_sync.dart) and a web stub [lib/services/contact_service_stub.dart](lib/services/contact_service_stub.dart).
- If you need full contact sync on web, implement a web-compatible contacts provider or remove the first-launch sync.

Files of interest
- [lib/main.dart](lib/main.dart): App entry and first-launch logic.
- [lib/screens/home.dart](lib/screens/home.dart): Main UI with call/message buttons.
- [lib/services/storage_service.dart](lib/services/storage_service.dart): `SharedPreferences` helpers.

Troubleshooting
- If web run fails with engine/assertion errors, try updating Flutter to latest stable and re-run `flutter clean`.
- If you see plugin/channel messages during startup, they usually indicate a plugin sending messages before the framework is ready; verify plugin initialization and consider moving heavy startup tasks out of `main()`.

Contributing
- Open a PR with a clear description. Add platform checks for plugin use and keep web-safe fallbacks.

License


# Contact
- Devlopper: Fouad El Azbi
- Company: EAF microservice
- Email: EAF.microservice@gmail.com
- Phone: +212 645 994 904
