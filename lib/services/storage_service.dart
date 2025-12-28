import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _kPhoneKey = 'contactme_phone';

  static Future<void> savePhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPhoneKey, phone);
  }

  static Future<String?> loadPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPhoneKey);
  }

  static Future<void> clearPhone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPhoneKey);
  }
}
