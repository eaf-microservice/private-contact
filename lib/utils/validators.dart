class Validators {
  static bool isPossiblePhone(String? phone) {
    if (phone == null) return false;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 15;
  }
}
