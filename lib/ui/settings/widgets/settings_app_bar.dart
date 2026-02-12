import 'package:flutter/material.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Ayarlar'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
