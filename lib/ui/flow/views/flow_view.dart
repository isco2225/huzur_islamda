import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class FlowView extends StatelessWidget {
  const FlowView({super.key, required this.viewModel});

  final FetchPostsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        title: const Text('Keşfet'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      safeArea: true,
      body: InfinityScrollablePosts(
        fetchPostsViewModel: viewModel,
        noItemsToShowWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Henüz gönderi yok.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        onFetch: () => viewModel.fetchPosts.execute(),
        posts: viewModel.posts,
        hasError: viewModel.fetchPosts.error,
        isFetching: viewModel.fetchPosts.running,
        isAllItemsFetched: viewModel.fetchPosts.completed,
      ),
    );
  }
}
