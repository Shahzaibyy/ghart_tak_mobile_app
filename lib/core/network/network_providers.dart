import 'package:attock_xpress/core/network/dio_client.dart';
import 'package:attock_xpress/core/storage/storage_providers.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_providers.g.dart';

/// Shared HTTP client. Feature screens never call this directly.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  return buildDio(tokenStore: ref.watch(tokenStoreProvider));
}
