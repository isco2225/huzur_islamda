import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class PostRepository {
  ValueListenable<List<Post>> get posts;
  ValueListenable<List<String>> get savedPostIds;
  ValueListenable<List<Post>> get savedPosts;

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

  /// Post'u kaydet
  Future<Result<void>> savePost({
    required String userId,
    required String postId,
  });

  /// Post'u kayıttan çıkar
  Future<Result<void>> unsavePost({
    required String userId,
    required String postId,
  });

  /// Kayıtlı post'ların ids'ini getir
  Future<Result<List<String>>> fetchSavedPostIds({required String userId});

  /// Kayıtlı post'ları getir
  Future<Result<List<Post>>> fetchPostsByIds();
}
