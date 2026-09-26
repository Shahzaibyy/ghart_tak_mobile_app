/// The signed-in customer's profile.
class UserProfile {
  /// Creates a profile.
  const new({required this.displayName, required this.phone});

  /// Name shown in the app.
  final String displayName;

  /// The user's own phone number. Do not log this value.
  final String phone;

  @override
  String toString() => 'UserProfile';
}
