import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/app.dart';

class FirestorePostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'posts';
  static const String _favoritesCollectionName = 'savedBy';
  static const int _fetchLimit = 3;
  // Todo(omran): Fetch posts that are not reported, active and not favorited by the current user.
  Future<Result<QuerySnapshot<Map<String, dynamic>>>> fetchPosts({
    required DocumentSnapshot? lastFetchedPost,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);
      if (lastFetchedPost != null) {
        query = query.startAfterDocument(lastFetchedPost);
      }
      final snapshot = await query.limit(_fetchLimit).get();
      return Result.ok(snapshot);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to fetch posts: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to fetch posts: $e'));
    }
  }

  Future<Result<void>> savePost({
    required String userId,
    required String postId,
  }) async {
    print('savePost: $userId, $postId');
    try {
      await _firestore.collection(_collectionName).doc(postId).update({
        _favoritesCollectionName: FieldValue.arrayUnion([userId]),
      });
      return Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to favorite post: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to favorite post: $e'));
    }
  }

  Future<Result<void>> unsavePost({
    required String userId,
    required String postId,
  }) async {
    try {
      await _firestore.collection(_collectionName).doc(postId).update({
        _favoritesCollectionName: FieldValue.arrayRemove([userId]),
      });
      return Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to unfavorite post: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to unfavorite post: $e'));
    }
  }

  Future<Result<List<String>>> fetchSavedPostIds({
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where(_favoritesCollectionName, arrayContains: userId)
          .get();
      final savedPostIds = snapshot.docs.map((doc) => doc.id).toList();
      return Result.ok(savedPostIds);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to fetch saved post ids: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to fetch saved post ids: $e'));
    }
  }

  // Future<Result<List<String>>> getFavoritedPostIds({
  //   required String userId,
  // }) async {
  //   try {
  //     final snapshot = await _firestore
  //         .collection(_usersCollectionName)
  //         .doc(userId)
  //         .collection('favorites')
  //         .get();
  //     final favoritedPostIds = snapshot.docs.map((doc) => doc.id).toList();
  //     return Result.ok(favoritedPostIds);
  //   } on FirebaseException catch (e) {
  //     return Result.error(
  //       Exception('Failed to get favorited post ids: ${e.message ?? e.code}'),
  //     );
  //   } catch (e) {
  //     return Result.error(Exception('Failed to get favorited post ids: $e'));
  //   }
  // }
}
