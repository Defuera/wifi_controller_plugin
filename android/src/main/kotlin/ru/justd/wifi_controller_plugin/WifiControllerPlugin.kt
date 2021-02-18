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
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

private const val METHOD_CALL_IS_ENABLED = "METHOD_CALL_IS_ENABLED"
private const val METHOD_GET_WIFI_SSID = "METHOD_GET_WIFI_SSID"

private const val RESULT_ERROR = "PERMISSION_IS_MISSING"

class WifiControllerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var activity: Activity
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
        try {
            when (call.method) {
                METHOD_CALL_IS_ENABLED -> handleIsWifiEnabled(result)
                METHOD_GET_WIFI_SSID -> handleGetWifiSsid(result)
                else -> result.notImplemented()
            }
        } catch (exception: Exception) {
            result.error(exception.javaClass.simpleName, exception.message, null)
            exception.printStackTrace()
        }
    }

    private fun handleIsWifiEnabled(result: Result) {
        val wifiEnabled = wifiManager.isWifiEnabled
        Log.i("WifiControllerPlugin", "[handleIsWifiEnabled] result: $wifiEnabled")
        result.success(wifiEnabled)
    }

    private fun handleGetWifiSsid(result: Result) {
        val permissionNeeded = checkAndRequestPermission(Manifest.permission.ACCESS_FINE_LOCATION)
        if (!permissionNeeded) {
            val ssid = wifiManager.connectionInfo.ssid
            val resolvedSsid = if (ssid == "<unknown ssid>") null else ssid

            Log.i("WifiControllerPlugin", "[handleGetWifiSsid] ssid: $resolvedSsid")
            result.success(resolvedSsid)
        } else {
            result.error(RESULT_ERROR, null, Manifest.permission.ACCESS_FINE_LOCATION)
        }
    }


    //region helper methods

    @Suppress("SameParameterValue")
    private fun checkAndRequestPermission(permission: String): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (context.checkSelfPermission(permission) != PackageManager.PERMISSION_GRANTED) {
                activity.requestPermissions(arrayOf(permission), 87)
                return true
            }
        }
        return false
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
