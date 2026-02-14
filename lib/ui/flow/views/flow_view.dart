import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class FlowView extends StatelessWidget {
  const FlowView({
    super.key,
    required this.fetchPostsViewModel,
    required this.postReportViewModel,
    required this.postSaveViewModel,
    required this.advertViewModel,
  });

  final FetchPostsViewModel fetchPostsViewModel;
  final PostReportViewModel postReportViewModel;
  final PostSaveViewModel postSaveViewModel;
  final AdvertViewModel advertViewModel;
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(title: const Text('Keşfet')),
      safeArea: true,
      body: Column(
        children: [
          Expanded(
            child: InfinityScrollablePosts(
              fetchPostsViewModel: fetchPostsViewModel,
              postReportViewModel: postReportViewModel,
              postSaveViewModel: postSaveViewModel,
              noItemsToShowWidget: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
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
              onFetch: () => fetchPostsViewModel.fetchPosts.execute(),
              posts: fetchPostsViewModel.posts,
              hasError: fetchPostsViewModel.fetchPosts.error,
              isFetching: fetchPostsViewModel.fetchPosts.running,
              isAllItemsFetched: fetchPostsViewModel.isAllItemsFetched,
            ),
          ),
        ],
      ),
    );
  }
}
