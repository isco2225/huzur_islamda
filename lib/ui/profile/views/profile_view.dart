import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.viewModel,
    required this.userViewModel,
  });
  final LogOutViewModel viewModel;
  final FetchUserViewModel userViewModel;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              viewModel.logOut.execute();
            },
            icon: Icon(Icons.logout, color: AppColors.error),
          ),
        ],
      ),
      safeArea: true,
      body: Center(
        child: Column(
          children: [
            Text(
              '${userViewModel.currentUser.value.name} ${userViewModel.currentUser.value.surname}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              userViewModel.currentUser.value.email,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              userViewModel.currentUser.value.dateOfBirth,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              userViewModel.currentUser.value.maritalStatus,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
