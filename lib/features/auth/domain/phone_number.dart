final RegExp _pakistaniMobile = RegExp(r'^(?:\+92|0)3\d{9}$');

/// Whether [phone] is a Pakistani mobile number.
bool isPakistaniMobile(String phone) {
  final compact = phone.replaceAll(RegExp(r'[\s-]'), '');
  return _pakistaniMobile.hasMatch(compact);
}
