import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakePostRepository postRepository;
  late FakeUserRepository userRepository;
  late FakeConnectivityUseCase connectivityUseCase;
  late PostSaveViewModel viewModel;

  setUp(() {
    postRepository = FakePostRepository();
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    connectivityUseCase = FakeConnectivityUseCase();
    viewModel = PostSaveViewModel(
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
    expect(viewModel.savedPostIds, same(postRepository.savedPostIdsNotifier));
    expect(viewModel.currentUser, same(userRepository.currentUserNotifier));
  });

  group('savePost', () {
    test('errors without touching connectivity when there is no user', () async {
      userRepository.currentUserNotifier.value = User.empty();

      await viewModel.savePost.execute((postId: 'post-1'));

      expect(viewModel.savePost.error.value, isTrue);
      expect(connectivityUseCase.calls, isEmpty);
      expect(postRepository.calls, isEmpty);
    });

    test('fails with ConnectivityNoConnection when offline', () async {
      connectivityUseCase.type = ConnectivityEnum.none;

      await viewModel.savePost.execute((postId: 'post-1'));

      expect(viewModel.savePost.result.value!.asError.error, isA<ConnectivityNoConnection>());
      expect(postRepository.calls, isEmpty);
    });

    test('fails with ConnectivityUnknown when the check errors', () async {
      connectivityUseCase.connectionTypeResult = Error<ConnectivityEnum>(Exception('x'));

      await viewModel.savePost.execute((postId: 'post-1'));

      expect(viewModel.savePost.result.value!.asError.error, isA<ConnectivityUnknown>());
      expect(postRepository.calls, isEmpty);
    });

    test('calls savePost with uid and postId when online', () async {
      await viewModel.savePost.execute((postId: 'post-1'));

      expect(postRepository.calls, ['savePost(userId=uid-1, postId=post-1)']);
      expect(viewModel.savePost.completed.value, isTrue);
    });

    test('propagates a repository error', () async {
      final exception = Exception('firestore');
      postRepository.savePostResult = Error<void>(exception);

      await viewModel.savePost.execute((postId: 'post-1'));

      expect(viewModel.savePost.error.value, isTrue);
      expect(viewModel.savePost.result.value!.asError.error, same(exception));
    });
  });

  group('unsavePost', () {
    test('errors without touching connectivity when there is no user', () async {
      userRepository.currentUserNotifier.value = User.empty();

      await viewModel.unsavePost.execute((postId: 'post-1'));

      expect(viewModel.unsavePost.error.value, isTrue);
      expect(connectivityUseCase.calls, isEmpty);
    });

    test('fails with ConnectivityNoConnection when offline', () async {
      connectivityUseCase.type = ConnectivityEnum.none;

      await viewModel.unsavePost.execute((postId: 'post-1'));

      expect(viewModel.unsavePost.result.value!.asError.error, isA<ConnectivityNoConnection>());
    });

    test('fails with ConnectivityUnknown when the check errors', () async {
      connectivityUseCase.connectionTypeResult = Error<ConnectivityEnum>(Exception('x'));

      await viewModel.unsavePost.execute((postId: 'post-1'));

      expect(viewModel.unsavePost.result.value!.asError.error, isA<ConnectivityUnknown>());
    });

    test('calls unsavePost with uid and postId when online', () async {
      await viewModel.unsavePost.execute((postId: 'post-1'));

      expect(postRepository.calls, ['unsavePost(userId=uid-1, postId=post-1)']);
      expect(viewModel.unsavePost.completed.value, isTrue);
    });

    test('propagates a repository error', () async {
      final exception = Exception('firestore');
      postRepository.unsavePostResult = Error<void>(exception);

      await viewModel.unsavePost.execute((postId: 'post-1'));

      expect(viewModel.unsavePost.error.value, isTrue);
      expect(viewModel.unsavePost.result.value!.asError.error, same(exception));
    });
  });
}
