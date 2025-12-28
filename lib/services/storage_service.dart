import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _kPhoneKey = 'contactme_phone';
  static const _kOptInUploadKey = 'contactme_opt_in_upload';

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

  static Future<void> saveOptInUpload(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOptInUploadKey, value);
  }

  static Future<bool> loadOptInUpload() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOptInUploadKey) ?? false;
  }
}
