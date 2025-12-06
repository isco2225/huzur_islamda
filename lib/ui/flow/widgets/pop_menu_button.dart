import 'package:flutter/material.dart';

import '../../../app/app.dart';

class PopMenuButton extends StatelessWidget {
  const PopMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: context.isSmallScreen ? 20.0 : 24.0),

      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            print('share');
          },
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share, size: 20),
              SizedBox(width: 8),
              Text('Paylaş'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            print('report');
          },
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.flag_outlined, size: 20),
              SizedBox(width: 8),
              Text('Şikayet Et'),
            ],
          ),
        ),
      ],
    );
  }
}
