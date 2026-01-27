import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class PostDetailViewModel {
  PostDetailViewModel({
    required PostRepository postRepository,
    required String postId,
  }) {
    // DEFINE COMMANDS
  }

  // LOGGER
  final _log = Logger('PostDetailViewModel');

  // REPOSITORIES & USE CASES

  // DOMAIN
  ValueListenable<Post?> get post => _post;
  final _post = ValueNotifier<Post?>(null);

  // COMMANDS

  // DISPOSE
  void dispose() {
    _post.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
}
