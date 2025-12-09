import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

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
            AppButton(
              onPressed: () {
                if (!_isValueObjectsValid()) return;
                viewModel.createDhikr.execute((
                  name: viewModel.nameController.text.trim(),
                  targetCount: viewModel.targetCount.value,
                ));
              },
              text: 'Kaydet ve Ekle',
              running: viewModel.createDhikr.running,
            ),
            //CreateDhikrAcceptButton(viewModel: viewModel),
            SizedBox(height: context.spacingLarge),
          ],
        ),
      ),
    );
  }

  bool _isValueObjectsValid() {
    final name = viewModel.nameController.text.trim();
    if (name.isEmpty) {
      return false;
    }
    final targetCount = viewModel.targetCount.value;
    if (targetCount <= 0) {
      return false;
    }
    return true;
  }
}
