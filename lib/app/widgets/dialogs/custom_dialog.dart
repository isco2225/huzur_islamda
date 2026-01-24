import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });
  final String title;
  final String content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(title, style: theme.textTheme.titleLarge),
      content: Text(content, style: theme.textTheme.bodyMedium),
      actions: actions,
    );
  }
}
