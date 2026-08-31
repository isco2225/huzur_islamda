import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  late FakePostRepository postRepository;
  late FakeUserRepository userRepository;
  late FakeConnectivityUseCase connectivityUseCase;
  late SavedPostsViewModel viewModel;

  setUp(() {
    postRepository = FakePostRepository();
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    connectivityUseCase = FakeConnectivityUseCase();
    viewModel = SavedPostsViewModel(
      postRepository: postRepository,
      userRepository: userRepository,
      connectivityUseCase: connectivityUseCase,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('listenables mirror the repositories', () {
    expect(viewModel.savedPosts, same(postRepository.savedPostsNotifier));
    expect(viewModel.currentUser, same(userRepository.currentUserNotifier));
    expect(viewModel.isAllItemsFetched.value, isFalse);
  });

  group('fetchSavedPosts', () {
    test('errors with a Turkish message when there is no user', () async {
      userRepository.currentUserNotifier.value = User.empty();

      await viewModel.fetchSavedPosts.execute();

      expect(viewModel.fetchSavedPosts.error.value, isTrue);
      expect(
        viewModel.fetchSavedPosts.result.value!.asError.error.toString(),
        contains('Kullanıcı oturumu bulunamadı'),
      );
      expect(connectivityUseCase.calls, isEmpty);
      expect(postRepository.calls, isEmpty);
    });

    test('fails with ConnectivityNoConnection when offline', () async {
      connectivityUseCase.type = ConnectivityEnum.none;

      await viewModel.fetchSavedPosts.execute();

      expect(viewModel.fetchSavedPosts.result.value!.asError.error, isA<ConnectivityNoConnection>());
      expect(postRepository.calls, isEmpty);
    });

    test('fails with ConnectivityUnknown when the check errors', () async {
      connectivityUseCase.connectionTypeResult = Error<ConnectivityEnum>(Exception('x'));

      await viewModel.fetchSavedPosts.execute();

      expect(viewModel.fetchSavedPosts.result.value!.asError.error, isA<ConnectivityUnknown>());
      expect(postRepository.calls, isEmpty);
    });

    test('calls fetchPostsByIds when online and stays false on an empty result', () async {
      await viewModel.fetchSavedPosts.execute();

      expect(postRepository.calls, ['fetchPostsByIds()']);
      expect(viewModel.fetchSavedPosts.completed.value, isTrue);
      expect(viewModel.isAllItemsFetched.value, isFalse);
    });

    test('stays false while a fetch keeps adding saved posts', () async {
      postRepository.onFetchPostsByIds = () async {
        postRepository.savedPostsNotifier.value = [
          ...postRepository.savedPostsNotifier.value,
          Fixtures.post(id: 'saved-${postRepository.savedPostsNotifier.value.length}'),
        ];
        return Ok(postRepository.savedPostsNotifier.value);
      };

      await viewModel.fetchSavedPosts.execute();
      await viewModel.fetchSavedPosts.execute();

      expect(postRepository.savedPostsNotifier.value, hasLength(2));
      expect(viewModel.isAllItemsFetched.value, isFalse);
    });

    test('becomes true once a fetch leaves a non-empty list unchanged', () async {
      postRepository.savedPostsNotifier.value = [Fixtures.post()];

      await viewModel.fetchSavedPosts.execute();

      expect(viewModel.isAllItemsFetched.value, isTrue);
    });

    test('propagates a repository error and stays false', () async {
      postRepository.savedPostsNotifier.value = [Fixtures.post()];
      final exception = Exception('firestore');
      postRepository.fetchPostsByIdsResult = Error<List<Post>>(exception);

      await viewModel.fetchSavedPosts.execute();

      expect(viewModel.fetchSavedPosts.error.value, isTrue);
      expect(viewModel.fetchSavedPosts.result.value!.asError.error, same(exception));
      expect(viewModel.isAllItemsFetched.value, isFalse);
    });
  });
}
