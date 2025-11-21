import 'package:flutter/material.dart';
import 'package:huzur_islamda/app/widgets/base/base_scaffold.dart';

import '../../ui.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.viewModel});
  final LogOutViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      safeArea: true,
      body: Center(
        child: LogOutButton(
          onPressed: () => viewModel.logOut.execute(),
          running: viewModel.logOut.running,
        ),
      ),
    );
  }
}
