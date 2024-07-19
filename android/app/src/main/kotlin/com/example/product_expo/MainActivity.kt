package com.example.product_expo


import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sharefileMethodChannel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "shareFile") {
                val fileName = call.argument<String>("fileName")
                val fileBytes = call.argument<ByteArray>("fileBytes")
                if (fileName != null && fileBytes != null) {
                    val file = createFileFromBytes(fileName, fileBytes)
                    shareFile(file)
                    result.success(null)
                } else {
                    result.error("UNAVAILABLE", "File data not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun createFileFromBytes(fileName: String, fileBytes: ByteArray): File {
        val file = File(cacheDir, fileName)
        val fos = FileOutputStream(file)
        fos.write(fileBytes)
        fos.close()
        return file
    }

    private fun shareFile(file: File) {
        val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
        val intent = Intent(Intent.ACTION_SEND).apply {
            val mimeType = when {
                file.name.endsWith(".jpg", true) || file.name.endsWith(".jpeg", true) || file.name.endsWith(".png", true) -> "image/*"
                file.name.endsWith(".mp4", true) -> "video/*"
                else -> "*/*"
            }
            type = mimeType
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(Intent.createChooser(intent, "Share file"))
    }
}
