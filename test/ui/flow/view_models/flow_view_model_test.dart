import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../helpers/helpers.dart';

void main() {
  test('FlowViewModel constructs and disposes without touching the repository', () {
    final postRepository = FakePostRepository();
    final viewModel = FlowViewModel(postRepository: postRepository);

    expect(viewModel.dispose, returnsNormally);
    expect(postRepository.calls, isEmpty);
  });
}
