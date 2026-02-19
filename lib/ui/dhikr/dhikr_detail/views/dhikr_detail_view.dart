import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class DhikrDetailView extends StatelessWidget {
  const DhikrDetailView({super.key, required this.viewModel});

  final DhikrDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return ListenableBuilder(
      listenable: Listenable.merge([
        viewModel.loadDhikr.running,
        viewModel.deleteDhikr.running,
      ]),
      builder: (context, child) {
        final isLoading =
            viewModel.loadDhikr.running.value ||
            viewModel.deleteDhikr.running.value;
        if (isLoading) {
          return BaseScaffold(
            appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
            backgroundColor: AppColors.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        return ValueListenableBuilder(
          valueListenable: viewModel.currentDhikr,
          builder: (context, dhikr, child) {
            if (dhikr == null) {
              return BaseScaffold(
                appBar: AppBar(
                  backgroundColor: AppColors.background,
                  elevation: 0,
                ),
                backgroundColor: AppColors.background,
                body: const Center(child: Text('Zikir bulunamadı')),
              );
            }
            return BaseScaffold(
              appBar: AppBar(
                title: Text(dhikr.name),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goToDhikr();
                    }
                  },
                ),
                backgroundColor: AppColors.background,
                elevation: 0,
                actions: [
                  if (dhikr.meaning != null) ...[
                    IconButton(
                      onPressed: () {
                        _showDhikrMeaningBottomSheet(context, dhikr);
                      },
                      icon: const Icon(Icons.info_outline),
                      color: AppColors.success,
                    ),
                  ],
                  DhikrDetailPopMenuButton(
                    onDeleteDhikrTapped: () {
                      _showDeleteConfirmation(context);
                    },
                    onResetDhikrTapped: () {
                      _showResetConfirmation(context);
                    },
                  ),
                ],
              ),
              backgroundColor: AppColors.background,
              safeArea: true,
              body: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Name
                          Padding(
                            padding: const EdgeInsets.only(bottom: 100.0),
                            child: Center(
                              child: Text(
                                dhikr.arabic ?? dhikr.name,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.success,
                                    ),
                              ),
                            ),
                          ),
                          // Progress Indicator
                          DhikrProgressIndicator(
                            currentCount: dhikr.currentCount,
                            targetCount: dhikr.targetCount,
                            progress: viewModel.progress,
                          ),
                          SizedBox(height: context.spacingExtraLarge),
                          // Completion Status
                          if (dhikr.isCompleted) ...[
                            DhikrCompletionBadge(
                              responsiveWidth: responsive.screenWidth * 0.8,
                              dhikr: dhikr,
                            ),
                            SizedBox(height: context.spacingLarge),
                          ],
                          // Counter Controls
                          DhikrCounterControls(
                            dhikr: dhikr,
                            onIncrement: () {
                              if (dhikr.currentCount == dhikr.targetCount - 1) {
                                VibrationUseCase.vibrateHigh(context);
                              } else {
                                VibrationUseCase.vibrateLight(context);
                              }
                              viewModel.incrementCount.execute();
                            },
                            onDecrement: () {
                              VibrationUseCase.vibrateMedium(context);
                              viewModel.decrementCount.execute();
                            },
                            incrementRunning: viewModel.incrementCount.running,
                            decrementRunning: viewModel.decrementCount.running,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showDhikrMeaningBottomSheet(BuildContext context, Dhikr dhikr) {
    showModalBottomSheet(
      backgroundColor: AppColors.background,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DhikrMeanBottomSheet(dhikr: dhikr);
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Zikiri Sil',
        content: 'Bu zikiri silmek istediğinize emin misiniz?',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          AppButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteDhikr.execute();
            },
            running: viewModel.deleteDhikr.running,
            text: 'Sil',
            backgroundColor: AppColors.error,
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Dikkat!',
        content: 'Sayacı sıfırlamak istediğinize emin misiniz?',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          AppButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.resetCount.execute();
            },
            text: 'Sıfırla',
            running: viewModel.resetCount.running,
            backgroundColor: AppColors.error,
          ),
        ],
      ),
    );
  }
}
