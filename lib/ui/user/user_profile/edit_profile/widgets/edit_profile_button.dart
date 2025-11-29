import 'package:flutter/material.dart';

import '../../../../../app/app.dart';

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key, required this.textTheme});
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.isSmallScreen ? 48 : 52,
      child: ElevatedButton.icon(
        onPressed: () {
          const EditProfileRoute().push(context);
        },
        icon: Icon(Icons.edit_rounded, size: context.isSmallScreen ? 20 : 22),
        label: Text(
          'Profili Düzenle',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: context.responsiveFontSize(
              textTheme.titleMedium?.fontSize,
            ),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
