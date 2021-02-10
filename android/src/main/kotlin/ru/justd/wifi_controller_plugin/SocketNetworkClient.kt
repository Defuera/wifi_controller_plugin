package ru.justd.wifi_controller_plugin

import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Handler
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.internal.EMPTY_REQUEST
import okhttp3.logging.HttpLoggingInterceptor
import java.net.InetAddress
import java.net.Socket
import javax.net.SocketFactory

class SocketNetworkClient(private val connectivityManager: ConnectivityManager) {
    private val client: OkHttpClient
    private val handler = Handler()

    companion object {
        const val TAG = "SocketNetworkClient";
    }

    init {
        val logging = HttpLoggingInterceptor()
        logging.level = HttpLoggingInterceptor.Level.BODY
        client = OkHttpClient.Builder().addInterceptor(logging).socketFactory(object : SocketFactory() {
            override fun createSocket(): Socket {
                val socket = Socket()
                val hubNetwork = getHubNetworkObject()
                if (hubNetwork == null) {
                    Log.e(TAG, "Failed to get network.")
                } else {
                    hubNetwork.bindSocket(socket)
                }

                return socket
            }

            override fun createSocket(host: String?, port: Int): Socket {
                throw NotImplementedError()
            }

            override fun createSocket(host: String?, port: Int, localHost: InetAddress?, localPort: Int): Socket {
                throw NotImplementedError()
            }

            override fun createSocket(host: InetAddress?, port: Int): Socket {
                throw NotImplementedError()
            }

            override fun createSocket(address: InetAddress?, port: Int, localAddress: InetAddress?, localPort: Int): Socket {
                throw NotImplementedError()
            }

        })
                .build()
    }

    fun sendRequest(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as List<String>
        val method = args[0]
        val url = args[1]
        val body = args[2]
        executeCall(method, url, body, result)
    }

    private fun executeCall(method: String, url: String, body: String?, result: MethodChannel.Result) {
        getHubNetworkObject()

        val requestBuilder = Request.Builder()
                .url(url)

        val request = when (method) {
            "GET" -> requestBuilder.get()
            "POST" -> requestBuilder.post(body?.toRequestBody("application/json; charset=utf-8".toMediaTypeOrNull()) ?: EMPTY_REQUEST)
            "DELETE" -> requestBuilder.delete()
            else -> throw  NotImplementedError() //todo find batter error here
        }.build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: java.io.IOException) {
                handler.post {
                    result.error("400", e.message, null)
                }
            }

            override fun onResponse(call: Call, response: Response) {
                handler.post {
                    result.success(response.body?.string())
                }
            }
        })
    }

    fun getHubNetworkObject(): Network? {
        return connectivityManager.allNetworks.asList().find { network ->
            val capabilities = connectivityManager.getNetworkCapabilities(network)
            if (capabilities == null || capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_WIFI_P2P)) {
                false
            } else {
                capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
            }
        }
    }
}