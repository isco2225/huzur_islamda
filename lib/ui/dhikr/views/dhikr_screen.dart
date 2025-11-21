import 'package:flutter/material.dart';

import '../../ui.dart';

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  late final DhikrViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DhikrViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DhikrView(viewModel: _viewModel);
  }
}
