import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../helpers/helpers.dart';

void main() {
  test('isAdMobInitialized is the service listenable', () {
    final adMobService = RecordingAdMobService();
    final viewModel = AdvertViewModel(admobService: adMobService);

    expect(viewModel.isAdMobInitialized, same(adMobService.isInitialized));
    expect(viewModel.isAdMobInitialized.value, isFalse);
    expect(viewModel.dispose, returnsNormally);
  });
}
