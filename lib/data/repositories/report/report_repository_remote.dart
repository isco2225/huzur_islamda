import '../../../app/app.dart';
import '../../data.dart';

class ReportRepositoryRemote implements ReportRepository {
  ReportRepositoryRemote({required ReportService reportService})
    : _reportService = reportService;

  final ReportService _reportService;
  @override
  Future<Result<void>> reportPost({
    required String reporterId,
    required String reportedPostId,
    required String reason,
  }) async {
    try {
      final result = await _reportService.reportPost(
        reporterId: reporterId,
        reportedPostId: reportedPostId,
        reason: reason,
      );
      return result;
    } catch (e) {
      return Result.error(Exception('Failed to report post: $e'));
    }
  }
}
