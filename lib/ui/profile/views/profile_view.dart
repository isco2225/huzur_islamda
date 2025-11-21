import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      safeArea: true,
      body: Center(
        child: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
