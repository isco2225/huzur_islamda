import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/data.dart';
import '../../ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final LogOutViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = LogOutViewModel(
      authRepository: context.read<AuthRepository>(),
    );
    // Error handling
    _viewModel.logOut.handleError(context, showSnackBar: true);
    // Success handling
    _viewModel.logOut.handleCompleted(
      context,
      successMessage: 'Çıkış başarılı!',
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomeView(viewModel: _viewModel);
  }
}
