import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class FlowView extends StatefulWidget {
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
  State<FlowView> createState() => _FlowViewState();
}

class _FlowViewState extends State<FlowView> {
  late final ScrollController _scrollController;

  static const String _logoAsset = 'assets/icons/app_icon.png';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final logoSize = responsive.spacingMedium;
    return BaseScaffold(
      appBar: AppBar(
        leadingWidth: logoSize * 3,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _scrollToTop,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    _logoAsset,
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.explore_outlined,
                      color: Theme.of(context).appBarTheme.iconTheme?.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        title: const Text('Keşfet'),
      ),
      safeArea: true,
      body: Column(
        children: [
          Expanded(
            child: InfinityScrollablePosts(
              scrollController: _scrollController,
              fetchPostsViewModel: widget.fetchPostsViewModel,
              postReportViewModel: widget.postReportViewModel,
              postSaveViewModel: widget.postSaveViewModel,
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
              onFetch: () => widget.fetchPostsViewModel.fetchPosts.execute(),
              posts: widget.fetchPostsViewModel.posts,
              hasError: widget.fetchPostsViewModel.fetchPosts.error,
              isFetching: widget.fetchPostsViewModel.fetchPosts.running,
              isAllItemsFetched: widget.fetchPostsViewModel.isAllItemsFetched,
            ),
          ),
        ],
      ),
    );
  }
}
