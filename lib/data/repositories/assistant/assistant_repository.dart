import '../../../app/app.dart';

abstract class AssistantRepository {
  Future<Result<String>> sendMessage({
    required String message,
    required String senderName,
    required String senderAge,
    required String senderGender,
    List<String>? previousMessages,
  });
}
