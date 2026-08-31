import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/data.dart';
import '../../ui.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingViewModel _onboardingViewModel;
  @override
  void initState() {
    super.initState();
    _onboardingViewModel = OnboardingViewModel(
      appRepository: context.read<AppRepository>(),
    );
    _onboardingViewModel.updateIsOnboardingCompleted.handleError(
      context,
      showSnackBar: true,
    );
  }

  @override
  void dispose() {
    _onboardingViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingView(viewModel: _onboardingViewModel);
  }
}
