import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class LogOutButton extends StatelessWidget {
  const LogOutButton({
    super.key,
    required this.onPressed,
    required this.running,
  });
  final VoidCallback onPressed;
  final ValueListenable<bool> running;

  @override
  Widget build(BuildContext context) {
    return AppButton(text: 'Log Out', onPressed: onPressed, running: running);
  }
}
