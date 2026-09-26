import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/repositories/rider_repository.dart';

/// Toggles rider availability.
class SetAvailability {
  /// Creates a use case over the repository.
  const new(this._repository);

  final RiderRepository _repository;

  /// Sets [isOnline].
  Future<Result<Nothing>> call({required bool isOnline}) {
    return _repository.setOnline(isOnline: isOnline);
  }
}
