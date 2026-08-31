import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';

import '../../helpers/fakes/fake_services.dart';

void main() {
  late FakeReportService service;
  late ReportRepositoryRemote repository;

  setUp(() {
    service = FakeReportService();
    repository = ReportRepositoryRemote(reportService: service);
  });

  Future<Result<void>> report() => repository.reportPost(
    reporterId: 'uid-1',
    reportedPostId: 'post-1',
    reason: 'spam',
  );

  test('forwards every argument to the service and returns Ok', () async {
    final result = await report();

    expect(result, isA<Ok<void>>());
    expect(service.reportPostCalls.single, {
      'reporterId': 'uid-1',
      'reportedPostId': 'post-1',
      'reason': 'spam',
    });
  });

  test('returns the service Error unchanged', () async {
    final failure = Exception('Failed to report post: permission-denied');
    service.reportPostResult = Result.error(failure);

    final result = await report();

    expect(result, isA<Error<void>>());
    expect(result.asError.error, same(failure));
  });

  test('wraps an exception thrown by the service into an Error', () async {
    service.throwOnCall = true;

    final result = await report();

    expect(result, isA<Error<void>>());
    expect(
      result.asError.error.toString(),
      'Exception: Failed to report post: Exception: fake report throw',
    );
  });
}
