import 'package:flutter/material.dart';

import '../../ui.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  late final AssistantViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AssistantViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AssistantView(viewModel: _viewModel);
  }
}
