import 'package:connectivity_plus/connectivity_plus.dart';

import '../../app/app.dart';
import 'enums/connectivity_enum.dart';

class ConnectivityUseCase {
  ConnectivityUseCase();

  final _connectivity = Connectivity();
  Future<Result<ConnectivityEnum>> hasConnection() async {
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.contains(ConnectivityResult.wifi)) {
      return Result.ok(ConnectivityEnum.wifi);
    } else if (connectivity.contains(ConnectivityResult.mobile)) {
      return Result.ok(ConnectivityEnum.mobile);
    } else {
      return Result.ok(ConnectivityEnum.none);
    }
  }
}
