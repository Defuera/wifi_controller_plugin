package ru.justd.wifi_controller_plugin

import android.R.attr.key
import android.annotation.TargetApi
import android.content.Context
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiManager
import android.net.wifi.WifiNetworkSpecifier
import android.os.Build
import android.util.Log

class WifiConnector(private val context: Context, private val wifiManager: WifiManager) {

    private val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

    fun connect(ssid: String, password: String, callback: (Boolean) -> Unit) {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//            connectQ(ssid, password, callback)
//        } else {
            callback(connectOthers(ssid, password))
//        }
    }

    @TargetApi(Build.VERSION_CODES.Q)
    private fun connectQ(ssid: String, password: String, callback: (Boolean) -> Unit) {
        val specifier = WifiNetworkSpecifier.Builder().apply {
            setSsid(ssid)
            setWpa2Passphrase(password)
        }.build()

        val request = NetworkRequest.Builder().apply {
            addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
            removeCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            setNetworkSpecifier(specifier)
        }.build()

        connectivityManager.requestNetwork(
            request,
            object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(network: Network) {
                    super.onAvailable(network)
                    Log.i("WifiControllerPlugin", "$ssid available")
                    callback(true)
//                    it.resumeWith(Result.success(true))
                }

                override fun onUnavailable() {
                    super.onUnavailable()
                    Log.i("WifiControllerPlugin", "$ssid unavailable")
                    callback(false)
//                    it.resumeWith(Result.success())
                }

                override fun onBlockedStatusChanged(network: Network, blocked: Boolean) {
                    super.onBlockedStatusChanged(network, blocked)
                    Log.i("WifiControllerPlugin", "$ssid onBlockedStatusChanged, $blocked")
                }

                override fun onCapabilitiesChanged(network: Network, networkCapabilities: NetworkCapabilities) {
                    super.onCapabilitiesChanged(network, networkCapabilities)
                    Log.i("WifiControllerPlugin", "$ssid onCapabilitiesChanged")
                }

                override fun onLinkPropertiesChanged(network: Network, linkProperties: LinkProperties) {
                    super.onLinkPropertiesChanged(network, linkProperties)
                    Log.i("WifiControllerPlugin", "$ssid onLinkPropertiesChanged")
                }

                override fun onLosing(network: Network, maxMsToLive: Int) {
                    Log.i("WifiControllerPlugin", "$ssid onLosing")
                }

                override fun onLost(network: Network) {
                    Log.i("WifiControllerPlugin", "$ssid onLost")
                }
            });

    }

    @TargetApi(Build.VERSION_CODES.P)
    private fun connectOthers(ssid: String, password: String): Boolean {
        val wifiConfig = WifiConfiguration()
        wifiConfig.SSID = java.lang.String.format("\"%s\"", ssid)
        wifiConfig.preSharedKey = String.format("\"%s\"", password)

        val configList: List<WifiConfiguration> = wifiManager.getConfiguredNetworks()
        val preconfigured = configList.find { it.SSID == "\"$ssid\"" }
        val netId = if (preconfigured != null) {
            preconfigured.networkId
        } else {
            wifiManager.addNetwork(wifiConfig)
        }
        wifiManager.disconnect()
        wifiManager.enableNetwork(netId, true)
        return wifiManager.reconnect()

    }

}
