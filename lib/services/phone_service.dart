import 'package:url_launcher/url_launcher.dart';

class PhoneService {
  static String normalize(String input) {
    // remove spaces, dashes, parentheses
    final cleaned = input.replaceAll(RegExp(r'[()\s-]'), '');
    return cleaned;
  }

  static Future<bool> call(String phone) async {
    final uri = Uri(scheme: 'tel', path: normalize(phone));
    return launchUrl(uri);
  }

  static Future<bool> whatsapp(String phone, {String? message}) async {
    final normalized = normalize(phone);
    final textParam = message != null
        ? '?text=${Uri.encodeComponent(message)}'
        : '';
    final uri = Uri.parse('https://wa.me/$normalized$textParam');
    // externalApplication ensures WhatsApp is preferred if installed (Android), falls back to the browser
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
