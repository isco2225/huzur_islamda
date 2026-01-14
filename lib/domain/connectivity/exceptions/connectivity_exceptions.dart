sealed class ConnectivityException implements Exception {
  const ConnectivityException();
}

final class ConnectivityNoConnection extends ConnectivityException {
  const ConnectivityNoConnection();
}

final class ConnectivityUnknown extends ConnectivityException {
  const ConnectivityUnknown();
}
