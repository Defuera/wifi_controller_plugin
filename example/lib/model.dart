import 'package:flutter/cupertino.dart';

class WifiEntryModel {
  dynamic network; //todo
  bool isRegistered;

  WifiEntryModel(this.network, this.isRegistered);
}

abstract class Event {}

// class DoMagic extends Event {}

class Init extends Event {}

// class SetupHubWifi extends Event {}

class EnableWifi extends Event {}

class RetrieveHomeNetworkSsid extends Event {}

class ConnectToHub extends Event {

  final String ssid;
  final String password;
  ConnectToHub(this.ssid, this.password);
}

//
// class DisableWifi extends Event {}
//
// class DisconnectWifi extends Event {}
//
// class ConnectToWifi extends Event {
//   final String ssid;
//   final String password;
//
//   ConnectToWifi(this.ssid, {this.password});
// } //extra data
//
// class ForgetWifi extends Event {
//   final String ssid;
//
//   ForgetWifi(this.ssid);
// } //extra data
//
// class LoadWifiList extends Event {}

class MyAppState {
  //Page with enable wifi
  final bool showEnableWifiPage;
  final bool requestManualEnabling;

  //Are you connected to home network?
  final bool connectToHomeNetwork;

  //Enter home network password
  final bool provideWifiPassword;
  final String ssid;

  //Setting up hub and connecting to hub
  final bool setupHubWifi;

  MyAppState._internal({
    this.showEnableWifiPage: false,
    this.requestManualEnabling: false,
    this.connectToHomeNetwork: false,
    this.provideWifiPassword: false,
    this.ssid,
    this.setupHubWifi: false,
  });

  factory MyAppState.init() => MyAppState._internal(showEnableWifiPage: true);

  factory MyAppState.showEnableWifiPage({bool requestManualEnabling: false}) => MyAppState._internal(
        showEnableWifiPage: true,
        requestManualEnabling: requestManualEnabling,
      );

  factory MyAppState.showConnectToHomeNetwork() => MyAppState._internal(connectToHomeNetwork: true);

  factory MyAppState.provideWifiPassword({@required String ssid}) => MyAppState._internal(provideWifiPassword: true, ssid: ssid);
}

class WifiState {
  final bool isEnabled;
  final bool isConnected;
  final bool isWiFiAPEnabled;
  final bool isWiFiAPSSIDHidden;
  final bool isWifiAPSupported;
  final List<WifiEntryModel> wifiList;

  final String error;

  WifiState({
    this.isEnabled: false,
    this.isConnected: false,
    this.isWiFiAPEnabled: false,
    this.isWiFiAPSSIDHidden: false,
    this.isWifiAPSupported: false,
    this.wifiList,
    this.error,
  });

  WifiState copyWith({
    bool isEnabled,
    bool isConnected,
    bool isWiFiAPEnabled,
    bool isWiFiAPSSIDHidden,
    bool isWifiAPSupported,
    List<WifiEntryModel> wifiList,
    String error,
  }) =>
      WifiState(
        isEnabled: isEnabled ?? this.isEnabled,
        isConnected: isConnected ?? this.isConnected,
        isWiFiAPEnabled: isWiFiAPEnabled ?? this.isWiFiAPEnabled,
        isWiFiAPSSIDHidden: isWiFiAPSSIDHidden ?? this.isWiFiAPSSIDHidden,
        isWifiAPSupported: isWifiAPSupported ?? this.isWifiAPSupported,
        wifiList: wifiList,
        error: error,
      );
}

const ERROR_WIFI_NOT_ENABLED = 'ERROR_WIFI_NOT_ENABLED';
