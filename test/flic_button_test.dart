import 'package:flutter_test/flutter_test.dart';
import 'package:flic_button/flic_button.dart';

class ButtonListener extends Flic2Listener {
  void onButtonClicked(Flic2ButtonClick buttonClick) {
    print('button ${buttonClick.button.uuid} clicked');
  }

  void onButtonConnected() {
    print('button connected');
  }

  void onButtonDiscovered(String buttonAddress) {
    print('button at $buttonAddress discovered');
  }

  void onButtonFound(Flic2Button button) {
    print('button ${button.uuid} found');
  }

  void onFlic2Error(String error) {
    print('error $error');
  }

  void onPairedButtonDiscovered(Flic2Button button) {
    print('button ${button.uuid} discovered');
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
