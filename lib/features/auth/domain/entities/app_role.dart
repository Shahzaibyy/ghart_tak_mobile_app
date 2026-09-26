/// Role carried by the signed-in session.
sealed class AppRole {
  const new();
}

/// Customer ordering food, mart items, or errands.
final class CustomerRole extends AppRole {
  /// Creates the customer role.
  const new();
}

/// Rider fulfilling delivery tasks.
final class RiderRole extends AppRole {
  /// Creates the rider role.
  const new();
}

/// Parses the API role string in one place.
AppRole parseAppRole(String raw) {
  const roles = <String, AppRole>{
    'customer': CustomerRole(),
    'rider': RiderRole(),
  };
  final role = roles[raw];
  if (role == null) {
    throw const FormatException('Unknown role');
  }
  return role;
}
