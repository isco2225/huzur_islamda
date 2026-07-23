import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class DhikrDetailScreen extends StatefulWidget {
  const DhikrDetailScreen({
    super.key,
    required this.initialDhikrId,
    this.groupDhikrIds,
  });

  final String initialDhikrId;
  final List<String>? groupDhikrIds;

  @override
  State<DhikrDetailScreen> createState() => _DhikrDetailScreenState();
}

class _DhikrDetailScreenState extends State<DhikrDetailScreen> {
  late final DhikrDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DhikrDetailViewModel(
      dhikrRepository: context.read<DhikrRepository>(),
      initialDhikrId: widget.initialDhikrId,
      groupDhikrIds: widget.groupDhikrIds,
      dhikrUseCase: context.read<DhikrUseCase>(),
    );

    // Error handling
    _viewModel.loadDhikr.handleError(context);
    _viewModel.incrementCount.handleError(context);
    _viewModel.decrementCount.handleError(context);
    _viewModel.resetCount.handleError(context);
    _viewModel.deleteDhikr.handleError(context);
    _viewModel.deleteDhikr.handleCompleted(
      context,
      successMessage: 'Zikir silindi',
      popCount: 1,
    );

    // Zikir tamamlandığında paywall ekranını göster
    _viewModel.showPaywall.addListener(_onShowPaywallChanged);
  }

  @override
  void dispose() {
    _viewModel.showPaywall.removeListener(_onShowPaywallChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onShowPaywallChanged() {
    if (!_viewModel.showPaywall.value) {
      return;
    }
    // Bir kere tetiklensin
    _viewModel.showPaywall.value = false;

    if (!mounted) return;

    // Kullanıcı zaten aboneyse paywall gösterme
    final isPremium = context.read<UserRepository>().currentUser.value.isPremium;
    if (isPremium) return;

    // Paywall ekranını navigation stack üzerine aç
    context.pushPurchase();
  }

  @override
  Widget build(BuildContext context) {
    return DhikrDetailView(viewModel: _viewModel);
  }
}
