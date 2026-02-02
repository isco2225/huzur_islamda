import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/data.dart';
import '../../ui.dart';

class FlowScreen extends StatefulWidget {
  const FlowScreen({super.key});

  @override
  State<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends State<FlowScreen> {
  late final FetchPostsViewModel _fetchPostsViewModel;
  late final PostReportViewModel _postReportViewModel;
  @override
  void initState() {
    super.initState();
    _fetchPostsViewModel = FetchPostsViewModel(
      postRepository: context.read<PostRepository>(),
    );
    _postReportViewModel = PostReportViewModel(
      reportRepository: context.read<ReportRepository>(),
      userRepository: context.read<UserRepository>(),
    );
    _fetchPostsViewModel.fetchPosts.handleError(context, showSnackBar: true);
    _postReportViewModel.reportPost.handleError(context, showSnackBar: true);
    _postReportViewModel.reportPost.handleCompleted(
      context,
      successMessage: 'Şikayetiniz alındı!',
    );
    // _viewModel.fetchPosts.handleCompleted(
    //   context,
    //   successMessage: 'Posts fetched successfully',
    // );
  }

  @override
  void dispose() {
    _fetchPostsViewModel.dispose();
    _postReportViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlowView(
      fetchPostsViewModel: _fetchPostsViewModel,
      postReportViewModel: _postReportViewModel,
    );
  }
}
