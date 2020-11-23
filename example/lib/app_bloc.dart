import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:wifi_controller_plugin/wifi_controller_plugin.dart';
import 'package:wifi_controller_plugin_example/app_model.dart';

// 1. check if enabled
// 1.1 if not enabled enable
// 2. Ask user to connect to his home wifi if he is on a home network if he is, get it's ssid and pass
// 3. connect to ssid liveleds/ liveleds
// 3. via ssh communicate master ssid/pass
// 4. connect back to home wifi
class MyAppBloc extends Bloc<Event, MyAppState> {
  MyAppBloc() : super(MyAppState.init()) {
    add(Init());
  }

  @override
  Stream<MyAppState> mapEventToState(Event event) async* {
    if (event is Init) {
      yield await _init();
    } else if (event is EnableWifi) {
      yield await _enableWifi();
    } else if (event is RetrieveHomeNetworkSsid) {
      final ssid = await WifiControllerPlugin.wifiSsid;
      yield MyAppState.provideWifiPassword(ssid: ssid);
    } else if (event is SetupLiveLedsHub) {
      await setupLiveLedsHub(event.ssid, event.password);
    }
    // else if (event is DisableWifi) {
    //   yield await _disableWifi();
    // } else if (event is DisconnectWifi) {
    //   yield await _disconnectWifi();
    // } else if (event is ConnectToWifi) {
    //   yield await _onConnectToWifiPressed(event.ssid, password: event.password);
    // } else if (event is ForgetWifi) {
    //   yield await _forgetWifi(event.ssid);
    // } else if (event is LoadWifiList) {
    //   yield await _loadWifiList();
    // } else if (event is DoMagic) {
    //   await doMagic();
    // }
  }

  Future<MyAppState> _init() async {
    var isEnabled = await WifiControllerPlugin.isWifiEnabled;
    return !isEnabled ? MyAppState.showEnableWifiPage() : MyAppState.showConnectToHomeNetwork();

    // var isEnabled = await WifiControllerPlugin.isWifiEnabled;
    // if (!isEnabled) {
    //   isEnabled = await WifiControllerPlugin.enableWifiAndWait();
    // }
    //
    // if (!isEnabled) {
    //   // return MyAppState(error: ERROR_WIFI_NOT_ENABLED);
    // }
    //
    // return state; //todo?

    // final networks = await WifiControllerPlugin.getAvailableNetworksList();

    // print("networks: $networks");
    // return

    // final isEnabled = await WiFiForIoTPlugin.isEnabled();
    // final isConnected = await WiFiForIoTPlugin.isConnected();
    //
    // try {
    //   final isWiFiAPEnabled = await WiFiForIoTPlugin.isWiFiAPEnabled();
    //   final isWiFiAPSSIDHidden = await WiFiForIoTPlugin.isWiFiAPSSIDHidden();
    //
    //   return MyAppState(
    //     isEnabled: isEnabled,
    //     isConnected: isConnected,
    //     isWiFiAPEnabled: isWiFiAPEnabled,
    //     isWiFiAPSSIDHidden: isWiFiAPSSIDHidden,
    //     isWifiAPSupported: true,
    //   );
    // } catch (error, stacktrace) {
    //   // print(stacktrace);
    //   final wifiState = MyAppState(
    //     isEnabled: isEnabled,
    //     isConnected: isConnected,
    //     isWifiAPSupported: false,
    //   );
    //   return wifiState;
    // }
  }

  Future<MyAppState> _enableWifi() async {
    final result = await WifiControllerPlugin.enableWifiAndWait();
    if (result) {
      return MyAppState.showConnectToHomeNetwork();
    } else {
      return MyAppState.showEnableWifiPage(requestManualEnabling: true);
    }
    // await WiFiForIoTPlugin.setEnabled(true);
    // await _loopUntilWifiIsEnabled();
    // return await _init();
  }

  Future<MyAppState> _disableWifi() async {
    // await WiFiForIoTPlugin.setEnabled(false);
    // await Future.delayed(Duration(seconds: 2));
    // return await _init();
  }

  Future<MyAppState> _disconnectWifi() async {
    // await WiFiForIoTPlugin.disconnect();
    // return await _loadWifiList();
  }

  Future<MyAppState> _forgetWifi(String ssid) async {
    // //todo this is not working
    // final result = await WiFiForIoTPlugin.removeWifiNetwork(ssid);
    // print("Wifi network $ssid removed succesfully: $result");
    // await Future.delayed(Duration(seconds: 3));
    // return await _loadWifiList();
  }

  Future<MyAppState> _onConnectToWifiPressed(String ssid, {String password}) async {
    // final pass = password ?? STA_DEFAULT_PASSWORD;
    // print("Connect to $ssid with password $pass");
    // await WiFiForIoTPlugin.findAndConnect(ssid, password: pass);
    // await Future.delayed(Duration(seconds: 3));
    // return await _init();
  }

  Future<MyAppState> _loadWifiList() async {
    // try {
    //   print("get wifi list");
    //   final wifiList = await WiFiForIoTPlugin.loadWifiList();
    //   final wifiModels = await mapToEntryModel(wifiList);
    //   print("${wifiModels.length} Wifi networks loaded");
    //   return state.copyWith(wifiList: wifiModels);
    // } catch (error, stacktrace) {
    //   print("error");
    //   print(stacktrace);
    //   //todo notify
    // }
  }

  Future<void> _loopUntilWifiIsEnabled() async {
    // await Future.delayed(Duration(milliseconds: 500));
    // if (!await WiFiForIoTPlugin.isEnabled()) {
    //   await _loopUntilWifiIsEnabled();
    // }
  }

  Future<List<WifiEntryModel>> mapToEntryModel(List wifiList) async {
    final list = List<WifiEntryModel>();
    // wifiList.forEach((element) async {
    //   bool isRegistered = await WiFiForIoTPlugin.isRegisteredWifiNetwork(element.ssid);
    //   list.add(WifiEntryModel(element, isRegistered));
    // });
    return list;
  }

  Future<void> setupLiveLedsHub(String ssid, String password) async {
    password = '1LoveDenis';

    final result = await WifiControllerPlugin.connectToHubWifi("liveleds", "liveleds");

    //todo check if success
    //todo talk to hub via API
  }

//   // 1. check if enabled
// // 1.1 if not enabled enable
// // 2. ask to what wifi hub should be connected, ask password for this wifi, store ssid and pass
// // 3. connect to ssid liveleds/ liveleds
// // 3. via ssh communicate master ssid/pass
// // 4. connect back to home wifi
//   Future doMagic() async {
//     if (!(await WifiControllerPlugin.isWifiEnabled)) {
//       WifiControllerPlugin.enableWifiAndWait();
//     }
//   }
}
