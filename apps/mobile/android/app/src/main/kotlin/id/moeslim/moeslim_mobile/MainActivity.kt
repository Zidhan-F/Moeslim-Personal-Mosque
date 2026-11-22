package id.moeslim.moeslim_mobile

import android.app.NotificationManager
import android.content.Context
import android.hardware.GeomagneticField
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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

        val adzanChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "id.moeslim.moeslim_mobile/adzan_alarm"
        )
        adzanChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarms" -> {
                    val alarms = call.argument<List<Map<*, *>>>("alarms") ?: emptyList()
                    val assetPath = call.argument<String>("assetPath") ?: "assets/audio/adzan/makkah.mp3"
                    val muadzinName = call.argument<String>("muadzinName") ?: "Muadzin"
                    AdzanAlarmReceiver.scheduleAlarms(applicationContext, alarms, assetPath, muadzinName)
                    result.success(true)
                }
                "cancelAllAlarms" -> {
                    AdzanAlarmReceiver.cancelAll(applicationContext)
                    result.success(true)
                }
                "playAdzan" -> {
                    val assetPath = call.argument<String>("assetPath") ?: "assets/audio/adzan/makkah.mp3"
                    val isPreview = call.argument<Boolean>("isPreview") ?: false
                    val ok = AdzanAudioPlayer.playAsset(
                        applicationContext,
                        assetPath,
                        isPreview = isPreview,
                        onComplete = {
                            try {
                                adzanChannel.invokeMethod("onPlaybackCompleted", null)
                            } catch (_: Exception) {
                            }
                        }
                    )
                    result.success(ok)
                }
                "stopAdzan" -> {
                    AdzanAudioPlayer.stop()
                    val nm = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                    nm?.cancel(AdzanAlarmReceiver.NOTIFICATION_ID)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
