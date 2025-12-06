import 'package:logging/logging.dart';

import '../../../data/data.dart';

class FlowViewModel {
  FlowViewModel({required PostRepository postRepository})
    : _postRepository = postRepository {}

  // LOGGER
  final _log = Logger('FlowViewModel');

  // REPOSITORIES & USE CASES
  final PostRepository _postRepository;
  // DOMAIN
  // COMMANDS

  // DISPOSE
  void dispose() {
    _log.fine('Disposed');
  }

  // FUNCTIONS
}
