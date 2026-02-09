import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/app.dart';

/// Bildirim izni kalıcı olarak reddedildiğinde gösterilen dialog
/// Kullanıcıyı ayarlara yönlendirir
class OpenSettingsDialog extends StatelessWidget {
  const OpenSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Bildirim İzni Gerekli',
      content: 'Lütfen telefon ayarlarından, uygulamaya bildirim izni verin.',
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
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Ayarlara Git'),
        ),
      ],
    );
  }
}
