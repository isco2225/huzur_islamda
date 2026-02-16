import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../ui.dart';

class AssistantAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AssistantAppBar({
    super.key,
    required this.viewModel,
    required this.user,
  });

  final AssistantViewModel viewModel;
  final ValueListenable<User> user;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel.dailyLimit, user]),
      builder: (context, _) {
        final isPremium = user.value.isPremium;
        final dailyLimit = viewModel.dailyLimit.value;
        return AppBar(
          title: const Text('Asistan'),
          // Show daily limit if user is not premium
          actions: [
            if (!isPremium)
              Padding(
                padding: EdgeInsets.only(right: context.spacingMedium),
                child: TextButton(
                  onPressed: dailyLimit != 0
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (context) => CustomDialog(
                              title: 'Haklarınız Doldu',
                              content:
                                  'Günlük hakkınız doldu, devam etmek için premium olmalısınız.',
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(AppStrings.cancel),
                                ),
                                AppButton(
                                  onPressed: () => Navigator.pop(context),
                                  text: 'Premium Ol',
                                  backgroundColor: AppColors.primary,
                                  running: ValueNotifier(false),
                                ),
                              ],
                            ),
                          );
                        },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacingSmall,
                      vertical: context.spacingExtraSmall,
                    ),
                    decoration: BoxDecoration(
                      color: dailyLimit <= 0
                          ? AppColors.error
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(context.spacingSmall),
                    ),
                    child: Text(
                      '$dailyLimit Hak',
                      style: TextStyle(
                        color: dailyLimit <= 0 ? Colors.white : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
