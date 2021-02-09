package ru.justd.wifi_controller_plugin

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

private const val METHOD_CALL_IS_ENABLED = "METHOD_CALL_IS_ENABLED"
private const val METHOD_GET_WIFI_SSID = "METHOD_GET_WIFI_SSID"

class WifiControllerPlugin : FlutterPlugin, MethodCallHandler {

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
            METHOD_CALL_IS_ENABLED -> handleIsWifiEnabled(result)
            METHOD_GET_WIFI_SSID -> handleGetWifiSsid(result)
            else -> result.notImplemented()
        }

    }

    private fun handleIsWifiEnabled(result: Result) {
        val wifiEnabled = wifiManager.isWifiEnabled
        Log.i("WifiControllerPlugin", "[handleIsWifiEnabled] result: $wifiEnabled")
        result.success(wifiEnabled)
    }

    private fun handleGetWifiSsid(result: Result) {
        checkAndRequestPermission(Manifest.permission.ACCESS_FINE_LOCATION)
        Log.i("WifiControllerPlugin", "[handleGetWifiSsid] ssid: ${wifiManager.connectionInfo.ssid}")
        result.success(wifiManager.connectionInfo.ssid)
    }


    //region helper methods

    @Suppress("SameParameterValue")
    private fun checkAndRequestPermission(permission: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (context.checkSelfPermission(permission) != PackageManager.PERMISSION_GRANTED) {
                activity?.requestPermissions(arrayOf(permission), 87)
            }
        }
    }

    //endregion

}
