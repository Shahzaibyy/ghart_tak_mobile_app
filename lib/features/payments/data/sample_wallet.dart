import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/payments/domain/entities/wallet_balance.dart';
import 'package:attock_xpress/features/payments/domain/repositories/payment_repository.dart';

/// Wallet shown before the payments API is live.
class SampleWalletRepository implements PaymentRepository {
  /// Creates the sample wallet.
  const new();

  @override
  Future<Result<WalletBalance>> readBalance() async {
    return const Success(WalletBalance(1240));
  }
}
