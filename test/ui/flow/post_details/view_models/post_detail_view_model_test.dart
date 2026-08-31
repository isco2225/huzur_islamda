import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  test('PostDetailViewModel constructs with a null post and disposes', () {
    final viewModel = PostDetailViewModel(
      postRepository: FakePostRepository(),
      postId: 'post-1',
    );

    expect(viewModel.post.value, isNull);
    expect(viewModel.dispose, returnsNormally);
  });
}
