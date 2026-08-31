import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../../app/app.dart';
import '../../../../../data/data.dart';
import '../../../../../domain/domain.dart';

class SavedPostsViewModel {
  SavedPostsViewModel({
    required PostRepository postRepository,
    required UserRepository userRepository,
    required ConnectivityUseCase connectivityUseCase,
  }) : _postRepository = postRepository,
       _userRepository = userRepository,
       _connectivityUseCase = connectivityUseCase {
    fetchSavedPosts = Command0<void>(
      _fetchSavedPosts,
      debugLabel: 'fetchSavedPosts',
    );
  }

  // LOGGER
  final _log = Logger('SavedPostsViewModel');

  // REPOSITORIES & USE CASES
  final PostRepository _postRepository;
  final UserRepository _userRepository;
  final ConnectivityUseCase _connectivityUseCase;

  // DOMAIN
  ValueListenable<List<Post>> get savedPosts => _postRepository.savedPosts;
  ValueListenable<User> get currentUser => _userRepository.currentUser;

  // STATE
  ValueListenable<bool> get isAllItemsFetched => _isAllItemsFetched;
  final ValueNotifier<bool> _isAllItemsFetched = ValueNotifier<bool>(false);

  // COMMANDS
  late final Command0<void> fetchSavedPosts;

  // DISPOSE
  void dispose() {
    fetchSavedPosts.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _fetchSavedPosts() async {
    final userId = currentUser.value.uid;
    if (userId.isEmpty) {
      _log.warning('Current user is not logged in');
      return Result.error(const UserMessageException('Kullanıcı oturumu bulunamadı'));
    }
    try {
      final previousLength = savedPosts.value.length;
      final connectivityResult = await _connectivityUseCase.connectionType();
      switch (connectivityResult) {
        case Ok():
          if (connectivityResult.asOk.value == ConnectivityEnum.none) {
            _log.severe('No internet connection');
            return Result.error(const ConnectivityNoConnection());
          }
        case Error():
          _log.warning(
            'Failed to check internet connection: ${connectivityResult.asError.error}',
          );
          return Result.error(const ConnectivityUnknown());
      }
      _log.info('Internet connection is available');
      final result = await _postRepository.fetchPostsByIds();
      switch (result) {
        case Ok():
          _log.info('Saved posts fetched successfully');
          final currentLength = savedPosts.value.length;
          if (currentLength == previousLength && currentLength > 0) {
            _isAllItemsFetched.value = true;
          }
          _log.fine('Saved posts fetched successfully');
          return Result.ok(null);
        case Error():
          _log.warning('Failed to fetch saved posts: ${result.asError.error}');
          return Result.error(result.asError.error);
      }
    } catch (e) {
      _log.severe('Failed to fetch saved posts: $e');
      return Result.error(UserMessageException('Kaydedilen gönderiler yüklenemedi', cause: e));
    }
  }
}
