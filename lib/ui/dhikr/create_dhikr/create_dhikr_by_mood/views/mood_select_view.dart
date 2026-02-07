import 'package:flutter/material.dart';

import '../../../../../app/app.dart';
import '../../../../../domain/domain.dart';
import '../view_models/view_models.dart';

class MoodSelectView extends StatelessWidget {
  const MoodSelectView({super.key, required this.viewModel});

  final MoodSelectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: viewModel.createDhikrsForMood.running,
      builder: (context, isCreating, _) {
        return Stack(
          children: [
            BaseScaffold(
              appBar: AppBar(
                title: const Text('Ruh haline göre zikir'),
                backgroundColor: AppColors.background,
                elevation: 0,
              ),
              safeArea: true,
              backgroundColor: AppColors.background,
              body: ValueListenableBuilder<bool>(
                valueListenable: viewModel.isLoadingMoods,
                builder: (context, isLoading, _) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ValueListenableBuilder<Object?>(
                    valueListenable: viewModel.loadMoodsError,
                    builder: (context, error, _) {
                      if (error != null) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(context.horizontalPadding),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(height: context.spacingLarge),
                                Text(
                                  error is Exception
                                      ? error.toString()
                                      : 'Ruh halleri yüklenemedi.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ValueListenableBuilder<List<Mood>?>(
                        valueListenable: viewModel.moods,
                        builder: (context, moods, _) {
                          if (moods == null || moods.isEmpty) {
                            return const Center(
                              child: Text('Ruh hali bulunamadı.'),
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.all(context.horizontalPadding),
                            itemCount: moods.length,
                            itemBuilder: (context, index) {
                              final mood = moods[index];
                              return _MoodTile(
                                mood: mood,
                                onTap: () =>
                                    viewModel.createDhikrsForMood.execute(mood),
                                isCreating: isCreating,
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            if (isCreating)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.onTap,
    required this.isCreating,
  });

  final Mood mood;
  final VoidCallback onTap;
  final bool isCreating;

  @override
  Widget build(BuildContext context) {
    Color? color;
    try {
      color = Color(int.parse(mood.colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      color = null;
    }
    final tileColor = color ?? Theme.of(context).colorScheme.primary;

    return Card(
      margin: EdgeInsets.only(bottom: context.spacingMedium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: tileColor.withValues(alpha: 0.2),
          child: Icon(Icons.snowing, color: tileColor),
        ),
        title: Text(mood.title),
        subtitle: Text(
          '${mood.suggestions.length} zikir önerisi',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.add_circle_outline),
        onTap: isCreating ? null : onTap,
      ),
    );
  }
}
