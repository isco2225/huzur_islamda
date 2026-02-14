import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/data.dart';
import '../../../../../domain/domain.dart';
import '../../../../ui.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  late final SavedPostsViewModel _viewModel;
  late final PostReportViewModel _postReportViewModel;
  late final PostSaveViewModel _postSaveViewModel;
  late final AdvertViewModel _advertViewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = SavedPostsViewModel(
      postRepository: context.read<PostRepository>(),
      userRepository: context.read<UserRepository>(),
      connectivityUseCase: context.read<ConnectivityUseCase>(),
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
    _advertViewModel = AdvertViewModel(
      admobService: context.read<AdMobService>(),
    );
    _viewModel.fetchSavedPosts.handleError(context, showSnackBar: true);
    _viewModel.fetchSavedPosts.execute();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _postReportViewModel.dispose();
    _postSaveViewModel.dispose();
    _advertViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SavedPostsView(
      viewModel: _viewModel,
      postReportViewModel: _postReportViewModel,
      postSaveViewModel: _postSaveViewModel,
      advertViewModel: _advertViewModel,
    );
  }
}
