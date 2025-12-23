import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class CreateDhikrAcceptButton extends StatelessWidget {
  const CreateDhikrAcceptButton({super.key, required this.viewModel});

  final CreateDhikrViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: viewModel.createDhikr.running,
      builder: (context, isRunning, _) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            // TODO: check it after.
            onPressed: isRunning ? null : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: context.spacingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isRunning
                ? const SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, color: Colors.white),
                      SizedBox(width: context.spacingExtraSmall),
                      Text(
                        'Kaydet ve Ekle',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
