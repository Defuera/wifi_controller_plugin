import 'dart:async';

import 'package:flutter/services.dart';

const _METHOD_CALL_IS_ENABLED = "METHOD_CALL_IS_ENABLED";
const _METHOD_CALL_ENABLE_WIFI = "METHOD_CALL_ENABLE_WIFI";
const _METHOD_GET_WIFI_SSID = "METHOD_GET_WIFI_SSID";
// const _METHOD_CALL_GET_AVAILABLE_NETWORKS = "METHOD_CALL_GET_AVAILABLE_NETWORKS";

// 1. check if enabled
// 1.1 if not enabled enable
// 2. Ask user to connect to his home wifi if he is on a home network if he is, get it's ssid and pass
// 3. connect to ssid liveleds/ liveleds
// 3. via ssh communicate master ssid/pass
// 4. connect back to home wifi
class WifiControllerPlugin {
  static const MethodChannel _channel = const MethodChannel('wifi_controller_plugin');

  static Future<bool> get isWifiEnabled async {
    final bool isEnabled = await _channel.invokeMethod(_METHOD_CALL_IS_ENABLED);
    return isEnabled;
  }

  static Future<String> get wifiSsid async {
    return await _channel.invokeMethod(_METHOD_GET_WIFI_SSID);
  }

  /// Enables wifi and loops for 5 seconds until wifi is enabled,
  /// if wifi is not enabled within given time frame throws an error
  static Future<bool> enableWifiAndWait() async {
    final result = await _channel.invokeMethod(_METHOD_CALL_ENABLE_WIFI);
    if (!result) {
      return false;
    } else {
      await _loopUntilWifiIsEnabled(); //todo limit loop to 5 secs
      return await isWifiEnabled;
    }
  }

  // static Future<dynamic> getAvailableNetworksList() async { //todo not dynamic
  //   final networksJson = await _channel.invokeMethod(_METHOD_CALL_GET_AVAILABLE_NETWORKS); //todo handle ERROR_WIFI_SCAN_NOT_POSSIBLE
  //
  //   return networksJson;
  // }

  static Future<void> _loopUntilWifiIsEnabled({double loopForMillis: 5000}) async {
    await Future.delayed(Duration(milliseconds: 500));
    if (!await isWifiEnabled) {
      await _loopUntilWifiIsEnabled();
    }
  }
}
