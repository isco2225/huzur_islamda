import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class CreateDhikrScreen extends StatefulWidget {
  const CreateDhikrScreen({super.key});

  @override
  State<CreateDhikrScreen> createState() => _CreateDhikrScreenState();
}

class _CreateDhikrScreenState extends State<CreateDhikrScreen> {
  late final CreateDhikrViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = CreateDhikrViewModel(
      dhikrRepository: context.read<DhikrRepository>(),
      userRepository: context.read<UserRepository>(),
      dhikrUseCase: context.read<DhikrUseCase>(),
    );
    _viewModel.createDhikr.handleError(context);
    _viewModel.createDhikr.handleCompleted(
      context,
      successMessage: 'Zikir oluşturuldu!',
      popCount: 0,
      onCompleted: (_) {
        // return true to the parent screen for fetching dhikrs
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      },
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CreateDhikrView(viewModel: _viewModel);
  }
}
