import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class PostDetailViewModel {
  PostDetailViewModel({
    required PostRepository postRepository,
    required String postId,
  }) : _postRepository = postRepository,
       _postId = postId {
    // DEFINE COMMANDS
    fetchPost = Command0<Post>(_fetchPost, debugLabel: 'fetchPost');
  }

  // LOGGER
  final _log = Logger('PostDetailViewModel');

  // REPOSITORIES & USE CASES
  final PostRepository _postRepository;
  final String _postId;

  // DOMAIN
  ValueListenable<Post?> get post => _post;
  final _post = ValueNotifier<Post?>(null);

  // COMMANDS
  late final Command0<Post> fetchPost;

  // DISPOSE
  void dispose() {
    fetchPost.dispose();
    _post.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<Post>> _fetchPost() async {
    final result = await _postRepository.fetchPost(postId: _postId);

    switch (result) {
      case Ok():
        _post.value = result.asOk.value;
        _log.info('Post fetched successfully: ${_postId}');
      case Error():
        _log.warning('Failed to fetch post: ${result.asError.error}');
    }

    return result;
  }
}
