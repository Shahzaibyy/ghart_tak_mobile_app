import 'package:attock_xpress/core/utils/pii_redactor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('redacts tokens, phone numbers, and CNIC values', () {
    const raw = 'Bearer abc.def phone 03001234567 cnic 12345-1234567-1';

    expect(
      PiiRedactor.redact(raw),
      'Bearer [redacted] phone [phone] cnic [cnic]',
    );
  });
}
