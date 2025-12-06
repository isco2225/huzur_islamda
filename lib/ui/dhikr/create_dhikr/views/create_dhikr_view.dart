import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../view_models/create_dhikr_view_model.dart';
import '../widgets/dhikr_name_text_field.dart';
import '../widgets/dhikr_target_count_field.dart';
import '../widgets/create_dhikr_accept_button.dart';

class CreateDhikrView extends StatelessWidget {
  const CreateDhikrView({super.key, required this.viewModel});

  final CreateDhikrViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        title: Text('Zikir Oluştur'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      safeArea: true,
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: context.spacingLarge),
            // Dhikr Name Field
            DhikrNameTextField(controller: viewModel.nameController),
            SizedBox(height: context.spacingLarge),
            // Target Count Field
            ValueListenableBuilder<int>(
              valueListenable: viewModel.targetCount,
              builder: (context, targetCount, _) {
                return DhikrTargetCountField(
                  value: targetCount,
                  onChanged: (value) => viewModel.targetCount.value = value,
                );
              },
            ),
            SizedBox(height: context.spacingExtraLarge),
            // Create Button
            CreateDhikrAcceptButton(viewModel: viewModel),
            SizedBox(height: context.spacingLarge),
          ],
        ),
      ),
    );
  }
}
