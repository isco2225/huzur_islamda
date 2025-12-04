import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class PostRepository {
  ValueListenable<List<Post>> get posts;

  /// Post oluştur
  Future<Result<Post>> createPost({
    required String userId,
    required String title,
    required String content,
  });

  /// Post güncelle
  Future<Result<Post>> updatePost({
    required String postId,
    String? title,
    String? content,
  });

  /// Post'u getir
  Future<Result<Post>> fetchPost({required String postId});

  /// Tüm post'ları getir
  Future<Result<List<Post>>> fetchPosts();

  /// Kullanıcının post'larını getir
  Future<Result<List<Post>>> fetchPostsByUser({required String userId});

  /// Post'u sil
  Future<Result<void>> deletePost({required String postId});
}
