import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../user_initialize.dart';

class UserInitializeScreen extends StatefulWidget {
  const UserInitializeScreen({super.key});

  @override
  State<UserInitializeScreen> createState() => _UserInitializeScreenState();
}

class _UserInitializeScreenState extends State<UserInitializeScreen> {
  late final UserInitializeViewModel viewModel;
  @override
  void initState() {
    super.initState();
    viewModel = UserInitializeViewModel(
      userRepository: context.read(),
      authRepository: context.read(),
    );
    viewModel.initUser.handleCompleted(
      context,
      onCompleted: (isRegistered) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (isRegistered) {
            const FlowRoute().go(context);
          } else {
            const CreateProfileRoute().go(context);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: viewModel.initUser.error,
      builder: (context, error, child) {
        return !error
            ? const UserInitializeView()
            : UserInitializeErrorView(viewModel: viewModel);
      },
    );
  }
}
