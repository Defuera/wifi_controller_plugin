import 'dart:async';

import 'package:flutter/services.dart';

const _METHOD_CALL_IS_ENABLED = "METHOD_CALL_IS_ENABLED";
const _METHOD_CALL_ENABLE_WIFI = "METHOD_CALL_ENABLE_WIFI";
const _METHOD_GET_WIFI_SSID = "METHOD_GET_WIFI_SSID";
const _METHOD_SETUP_HUB = "METHOD_SETUP_HUB";
const _METHOD_RESOLVE_IP = "METHOD_RESOLVE_IP";
// const _METHOD_CALL_GET_AVAILABLE_NETWORKS = "METHOD_CALL_GET_AVAILABLE_NETWORKS";

// 1. check if enabled
// 1.1 if not enabled enable
// 2. Ask user to connect to his home wifi if he is on a home network if he is, get it's ssid and pass
// 3. connect to ssid liveleds/ liveleds
// 3. via ssh communicate master ssid/pass
// 4. connect back to home wifi
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

  /// Enables wifi and loops for 5 seconds until wifi is enabled,
  /// if wifi is not enabled within given time frame throws an error
  static Future<bool> enableWifiAndWait() async {
    final result = await _channel.invokeMethod(_METHOD_CALL_ENABLE_WIFI);
    if (!result) {
      return false;
    } else {
      await loopUntilWifiIsEnabled(); //todo limit loop to 5 secs
      return await isWifiEnabled;
    }
  }

  /// Loops until wifi is enabled
  /// @param maxTime - loop for max milliseconds before stop trying
  /// @param periodicity - how often is to send isEnabled request
  static Future<void> loopUntilWifiIsEnabled({double maxTime: 5000, int periodicity: 500}) async {
    //todo implement maxTime Functionality
    await Future.delayed(Duration(milliseconds: periodicity));
    if (!await isWifiEnabled) {
      await loopUntilWifiIsEnabled(maxTime: maxTime, periodicity: periodicity);
    }
  }

  static Future<void> loopUntilWifiIsConnectedTo(String ssid, {double maxTime: 5000, int periodicity: 500}) async {
    //todo implement maxTime Functionality
    await Future.delayed(Duration(milliseconds: periodicity));
    if (await wifiSsid != ssid) {
      await loopUntilWifiIsConnectedTo(ssid, maxTime: maxTime, periodicity: periodicity);
    }
  }

  static Future<void> loopUntilWifiIsConnectedToAny({double maxTime: 5000, int periodicity: 500}) async {
    //todo implement maxTime Functionality
    await Future.delayed(Duration(milliseconds: periodicity));
    if (await wifiSsid == null) {
      await loopUntilWifiIsConnectedToAny(maxTime: maxTime, periodicity: periodicity);
    }
  }

  static Future<bool> connectToHubWifi(String hubSsid, String hubPass) async {
    final result = await _channel.invokeMethod(_METHOD_SETUP_HUB, [hubSsid, hubPass]);
    return result;
  }

  static Future<String> resolveIp(String dns) => _channel.invokeMethod(_METHOD_RESOLVE_IP, dns);

}
