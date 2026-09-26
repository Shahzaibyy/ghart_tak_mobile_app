import 'dart:convert';

/// A rider action stored until the network is back.
sealed class QueuedAction {
  const new();

  /// Serializes this action.
  Map<String, Object?> toJson();

  /// Parses a JSON string written by [toJson].
  static QueuedAction decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Expected a queued action');
    }
    return fromJson(Map<String, dynamic>.from(decoded));
  }

  /// Parses [json].
  static QueuedAction fromJson(Map<String, dynamic> json) {
    final kind = json['kind'];
    if (kind is! String) {
      throw const FormatException('Queued action is missing a kind');
    }
    final parse = _parsers[kind];
    if (parse == null) {
      throw const FormatException('Unknown queued action');
    }
    return parse(json);
  }
}

final Map<String, QueuedAction Function(Map<String, dynamic>)> _parsers = {
  'toggle_online': ToggleOnlineAction.fromJson,
  'confirm_delivery': DeliveryConfirmationAction.fromJson,
};

/// Online or offline toggle that did not reach the server.
final class ToggleOnlineAction extends QueuedAction {
  /// Creates a toggle action.
  const new({required this.isOnline});

  /// Parses [json].
  factory fromJson(Map<String, dynamic> json) {
    final isOnline = json['is_online'];
    if (isOnline is! bool) {
      throw const FormatException('Expected an online flag');
    }
    return ToggleOnlineAction(isOnline: isOnline);
  }

  /// Desired availability.
  final bool isOnline;

  @override
  Map<String, Object?> toJson() {
    return {'kind': 'toggle_online', 'is_online': isOnline};
  }
}

/// Delivery confirmation waiting to sync. The OTP is not part of `toString`.
final class DeliveryConfirmationAction extends QueuedAction {
  /// Creates a delivery confirmation.
  const new({required this.taskId, required this.otp});

  /// Parses [json].
  factory fromJson(Map<String, dynamic> json) {
    final taskId = json['task_id'];
    final otp = json['otp'];
    if (taskId is! String || otp is! String) {
      throw const FormatException('Expected a delivery confirmation');
    }
    return DeliveryConfirmationAction(taskId: taskId, otp: otp);
  }

  /// Task being confirmed.
  final String taskId;

  /// Customer OTP. Do not log this value.
  final String otp;

  @override
  Map<String, Object?> toJson() {
    return {'kind': 'confirm_delivery', 'task_id': taskId, 'otp': otp};
  }

  @override
  String toString() => 'DeliveryConfirmationAction($taskId)';
}
