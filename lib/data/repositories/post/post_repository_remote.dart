import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../data.dart';

class PostRepositoryRemote extends PostRepository {
  PostRepositoryRemote({required FirestorePostService firestorePostService})
    : _firestorePostService = firestorePostService;

  final FirestorePostService _firestorePostService;
  DocumentSnapshot? _lastFetchedPostDoc;
  bool _hasMore = true;

  @override
  ValueListenable<List<Post>> get posts => _posts;
  final ValueNotifier<List<Post>> _posts = ValueNotifier<List<Post>>([]);

  @override
  ValueListenable<List<String>> get savedPostIds => _savedPostIds;
  final ValueNotifier<List<String>> _savedPostIds = ValueNotifier<List<String>>(
    [],
  );

  @override
  ValueListenable<List<Post>> get savedPosts => _savedPosts;
  final ValueNotifier<List<Post>> _savedPosts = ValueNotifier<List<Post>>([]);

  @override
  Future<Result<Post>> createPost({
    required String userId,
    required String title,
    required String content,
  }) {
    // TODO: implement createPost
    throw UnimplementedError();
  }

  @override
  Future<Result<Post>> updatePost({
    required String postId,
    String? title,
    String? content,
  }) {
    // TODO: implement updatePost
    throw UnimplementedError();
  }

  @override
  Future<Result<Post>> fetchPost({required String postId}) {
    // TODO: implement fetchPost
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Post>>> fetchPosts() async {
    if (!_hasMore) {
      // Zaten tüm postlar çekildi
      return Result.ok(_posts.value);
    }

    try {
      // Not: saved post'ları client-side filtreliyoruz.
      // Bu yüzden ilk sayfa tamamen filtrelenirse "boş" görünmesin diye
      // bir sonraki sayfayı çekmeye devam ediyoruz.
      const targetNewItems = 3;
      final collectedDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

      while (collectedDocs.length < targetNewItems && _hasMore) {
        final result = await _firestorePostService.fetchPosts(
          lastFetchedPost: _lastFetchedPostDoc,
        );

        switch (result) {
          case Ok():
            final snapshot = result.asOk.value;
            final snapshotDocs = snapshot.docs;

            if (snapshotDocs.isEmpty) {
              _hasMore = false;
              break;
            }
            _lastFetchedPostDoc = snapshotDocs.last;
            final filtered = snapshotDocs
                .where((doc) => !_savedPostIds.value.contains(doc.id))
                .toList();
            collectedDocs.addAll(filtered);
          case Error():
            return Result.error(result.asError.error);
        }
      }

      if (collectedDocs.isEmpty) {
        // Daha fazla yoksa veya tüm postlar filtreleniyorsa mevcut listeyi dön.
        return Result.ok(_posts.value);
      }

      final newPosts = collectedDocs
          .take(targetNewItems)
          .map((doc) => Post.fromJson({'id': doc.id, ...doc.data()}))
          .toList();

      final allPosts = <Post>[..._posts.value, ...newPosts];
      _posts.value = allPosts;
      return Result.ok(allPosts);
    } catch (e) {
      return Result.error(Exception('Failed to fetch posts: $e'));
    }
  }

  @override
  Future<Result<List<Post>>> fetchPostsByUser({required String userId}) {
    // TODO: implement fetchPostsByUser
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deletePost({required String postId}) {
    // TODO: implement deletePost
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> savePost({
    required String userId,
    required String postId,
  }) async {
    try {
      final result = await _firestorePostService.savePost(
        userId: userId,
        postId: postId,
      );
      switch (result) {
        case Ok():
          _savedPostIds.value = [..._savedPostIds.value, postId];
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to save post: $e'));
    }
  }

  @override
  Future<Result<void>> unsavePost({
    required String userId,
    required String postId,
  }) async {
    try {
      final result = await _firestorePostService.unsavePost(
        userId: userId,
        postId: postId,
      );
      switch (result) {
        case Ok():
          _savedPostIds.value = _savedPostIds.value
              .where((id) => id != postId)
              .toList();
          _savedPosts.value = _savedPosts.value
              .where((post) => post.id != postId)
              .toList();
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to unsave post: $e'));
    }
  }

  @override
  Future<Result<List<String>>> fetchSavedPostIds({
    required String userId,
  }) async {
    try {
      final result = await _firestorePostService.fetchSavedPostIds(
        userId: userId,
      );
      switch (result) {
        case Ok():
          _savedPostIds.value = result.asOk.value;
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to fetch saved post ids: $e'));
    }
  }

  @override
  Future<Result<List<Post>>> fetchPostsByIds() async {
    if (_savedPostIds.value.isEmpty) {
      return Result.ok([]);
    }
    final wantedIds = _savedPostIds.value.toSet();
    final cachedIds = _savedPosts.value.map((post) => post.id).toSet();
    if (cachedIds.length == wantedIds.length &&
        cachedIds.containsAll(wantedIds)) {
      return Result.ok(_savedPosts.value);
    }
    try {
      final result = await _firestorePostService.fetchPostsByIds(
        postIds: _savedPostIds.value,
      );
      switch (result) {
        case Ok():
          _savedPosts.value = result.asOk.value;
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to fetch saved posts: $e'));
    }
  }
}
