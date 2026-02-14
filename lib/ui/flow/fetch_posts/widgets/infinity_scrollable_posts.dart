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
    required this.postReportViewModel,
    required this.postSaveViewModel,
    super.key,
  });
  final FetchPostsViewModel fetchPostsViewModel;
  final Widget noItemsToShowWidget;
  final VoidCallback onFetch;
  final ValueListenable<List<Post>> posts;
  final ValueListenable<bool> hasError;
  final ValueListenable<bool> isFetching;
  final ValueListenable<bool> isAllItemsFetched;
  final PostReportViewModel postReportViewModel;
  final PostSaveViewModel postSaveViewModel;
  @override
  State<InfinityScrollablePosts> createState() =>
      _InfinityScrollablePostsState();
}

class _InfinityScrollablePostsState extends State<InfinityScrollablePosts> {
  final int adsEveryNPosts = 3;
  @override
  void initState() {
    super.initState();
    widget.fetchPostsViewModel.fetchPosts.execute();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.posts,
        widget.hasError,
        widget.isFetching,
        widget.isAllItemsFetched,
      ]),
      builder: (context, _) {
        final posts = widget.posts.value;
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
            children: [
              Text('Gönderiler yüklenemedi. Tekrar deneyiniz.'),
              AppButton(
                onPressed: () =>
                    widget.fetchPostsViewModel.fetchPosts.execute(),
                text: 'Tekrar Dene',
                running: widget.fetchPostsViewModel.fetchPosts.running,
              ),
            ],
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            if (index % adsEveryNPosts == 0 && index != 0) {
              return Center(
                child: FlowNativeAd(
                  isCurrentUserPremium:
                      widget.postSaveViewModel.currentUser.value.isPremium,
                ),
              );
            }
            return Center(
              child: FlowCard(
                post: post,
                postReportViewModel: widget.postReportViewModel,
                postSaveViewModel: widget.postSaveViewModel,
              ),
            );
          },
          isFetching: widget.isFetching.value,
          onFetchMore: () => widget.onFetch(),
          isAllItemsFetched: widget.isAllItemsFetched.value,
          fetchingFirstItems: Center(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(2, (index) => LoadingPostsCard()),
              ),
            ),
          ),
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
