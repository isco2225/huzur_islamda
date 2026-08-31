import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../ui.dart';
import '../view_models/view_models.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with WidgetsBindingObserver {
  late final EmailVerificationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = EmailVerificationViewModel(
      authRepository: context.read<AuthRepository>(),
      checkInterval: const Duration(
        seconds: 5,
      ), // Her 5 saniyede bir kontrol et
      onEmailVerified: () {
        // Email doğrulandığında yönlendir
        if (!mounted) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.mounted) {
            context.goToFlow();
          }
        });
      },
    );

    _viewModel.sendEmailVerification.handleError(context, showSnackBar: true);
    _viewModel.checkEmailVerification.handleError(context, showSnackBar: false);
    _viewModel.deleteAccount.handleError(context, showSnackBar: true);

    // Email gönderme başarılı olduğunda
    _viewModel.sendEmailVerification.handleCompleted(
      context,
      successMessage: 'Doğrulama e-postası gönderildi!',
    );

    // Hesap silme başarılı olduğunda
    _viewModel.deleteAccount.handleCompleted(
      context,
      successMessage:
          'Hesap silindi. Doğru email ile tekrar kayıt olabilirsiniz.',
      onCompleted: (_) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.mounted) {
            context.goToSignUp();
          }
        });
      },
    );
    // Ekran açıldığında otomatik olarak email gönder
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.sendEmailVerification.execute();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Uygulama foreground'a döndüğünde (kullanıcı Gmail'den geri döndü)
    if (state == AppLifecycleState.resumed) {
      // Widget hala mounted mı kontrol et (güvenlik için)
      if (!mounted) return;

      // Email doğrulama kontrolünü hemen yap
      // Kullanıcı email'i doğrulamış olabilir
      // PostFrameCallback kullanarak bir sonraki frame'de çalıştır
      // (context'in tamamen hazır olduğundan emin olmak için)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          _viewModel.checkEmailVerification.execute();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return EmailVerificationView(viewModel: _viewModel);
  }
}
