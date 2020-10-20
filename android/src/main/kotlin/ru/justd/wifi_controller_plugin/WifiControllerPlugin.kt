package ru.justd.wifi_controller_plugin

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat.startActivityForResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

private const val METHOD_CALL_IS_ENABLED = "METHOD_CALL_IS_ENABLED"
private const val METHOD_CALL_ENABLE_WIFI = "METHOD_CALL_ENABLE_WIFI"
private const val METHOD_GET_WIFI_SSID = "METHOD_GET_WIFI_SSID"

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
//            METHOD_CALL_GET_AVAILABLE_NETWORKS -> handleGetAvailableNetworks(call, result)
            else -> result.notImplemented()
        }

    }

    private fun handleIsWifiEnabled(call: MethodCall, result: Result) {
        result.success(wifiManager.isWifiEnabled)
    }

    //            Starting with Build.VERSION_CODES#Q, applications are not allowed to enable/disable Wi-Fi.
//        Compatibility Note: For applications targeting Build.VERSION_CODES.Q or above,
//        this API will always return false and will have no effect.
//        If apps are targeting an older SDK ( Build.VERSION_CODES.P or below),
//        they can continue to use this API
    private fun handleEnableWifi(call: MethodCall, result: Result) {
        checkAndRequestPermission(Manifest.permission.CHANGE_WIFI_STATE) //todo ACCESS_FINE_LOCATION?
        val wifiEnabled = wifiManager.setWifiEnabled(true)
        if (wifiEnabled){
            result.success(wifiEnabled)
        } else {
            result.success(false)
            // todo
//            val panelIntent = Intent(Settings.Panel.ACTION_WIFI)
//            startActivityForResult(panelIntent, 1)
//            val panelIntent = Intent(Settings.Panel.ACTION_INTERNET_CONNECTIVITY)
//            startActivityForResult(panelIntent, 0)
        }
    }

    private fun handleGetWifiSsid(call: MethodCall, result: Result) {
        checkAndRequestPermission(Manifest.permission.ACCESS_FINE_LOCATION) //todo ?

        Log.i("DensTest", "ssid: ${wifiManager.connectionInfo.ssid}")
        Log.i("DensTest", "bssid: ${wifiManager.connectionInfo.bssid}")
        result.success(wifiManager.connectionInfo.ssid)

//        WifiInfo.getSSID()
    }

    private fun handleGetAvailableNetworks(call: MethodCall, result: Result) {
        checkAndRequestPermission(Manifest.permission.ACCESS_COARSE_LOCATION) //todo handle when permission is not granted
        val scanInitiated = wifiManager.startScan()
        if (!scanInitiated) {
            result.error(ERROR_WIFI_SCAN_NOT_POSSIBLE, null, null)
        }

    }

    private fun checkAndRequestPermission(permission: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (context.checkSelfPermission(permission) != PackageManager.PERMISSION_GRANTED) {
                activity?.requestPermissions(arrayOf(permission), 87)
            }
        }
    }

    override fun onDetachedFromActivity() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

}
