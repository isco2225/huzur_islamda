import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakeReportRepository reportRepository;
  late FakeUserRepository userRepository;
  late PostReportViewModel viewModel;

  setUp(() {
    reportRepository = FakeReportRepository();
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    viewModel = PostReportViewModel(
      reportRepository: reportRepository,
      userRepository: userRepository,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('currentUser mirrors the repository listenable', () {
    expect(viewModel.currentUser, same(userRepository.currentUserNotifier));
  });

  group('reportPost', () {
    test('errors with a Turkish message when there is no user', () async {
      userRepository.currentUserNotifier.value = User.empty();

      await viewModel.reportPost.execute((reportedPostId: 'post-1', reason: 'spam'));

      expect(viewModel.reportPost.error.value, isTrue);
      expect(
        viewModel.reportPost.result.value!.asError.error.toString(),
        contains('Kullanıcı bilgisi bulunamadı'),
      );
      expect(reportRepository.calls, isEmpty);
    });

    test('forwards reporter id, post id and reason to the repository', () async {
      await viewModel.reportPost.execute((reportedPostId: 'post-1', reason: 'spam'));

      expect(reportRepository.calls, [
        'reportPost(reporterId=uid-1, reportedPostId=post-1, reason=spam)',
      ]);
      expect(viewModel.reportPost.completed.value, isTrue);
    });

    test('propagates a repository error', () async {
      final exception = Exception('firestore');
      reportRepository.reportPostResult = Error<void>(exception);

      await viewModel.reportPost.execute((reportedPostId: 'post-1', reason: 'spam'));

      expect(viewModel.reportPost.error.value, isTrue);
      expect(viewModel.reportPost.result.value!.asError.error, same(exception));
    });
  });
}
