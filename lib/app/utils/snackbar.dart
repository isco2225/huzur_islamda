import 'package:flutter/material.dart';

extension ShowSnackBar on BuildContext {
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        backgroundColor: Colors.greenAccent,
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            message,
            style: TextStyle(color: Theme.of(this).colorScheme.onSurface),
          ),
        ),
      );
  }
}
