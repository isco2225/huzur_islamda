import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class CreateDhikrView extends StatefulWidget {
  const CreateDhikrView({super.key, required this.viewModel});

  final CreateDhikrViewModel viewModel;

  @override
  State<CreateDhikrView> createState() => _CreateDhikrViewState();
}

class _CreateDhikrViewState extends State<CreateDhikrView> {
  final TextEditingController nameController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

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
            DhikrNameTextField(controller: nameController),
            SizedBox(height: context.spacingLarge),
            // Target Count Field
            ValueListenableBuilder<int>(
              valueListenable: widget.viewModel.targetCount,
              builder: (context, targetCount, _) {
                return DhikrTargetCountField(
                  value: targetCount,
                  onChanged: (value) =>
                      widget.viewModel.targetCount.value = value,
                );
              },
            ),
            SizedBox(height: context.spacingExtraLarge),
            // Create Button
            AppButton(
              onPressed: () {
                if (!_isValueObjectsValid()) return;
                widget.viewModel.createDhikr.execute((
                  name: nameController.text.trim(),
                  targetCount: widget.viewModel.targetCount.value,
                ));
              },
              text: 'Oluştur',
              running: widget.viewModel.createDhikr.running,
            ),
            SizedBox(height: context.spacingLarge),
          ],
        ),
      ),
    );
  }

  bool _isValueObjectsValid() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      return false;
    }
    final targetCount = widget.viewModel.targetCount.value;
    if (targetCount <= 0) {
      return false;
    }
    return true;
  }
}
