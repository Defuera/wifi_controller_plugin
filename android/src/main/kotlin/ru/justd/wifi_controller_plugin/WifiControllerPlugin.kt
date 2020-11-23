package ru.justd.wifi_controller_plugin

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Handler
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.net.InetAddress

private const val METHOD_CALL_IS_ENABLED = "METHOD_CALL_IS_ENABLED"
private const val METHOD_CALL_ENABLE_WIFI = "METHOD_CALL_ENABLE_WIFI"
private const val METHOD_GET_WIFI_SSID = "METHOD_GET_WIFI_SSID"
private const val METHOD_SETUP_HUB = "METHOD_SETUP_HUB"
private const val METHOD_RESOLVE_IP = "METHOD_RESOLVE_IP"

//private const val METHOD_CALL_IS_CONNECTED = "METHOD_CALL_IS_CONNECTED"
//private const val METHOD_CALL_GET_AVAILABLE_NETWORKS = "METHOD_CALL_GET_AVAILABLE_NETWORKS"

private const val ERROR_WIFI_SCAN_NOT_POSSIBLE = "ERROR_WIFI_SCAN_NOT_POSSIBLE"

class WifiControllerPlugin : FlutterPlugin,
                             MethodCallHandler,
                             ActivityAware {

    private var activity: Activity? = null
    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private lateinit var wifiManager: WifiManager

    @SuppressLint("WifiManagerPotentialLeak")
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wifi_controller_plugin")
        channel.setMethodCallHandler(this)

        context = flutterPluginBinding.applicationContext
        wifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            METHOD_CALL_IS_ENABLED -> handleIsWifiEnabled(call, result)
            METHOD_CALL_ENABLE_WIFI -> handleEnableWifi(call, result)
            METHOD_GET_WIFI_SSID -> handleGetWifiSsid(call, result)
            METHOD_SETUP_HUB -> handleSetupHub(call, result)
            METHOD_RESOLVE_IP -> handleResolveIp(call, result)
//            METHOD_CALL_GET_AVAILABLE_NETWORKS -> handleGetAvailableNetworks(call, result)
            else -> result.notImplemented()
        }

    }

    private fun handleIsWifiEnabled(call: MethodCall, result: Result) {
        val wifiEnabled = wifiManager.isWifiEnabled
        Log.i("WifiControllerPlugin", "[handleIsWifiEnabled] result: $wifiEnabled")
        result.success(wifiEnabled)
    }

    //            Starting with Build.VERSION_CODES#Q, applications are not allowed to enable/disable Wi-Fi.
//        Compatibility Note: For applications targeting Build.VERSION_CODES.Q or above,
//        this API will always return false and will have no effect.
//        If apps are targeting an older SDK ( Build.VERSION_CODES.P or below),
//        they can continue to use this API
    private fun handleEnableWifi(call: MethodCall, result: Result) {
        checkAndRequestPermission(Manifest.permission.CHANGE_WIFI_STATE) //todo ACCESS_FINE_LOCATION?
        val wifiEnabled = wifiManager.setWifiEnabled(true)
        if (wifiEnabled) {
            Log.i("WifiControllerPlugin", "[handleEnableWifi] result: $wifiEnabled")
            result.success(wifiEnabled)
        } else {
            Log.i("WifiControllerPlugin", "[handleEnableWifi] result: false")
            result.success(false)
            // todo
//            val panelIntent = Intent(Settings.Panel.ACTION_WIFI)
//            startActivityForResult(panelIntent, 1)
//            val panelIntent = Intent(Settings.Panel.ACTION_INTERNET_CONNECTIVITY)
//            startActivityForResult(panelIntent, 0)
        }
    }

    private fun handleSetupHub(call: MethodCall, result: Result) {
        try {
            val ssid = (call.arguments as List<String>)[0]
            val pass = (call.arguments as List<String>)[1]

            WifiConnector(context, wifiManager).connect(ssid, pass) { isConnected ->
                Log.i("WifiControllerPlugin", "[handleSetupHub] isConnected: $isConnected")
                result.success(isConnected)
            }
        } catch (exception: Exception) {
            result.error("", exception.message, null)
        }
    }

    private fun handleGetWifiSsid(call: MethodCall, result: Result) {
        checkAndRequestPermission(Manifest.permission.ACCESS_FINE_LOCATION) //todo ?

        Log.i("WifiControllerPlugin", "[handleGetWifiSsid] ssid: ${wifiManager.connectionInfo.ssid}")
        result.success(wifiManager.connectionInfo.ssid)
    }

    private fun handleResolveIp(call: MethodCall, result: Result) {
        Thread {

            try {
                Log.i("WifiControllerPlugin", "[handleResolveIp]")
//            val ssid = require(call.arguments as String) { "DNS url must be provided" }
                val ssid = (call.arguments as String)

                val address = InetAddress.getByName("http://$ssid")

                Log.i("WifiControllerPlugin", "[handleResolveIp] Resolved for $ssid: $address")

                Handler().post{
                    result.success(address.hostAddress)
                }


            } catch (exception: Exception) {
                Log.i("WifiControllerPlugin", "[handleResolveIp] Resolution failed")
                exception.printStackTrace()
                Handler().post{
                    result.error("", exception.message, null)
                }

            }

        }.start()

    }

//    private fun handleGetAvailableNetworks(call: MethodCall, result: Result) {
//        checkAndRequestPermission(Manifest.permission.ACCESS_COARSE_LOCATION) //todo handle when permission is not granted
//        val scanInitiated = wifiManager.startScan()
//        if (!scanInitiated) {
//            result.error(ERROR_WIFI_SCAN_NOT_POSSIBLE, null, null)
//        }
//
//    }

    //region helper methods
    private fun checkAndRequestPermission(permission: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (context.checkSelfPermission(permission) != PackageManager.PERMISSION_GRANTED) {
                activity?.requestPermissions(arrayOf(permission), 87)
            }
        }
    }

    //endregion

    //region ActivityAware
    override fun onDetachedFromActivity() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {}
    //endregion
}
