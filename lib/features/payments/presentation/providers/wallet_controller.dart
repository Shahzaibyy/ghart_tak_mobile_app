import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/network_providers.dart';
import 'package:attock_xpress/features/payments/data/datasources/payment_remote_data_source.dart';
import 'package:attock_xpress/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:attock_xpress/features/payments/domain/entities/wallet_balance.dart';
import 'package:attock_xpress/features/payments/domain/repositories/payment_repository.dart';
import 'package:attock_xpress/features/payments/domain/usecases/read_wallet.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_controller.g.dart';

/// Payment repository.
@Riverpod(keepAlive: true)
PaymentRepository paymentRepository(Ref ref) {
  return PaymentRepositoryImpl(
    PaymentRemoteDataSource(ref.watch(dioProvider)),
  );
}

/// Wallet use case.
@riverpod
ReadWallet readWallet(Ref ref) {
  return ReadWallet(ref.watch(paymentRepositoryProvider));
}

/// Signed-in wallet balance.
@riverpod
class WalletController extends _$WalletController {
  @override
  Future<WalletBalance> build() async {
    final result = await ref.watch(readWalletProvider).call();
    return switch (result) {
      Success(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }
}
