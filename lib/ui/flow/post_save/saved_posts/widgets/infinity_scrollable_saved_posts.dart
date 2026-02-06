import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../app/app.dart';
import '../../../../../domain/domain.dart';
import '../../../../ui.dart';

class InfinityScrollableSavedPosts extends StatefulWidget {
  const InfinityScrollableSavedPosts({
    super.key,
    required this.viewModel,
    required this.noItemsToShowWidget,
    required this.onFetch,
    required this.savedPosts,
    required this.hasError,
    required this.isFetching,
    required this.isAllItemsFetched,
    required this.postReportViewModel,
    required this.postSaveViewModel,
  });

  final SavedPostsViewModel viewModel;
  final Widget noItemsToShowWidget;
  final VoidCallback onFetch;
  final ValueListenable<List<Post>> savedPosts;
  final ValueListenable<bool> hasError;
  final ValueListenable<bool> isFetching;
  final ValueListenable<bool> isAllItemsFetched;
  final PostReportViewModel postReportViewModel;
  final PostSaveViewModel postSaveViewModel;
  @override
  State<InfinityScrollableSavedPosts> createState() =>
      _InfinityScrollableSavedPostsState();
}

class _InfinityScrollableSavedPostsState
    extends State<InfinityScrollableSavedPosts> {
  @override
  void initState() {
    super.initState();
    widget.onFetch();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.savedPosts,
        widget.hasError,
        widget.isFetching,
        widget.isAllItemsFetched,
      ]),
      builder: (context, _) {
        return InfinityScrollable.listView(
          scrollController: null,
          bottomPadding: 8,
          initializeFailureWidget: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Kayıtlı gönderiler yüklenemedi. Tekrar deneyiniz.'),
                TextButton(
                  onPressed: () => widget.onFetch(),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
          fetchMoreFailureWidget: Column(
            children: [
              const Text('Kayıtlı gönderiler yüklenemedi. Tekrar deneyiniz.'),
              AppButton(
                onPressed: () => widget.onFetch(),
                text: 'Tekrar Dene',
                running: widget.viewModel.fetchSavedPosts.running,
              ),
            ],
          ),
          itemCount: widget.savedPosts.value.length,
          itemBuilder: (context, index) {
            final post = widget.savedPosts.value[index];
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
                children: List.generate(2, (index) => const LoadingPostsCard()),
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
