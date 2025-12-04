import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';
import '../../../domain/domain.dart';

class FlowView extends StatelessWidget {
  const FlowView({super.key, required this.viewModel});

  final FlowViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      safeArea: true,
      body: ValueListenableBuilder<List<Post>>(
        valueListenable: viewModel.posts,
        builder: (context, posts, _) {
          return ValueListenableBuilder<bool>(
            valueListenable: viewModel.fetchPosts.running,
            builder: (context, isFetching, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: viewModel.fetchPosts.error,
                builder: (context, hasError, _) {
                  return InfinityScrollable.listView(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return _PostCard(post: post);
                    },
                    isFetching: isFetching,
                    hasError: hasError,
                    isAllItemsFetched:
                        false, // TODO: Pagination eklendiğinde güncellenecek
                    onFetchMore: () {
                      viewModel.fetchPosts.execute();
                    },
                    fetchingFirstItems: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    fetchingMoreItemsWidget: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    initializeFailureWidget: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Posts yüklenirken bir hata oluştu',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => viewModel.fetchPosts.execute(),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                    fetchMoreFailureWidget: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 32,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Daha fazla post yüklenirken hata oluştu',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => viewModel.fetchPosts.execute(),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
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
                            'Henüz post yok',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    bottomPadding: 16,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (post.emotions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: post.emotions.entries.map((entry) {
                  return Chip(
                    label: Text('${entry.key.value}: ${entry.value}'),
                    labelStyle: const TextStyle(fontSize: 12),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
