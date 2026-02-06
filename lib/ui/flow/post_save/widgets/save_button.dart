import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.viewModel, required this.post});
  final PostSaveViewModel viewModel;
  final Post post;
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return ListenableBuilder(
      listenable: viewModel.savedPostIds,
      builder: (context, _) {
        final isSaved = viewModel.savedPostIds.value.contains(post.id);
        final running = viewModel.savePost.running.value;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: AppColors.primary,
              size: responsive.isSmallScreen ? 20.0 : 24.0,
            ),
            onPressed: running
                ? null
                : () {
                    isSaved
                        ? viewModel.unsavePost.execute((postId: post.id))
                        : viewModel.savePost.execute((postId: post.id));
                  },
            tooltip: 'Kaydet',
          ),
        );
      },
    );
  }
}
