import 'package:flutter/material.dart';

import '../../ui.dart';

class FlowScreen extends StatefulWidget {
  const FlowScreen({super.key});

  @override
  State<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends State<FlowScreen> {
  late final FlowViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FlowViewModel();
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
