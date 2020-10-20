#import "WifiControllerPlugin.h"
#if __has_include(<wifi_controller_plugin/wifi_controller_plugin-Swift.h>)
#import <wifi_controller_plugin/wifi_controller_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "wifi_controller_plugin-Swift.h"
#endif

@implementation WifiControllerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWifiControllerPlugin registerWithRegistrar:registrar];
}
@end
