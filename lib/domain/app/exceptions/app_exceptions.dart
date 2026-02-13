sealed class AppException implements Exception {
  const AppException();
}

final class AppLoadFailed extends AppException {
  const AppLoadFailed();
}
