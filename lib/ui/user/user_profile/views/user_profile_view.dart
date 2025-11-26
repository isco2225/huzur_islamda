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
                  _buildInfoCard(
                    context,
                    textTheme,
                    icon: Icons.email_outlined,
                    label: 'E-posta',
                    value: user.email,
                  ),
                  SizedBox(height: context.spacingMedium),
                  _buildInfoCard(
                    context,
                    textTheme,
                    icon: Icons.cake_outlined,
                    label: 'Doğum Tarihi',
                    value: user.dateOfBirth,
                  ),
                  SizedBox(height: context.spacingMedium),
                  _buildInfoCard(
                    context,
                    textTheme,
                    icon: Icons.favorite_outline,
                    label: 'Medeni Durum',
                    value: user.maritalStatus,
                  ),
                  SizedBox(height: context.spacingLarge),
                  // Edit Profile Button
                  _buildEditProfileButton(context, textTheme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context, TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      height: context.isSmallScreen ? 48 : 52,
      child: ElevatedButton.icon(
        onPressed: () {
          const EditProfileRoute().push(context);
        },
        icon: Icon(Icons.edit_rounded, size: context.isSmallScreen ? 20 : 22),
        label: Text(
          'Profili Düzenle',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: context.responsiveFontSize(
              textTheme.titleMedium?.fontSize,
            ),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, TextTheme textTheme, user) {
    final initials = _getInitials(user.name, user.surname);

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
                initials,
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

  Widget _buildInfoCard(
    BuildContext context,
    TextTheme textTheme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: context.containerPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: context.isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: context.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: context.responsiveFontSize(
                      textTheme.bodySmall?.fontSize,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.subtitleColor,
                    fontSize: context.responsiveFontSize(
                      textTheme.bodyLarge?.fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name, String surname) {
    final nameInitial = name.isNotEmpty ? name[0].toUpperCase() : '';
    final surnameInitial = surname.isNotEmpty ? surname[0].toUpperCase() : '';
    return '$nameInitial$surnameInitial';
  }
}
