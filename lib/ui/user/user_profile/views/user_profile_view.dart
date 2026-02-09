import 'package:flutter/material.dart';

import '../../../../../app/app.dart';
import '../../../ui.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({
    super.key,
    required this.viewModel,
    required this.userViewModel,
  });
  final LogOutViewModel viewModel;
  final FetchUserViewModel userViewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BaseScaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: context.responsiveFontSize(
              textTheme.titleLarge?.fontSize,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.pushSavedPosts();
            },
            icon: Icon(
              Icons.bookmark,
              size: context.isSmallScreen ? 22 : 24,
              color: AppColors.primary,
            ),
            tooltip: 'Kaydedilenler',
          ),
          IconButton(
            onPressed: () {
              context.pushSettings();
            },
            icon: Icon(Icons.settings, size: context.isSmallScreen ? 22 : 24),
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      safeArea: true,
      body: ValueListenableBuilder(
        valueListenable: userViewModel.currentUser,
        builder: (context, user, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalPadding,
              vertical: context.verticalPadding,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header Card
                  ProfileHeaderDisplayer(user: user, textTheme: textTheme),
                  SizedBox(height: context.spacingSmall),
                  // Profile Information Cards
                  UserProfileInfoCard(
                    icon: Icons.email_outlined,
                    label: 'E-posta',
                    value: user.email,
                  ),
                  SizedBox(height: context.spacingExtraSmall),
                  UserProfileInfoCard(
                    icon: Icons.cake_outlined,
                    label: 'Doğum Tarihi',
                    value: user.dateOfBirth,
                  ),
                  SizedBox(height: context.spacingExtraSmall),
                  UserProfileInfoCard(
                    icon: Icons.favorite_outline,
                    label: 'Cinsiyet',
                    value: user.gender,
                  ),
                  SizedBox(height: context.spacingSmall),
                  // Edit Profile Button
                  EditProfileButton(textTheme: textTheme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
