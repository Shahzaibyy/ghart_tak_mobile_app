import 'package:attock_xpress/features/payments/data/models/wallet_balance_model.dart';
import 'package:dio/dio.dart';

/// HTTP access to the wallet.
class PaymentRemoteDataSource {
  /// Creates a data source over the HTTP client.
  const new(this._dio);

  final Dio _dio;

  /// Fetches the wallet balance.
  Future<WalletBalanceModel> readBalance() async {
    final response = await _dio.get<Map<String, dynamic>>('/payments/wallet');
    final raw = response.data;
    if (raw == null) {
      throw const FormatException('Expected a wallet object');
    }
    return WalletBalanceModel.fromJson(raw);
  }
}
