import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class InfinityScrollablePosts extends StatefulWidget {
  const InfinityScrollablePosts({
    required this.fetchPostsViewModel,
    required this.noItemsToShowWidget,
    required this.onFetch,
    required this.posts,
    required this.hasError,
    required this.isFetching,
    required this.isAllItemsFetched,
    super.key,
  });
  final FetchPostsViewModel fetchPostsViewModel;
  final Widget noItemsToShowWidget;
  final VoidCallback onFetch;
  final ValueListenable<List<Post>> posts;
  final ValueListenable<bool> hasError;
  final ValueListenable<bool> isFetching;
  final ValueListenable<bool> isAllItemsFetched;
  @override
  State<InfinityScrollablePosts> createState() =>
      _InfinityScrollablePostsState();
}

class _InfinityScrollablePostsState extends State<InfinityScrollablePosts> {
  @override
  void initState() {
    super.initState();
    widget.fetchPostsViewModel.fetchPosts.execute();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Post>>(
      valueListenable: widget.posts,
      builder: (context, posts, _) {
        return InfinityScrollable.listView(
          scrollController: null,
          bottomPadding: 8,
          initializeFailureWidget: Center(
            child: Column(
              children: [
                Text('Gönderiler yüklenemedi. Tekrar deneyiniz.'),
                TextButton(
                  onPressed: () =>
                      widget.fetchPostsViewModel.fetchPosts.execute(),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
          fetchMoreFailureWidget: Column(
            children: [Text('Gönderiler yüklenemedi. Tekrar deneyiniz.')],
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Center(child: FlowCard(post: post));
          },
          isFetching: widget.isFetching.value,
          onFetchMore: () => widget.onFetch(),
          isAllItemsFetched: widget.isAllItemsFetched.value,
          fetchingFirstItems: const SizedBox.shrink(),
          fetchingMoreItemsWidget: const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          noItemsToShowWidget: widget.noItemsToShowWidget,
          hasError: widget.hasError.value,
        );
      },
    );
  }
}
