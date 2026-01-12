import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../view_models/view_models.dart';
import '../widgets/widgets.dart';

class DhikrDetailView extends StatelessWidget {
  const DhikrDetailView({super.key, required this.viewModel});

  final DhikrDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: viewModel.loadDhikr.running,
      builder: (context, isLoading, child) {
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
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress Indicator
                    DhikrProgressIndicator(
                      currentCount: dhikr.currentCount,
                      targetCount: dhikr.targetCount,
                      progress: viewModel.progress,
                    ),
                    SizedBox(height: context.spacingExtraLarge),
                    // Completion Status
                    if (dhikr.isCompleted) ...[
                      DhikrCompletionBadge(),
                      SizedBox(height: context.spacingLarge),
                    ],
                    // Counter Controls
                    DhikrCounterControls(
                      dhikr: dhikr,
                      onIncrement: () => viewModel.incrementCount.execute(),
                      onDecrement: () => viewModel.decrementCount.execute(),
                      incrementRunning: viewModel.incrementCount.running,
                      decrementRunning: viewModel.decrementCount.running,
                    ),
                  ],
                ),
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
