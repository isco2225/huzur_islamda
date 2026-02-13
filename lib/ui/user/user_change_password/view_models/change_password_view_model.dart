import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';

class ChangePasswordViewModel {
  ChangePasswordViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository {
    changePassword = Command1(
      _changePassword,
      debugLabel: 'ChangePasswordViewModel.changePassword',
    );
  }

  final _log = Logger('ChangePasswordViewModel');
  final AuthRepository _authRepository;

  late Command1<void, ({String currentPassword, String newPassword})>
      changePassword;

  void dispose() {
    changePassword.dispose();
  }

  Future<Result<void>> _changePassword(
    ({String currentPassword, String newPassword}) args,
  ) async {
    _log.info('Changing password...');
    final result = await _authRepository.updatePassword(
      currentPassword: args.currentPassword,
      newPassword: args.newPassword,
    );
    switch (result) {
      case Ok():
        _log.info('Password changed successfully');
        return Result.ok(null);
      case Error():
        _log.warning('Change password failed: ${result.asError.error}');
        return Result.error(result.asError.error);
    }
  }
}
