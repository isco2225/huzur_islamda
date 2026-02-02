import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';

class PostReportViewModel {
  PostReportViewModel({required ReportRepository reportRepository})
    : _reportRepository = reportRepository {
    // DEFINE COMMANDS
    reportPost =
        Command1<
          void,
          ({String reporterId, String reportedPostId, String reason})
        >(_reportPost, debugLabel: 'reportPost');
  }

  // LOGGER
  final _log = Logger('PostReportViewModel');

  // REPOSITORIES & USE CASES
  final ReportRepository _reportRepository;
  // DOMAIN

  // COMMANDS
  late Command1<
    void,
    ({String reporterId, String reportedPostId, String reason})
  >
  reportPost;

  // DISPOSE
  void dispose() {
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _reportPost(
    ({String reporterId, String reportedPostId, String reason}) commands,
  ) async {
    final result = await _reportRepository.reportPost(
      reporterId: commands.reporterId,
      reportedPostId: commands.reportedPostId,
      reason: commands.reason,
    );
    switch (result) {
      case Ok():
        _log.info('Post reported successfully');
        return result;
      case Error():
        _log.warning('Failed to report post: ${result.asError.error}');
        return result;
    }
  }
}
