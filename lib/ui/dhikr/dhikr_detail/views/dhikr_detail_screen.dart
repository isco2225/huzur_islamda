import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class DhikrDetailScreen extends StatefulWidget {
  const DhikrDetailScreen({
    super.key,
    required this.initialDhikrId,
    this.groupDhikrIds,
  });

  final String initialDhikrId;
  final List<String>? groupDhikrIds;

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
      initialDhikrId: widget.initialDhikrId,
      groupDhikrIds: widget.groupDhikrIds,
      dhikrUseCase: context.read<DhikrUseCase>(),
    );

    // Error handling
    _viewModel.loadDhikr.handleError(context);
    _viewModel.incrementCount.handleError(context);
    _viewModel.decrementCount.handleError(context);
    _viewModel.resetCount.handleError(context);
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
