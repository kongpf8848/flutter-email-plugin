package com.zenmen.flutter_email_example

import android.app.Application
import com.chirpeur.chirpmail.jniutil.JniUtils
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class MailApplication: Application() {
    override fun onCreate() {
        super.onCreate()
        initJni()
    }

    private fun initJni() {
        val caBundleFile = extractAsset(R.raw.cacert20190123_z, "ews", "ca_bundle_z.pem")

        //exchange startUp only once on APP create
        JniUtils.startUp(caBundleFile.absolutePath, 1)

        //初始化加解密模块 only once
        JniUtils.czcryptoInit()
    }

    private fun extractAsset(assetResId: Int, folderName: String, fileName: String): File {
        val cacheFolder = File(applicationContext.cacheDir, folderName)
        if (!cacheFolder.exists()) {
            cacheFolder.mkdirs()
        }
        val outputFile = File(cacheFolder, fileName)
        if (!outputFile.exists() || outputFile.length() <= 0) {
            val buffer = ByteArray(2 * 1024 * 1024)
            var byteCount = 0
            try {
                val `is` = resources.openRawResource(assetResId)
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
}