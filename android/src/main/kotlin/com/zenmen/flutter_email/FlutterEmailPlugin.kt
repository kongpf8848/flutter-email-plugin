package com.zenmen.flutter_email

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.chirpeur.chirpmail.jniutil.JniUtils

class FlutterEmailPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "zenmen_flutter_email")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method.equals(METHOD_NEW_SESSION)) {
            val url: String? = call.argument("url")
            val address: String? = call.argument("address")
            val password: String? = call.argument("password")
            val domain: String? = call.argument("domain")
            val session: Long = JniUtils.newSession(url, address, password, domain)
            result.success(session)
        } else if (call.method.equals(METHOD_CHECK_ACCOUNT)) {
            val session: Long = call.argument("session")!!
            val str: String = JniUtils.checkAccount(session, 2)
            result.success(str)
        } else if (call.method.contentEquals(METHOD_GET_FOLDERS)) {
            val session: Long = call.argument("session")!!
            val str: String = JniUtils.getFolders(session, 2)
            result.success(str)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    companion object {
        //渠道名称
        private const val CHANNEL_NAME = "zen_men_flutter_email"

        //生成session
        private const val METHOD_NEW_SESSION = "email_new_session"

        //检查账户是否可用
        private const val METHOD_CHECK_ACCOUNT = "email_check_account"

        //获取文件夹列表
        private const val METHOD_GET_FOLDERS = "email_get_folders"
    }
}
