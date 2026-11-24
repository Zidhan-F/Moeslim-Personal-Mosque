package id.moeslim.moeslim_mobile

import android.Manifest
import android.app.Activity
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.hardware.GeomagneticField
import android.media.ExifInterface
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import kotlin.math.max

class MainActivity : FlutterActivity() {
    companion object {
        private const val REQ_POST_NOTIFICATIONS = 4109
        private const val REQ_PICK_PROFILE_PHOTO = 4110
    }

    private var adzanChannel: MethodChannel? = null
    private var pendingNotifResult: MethodChannel.Result? = null
    private var pendingPhotoResult: MethodChannel.Result? = null

    private val alarmObserver: (ActiveAlarmInfo?) -> Unit = { info ->
        try {
            adzanChannel?.invokeMethod("onAlarmStateChanged", info?.toMap())
        } catch (_: Exception) {
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AdzanAlarmReceiver.ensureChannel(applicationContext)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "id.moeslim.moeslim_mobile/geomagnetic"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getDeclination") {
                val lat = (call.argument<Number>("latitude") ?: 0.0).toFloat()
                val lon = (call.argument<Number>("longitude") ?: 0.0).toFloat()
                val alt = (call.argument<Number>("altitude") ?: 0.0).toFloat()
                val timeMs = (call.argument<Number>("timestampMs") ?: System.currentTimeMillis()).toLong()
                val field = GeomagneticField(lat, lon, alt, timeMs)
                result.success(field.declination.toDouble())
            } else {
                result.notImplemented()
            }
        }

        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "id.moeslim.moeslim_mobile/adzan_alarm"
        )
        adzanChannel = channel
        AdzanAudioPlayer.addAlarmObserver(alarmObserver)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarms" -> {
                    val alarms = call.argument<List<Map<*, *>>>("alarms") ?: emptyList()
                    val assetPath = call.argument<String>("assetPath") ?: "assets/audio/adzan/makkah.mp3"
                    val muadzinName = call.argument<String>("muadzinName") ?: "Muadzin"
                    val themeMode = call.argument<String>("themeMode") ?: "light"
                    val language = call.argument<String>("language") ?: "id"
                    val adzanVolume = (call.argument<Number>("adzanVolume")?.toFloat()
                        ?: AdzanAlarmReceiver.savedAdzanVolume(applicationContext)).coerceIn(0f, 1f)
                    val overrideDeviceVolume = call.argument<Boolean>("overrideDeviceVolume")
                        ?: AdzanAlarmReceiver.savedOverrideDeviceVolume(applicationContext)
                    AdzanAlarmReceiver.scheduleAlarms(
                        applicationContext,
                        alarms,
                        assetPath,
                        muadzinName,
                        themeMode = themeMode,
                        language = language,
                        adzanVolume = adzanVolume,
                        overrideDeviceVolume = overrideDeviceVolume
                    )
                    result.success(true)
                }
                "cancelAllAlarms" -> {
                    val themeMode = call.argument<String>("themeMode")
                    val language = call.argument<String>("language")
                    val adzanVolume = call.argument<Number>("adzanVolume")?.toFloat()
                    val overrideDeviceVolume = call.argument<Boolean>("overrideDeviceVolume")
                    AdzanAlarmReceiver.saveUiPreferences(applicationContext, themeMode, language)
                    AdzanAlarmReceiver.saveAudioPreferences(applicationContext, adzanVolume, overrideDeviceVolume)
                    AdzanAlarmReceiver.cancelAll(applicationContext)
                    result.success(true)
                }
                "playAdzan" -> {
                    val assetPath = call.argument<String>("assetPath") ?: "assets/audio/adzan/makkah.mp3"
                    val isPreview = call.argument<Boolean>("isPreview") ?: false
                    val themeMode = call.argument<String>("themeMode")
                        ?: AdzanAlarmReceiver.savedThemeMode(applicationContext)
                    val language = call.argument<String>("language")
                        ?: AdzanAlarmReceiver.savedLanguage(applicationContext)
                    val adzanVolume = (call.argument<Number>("adzanVolume")?.toFloat()
                        ?: AdzanAlarmReceiver.savedAdzanVolume(applicationContext)).coerceIn(0f, 1f)
                    val overrideDeviceVolume = call.argument<Boolean>("overrideDeviceVolume")
                        ?: AdzanAlarmReceiver.savedOverrideDeviceVolume(applicationContext)
                    AdzanAlarmReceiver.saveUiPreferences(applicationContext, themeMode, language)
                    AdzanAlarmReceiver.saveAudioPreferences(applicationContext, adzanVolume, overrideDeviceVolume)
                    val alarmInfo = if (!isPreview) {
                        ActiveAlarmInfo(
                            prayer = call.argument<String>("prayer") ?: "fajr",
                            prayerLabel = call.argument<String>("prayerLabel") ?: "Salat",
                            localTime = call.argument<String>("localTime") ?: "",
                            locationName = call.argument<String>("locationName") ?: "",
                            muadzinName = call.argument<String>("muadzinName") ?: "Muadzin",
                            isFajr = call.argument<Boolean>("isFajr") ?: false,
                            themeMode = themeMode,
                            language = language,
                            adzanVolume = adzanVolume,
                            overrideDeviceVolume = overrideDeviceVolume
                        )
                    } else {
                        null
                    }
                    val ok = AdzanAudioPlayer.playAsset(
                        applicationContext,
                        assetPath,
                        isPreview = isPreview,
                        alarmInfo = alarmInfo,
                        volume = adzanVolume,
                        overrideDeviceVolume = overrideDeviceVolume,
                        onComplete = {
                            try {
                                channel.invokeMethod("onPlaybackCompleted", null)
                            } catch (_: Exception) {
                            }
                        }
                    )
                    result.success(ok)
                }
                "setAdzanVolume" -> {
                    val adzanVolume = (call.argument<Number>("adzanVolume")?.toFloat()
                        ?: AdzanAlarmReceiver.savedAdzanVolume(applicationContext)).coerceIn(0f, 1f)
                    val overrideDeviceVolume = call.argument<Boolean>("overrideDeviceVolume")
                        ?: AdzanAlarmReceiver.savedOverrideDeviceVolume(applicationContext)
                    AdzanAudioPlayer.setLiveVolume(applicationContext, adzanVolume, overrideDeviceVolume)
                    result.success(true)
                }
                "stopAdzan" -> {
                    AdzanAudioPlayer.stop(applicationContext)
                    result.success(true)
                }
                "getActiveAlarm" -> {
                    if (AdzanAudioPlayer.isActivelyPlaying()) {
                        result.success(AdzanAudioPlayer.activeAlarm?.toMap())
                    } else {
                        AdzanAudioPlayer.stop(applicationContext)
                        result.success(null)
                    }
                }
                "checkNotificationStatus" -> {
                    result.success(notificationStatusMap())
                }
                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                        result.success(notificationStatusMap())
                    } else if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) {
                        result.success(notificationStatusMap())
                    } else {
                        pendingNotifResult?.success(notificationStatusMap())
                        pendingNotifResult = result
                        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQ_POST_NOTIFICATIONS)
                    }
                }
                "openNotificationSettings" -> {
                    val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                            putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        }
                    } else {
                        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.fromParts("package", packageName, null)
                        }
                    }
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "id.moeslim.moeslim_mobile/profile_photo"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickFromGallery" -> {
                    pendingPhotoResult?.success(null)
                    pendingPhotoResult = result
                    try {
                        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            Intent(MediaStore.ACTION_PICK_IMAGES).apply {
                                type = "image/*"
                            }
                        } else {
                            Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                                addCategory(Intent.CATEGORY_OPENABLE)
                                type = "image/*"
                            }
                        }
                        @Suppress("DEPRECATION")
                        startActivityForResult(intent, REQ_PICK_PROFILE_PHOTO)
                    } catch (e: Exception) {
                        pendingPhotoResult = null
                        result.error("picker_error", e.message ?: "Gagal membuka galeri.", null)
                    }
                }
                "deletePhoto" -> {
                    val path = call.argument<String>("path")
                    try {
                        if (!path.isNullOrBlank()) {
                            val f = File(path)
                            if (f.exists() && f.parentFile?.canonicalPath == filesDir.canonicalPath) {
                                f.delete()
                            }
                        }
                        result.success(true)
                    } catch (_: Exception) {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        AdzanAudioPlayer.removeAlarmObserver(alarmObserver)
        adzanChannel = null
        super.onDestroy()
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQ_PICK_PROFILE_PHOTO) {
            val callback = pendingPhotoResult
            pendingPhotoResult = null
            if (resultCode != Activity.RESULT_OK || data?.data == null) {
                callback?.success(null)
                return
            }
            val uri = data.data!!
            Thread {
                val saved = saveLocalAvatarFromUri(uri)
                runOnUiThread {
                    if (saved != null) {
                        callback?.success(saved)
                    } else {
                        callback?.error("decode_failed", "Gagal membaca berkas gambar.", null)
                    }
                }
            }.start()
        }
    }

    private fun saveLocalAvatarFromUri(uri: Uri): String? {
        return try {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            contentResolver.openInputStream(uri)?.use { BitmapFactory.decodeStream(it, null, bounds) }
            if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null

            val maxSide = 512
            var sampleSize = 1
            while (max(bounds.outWidth / sampleSize, bounds.outHeight / sampleSize) > maxSide * 2) {
                sampleSize *= 2
            }
            val decodeOpts = BitmapFactory.Options().apply { inSampleSize = sampleSize }
            val decoded = contentResolver.openInputStream(uri)?.use {
                BitmapFactory.decodeStream(it, null, decodeOpts)
            } ?: return null

            val oriented = applyExifRotation(uri, decoded)
            if (oriented !== decoded) decoded.recycle()

            val scale = maxSide.toFloat() / max(oriented.width, oriented.height).toFloat()
            val finalBitmap = if (scale < 1f) {
                val w = max(1, (oriented.width * scale).toInt())
                val h = max(1, (oriented.height * scale).toInt())
                Bitmap.createScaledBitmap(oriented, w, h, true).also {
                    if (it !== oriented) oriented.recycle()
                }
            } else {
                oriented
            }

            // Hapus avatar lama agar tidak menumpuk di penyimpanan lokal aplikasi.
            filesDir.listFiles()?.forEach { old ->
                if (old.isFile && old.name.startsWith("profile_avatar_") && old.name.endsWith(".jpg")) {
                    old.delete()
                }
            }

            val outFile = File(filesDir, "profile_avatar_${System.currentTimeMillis()}.jpg")
            FileOutputStream(outFile).use { fos ->
                finalBitmap.compress(Bitmap.CompressFormat.JPEG, 88, fos)
            }
            finalBitmap.recycle()
            outFile.absolutePath
        } catch (_: Exception) {
            null
        }
    }

    private fun applyExifRotation(uri: Uri, src: Bitmap): Bitmap {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return src
        return try {
            val orientation = contentResolver.openInputStream(uri)?.use { stream ->
                ExifInterface(stream).getAttributeInt(
                    ExifInterface.TAG_ORIENTATION,
                    ExifInterface.ORIENTATION_NORMAL
                )
            } ?: ExifInterface.ORIENTATION_NORMAL

            val matrix = Matrix()
            when (orientation) {
                ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
                ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
                ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
                ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.preScale(-1f, 1f)
                ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.preScale(1f, -1f)
                else -> return src
            }
            Bitmap.createBitmap(src, 0, 0, src.width, src.height, matrix, true)
        } catch (_: Exception) {
            src
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQ_POST_NOTIFICATIONS) {
            pendingNotifResult?.success(notificationStatusMap())
            pendingNotifResult = null
        }
    }

    private fun notificationStatusMap(): Map<String, Any> {
        val nm = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        val runtimeGranted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
        val notificationsEnabled = nm?.areNotificationsEnabled() ?: true
        val fullScreenAllowed = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            nm?.canUseFullScreenIntent() ?: true
        } else {
            true
        }
        return mapOf(
            "granted" to (runtimeGranted && notificationsEnabled),
            "runtimeGranted" to runtimeGranted,
            "fullScreenAllowed" to fullScreenAllowed
        )
    }
}
