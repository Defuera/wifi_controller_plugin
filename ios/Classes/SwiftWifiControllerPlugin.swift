import Flutter
import UIKit
import SystemConfiguration.CaptiveNetwork

//sorry, I don't follow swift naming conventions, since I just copy it from java here
private let METHOD_CALL_IS_ENABLED = "METHOD_CALL_IS_ENABLED"
private let METHOD_GET_WIFI_SSID = "METHOD_GET_WIFI_SSID"

public class SwiftWifiControllerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "wifi_controller_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftWifiControllerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case METHOD_CALL_IS_ENABLED:
        handleIsWifiEnabled(call, result)
    case METHOD_GET_WIFI_SSID:
        handleGetWifiSsid(call, result)
    default:
        result(FlutterMethodNotImplemented);
    }
  }
    
    private func handleIsWifiEnabled(_ call: FlutterMethodCall, _ result: @escaping FlutterResult){
        let sSSID: String? = getSSID()
           if (sSSID != nil) {
               result(true)
           } else {
               result(nil)
           }
    }
    
    private func  handleGetWifiSsid(_ call: FlutterMethodCall, _ result: @escaping FlutterResult){
        result(getSSID())
    }
    
    /**
     Starting iOS 13 you can only access Wifi SSID in these three cases:
     If your app has permission to access the location.
     If your app has an enabled VPN profile.
     If your app is a networking app that uses NEHotspotConfiguration. You will need extra approval from Apple for this case.
     https://medium.com/better-programming/how-to-access-wifi-ssid-on-ios-13-using-swift-40c4bba3c81d
     */
    private func getSSID() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    
//    private func getSSID() -> String? {
//        var currentSSID: String?
//        if let interfaces:CFArray = CNCopySupportedInterfaces() {
//            for i in 0..<CFArrayGetCount(interfaces){
//                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
//                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
//                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
//                if unsafeInterfaceData != nil {
//                    let interfaceData = unsafeInterfaceData! as Dictionary
//                    for dictData in interfaceData {
//                        if dictData.key as! String == "SSID" {
//                            currentSSID = dictData.value as String
//                        }
//                    }
//                }
//            }
//        }
//        return currentSSID
//    }
}
