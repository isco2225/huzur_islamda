import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class CreateDhikrsForPrayerAlertDialog extends StatelessWidget {
  const CreateDhikrsForPrayerAlertDialog({
    super.key,
    required this.createDhikrViewModel,
  });

  final CreateDhikrViewModel createDhikrViewModel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.mosque, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Namaz Tesbihatı',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aşağıdaki zikirler oluşturulacak:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          PrayerDhikrPreviewItem(
            name: PrayerDhikrConstants.subhanallahName,
            count: PrayerDhikrConstants.prayerDhikrTargetCount,
          ),
          const SizedBox(height: 12),
          PrayerDhikrPreviewItem(
            name: PrayerDhikrConstants.elhamdulillahName,
            count: PrayerDhikrConstants.prayerDhikrTargetCount,
          ),
          const SizedBox(height: 12),
          PrayerDhikrPreviewItem(
            name: PrayerDhikrConstants.allahuEkberName,
            count: PrayerDhikrConstants.prayerDhikrTargetCount,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text('iptal', style: TextStyle(color: Colors.grey[700])),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: createDhikrViewModel.createDhikrsForPrayer.running,
          builder: (context, isRunning, _) {
            return ElevatedButton(
              onPressed: isRunning
                  ? null
                  : () {
                      // On success DhikrScreen's handleCompleted(popCount: 1)
                      // closes this dialog; on failure it stays open so the
                      // user can retry or cancel.
                      createDhikrViewModel.createDhikrsForPrayer.execute();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isRunning
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Oluştur'),
            );
          },
        ),
      ],
    );
  }
}
