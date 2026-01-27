import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/app.dart';

class FirestorePostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'posts';
  static const int _fetchLimit = 1;

  Future<Result<QuerySnapshot<Map<String, dynamic>>>> fetchPosts({
    DocumentSnapshot? lastFetchedPost,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(
        _collectionName,
      );
      if (lastFetchedPost != null) {
        query = query.startAfterDocument(lastFetchedPost);
      }
      final snapshot = await query.limit(_fetchLimit).get();
      print('FETCHED DOC COUNT: ${snapshot.docs.length}');

      return Result.ok(snapshot);
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to fetch posts: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to fetch posts: $e'));
    }
  }
}
