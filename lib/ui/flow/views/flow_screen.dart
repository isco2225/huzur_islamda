import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../ui.dart';

class FlowScreen extends StatefulWidget {
  const FlowScreen({super.key});

  @override
  State<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends State<FlowScreen> {
  late final FetchPostsViewModel _fetchPostsViewModel;
  late final PostReportViewModel _postReportViewModel;
  late final PostSaveViewModel _postSaveViewModel;
  late final AdvertViewModel _advertViewModel;
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
    _postSaveViewModel = PostSaveViewModel(
      postRepository: context.read<PostRepository>(),
      userRepository: context.read<UserRepository>(),
      connectivityUseCase: context.read<ConnectivityUseCase>(),
    );
    _postSaveViewModel.savePost.handleError(context, showSnackBar: true);
    _postSaveViewModel.unsavePost.handleError(context, showSnackBar: true);
    _postSaveViewModel.savePost.handleCompleted(
      context,
      successMessage: 'Gönderi kaydedildi!',
    );
    _fetchPostsViewModel.fetchPosts.handleError(context, showSnackBar: true);
    _postReportViewModel.reportPost.handleError(context, showSnackBar: true);
    _postReportViewModel.reportPost.handleCompleted(
      context,
      successMessage: 'Şikayetiniz alındı!',
    );
    _advertViewModel = AdvertViewModel(
      admobService: context.read<AdMobService>(),
    );
  }

  @override
  void dispose() {
    _fetchPostsViewModel.dispose();
    _postReportViewModel.dispose();
    _postSaveViewModel.dispose();
    _advertViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlowView(
      fetchPostsViewModel: _fetchPostsViewModel,
      postReportViewModel: _postReportViewModel,
      postSaveViewModel: _postSaveViewModel,
      advertViewModel: _advertViewModel,
    );
  }
}
