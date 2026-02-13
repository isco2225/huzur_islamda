sealed class DhikrException implements Exception {
  const DhikrException();
}

/// When the user tries to perform a dhikr operation without being signed in.
final class DhikrUserIdEmpty extends DhikrException {
  const DhikrUserIdEmpty();
}

/// When the remote count is not found on Firestore.
final class DhikrRemoteCountNotFound extends DhikrException {
  const DhikrRemoteCountNotFound();
}

/// When the group ID list is empty for the group deletion operation.
final class DhikrGroupIdsEmpty extends DhikrException {
  const DhikrGroupIdsEmpty();
}

/// When the daily dhikr reminder notification cannot be cancelled.
final class DhikrReminderCancelFailed extends DhikrException {
  const DhikrReminderCancelFailed();
}

/// When the dhikrs are saved to Firestore.
final class DhikrSaveFailed extends DhikrException {
  const DhikrSaveFailed();
}

/// When the dhikrs are fetched from Firestore.
final class DhikrFetchFailed extends DhikrException {
  const DhikrFetchFailed();
}

/// When the dhikrs are fetched from Firestore.
final class DhikrFetchAllFailed extends DhikrException {
  const DhikrFetchAllFailed();
}

/// When the dhikrs are deleted from Firestore.
final class DhikrDeleteFailed extends DhikrException {
  const DhikrDeleteFailed();
}

/// When the dhikrs count is fetched from Firestore.
final class DhikrGetCountFailed extends DhikrException {
  const DhikrGetCountFailed();
}
