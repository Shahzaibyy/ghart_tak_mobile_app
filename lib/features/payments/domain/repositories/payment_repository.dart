import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/payments/domain/entities/wallet_balance.dart';

/// Wallet reads. Checkout screens do not call Dio.
abstract interface class PaymentRepository {
  /// Returns the signed-in user's wallet balance.
  Future<Result<WalletBalance>> readBalance();
}
