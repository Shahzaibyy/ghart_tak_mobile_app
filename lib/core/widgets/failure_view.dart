import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:flutter/material.dart';

/// Non-throwing error surface. Switches on [Failure] subtypes.
class FailureView extends StatelessWidget {
  /// Creates a failure view with an optional [onRetry] action.
  const new({required this.failure, this.onRetry, super.key});

  /// Failure to describe.
  final Failure failure;

  /// Called when the user asks to try again.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final title = switch (failure) {
      NetworkFailure() => 'You are offline',
      ServerFailure() => 'Something went wrong',
      ValidationFailure() => 'Check your details',
      AuthFailure() => 'Sign in again',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              GhButton(label: 'Try again', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
