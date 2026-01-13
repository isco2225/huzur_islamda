import '../../../app/app.dart';
import '../../../data/data.dart';

class DhikrUseCase {
  DhikrUseCase({required DhikrRepository dhikrRepository})
    : _dhikrRepository = dhikrRepository;

  final DhikrRepository _dhikrRepository;

  Future<Result<bool>> syncDhikrs() async {
    // chech network connection
    //final hasConnection = await _networkService.hasConnection();

    /*if (hasConnection) {
      // get unsynced dhikrs from hive


      // try to sync dhikrs to firestore
      // if success, mark dhikrs as synced in hive
      
  }*/
    return Result.ok(true);
  }
}
