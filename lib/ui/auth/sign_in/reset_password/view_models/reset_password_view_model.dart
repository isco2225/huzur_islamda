import 'package:logging/logging.dart';

import '../../../../../app/app.dart';
import '../../../../../data/data.dart';

class ResetPasswordViewModel {
  ResetPasswordViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    sendResetEmail = Command1(_sendResetEmail, debugLabel: 'sendResetEmail');
  }

  final _log = Logger('ResetPasswordViewModel');

  final AuthRepository _authRepository;

  late Command1<void, String> sendResetEmail;

  void dispose() {
    sendResetEmail.dispose();
  }

  Future<Result<void>> _sendResetEmail(String email) async {
    _log.info('Sending password reset email to: $email');
    final result = await _authRepository.sendPasswordResetEmail(email: email);
    switch (result) {
      case Ok():
        _log.info('Password reset email sent successfully');
        return Result.ok(null);
      case Error():
        _log.warning(
          'Send password reset email failed: ${result.asError.error}',
        );
        return Result.error(result.asError.error);
    }
  }
}
