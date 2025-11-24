import 'package:flutter/material.dart';

import '../../../ui.dart';

class UserInitializeErrorAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const UserInitializeErrorAppBar({required this.viewModel, super.key});
  final UserInitializeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      forceMaterialTransparency: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: [
        TextButton(
          onPressed: () {
            print('Çıkış Yap');
          },
          child: Text('Çıkış Yap'),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
