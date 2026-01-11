import 'package:logging/logging.dart';

import '../../../data/data.dart';

class FlowViewModel {
  FlowViewModel({required PostRepository postRepository}) {
    // DEFINE COMMANDS
    // DEFINE LISTENERS
  }

  // LOGGER
  final _log = Logger('FlowViewModel');

  // REPOSITORIES & USE CASES
  // DOMAIN
  // COMMANDS

  // DISPOSE
  void dispose() {
    _log.fine('Disposed');
  }

  // FUNCTIONS
}
