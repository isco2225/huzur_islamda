import 'package:cloud_functions/cloud_functions.dart' hide Result;

import '../../app/app.dart';

class FirebaseCloudFunctionsService {
  FirebaseCloudFunctionsService({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFunctions _functions;
  static const String _deleteAccountFunctionName = 'deleteUserAccount';

  Future<Result<void>> deleteUserAccount() async {
    try {
      final callable = _functions.httpsCallable(_deleteAccountFunctionName);
      final result = await callable.call();
      if (!result.data['success']) {
        return Result.error(Exception('Failed to delete user account'));
      }
      return Result.ok(null);
    } on FirebaseFunctionsException catch (e) {
      return Result.error(
        Exception('Failed to delete user account: ${e.code} - ${e.message}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to delete user account: $e'));
    }
  }
}
