import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:wifi_controller_plugin/wifi_controller_plugin.dart';
import 'package:wifi_controller_plugin_example/app_model.dart';

class MyAppBloc extends Bloc<Event, MyAppState> {
  MyAppBloc() : super(MyAppState.loading()) {
    add(OnReloadState());
  }

  @override
  Stream<MyAppState> mapEventToState(Event event) async* {
    if (event is OnReloadState) {
      final isEnabled = await WifiControllerPlugin.isWifiEnabled;
      final ssid = await WifiControllerPlugin.wifiSsid;
      yield MyAppState.ready(isEnabled: isEnabled, ssid: ssid);
    } else if (event is TestSocketConnection) {
      try {
        final result = await WifiControllerPlugin.socketRequest('GET', 'http://192.168.178.241:16006/connections');
        print("call succeed: $result");
      } catch (error) {
        print("call failed: $error");
      }
    }
  }
}
