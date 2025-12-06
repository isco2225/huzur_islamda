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
  late final FetchPostsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FetchPostsViewModel(
      postRepository: context.read<PostRepository>(),
    );
    _viewModel.fetchPosts.handleError(context, showSnackBar: true);
    // _viewModel.fetchPosts.handleCompleted(
    //   context,
    //   successMessage: 'Posts fetched successfully',
    // );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlowView(viewModel: _viewModel);
  }
}
