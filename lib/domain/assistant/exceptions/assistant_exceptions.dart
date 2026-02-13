sealed class AssistantException implements Exception {
  const AssistantException();
}

final class AssistantDailyLimitExceeded extends AssistantException {
  const AssistantDailyLimitExceeded();
}

final class AssistantUnexpectedError extends AssistantException {
  const AssistantUnexpectedError();
}
