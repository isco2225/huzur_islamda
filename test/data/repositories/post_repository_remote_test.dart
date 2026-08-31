import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/fakes/fake_services.dart';
import '../../helpers/fixtures.dart';

/// Only the parts of [PostRepositoryRemote] that do not depend on Firestore
/// snapshot types are covered here. `fetchPosts` consumes a `QuerySnapshot`
/// (and `DocumentSnapshot` cursors) that cannot be constructed outside the
/// Firestore SDK, so its pagination/filtering logic is untestable without a
/// refactor that abstracts the snapshot behind a plain data type.
void main() {
  late FakeFirestorePostService service;
  late PostRepositoryRemote repository;

  List<String> ids(Iterable<Post> posts) => posts.map((p) => p.id).toList();

  setUp(() {
    service = FakeFirestorePostService();
    repository = PostRepositoryRemote(firestorePostService: service);
    service.postsById.addAll({
      'a': Fixtures.post(id: 'a'),
      'b': Fixtures.post(id: 'b'),
      'c': Fixtures.post(id: 'c'),
      'd': Fixtures.post(id: 'd'),
    });
  });

  test('starts with empty notifiers', () {
    expect(repository.posts.value, isEmpty);
    expect(repository.savedPostIds.value, isEmpty);
    expect(repository.savedPosts.value, isEmpty);
  });

  group('fetchSavedPostIds', () {
    test('publishes and returns the ids', () async {
      service.fetchSavedPostIdsResult = const Ok(['a', 'b']);

      final result = await repository.fetchSavedPostIds(userId: 'uid-1');

      expect(result, isA<Ok<List<String>>>());
      expect(result.asOk.value, ['a', 'b']);
      expect(repository.savedPostIds.value, ['a', 'b']);
      expect(service.fetchSavedPostIdsUserIds, ['uid-1']);
    });

    test('propagates a service error and keeps the notifier', () async {
      final failure = Exception('x');
      service.fetchSavedPostIdsResult = Result.error(failure);

      final result = await repository.fetchSavedPostIds(userId: 'uid-1');

      expect(result, isA<Error<List<String>>>());
      expect(result.asError.error, same(failure));
      expect(repository.savedPostIds.value, isEmpty);
    });
  });

  group('fetchPostsByIds', () {
    test('returns Ok([]) without a service call when no ids are saved', () async {
      final result = await repository.fetchPostsByIds();

      expect(result, isA<Ok<List<Post>>>());
      expect(result.asOk.value, isEmpty);
      expect(service.fetchPostsByIdsCalls, isEmpty);
    });

    test('fetches and publishes the posts when the cache is stale', () async {
      service.fetchSavedPostIdsResult = const Ok(['a', 'b']);
      await repository.fetchSavedPostIds(userId: 'uid-1');

      final result = await repository.fetchPostsByIds();

      expect(result, isA<Ok<List<Post>>>());
      expect(ids(result.asOk.value), ['a', 'b']);
      expect(ids(repository.savedPosts.value), ['a', 'b']);
      expect(service.fetchPostsByIdsCalls, [
        ['a', 'b'],
      ]);
    });

    test('returns the cached posts when their count matches the saved ids', () async {
      service.fetchSavedPostIdsResult = const Ok(['a', 'b']);
      await repository.fetchSavedPostIds(userId: 'uid-1');
      await repository.fetchPostsByIds();

      final result = await repository.fetchPostsByIds();

      expect(ids(result.asOk.value), ['a', 'b']);
      expect(service.fetchPostsByIdsCalls.length, 1);
    });

    test(
      'refetches when the saved ids changed but their count did not',
      () async {
        service.fetchSavedPostIdsResult = const Ok(['a', 'b']);
        await repository.fetchSavedPostIds(userId: 'uid-1');
        await repository.fetchPostsByIds();
        service.fetchSavedPostIdsResult = const Ok(['c', 'd']);
        await repository.fetchSavedPostIds(userId: 'uid-1');

        final result = await repository.fetchPostsByIds();

        expect(ids(result.asOk.value), ['c', 'd']);
        expect(ids(repository.savedPosts.value), ['c', 'd']);
        expect(service.fetchPostsByIdsCalls.length, 2);
      },
    );

    test('propagates a service error and keeps the cache', () async {
      service.fetchSavedPostIdsResult = const Ok(['a']);
      await repository.fetchSavedPostIds(userId: 'uid-1');
      final failure = Exception('x');
      service.fetchPostsByIdsResult = Result.error(failure);

      final result = await repository.fetchPostsByIds();

      expect(result, isA<Error<List<Post>>>());
      expect(result.asError.error, same(failure));
      expect(repository.savedPosts.value, isEmpty);
    });
  });

  group('savePost', () {
    test('appends the id to savedPostIds after a successful save', () async {
      service.fetchSavedPostIdsResult = const Ok(['a']);
      await repository.fetchSavedPostIds(userId: 'uid-1');

      final result = await repository.savePost(userId: 'uid-1', postId: 'b');

      expect(result, isA<Ok<void>>());
      expect(repository.savedPostIds.value, ['a', 'b']);
      expect(service.savePostCalls.single, (userId: 'uid-1', postId: 'b'));
    });

    test('keeps savedPostIds when the service fails', () async {
      final failure = Exception('x');
      service.savePostResult = Result.error(failure);

      final result = await repository.savePost(userId: 'uid-1', postId: 'b');

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(failure));
      expect(repository.savedPostIds.value, isEmpty);
    });

    test('does not deduplicate an id that is saved twice', () async {
      await repository.savePost(userId: 'uid-1', postId: 'b');
      await repository.savePost(userId: 'uid-1', postId: 'b');

      expect(repository.savedPostIds.value, ['b', 'b']);
    });
  });

  group('unsavePost', () {
    test('removes the id and the cached post', () async {
      service.fetchSavedPostIdsResult = const Ok(['a', 'b']);
      await repository.fetchSavedPostIds(userId: 'uid-1');
      await repository.fetchPostsByIds();

      final result = await repository.unsavePost(userId: 'uid-1', postId: 'a');

      expect(result, isA<Ok<void>>());
      expect(repository.savedPostIds.value, ['b']);
      expect(ids(repository.savedPosts.value), ['b']);
      expect(service.unsavePostCalls.single, (userId: 'uid-1', postId: 'a'));
    });

    test('keeps both notifiers when the service fails', () async {
      service.fetchSavedPostIdsResult = const Ok(['a', 'b']);
      await repository.fetchSavedPostIds(userId: 'uid-1');
      await repository.fetchPostsByIds();
      service.unsavePostResult = Result.error(Exception('x'));

      final result = await repository.unsavePost(userId: 'uid-1', postId: 'a');

      expect(result, isA<Error<void>>());
      expect(repository.savedPostIds.value, ['a', 'b']);
      expect(ids(repository.savedPosts.value), ['a', 'b']);
    });
  });

  group('fetchPosts', () {
    test('wraps anything thrown by the service into an Error', () async {
      // The fake throws UnimplementedError because QuerySnapshot cannot be
      // built in tests; this only verifies the catch-all wrapping.
      final result = await repository.fetchPosts();

      expect(result, isA<Error<List<Post>>>());
      expect(
        result.asError.error.toString(),
        startsWith('Exception: Failed to fetch posts: '),
      );
      expect(repository.posts.value, isEmpty);
    });
  });

  group('unimplemented stubs', () {
    test('createPost throws UnimplementedError', () {
      expect(
        () => repository.createPost(userId: 'u', title: 't', content: 'c'),
        throwsUnimplementedError,
      );
    });

    test('updatePost throws UnimplementedError', () {
      expect(
        () => repository.updatePost(postId: 'p'),
        throwsUnimplementedError,
      );
    });

    test('fetchPost throws UnimplementedError', () {
      expect(() => repository.fetchPost(postId: 'p'), throwsUnimplementedError);
    });

    test('fetchPostsByUser throws UnimplementedError', () {
      expect(
        () => repository.fetchPostsByUser(userId: 'u'),
        throwsUnimplementedError,
      );
    });

    test('deletePost throws UnimplementedError', () {
      expect(
        () => repository.deletePost(postId: 'p'),
        throwsUnimplementedError,
      );
    });
  });
}
