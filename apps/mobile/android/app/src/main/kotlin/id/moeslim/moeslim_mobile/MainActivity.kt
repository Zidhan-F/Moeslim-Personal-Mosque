package id.moeslim.moeslim_mobile

import android.Manifest
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.GeomagneticField
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val REQ_POST_NOTIFICATIONS = 4109
    }

    private var adzanChannel: MethodChannel? = null
    private var pendingNotifResult: MethodChannel.Result? = null

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
                    val themeMode = call.argument<String>("themeMode") ?: "system"
                    val language = call.argument<String>("language") ?: "id"
                    AdzanAlarmReceiver.scheduleAlarms(
                        applicationContext,
                        alarms,
                        assetPath,
                        muadzinName,
                        themeMode = themeMode,
                        language = language
                    )
                    result.success(true)
                }
                "cancelAllAlarms" -> {
                    val themeMode = call.argument<String>("themeMode")
                    val language = call.argument<String>("language")
                    AdzanAlarmReceiver.saveUiPreferences(applicationContext, themeMode, language)
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
                    AdzanAlarmReceiver.saveUiPreferences(applicationContext, themeMode, language)
                    val alarmInfo = if (!isPreview) {
                        ActiveAlarmInfo(
                            prayer = call.argument<String>("prayer") ?: "fajr",
                            prayerLabel = call.argument<String>("prayerLabel") ?: "Salat",
                            localTime = call.argument<String>("localTime") ?: "",
                            locationName = call.argument<String>("locationName") ?: "",
                            muadzinName = call.argument<String>("muadzinName") ?: "Muadzin",
                            isFajr = call.argument<Boolean>("isFajr") ?: false,
                            themeMode = themeMode,
                            language = language
                        )
                    } else {
                        null
                    }
                    val ok = AdzanAudioPlayer.playAsset(
                        applicationContext,
                        assetPath,
                        isPreview = isPreview,
                        alarmInfo = alarmInfo,
                        onComplete = {
                            try {
                                channel.invokeMethod("onPlaybackCompleted", null)
                            } catch (_: Exception) {
                            }
                        }
                    )
                    if (ok && alarmInfo != null) {
                        AdzanAlarmReceiver.showRingingNotification(applicationContext, alarmInfo)
                    }
                    result.success(ok)
                }
                "stopAdzan" -> {
                    AdzanAudioPlayer.stop(applicationContext)
                    result.success(true)
                }
                "getActiveAlarm" -> {
                    result.success(AdzanAudioPlayer.activeAlarm?.toMap())
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
    }

    override fun onDestroy() {
        AdzanAudioPlayer.removeAlarmObserver(alarmObserver)
        adzanChannel = null
        super.onDestroy()
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
