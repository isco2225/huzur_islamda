import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:huzur_islamda/app/errors/localization/exception_localization.dart';
import 'package:huzur_islamda/app/utils/utils.dart';

typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);

/// Facilitates interaction with a ViewModel.
///
/// Encapsulates an action,
/// exposes its running and error states,
/// and ensures that it can't be launched again until it finishes.
///
/// Use [Command0] for actions without arguments.
/// Use [Command1] for actions with one argument.
///
/// Actions must return a [Result].
///
/// Consume the action result by listening to changes,
/// then call to [clearResult] when the state is consumed.
abstract class Command<T> {
  Command({required this.debugLabel}) {
    _running = ValueNotifier<bool>(false);
    _result = ValueNotifier<Result<T>?>(null);
    _error = ValueNotifier<bool>(false);
    _completed = ValueNotifier<bool>(false);

    // Update error and completed when result changes
    _result.addListener(_updateErrorAndCompleted);
  }

  final String debugLabel;
  late final ValueNotifier<bool> _running;
  late final ValueNotifier<Result<T>?> _result;
  late final ValueNotifier<bool> _error;
  late final ValueNotifier<bool> _completed;
  bool _isDisposed = false;

  /// True when the action is running.
  ValueListenable<bool> get running => _running;

  /// true if action completed with error
  ValueListenable<bool> get error => _error;

  /// true if action completed successfully
  ValueListenable<bool> get completed => _completed;

  /// Get last action result
  ValueListenable<Result<T>?> get result => _result;

  void _updateErrorAndCompleted() {
    if (!_isDisposed) {
      _error.value = _result.value is Error;
      _completed.value = _result.value is Ok;
    }
  }

  /// Clear last action result
  void clearResult() {
    if (!_isDisposed) {
      _result.value = null;
    }
  }

  VoidCallback? _errorListener;
  VoidCallback? _completedListener;

  /// Safely pops routes, waiting for them to be in idle state
  void _pop(BuildContext context, int popCount) {
    if (popCount <= 0) return;

    // Wait for route to be in idle state by waiting multiple frames
    // This ensures route animations are complete before popping
    Future<void> performPop() async {
      // Wait for at least 2 frames to ensure route is in idle state
      // Route animations typically complete within 1-2 frames
      for (int frame = 0; frame < 2; frame++) {
        await WidgetsBinding.instance.endOfFrame;
        if (!context.mounted) return;
      }

      if (!context.mounted) return;

      try {
        final navigator = Navigator.of(context, rootNavigator: false);

        for (var i = 0; i < popCount; i++) {
          if (!context.mounted) break;

          // Check if we can pop before attempting
          if (!navigator.canPop() || !context.canPop()) break;

          // Perform the pop operation
          context.pop();

          // Wait a frame between pops to avoid race conditions
          if (i < popCount - 1) {
            await WidgetsBinding.instance.endOfFrame;
          }
        }
      } catch (e) {
        // Silently ignore navigation errors when context is disposed
        // or route is in an invalid state (e.g., already popped)
        debugPrint('Navigation error in Command._pop: $e');
      }
    }

    // Schedule the pop operation after current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      performPop();
    });
  }

  void handleError(
    BuildContext context, {
    bool showSnackBar = true,
    int popCount = 0,
    void Function()? onDone,
  }) {
    _errorListener = () {
      if (!_error.value) return;
      final value = _result.value;
      if (value == null) return;
      if (!context.mounted) {
        clearResult();
        return;
      }
      final Exception exception = value.asError.error;
      clearResult();

      if (showSnackBar && context.mounted) {
        try {
          final String message = context.exceptionToUserFriendlyMessage(
            exception,
          );
          context.showErrorSnackBar(message);
        } catch (e) {
          debugPrint('Error showing snackbar: $e');
        }
      }

      if (popCount > 0 && context.mounted) {
        _pop(context, popCount);
      }

      onDone?.call();
    };
    _error.addListener(_errorListener!);
  }

  void handleCompleted(
    BuildContext context, {
    String? successMessage,
    int popCount = 0,
    void Function(T)? onCompleted,
  }) {
    _completedListener = () {
      if (!_completed.value) return;
      if (!context.mounted) {
        // if context is not mounted, only call onCompleted callback
        if (onCompleted != null && _result.value != null) {
          onCompleted(_result.value!.asOk.value);
        }
        clearResult();
        return;
      }

      if (successMessage != null && context.mounted) {
        try {
          context.showSuccessSnackBar(successMessage);
        } catch (e) {
          debugPrint('Error showing snackbar: $e');
        }
      }

      if (popCount > 0 && context.mounted) {
        _pop(context, popCount);
      }

      if (_result.value != null) {
        onCompleted?.call(_result.value!.asOk.value);
      }
      clearResult();
    };
    _completed.addListener(_completedListener!);
  }

  /// Internal execute implementation
  Future<void> _execute(CommandAction0<T> action) async {
    // Ensure the action can't launch multiple times.
    // e.g. avoid multiple taps on button
    if (_running.value || _isDisposed) return;

    // Notify listeners.
    // e.g. button shows loading state
    if (!_isDisposed) {
      _running.value = true;
      _result.value = null;
    }

    try {
      final Result<T> result = await action();
      if (!_isDisposed) {
        _result.value = result;
      }
    } finally {
      if (!_isDisposed) {
        _running.value = false;
      }
    }
  }

  /// Disposes all notifiers
  void dispose() {
    _isDisposed = true;
    if (_errorListener != null) {
      _error.removeListener(_errorListener!);
    }
    if (_completedListener != null) {
      _completed.removeListener(_completedListener!);
    }
    _result.removeListener(_updateErrorAndCompleted);
    _running.dispose();
    _result.dispose();
    _error.dispose();
    _completed.dispose();
  }
}

/// [Command] without arguments.
/// Takes a [CommandAction0] as action.
class Command0<T> extends Command<T> {
  Command0(this._action, {required super.debugLabel});

  final CommandAction0<T> _action;

  /// Executes the action.
  Future<void> execute() async {
    await _execute(_action);
  }
}

/// [Command] with one argument.
/// Takes a [CommandAction1] as action.
class Command1<T, A> extends Command<T> {
  Command1(this._action, {required super.debugLabel});

  final CommandAction1<T, A> _action;

  /// Executes the action with the argument.
  Future<void> execute(A argument) async {
    await _execute(() => _action(argument));
  }
}
