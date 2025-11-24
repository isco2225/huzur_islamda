import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class UserInitializeView extends StatelessWidget {
  const UserInitializeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      body: BaseColumn(children: [CircularProgressIndicator()]),
    );
  }
}
