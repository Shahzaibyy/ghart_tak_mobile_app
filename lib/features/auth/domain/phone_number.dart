final RegExp _pakistaniMobile = RegExp(r'^(?:\+92|0)3\d{9}$');

/// Whether [phone] is a Pakistani mobile number.
bool isPakistaniMobile(String phone) {
  final compact = phone.replaceAll(RegExp(r'[\s-]'), '');
  return _pakistaniMobile.hasMatch(compact);
}

/// Normalizes UI input (`300…` / `+92 300…`) to API form `03xxxxxxxxx`.
String normalizePakistaniPhone(String phone) {
  var digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('92') && digits.length >= 12) {
    digits = digits.substring(2);
  }
  if (digits.length == 10 && digits.startsWith('3')) {
    return '0$digits';
  }
  if (digits.length == 11 && digits.startsWith('03')) {
    return digits;
  }
  return phone.replaceAll(RegExp(r'[\s-]'), '');
}

/// OTP delivery channel for `POST /auth/otp/request`.
enum OtpChannel {
  /// WhatsApp (default on onboarding screens).
  whatsapp,

  /// SMS fallback.
  sms,
}

/// Wire value for [channel].
String otpChannelWire(OtpChannel channel) {
  return switch (channel) {
    OtpChannel.whatsapp => 'whatsapp',
    OtpChannel.sms => 'sms',
  };
}

