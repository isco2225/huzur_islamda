import 'package:flutter/material.dart';

import '../app.dart';

/// Shown instead of the router when app initialization fails.
///
/// Offers a retry and a way to continue with whatever could be initialized.
class AppInitializationErrorView extends StatelessWidget {
  const AppInitializationErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    required this.onContinue,
  });

  final Exception? error;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  static const String fallbackMessage = 'Uygulama başlatılamadı';
  static const String retryLabel = 'Tekrar dene';
  static const String continueLabel = 'Yine de devam et';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SafeArea(
          child: Builder(
            builder: (context) {
              final message = error == null
                  ? fallbackMessage
                  : context.exceptionToUserFriendlyMessage(error!);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 56),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: onRetry,
                        child: const Text(retryLabel),
                      ),
                      TextButton(
                        onPressed: onContinue,
                        child: const Text(continueLabel),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
