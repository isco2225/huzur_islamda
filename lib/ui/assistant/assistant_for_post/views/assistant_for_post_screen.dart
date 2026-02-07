import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import '../view_models/view_models.dart';
import 'assistant_for_post_view.dart';

class AssistantForPostScreen extends StatefulWidget {
  const AssistantForPostScreen({super.key, required this.post});

  final Post post;

  @override
  State<AssistantForPostScreen> createState() => _AssistantForPostScreenState();
}

class _AssistantForPostScreenState extends State<AssistantForPostScreen> {
  late final AssistantForPostViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AssistantForPostViewModel(
      post: widget.post,
      assistantUseCase: context.read<AssistantUseCase>(),
      connectivityUseCase: context.read<ConnectivityUseCase>(),
      userRepository: context.read<UserRepository>(),
    );
    _viewModel.sendMessage.handleError(context);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AssistantForPostView(viewModel: _viewModel);
  }
}
