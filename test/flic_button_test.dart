import 'package:flutter_test/flutter_test.dart';
import 'package:flic_button/flic_button.dart';

class ButtonListener with Flic2Listener {
  void onButtonClicked(Flic2ButtonClick buttonClick) {
    print('button ${buttonClick.button.uuid} clicked');
  }

  void onScanCompleted() {
    print('scan completed');
  }

  void onScanStarted() {
    print('scan started');
  }
}

void main() {
  setUp(() {
    // create the listener
  });

  void connectToAndSearchForFlic2() async {
    final plugin = FlicButtonPlugin(flic2listener: ButtonListener());
    final result = await plugin.scanForFlic2();
  }

  tearDown(() {});

  /*
  test('getPlatformVersion', () async {
    expect(await FlicButtonPlugin.platformVersion, '42');
  });
   */
}
