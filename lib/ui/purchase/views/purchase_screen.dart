import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import '../../ui.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  late final PurchaseViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PurchaseViewModel(
      purchasePremiumUseCase: context.read<PurchasePremiumUseCase>(),
      restorePurchasesUseCase: context.read<RestorePurchasesUseCase>(),
      syncRevenueCatStatusUseCase: context.read<SyncRevenueCatStatusUseCase>(),
      userRepository: context.read<UserRepository>(),
    );

    _viewModel.purchaseSelected.handleError(context, showSnackBar: true);
    _viewModel.restorePurchases.handleError(context, showSnackBar: true);
    _viewModel.syncStatus.handleError(context, showSnackBar: false);

    _viewModel.purchaseSelected.handleCompleted(
      context,
      successMessage: 'Tebriklar! Artık premium kullanıcısınız!',
    );
    _viewModel.restorePurchases.handleCompleted(
      context,
      successMessage: 'Satın alımlar geri yüklendi.',
    );

    // Ekran açılır açılmaz senkronla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.syncStatus.execute();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PurchaseView(viewModel: _viewModel);
  }
}
