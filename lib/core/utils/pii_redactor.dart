/// Strips tokens, phone numbers, and CNIC values from log text.
abstract final class PiiRedactor {
  static final RegExp _bearer = RegExp(
    r'Bearer\s+\S+',
    caseSensitive: false,
  );
  static final RegExp _cnic = RegExp(r'\d{5}-?\d{7}-?\d');
  static final RegExp _phone = RegExp(r'(?:\+92|0)3\d{9}');

  /// Returns [input] with sensitive tokens replaced.
  static String redact(String input) {
    final withoutToken = input.replaceAll(_bearer, 'Bearer [redacted]');
    final withoutCnic = withoutToken.replaceAll(_cnic, '[cnic]');
    return withoutCnic.replaceAll(_phone, '[phone]');
  }
}
