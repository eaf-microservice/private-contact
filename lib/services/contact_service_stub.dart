class ContactSyncService {
  Future<void> syncContacts() async {
    // No-op on web or unsupported platforms.
    return;
  }
}
