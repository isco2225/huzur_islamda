import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/app.dart';

class FirestorePostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'posts';
  static const int _fetchLimit = 1;
  // Todo(omran): Fetch posts that are not reported, active and not favorited by the current user.
  Future<Result<QuerySnapshot<Map<String, dynamic>>>> fetchPosts({
    DocumentSnapshot? lastFetchedPost,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(_collectionName)
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
