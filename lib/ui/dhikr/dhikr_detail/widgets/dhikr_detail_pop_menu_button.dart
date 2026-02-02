import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class DhikrDetailPopMenuButton extends StatelessWidget {
  const DhikrDetailPopMenuButton({
    super.key,
    required this.onDeleteDhikrTapped,
    required this.onResetDhikrTapped,
  });
  final void Function() onDeleteDhikrTapped;
  final void Function() onResetDhikrTapped;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: responsive.isSmallScreen ? 20.0 : 24.0),
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            onDeleteDhikrTapped();
          },
          value: 'delete_dhikr',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20),
              SizedBox(width: responsive.spacingSmall),
              Text('Zikiri Sil'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            onResetDhikrTapped();
          },
          value: 'reset_dhikr',
          child: Row(
            children: [
              Icon(Icons.refresh_outlined, size: 20),
              SizedBox(width: responsive.spacingSmall),
              Text('Zikiri Sıfırla'),
            ],
          ),
        ),
      ],
    );
  }
}
