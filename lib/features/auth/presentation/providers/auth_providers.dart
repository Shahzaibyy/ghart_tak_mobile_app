import 'package:attock_xpress/core/network/network_providers.dart';
import 'package:attock_xpress/core/storage/storage_providers.dart';
import 'package:attock_xpress/features/auth/data/auth_session_store.dart';
import 'package:attock_xpress/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:attock_xpress/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:attock_xpress/features/auth/domain/repositories/auth_repository.dart';
import 'package:attock_xpress/features/auth/domain/usecases/enter_preview.dart';
import 'package:attock_xpress/features/auth/domain/usecases/logout.dart';
import 'package:attock_xpress/features/auth/domain/usecases/request_otp.dart';
import 'package:attock_xpress/features/auth/domain/usecases/verify_otp.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

/// Auth repository wired to Dio and secure storage.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    remote: AuthRemoteDataSource(ref.watch(dioProvider)),
    sessions: AuthSessionStore(ref.watch(tokenStoreProvider)),
  );
}

/// OTP request use case.
@riverpod
RequestOtp requestOtp(Ref ref) {
  return RequestOtp(ref.watch(authRepositoryProvider));
}

/// OTP verification use case.
@riverpod
VerifyOtp verifyOtp(Ref ref) {
  return VerifyOtp(ref.watch(authRepositoryProvider));
}

/// Logout use case.
@riverpod
Logout logout(Ref ref) {
  return Logout(ref.watch(authRepositoryProvider));
}

/// Local preview use case.
@riverpod
EnterPreview enterPreview(Ref ref) {
  return EnterPreview(ref.watch(authRepositoryProvider));
}
