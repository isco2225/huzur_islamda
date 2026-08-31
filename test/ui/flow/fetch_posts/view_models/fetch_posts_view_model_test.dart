import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakePostRepository postRepository;
  late FetchPostsViewModel viewModel;

  setUp(() {
    postRepository = FakePostRepository();
    viewModel = FetchPostsViewModel(postRepository: postRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('posts mirrors the repository listenable', () {
    expect(viewModel.posts, same(postRepository.postsNotifier));
    expect(viewModel.isAllItemsFetched.value, isFalse);
  });

  group('fetchPosts', () {
    test('stays false when the first fetch returns nothing', () async {
      await viewModel.fetchPosts.execute();

      expect(postRepository.calls, ['fetchPosts()']);
      expect(viewModel.fetchPosts.completed.value, isTrue);
      expect(viewModel.isAllItemsFetched.value, isFalse);
    });

    test('stays false while a fetch keeps adding posts', () async {
      postRepository.onFetchPosts = () async {
        postRepository.postsNotifier.value = [
          ...postRepository.postsNotifier.value,
          Fixtures.post(id: 'post-${postRepository.postsNotifier.value.length}'),
        ];
        return Ok(postRepository.postsNotifier.value);
      };

      await viewModel.fetchPosts.execute();
      expect(viewModel.isAllItemsFetched.value, isFalse);

      await viewModel.fetchPosts.execute();

      expect(postRepository.postsNotifier.value, hasLength(2));
      expect(viewModel.isAllItemsFetched.value, isFalse);
    });

    test('becomes true once a fetch leaves a non-empty list unchanged', () async {
      postRepository.postsNotifier.value = [Fixtures.post()];

      await viewModel.fetchPosts.execute();

      expect(viewModel.isAllItemsFetched.value, isTrue);
    });

    test('stays false when the fetch fails even with an unchanged list', () async {
      postRepository.postsNotifier.value = [Fixtures.post()];
      final exception = Exception('firestore');
      postRepository.fetchPostsResult = Error<List<Post>>(exception);

      await viewModel.fetchPosts.execute();

      expect(viewModel.fetchPosts.error.value, isTrue);
      expect(viewModel.fetchPosts.result.value!.asError.error, same(exception));
      expect(viewModel.isAllItemsFetched.value, isFalse);
    });
  });
}
