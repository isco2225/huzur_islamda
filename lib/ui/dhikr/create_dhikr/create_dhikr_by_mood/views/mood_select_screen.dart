import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../app/app.dart';
import '../../../../../data/data.dart';
import '../../../../../domain/domain.dart';
import '../view_models/view_models.dart';
import 'mood_select_view.dart';

class MoodSelectScreen extends StatefulWidget {
  const MoodSelectScreen({super.key});

  @override
  State<MoodSelectScreen> createState() => _MoodSelectScreenState();
}

class _MoodSelectScreenState extends State<MoodSelectScreen> {
  late final MoodSelectViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MoodSelectViewModel(
      moodService: context.read<DhikrMoodService>(),
      dhikrRepository: context.read<DhikrRepository>(),
      userRepository: context.read<UserRepository>(),
      dhikrUseCase: context.read<DhikrUseCase>(),
    );
    _viewModel.loadMoods();
    _viewModel.createDhikrsForMood.handleError(context, showSnackBar: true);
    _viewModel.createDhikrsForMood.handleCompleted(
      context,
      successMessage: 'Zikir grubu oluşturuldu!',
      popCount: 0,
      onCompleted: (dhikrIds) {
        if (dhikrIds.isNotEmpty && context.mounted) {
          context.pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.pushToDhikrDetailForGroup(dhikrIds);
          });
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
    return MoodSelectView(viewModel: _viewModel);
  }
}
