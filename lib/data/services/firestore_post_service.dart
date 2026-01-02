import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class FirestorePostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'posts';

  Future<Result<List<Post>>> fetchPosts() async {
    try {
      await Future.delayed(const Duration(seconds: 5));
      final posts = await _firestore
          .collection(_collectionName)
          //.orderBy('createdAt', descending: true)
          .get();
      final List<Post> postsList = posts.docs
          .map((doc) => Post.fromJson(doc.data()))
          .toList();
      return Result.ok(postsList);
      //return Result.error(Exception('Failed to fetch posts'));
    } on FirebaseException catch (e) {
      return Result.error(
        Exception('Failed to fetch posts: ${e.message ?? e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to fetch posts: $e'));
    }
  }
}
