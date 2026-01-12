import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/data.dart';
import '../view_models/view_models.dart';
import 'dhikr_detail_view.dart';

class DhikrDetailScreen extends StatefulWidget {
  const DhikrDetailScreen({super.key, required this.dhikrId});

  final String dhikrId;

  @override
  State<DhikrDetailScreen> createState() => _DhikrDetailScreenState();
}

class _DhikrDetailScreenState extends State<DhikrDetailScreen> {
  late final DhikrDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DhikrDetailViewModel(
      dhikrRepository: context.read<DhikrRepository>(),
      dhikrId: widget.dhikrId,
    );

    // Error handling
    _viewModel.loadDhikr.handleError(context);
    _viewModel.incrementCount.handleError(context);
    _viewModel.decrementCount.handleError(context);
    _viewModel.resetCount.handleError(context);

    // Delete handling with navigation
    _viewModel.deleteDhikr.handleError(context);
    _viewModel.deleteDhikr.handleCompleted(
      context,
      successMessage: 'Zikir silindi',
      popCount: 1,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DhikrDetailView(viewModel: _viewModel);
  }
}
