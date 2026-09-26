import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/payments/domain/entities/wallet_balance.dart';
import 'package:attock_xpress/features/payments/domain/repositories/payment_repository.dart';

/// Loads the wallet balance.
class ReadWallet {
  /// Creates a use case over the repository.
  const new(this._repository);

  final PaymentRepository _repository;

  /// Fetches the balance.
  Future<Result<WalletBalance>> call() => _repository.readBalance();
}
