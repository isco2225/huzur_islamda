import 'package:flutter/material.dart';

import '../../../../../app/app.dart';
import '../../../../ui.dart';

class SavedPostsView extends StatelessWidget {
  const SavedPostsView({
    super.key,
    required this.viewModel,
    required this.postReportViewModel,
    required this.postSaveViewModel,
  });
  final SavedPostsViewModel viewModel;
  final PostReportViewModel postReportViewModel;
  final PostSaveViewModel postSaveViewModel;
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final textTheme = Theme.of(context).textTheme;
    return BaseScaffold(
      appBar: AppBar(title: const Text('Kaydedilenler'), elevation: 0),
      safeArea: true,
      body: Column(
        children: [
          Expanded(
            child: InfinityScrollableSavedPosts(
              viewModel: viewModel,
              savedPosts: viewModel.savedPosts,
              onFetch: () => viewModel.fetchSavedPosts.execute(),
              hasError: viewModel.fetchSavedPosts.error,
              isFetching: viewModel.fetchSavedPosts.running,
              isAllItemsFetched: viewModel.isAllItemsFetched,
              postReportViewModel: postReportViewModel,
              postSaveViewModel: postSaveViewModel,
              noItemsToShowWidget: Center(
                child: Padding(
                  padding: EdgeInsets.all(responsive.horizontalPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz kaydedilmiş bir gönderiniz yok.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //const BannerAdWidget(),
        ],
      ),
    );
  }
}
