import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class PostReportViewModel {
  PostReportViewModel({
    required ReportRepository reportRepository,
    required UserRepository userRepository,
  }) : _reportRepository = reportRepository,
       _userRepository = userRepository {
    // DEFINE COMMANDS
    reportPost = Command1<void, ({String reportedPostId, String reason})>(
      _reportPost,
      debugLabel: 'reportPost',
    );
  }

  // LOGGER
  final _log = Logger('PostReportViewModel');

  // REPOSITORIES & USE CASES
  final ReportRepository _reportRepository;
  final UserRepository _userRepository;
  // DOMAIN
  ValueListenable<User> get currentUser => _userRepository.currentUser;

  // COMMANDS
  late Command1<void, ({String reportedPostId, String reason})> reportPost;

  // DISPOSE
  void dispose() {
    reportPost.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _reportPost(
    ({String reportedPostId, String reason}) commands,
  ) async {
    final reporterId = currentUser.value.uid;
    if (reporterId.isEmpty) {
      _log.warning('Reporter ID is empty, cannot report post');
      return Result.error(Exception('Kullanıcı bilgisi bulunamadı'));
    }

    final result = await _reportRepository.reportPost(
      reporterId: reporterId,
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
