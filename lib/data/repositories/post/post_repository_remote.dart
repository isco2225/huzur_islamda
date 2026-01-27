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
      final result = await _firestorePostService.fetchPosts(
        lastFetchedPost: _lastFetchedPostDoc,
      );
      switch (result) {
        case Ok():
          final snapshot = result.asOk.value;
          final docs = snapshot.docs;
          final newPosts = docs
              .map((doc) => Post.fromJson(doc.data()))
              .toList();
          if (newPosts.isEmpty) {
            _hasMore = false;
            return Result.ok(_posts.value);
          }
          final allPosts = <Post>[..._posts.value, ...newPosts];
          _posts.value = allPosts;
          _lastFetchedPostDoc = docs.last;
          return Result.ok(allPosts);
        case Error():
          return Result.error(result.asError.error);
      }
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
}
