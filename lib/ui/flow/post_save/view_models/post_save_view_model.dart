import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class PostSaveViewModel {
  PostSaveViewModel({
    required PostRepository postRepository,
    required UserRepository userRepository,
    required ConnectivityUseCase connectivityUseCase,
  }) : _postRepository = postRepository,
       _userRepository = userRepository,
       _connectivityUseCase = connectivityUseCase {
    // DEFINE COMMANDS
    savePost = Command1<void, ({String postId})>(
      _savePost,
      debugLabel: 'savePost',
    );
    unsavePost = Command1<void, ({String postId})>(
      _unsavePost,
      debugLabel: 'unsavePost',
    );
  }
  // LOGGER
  final _log = Logger('PostSaveViewModel');

  // REPOSITORIES & USE CASES
  final PostRepository _postRepository;
  final UserRepository _userRepository;
  final ConnectivityUseCase _connectivityUseCase;

  // DOMAIN
  ValueListenable<List<Post>> get savedPosts => _postRepository.savedPosts;
  ValueListenable<List<String>> get savedPostIds =>
      _postRepository.savedPostIds;
  ValueListenable<User> get currentUser => _userRepository.currentUser;
  // COMMANDS
  late Command1<void, ({String postId})> savePost;
  late Command1<void, ({String postId})> unsavePost;

  // DISPOSE
  void dispose() {
    savePost.dispose();
    unsavePost.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _savePost(({String postId}) postId) async {
    final userId = currentUser.value.uid;
    if (userId.isEmpty) {
      _log.warning('Current user is not logged in');
      return Result.error(const UserMessageException('Bu işlem için oturum açmanız gerekiyor'));
    }
    try {
      final connectivityResult = await _connectivityUseCase.connectionType();
      switch (connectivityResult) {
        case Ok():
          if (connectivityResult.asOk.value == ConnectivityEnum.none) {
            _log.severe('No internet connection');
            return Result.error(const ConnectivityNoConnection());
          }
        case Error<ConnectivityEnum>():
          _log.warning(
            'Failed to check internet connection: ${connectivityResult.asError.error}',
          );
          return Result.error(const ConnectivityUnknown());
      }
      _log.info('Internet connection is available');
      final result = await _postRepository.savePost(
        userId: userId,
        postId: postId.postId,
      );
      switch (result) {
        case Ok():
          _log.info('Post saved successfully');
          return Result.ok(result.asOk.value);
        case Error():
          _log.warning('Failed to save post: ${result.asError.error}');
          return Result.error(result.asError.error);
      }
    } catch (e) {
      _log.severe('Failed to save post: $e');
      return Result.error(UserMessageException('Gönderi kaydedilemedi', cause: e));
    }
  }

  Future<Result<void>> _unsavePost(({String postId}) postId) async {
    final userId = currentUser.value.uid;
    if (userId.isEmpty) {
      _log.warning('Current user is not logged in');
      return Result.error(const UserMessageException('Bu işlem için oturum açmanız gerekiyor'));
    }
    try {
      final connectivityResult = await _connectivityUseCase.connectionType();
      switch (connectivityResult) {
        case Ok():
          if (connectivityResult.asOk.value == ConnectivityEnum.none) {
            _log.severe('No internet connection');
            return Result.error(const ConnectivityNoConnection());
          }
        case Error<ConnectivityEnum>():
          _log.warning(
            'Failed to check internet connection: ${connectivityResult.asError.error}',
          );
          return Result.error(const ConnectivityUnknown());
      }
      _log.info('Internet connection is available');
      final result = await _postRepository.unsavePost(
        userId: userId,
        postId: postId.postId,
      );
      switch (result) {
        case Ok():
          _log.info('Post unsaved successfully');
          return Result.ok(result.asOk.value);
        case Error():
          _log.warning('Failed to unsave post: ${result.asError.error}');
          return Result.error(result.asError.error);
      }
    } catch (e) {
      _log.severe('Failed to unsave post: $e');
      return Result.error(UserMessageException('Gönderi kayıtlardan çıkarılamadı', cause: e));
    }
  }
}
