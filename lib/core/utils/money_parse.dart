/// Money helpers. Backend money fields are decimal strings like `"450.00"`.
abstract final class MoneyParse {
  /// Parses a money string into whole rupees for UI display.
  static int rupees(String raw) {
    final value = double.tryParse(raw);
    if (value == null) {
      throw FormatException('Invalid money: $raw');
    }
    return value.round();
  }

  /// Parses a money string into a double (fees may include paise).
  static double amount(String raw) {
    final value = double.tryParse(raw);
    if (value == null) {
      throw FormatException('Invalid money: $raw');
    }
    return value;
  }
}
