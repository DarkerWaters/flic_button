import 'package:flutter_test/flutter_test.dart';
import 'package:flic_button/flic_button.dart';
import 'package:logging/logging.dart';

class ButtonListener with Flic2Listener {
  final log = Logger('FlicButtonPluginTest');
  @override
  void onButtonClicked(Flic2ButtonClick buttonClick) {
    log.info('button ${buttonClick.button.uuid} clicked');
  }

  @override
  void onScanCompleted() {
    log.info('scan completed');
  }

  @override
  void onScanStarted() {
    log.info('scan started');
  }
}

void main() {
  setUp(() {
    // create the listener
  });
  /*
  void connectToAndSearchForFlic2() async {
    final plugin = FlicButtonPlugin(flic2listener: ButtonListener());
    final result = await plugin.scanForFlic2();
  }
  */
  tearDown(() {});

  /*
  test('getPlatformVersion', () async {
    expect(await FlicButtonPlugin.platformVersion, '42');
  });
   */
}
