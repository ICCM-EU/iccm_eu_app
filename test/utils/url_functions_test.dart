import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iccm_eu_app/utils/url_functions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UrlFunctions.proxy Tests', () {
    test('returns empty string when url is null or empty', () {
      expect(UrlFunctions.proxy(null), equals(''));
      expect(UrlFunctions.proxy(''), equals(''));
    });

    test('returns original url unchanged in non-web environment', () {
      const testUrl = 'https://example.com/api/data';
      expect(UrlFunctions.proxy(testUrl), equals(testUrl));
    });

    test('returns Firebase and Google script URLs unchanged in non-web environment', () {
      const firebaseStorageUrl = 'https://firebasestorage.googleapis.com/v0/b/app/o/file.png';
      const googleScriptUrl = 'https://script.google.com/macros/s/12345/exec';
      expect(UrlFunctions.proxy(firebaseStorageUrl), equals(firebaseStorageUrl));
      expect(UrlFunctions.proxy(googleScriptUrl), equals(googleScriptUrl));
    });
  });

  group('UrlFunctions.launch Tests', () {
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    final log = <MethodCall>[];
    bool launchResult = true;

    setUp(() {
      log.clear();
      launchResult = true;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'canLaunch') {
          return true;
        }
        if (methodCall.method == 'launchUrl' || methodCall.method == 'launch') {
          return launchResult;
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('throws Exception when attempting to launch non-http/https URL scheme', () async {
      expect(
        () => UrlFunctions.launch('javascript:alert(1)', true),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid URL scheme for launching'),
        )),
      );

      expect(
        () => UrlFunctions.launch('file:///etc/passwd', false),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid URL scheme for launching'),
        )),
      );
    });

    test('launches URL inAppWebView mode when inApp is true', () async {
      await UrlFunctions.launch('https://example.com', true);
      expect(log, isNotEmpty);
    });

    test('launches URL externalApplication mode when inApp is false', () async {
      await UrlFunctions.launch('https://example.com', false);
      expect(log, isNotEmpty);
    });

    test('throws Exception when launchUrl returns false for inApp', () async {
      launchResult = false;
      expect(
        () => UrlFunctions.launch('https://example.com', true),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Could not launch https://example.com'),
        )),
      );
    });

    test('throws Exception when launchUrl returns false for externalApplication', () async {
      launchResult = false;
      expect(
        () => UrlFunctions.launch('https://example.com', false),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Could not launch https://example.com'),
        )),
      );
    });
  });
}
