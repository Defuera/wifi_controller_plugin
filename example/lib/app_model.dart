abstract class Event {}

class Init extends Event {}

class OnReloadState extends Event {}

class TestSocketConnection extends Event {}

class MyAppState {
  final bool isLoading;
  final bool isWifiEbabled;
  final String ssid;

  MyAppState._internal({
    this.isLoading,
    this.ssid,
    this.isWifiEbabled: false,
  });

  factory MyAppState.loading() => MyAppState._internal(isLoading: true);

  factory MyAppState.ready({bool isEnabled, String ssid}) => MyAppState._internal(
        isLoading: false,
        isWifiEbabled: isEnabled,
        ssid: ssid,
      );
}
