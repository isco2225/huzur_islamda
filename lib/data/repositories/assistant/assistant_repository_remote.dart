import '../../../app/app.dart';
import '../../data.dart';

class AssistantRepositoryRemote implements AssistantRepository {
  AssistantRepositoryRemote({required AssistantService assistantService})
    : _assistantService = assistantService;

  final AssistantService _assistantService;

  @override
  Future<Result<String>> sendMessage({
    required String message,
    required String senderName,
    required String senderAge,
    required String senderGender,
    List<String>? previousMessages,
  }) async {
    return await _assistantService.sendMessage(
      message: message,
      senderName: senderName,
      senderAge: senderAge,
      senderGender: senderGender,
      previousMessages: previousMessages,
    );
  }
}
