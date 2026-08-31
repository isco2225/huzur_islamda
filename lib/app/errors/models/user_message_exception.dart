/// An exception whose [message] is written for the end user (in Turkish) and
/// can be shown as-is by `exceptionToUserFriendlyMessage`.
///
/// Use it instead of a bare `Exception('...')` whenever the text is meant for
/// the user; bare exceptions fall back to the generic "Bilinmeyen bir hata
/// oluştu" message. Keep the technical detail in [cause] so it still reaches
/// the logs without leaking into the UI.
final class UserMessageException implements Exception {
  const UserMessageException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => cause == null
      ? 'UserMessageException: $message'
      : 'UserMessageException: $message (cause: $cause)';
}
