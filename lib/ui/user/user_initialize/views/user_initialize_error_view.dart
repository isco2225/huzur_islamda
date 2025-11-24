import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../user_initialize.dart';

class UserInitializeErrorView extends StatelessWidget {
  const UserInitializeErrorView({required this.viewModel, super.key});
  final UserInitializeViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      safeArea: true,
      appBar: UserInitializeErrorAppBar(viewModel: viewModel),
      body: BaseColumn(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox.shrink(),
          Column(
            children: [
              const Icon(Icons.sentiment_dissatisfied, size: 64),
              const SizedBox(height: 16),
              SelectableText(
                'Kullanıcı verileri yüklenemedi',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          AppGradientButton(
            text: 'Tekrar Dene',
            onPressed: viewModel.initUser.execute,
          ),
        ],
      ),
    );
  }
}
