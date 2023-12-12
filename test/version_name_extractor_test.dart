import 'package:test/test.dart';
import 'package:version_name_extractor/version_name_extractor.dart';

void main() {
  test('calculate', () {
    expect(
        convertToVersion('6.35.16+1004', 'beta'), 'release/v6.35.16.1004-beta');
  });
}
