import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class FetchPostsViewModel {
  FetchPostsViewModel({required PostRepository postRepository})
    : _postRepository = postRepository {
    fetchPosts = Command0<void>(_fetchPosts, debugLabel: 'fetchPosts');
  }

  // LOGGER
  final _log = Logger('FetchPostsViewModel');

  // REPOSITORIES & USE CASES
  final PostRepository _postRepository;
  // DOMAIN
  ValueListenable<List<Post>> get posts => _postRepository.posts;
  // STATE
  ValueListenable<bool> get isAllItemsFetched => _isAllItemsFetched;
  final ValueNotifier<bool> _isAllItemsFetched = ValueNotifier<bool>(false);
  // COMMANDS
  late Command0<void> fetchPosts;

  // DISPOSE
  void dispose() {
    fetchPosts.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _fetchPosts() async {
    final previousLength = posts.value.length;
    final result = await _postRepository.fetchPosts();
    switch (result) {
      case Ok():
        final currentLength = posts.value.length;
        if (currentLength == previousLength && currentLength > 0) {
          _isAllItemsFetched.value = true;
        }
        _log.fine('Posts fetched successfully');
        return Result.ok(null);
      case Error():
        _log.severe('Failed to fetch posts: ${result.asError.error}');
        return Result.error(result.asError.error);
    }
  }
}
