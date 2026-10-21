import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/platform/multiplatform_stub.dart';

void main() {
  group('MultiplatformStub Tests', () {
    test('getPlatform throws UnimplementedError with Unsupported message', () {
      expect(
        () => getPlatform(),
        throwsA(isA<UnimplementedError>().having(
          (e) => e.message,
          'message',
          contains('Unsupported'),
        )),
      );
    });
  });
}
