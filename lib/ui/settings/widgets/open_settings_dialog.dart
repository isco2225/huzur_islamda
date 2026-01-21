import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/app.dart';

/// Bildirim izni kalıcı olarak reddedildiğinde gösterilen dialog
/// Kullanıcıyı ayarlara yönlendirir
class OpenSettingsDialog extends StatelessWidget {
  const OpenSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AlertDialog(
      title: Text(
        'Bildirim İzni Gerekli',
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: context.responsiveFontSize(textTheme.titleLarge?.fontSize),
        ),
      ),
      content: Text(
        'Namaz vakitleri bildirimlerini almak için bildirim iznine ihtiyacımız var. Lütfen ayarlardan bildirim iznini açın.',
        style: textTheme.bodyMedium?.copyWith(
          fontSize: context.responsiveFontSize(textTheme.bodyMedium?.fontSize),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            // go to settings
            await openAppSettings();
          },
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
          ),
          child: const Text('Ayarlara Git'),
        ),
      ],
      contentPadding: context.dialogContentPadding,
      titlePadding: context.dialogTitlePadding,
      actionsPadding: context.dialogActionsPadding,
    );
  }
}
