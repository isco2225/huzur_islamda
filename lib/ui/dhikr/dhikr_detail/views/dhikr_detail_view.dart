import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class DhikrDetailView extends StatefulWidget {
  const DhikrDetailView({super.key, required this.viewModel});

  final DhikrDetailViewModel viewModel;

  @override
  State<DhikrDetailView> createState() => _DhikrDetailViewState();
}

class _DhikrDetailViewState extends State<DhikrDetailView> {
  // Callback to trigger animation - better than GlobalKey
  VoidCallback? _triggerNameAnimation;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.viewModel.loadDhikr.running,
        widget.viewModel.deleteDhikr.running,
      ]),
      builder: (context, child) {
        final isLoading =
            widget.viewModel.loadDhikr.running.value ||
            widget.viewModel.deleteDhikr.running.value;
        if (isLoading) {
          return BaseScaffold(
            appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
            backgroundColor: AppColors.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return ValueListenableBuilder(
          valueListenable: widget.viewModel.currentDhikr,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: Center(
                      child: _AnimatedDhikrName(
                        name: dhikr.name,
                        onAnimationReady: (callback) {
                          // Store the callback to trigger animation later
                          _triggerNameAnimation = callback;
                        },
                      ),
                    ),
                  ),
                  // Progress Indicator
                  DhikrProgressIndicator(
                    currentCount: dhikr.currentCount,
                    targetCount: dhikr.targetCount,
                    progress: widget.viewModel.progress,
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
                    onIncrement: () {
                      // Trigger animation when increment button is pressed
                      _triggerNameAnimation?.call();
                      widget.viewModel.incrementCount.execute();
                    },
                    onDecrement: () =>
                        widget.viewModel.decrementCount.execute(),
                    incrementRunning: widget.viewModel.incrementCount.running,
                    decrementRunning: widget.viewModel.decrementCount.running,
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
              widget.viewModel.deleteDhikr.execute();
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
              widget.viewModel.resetCount.execute();
            },
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }
}

/// Animated widget for displaying dhikr name with pop animation on increment
class _AnimatedDhikrName extends StatefulWidget {
  const _AnimatedDhikrName({
    required this.name,
    required this.onAnimationReady,
  });

  final String name;
  final ValueChanged<VoidCallback> onAnimationReady;

  @override
  State<_AnimatedDhikrName> createState() => _AnimatedDhikrNameState();
}

class _AnimatedDhikrNameState extends State<_AnimatedDhikrName>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Color animation: from success to a brighter color and back
    _colorAnimation = ColorTween(
      begin: AppColors.primary.withValues(alpha: 0.8),
      end: AppColors.primary,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Register the animation callback with parent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAnimationReady(triggerAnimation);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Trigger animation when increment button is pressed
  void triggerAnimation() {
    _controller.forward(from: 0.0).then((_) {
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Text(
          widget.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: _colorAnimation.value ?? AppColors.success,
          ),
        );
      },
    );
  }
}
