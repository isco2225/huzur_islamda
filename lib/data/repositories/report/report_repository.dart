import '../../../app/app.dart';

abstract class ReportRepository {
  Future<Result<void>> reportPost({
    required String reporterId,
    required String reportedPostId,
    required String reason,
  });
}
