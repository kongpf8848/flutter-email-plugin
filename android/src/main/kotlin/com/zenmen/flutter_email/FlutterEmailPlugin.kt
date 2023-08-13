package com.zenmen.flutter_email

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.chirpeur.chirpmail.jniutil.JniUtils
import android.content.Context
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class FlutterEmailPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)

        val caBundleFile = extractAsset(flutterPluginBinding.applicationContext,R.raw.cacert20190123_z, "ews", "ca_bundle_z.pem")
        JniUtils.startUp(caBundleFile.absolutePath, 1)
        JniUtils.czcryptoInit()
    }

     private fun extractAsset(context:Context,resId: Int, folderName: String, fileName: String): File {
        val cacheFolder = File(context.cacheDir, folderName)
        if (!cacheFolder.exists()) {
            cacheFolder.mkdirs()
        }
        val outputFile = File(cacheFolder, fileName)
        if (!outputFile.exists() || outputFile.length() <= 0) {
            val buffer = ByteArray(2 * 1024 * 1024)
            var byteCount = 0
            try {
                val `is` = context.resources.openRawResource(resId)
                val fos = FileOutputStream(outputFile)
                while (`is`.read(buffer).also { byteCount = it } != -1) {
                    fos.write(buffer, 0, byteCount)
                }
                fos.flush()
                `is`.close()
                fos.close()
            } catch (e: IOException) {
                outputFile.delete()
                e.printStackTrace()
            }
        }
        return outputFile
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
        private const val CHANNEL_NAME = "zenmen_flutter_email"

        //生成session
        private const val METHOD_NEW_SESSION = "ews_new_session"

        //检查账户是否可用
        private const val METHOD_CHECK_ACCOUNT = "ews_check_account"

        //获取文件夹列表
        private const val METHOD_GET_FOLDERS = "ews_get_folders"
    }
}
