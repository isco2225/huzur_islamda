import 'package:flutter/material.dart';

import '../../../../../app/app.dart';
import '../../../../domain/domain.dart';
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
              const SettingsRoute().push(context);
              //viewModel.logOut.execute();
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
                  _buildProfileHeader(context, textTheme, user),
                  SizedBox(height: context.spacingLarge),

                  // Profile Information Cards
                  UserProfileInfoCard(
                    icon: Icons.email_outlined,
                    label: 'E-posta',
                    value: user.email,
                  ),
                  SizedBox(height: context.spacingMedium),
                  UserProfileInfoCard(
                    icon: Icons.cake_outlined,
                    label: 'Doğum Tarihi',
                    value: user.dateOfBirth,
                  ),
                  SizedBox(height: context.spacingMedium),
                  UserProfileInfoCard(
                    icon: Icons.favorite_outline,
                    label: 'Medeni Durum',
                    value: user.maritalStatus,
                  ),
                  SizedBox(height: context.spacingLarge),
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

  Widget _buildProfileHeader(
    BuildContext context,
    TextTheme textTheme,
    User user,
  ) {
    return Container(
      padding: EdgeInsets.all(context.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar Circle
          Container(
            width: context.isSmallScreen ? 80 : 100,
            height: context.isSmallScreen ? 80 : 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
            ),
            child: Center(
              child: Text(
                '${user.name[0]}${user.surname[0]}',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: context.responsiveFontSize(
                    context.isSmallScreen ? 28 : 36,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: context.spacingMedium),
          // Name
          Text(
            '${user.name} ${user.surname}',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.subtitleColor,
              fontSize: context.responsiveFontSize(
                textTheme.headlineSmall?.fontSize,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
