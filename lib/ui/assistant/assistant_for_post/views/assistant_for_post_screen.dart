import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class AssistantForPostScreen extends StatefulWidget {
  const AssistantForPostScreen({super.key, required this.post});

  final Post post;

  @override
  State<AssistantForPostScreen> createState() => _AssistantForPostScreenState();
}

class _AssistantForPostScreenState extends State<AssistantForPostScreen> {
  late final AssistantViewModel _assistantViewModel;
  late final AssistantForPostViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _assistantViewModel = AssistantViewModel(
      userRepository: context.read<UserRepository>(),
      assistantUseCase: context.read<AssistantUseCase>(),
      connectivityUseCase: context.read<ConnectivityUseCase>(),
      appRepository: context.read<AppRepository>(),
    );
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
    _assistantViewModel.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AssistantForPostView(
      viewModel: _viewModel,
      assistantViewModel: _assistantViewModel,
    );
  }
}
