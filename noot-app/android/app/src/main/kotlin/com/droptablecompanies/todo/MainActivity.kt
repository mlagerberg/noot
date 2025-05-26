package com.droptablecompanies.todo

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Parcelable
import android.util.Log
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity: FlutterActivity() /* , EventChannel.StreamHandler */ {

    private val CHANNEL = "com.droptablecompanies.todo/io"
//    private val EVENT_CHANNEL = "com.droptablecompanies.todo/events"

    private var channel: MethodChannel? = null
//    private var eventSink: EventChannel? = null
//    private var eventSinkMedia: EventChannel.EventSink? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIncomingFile(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent);
        handleIncomingFile(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(
            flutterEngine!!.dartExecutor.binaryMessenger,
            CHANNEL
        )
        channel!!.setMethodCallHandler { call, result ->
            if (call.method == "takePersistableUriPermission") {
                val uriString = call.argument<String>("uri")
                if (uriString != null) {
                    takePersistableUriPermission(Uri.parse(uriString))
                    result.success(null)
                } else {
                    result.error("INVALID_URI", "URI is null", null)
                }
            } else if (call.method == "saveFileToDirectory") {
                val directory = call.argument<String>("directory")
                val mimeType = call.argument<String>("mimeType")
                val fileName = call.argument<String>("fileName")
                saveFileToDirectory(result, directory, mimeType, fileName)
            } else {
                result.notImplemented()
            }
        }

//        eventSink = EventChannel(
//            flutterEngine.dartExecutor.binaryMessenger,
//            EVENT_CHANNEL
//        )
//        eventSink!!.setStreamHandler(this)
    }

    private fun takePersistableUriPermission(uri: Uri) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            )
        }
    }

    private fun saveFileToDirectory(
        result: MethodChannel.Result,
        directory: String?,
        mimeType: String?,
        fileName: String?,
    ) {
        if (directory.isNullOrEmpty()) {
            result.error("invalid_arguments", "Missing 'directory'", null)
            return
        }

        if (mimeType.isNullOrEmpty()) {
            result.error("invalid_arguments", "Missing 'mimeType'", null)
            return
        }

        if (fileName.isNullOrEmpty()) {
            result.error("invalid_arguments", "Missing 'fileName'", null)
            return
        }

        val dirURI: Uri = Uri.parse(directory)
        val outputFolder: DocumentFile? = DocumentFile.fromTreeUri(this, dirURI)
        val newFile = outputFolder!!.createFile(mimeType, fileName)
        result.success(newFile?.uri.toString())
    }

    private fun handleIncomingFile(intent: Intent?) {
        if (intent?.action == Intent.ACTION_VIEW
                || intent?.action == Intent.ACTION_SEND) {
            val fileUri: Uri? = intent.data
            fileUri?.let {
                // Send to Flutter
                channel?.invokeMethod("openFile", it.toString())
            }
        }
    }
}
