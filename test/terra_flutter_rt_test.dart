import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terra_flutter_rt/terra_flutter_rt.dart';

void main() {
  const MethodChannel channel = MethodChannel('terra_flutter_rt');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await TerraFlutterRt.platformVersion, '42');
  });
}
