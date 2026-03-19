import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konnect/providers/platform_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('PlatformProvider Tests', () {
    test('getPlatformConfig returns correct config for IG', () {
      final igConfig = getPlatformConfig('IG');
      expect(igConfig.id, 'IG');
      expect(igConfig.name, 'Instagram');
      expect(igConfig.apiName, 'instagram');
    });

    test('getPlatformConfig returns correct config for FB', () {
      final fbConfig = getPlatformConfig('FB');
      expect(fbConfig.id, 'FB');
      expect(fbConfig.name, 'Facebook');
      expect(fbConfig.apiName, 'facebook');
    });

    test('getPlatformConfig returns correct config for X', () {
      final xConfig = getPlatformConfig('X');
      expect(xConfig.id, 'X');
      expect(xConfig.name, 'X (Twitter)');
      expect(xConfig.apiName, 'twitter');
    });

    test('getPlatformConfig returns correct config for LN', () {
      final lnConfig = getPlatformConfig('LN');
      expect(lnConfig.id, 'LN');
      expect(lnConfig.name, 'LinkedIn');
      expect(lnConfig.apiName, 'linkedin');
    });

    test('getPlatformConfig returns IG for unknown platform', () {
      final defaultConfig = getPlatformConfig('UNKNOWN');
      expect(defaultConfig.id, 'IG');
    });
  });
}
