import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/data.dart';
import '../../ui.dart';

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  late final FetchDhikrsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FetchDhikrsViewModel(
      dhikrRepository: context.read<DhikrRepository>(),
      userRepository: context.read<UserRepository>(),
    );
    _viewModel.fetchDhikrs.handleError(context, showSnackBar: true);
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
