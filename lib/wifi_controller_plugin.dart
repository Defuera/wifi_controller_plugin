import 'dart:async';

import 'package:flutter/services.dart';

const _METHOD_CALL_IS_ENABLED = "METHOD_CALL_IS_ENABLED";
const _METHOD_GET_WIFI_SSID = "METHOD_GET_WIFI_SSID";

class WifiControllerPlugin {
  static const MethodChannel _channel = const MethodChannel('wifi_controller_plugin');

  /// Return true or false when status is retrieved or null when status is not available on device
  static Future<bool> get isWifiEnabled async {
    final bool isEnabled = await _channel.invokeMethod(_METHOD_CALL_IS_ENABLED);
    return isEnabled;
  }

  /// Returns current ssid name or null if failed to retrieve
  static Future<String> get wifiSsid async {
    return ((await _channel.invokeMethod(_METHOD_GET_WIFI_SSID)) as String)?.replaceAll('"', '');
  }

  /// Loops until wifi is enabled
  /// @param maxTime - loop for max milliseconds before stop trying
  /// @param periodicity - how often is to send isEnabled request
  static Future<void> loopUntilWifiIsEnabled({double maxTime: 5000, int periodicity: 500}) async {
    await Future.delayed(Duration(milliseconds: periodicity));
    if (!await isWifiEnabled) {
      await loopUntilWifiIsEnabled(maxTime: maxTime, periodicity: periodicity);
    }
  }

  static Future<void> loopUntilWifiIsConnectedTo(String ssid, {double maxTime: 5000, int periodicity: 500}) async {
    await Future.delayed(Duration(milliseconds: periodicity));
    if (await wifiSsid != ssid) {
      await loopUntilWifiIsConnectedTo(ssid, maxTime: maxTime, periodicity: periodicity);
    }
  }

  static Future<void> loopUntilWifiIsConnectedToAny({double maxTime: 5000, int periodicity: 500}) async {
    await Future.delayed(Duration(milliseconds: periodicity));
    if (await wifiSsid == null) {
      await loopUntilWifiIsConnectedToAny(maxTime: maxTime, periodicity: periodicity);
    }
  }

}
