import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/ui/ui.dart';

void main() {
  test('UserProfileViewModel constructs and disposes without throwing', () {
    final viewModel = UserProfileViewModel();

    expect(viewModel.dispose, returnsNormally);
  });
}
