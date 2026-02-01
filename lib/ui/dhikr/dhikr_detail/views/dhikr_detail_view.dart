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
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    context.pop();
                  },
                ),
                backgroundColor: AppColors.background,
                elevation: 0,
                actions: [
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _showDeleteConfirmation(context),
                  ),
                  // Reset button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _showResetConfirmation(context),
                  ),
                ],
              ),
              backgroundColor: AppColors.background,
              safeArea: true,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Name
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: Center(
                      child: Text(
                        dhikr.name,
                        style: Theme.of(context).textTheme.headlineMedium
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
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zikiri Sil'),
        content: const Text('Bu zikiri silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteDhikr.execute();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sayacı Sıfırla'),
        content: const Text('Sayacı sıfırlamak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.resetCount.execute();
            },
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }
}
