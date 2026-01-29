import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../ui.dart';

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  late final FetchDhikrsViewModel _viewModel;
  late final CreateDhikrViewModel _createDhikrViewModel;
  @override
  void initState() {
    super.initState();
    _createDhikrViewModel = CreateDhikrViewModel(
      dhikrRepository: context.read<DhikrRepository>(),
      userRepository: context.read<UserRepository>(),
      dhikrUseCase: context.read<DhikrUseCase>(),
      showAdUseCase: context.read<ShowAdUseCase>(),
    );
    _viewModel = FetchDhikrsViewModel(
      dhikrRepository: context.read<DhikrRepository>(),
      userRepository: context.read<UserRepository>(),
    );
    _viewModel.fetchDhikrs.handleError(context, showSnackBar: true);
    _createDhikrViewModel.createDhikrsForPrayer.handleError(
      context,
      showSnackBar: true,
    );
    _createDhikrViewModel.createDhikrsForPrayer.handleCompleted(
      context,
      successMessage: 'Zikirler oluşturuldu!',
      popCount: 1,
      onCompleted: (_) {
        // TODO: go to created dhikrs detail screen
      },
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _createDhikrViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DhikrView(
      viewModel: _viewModel,
      createDhikrViewModel: _createDhikrViewModel,
    );
  }
}
