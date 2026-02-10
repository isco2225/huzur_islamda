import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

class UserViewModel {
  UserViewModel({required DeleteAccountUseCase deleteAccountUseCase})
    : _deleteAccountUseCase = deleteAccountUseCase {
    // DEFINE COMMANDS
    deleteAccount = Command0<void>(_deleteAccount, debugLabel: 'deleteAccount');
  }

  // logger
  final _log = Logger('UserViewModel');

  // repositories and use cases
  final DeleteAccountUseCase _deleteAccountUseCase;

  // commands
  late final Command0<void> deleteAccount;

  // dispose
  void dispose() {
    deleteAccount.dispose();
  }

  Future<Result<void>> _deleteAccount() async {
    final result = await _deleteAccountUseCase.execute();
    switch (result) {
      case Ok():
        _log.info('Account deleted successfully');
        return Result.ok(null);
      case Error():
        _log.warning('Failed to delete account: ${result.asError.error}');
        return Result.error(result.asError.error);
    }
  }
}
