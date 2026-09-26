import 'package:attock_xpress/features/payments/domain/entities/wallet_balance.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_balance_model.freezed.dart';
part 'wallet_balance_model.g.dart';

/// Wallet payload from `GET /payments/wallet`.
@freezed
abstract class WalletBalanceModel with _$WalletBalanceModel {

  /// Creates a wallet model.
  const factory({required double balance}) =
      _WalletBalanceModel;
  const new _();

  /// Parses [json].
  factory fromJson(Map<String, dynamic> json) =>
      _$WalletBalanceModelFromJson(json);

  /// Maps this model onto the domain balance.
  WalletBalance toEntity() => WalletBalance(balance);
}
