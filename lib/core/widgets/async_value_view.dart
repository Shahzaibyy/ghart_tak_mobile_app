import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/widgets/failure_view.dart';
import 'package:attock_xpress/core/widgets/gh_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders [AsyncValue] without manual loading or error booleans.
class AsyncValueView<T> extends StatelessWidget {
  /// Creates a view that switches on [value].
  const new({
    required this.value,
    required this.data,
    this.onRetry,
    super.key,
  });

  /// State to render.
  final AsyncValue<T> value;

  /// Builds the success UI.
  final Widget Function(T data) data;

  /// Called from the error state.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => const GhSkeletonList(),
      error: (error, _) => FailureView(
        failure: failureFrom(error),
        onRetry: onRetry,
      ),
    );
  }
}

/// Normalizes an async error into a [Failure].
Failure failureFrom(Object error) {
  return switch (error) {
    Failure() => error,
    _ => const ServerFailure(),
  };
}
