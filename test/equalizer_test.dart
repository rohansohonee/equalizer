import 'package:equalizer/equalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('openEqualizer', () async {
    Equalizer.openEqualizer(0);
  });
}
