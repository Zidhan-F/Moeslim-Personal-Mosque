package id.moeslim.moeslim_mobile

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Build

object AdzanAudioPlayer {
    private var mediaPlayer: MediaPlayer? = null

    fun playAsset(context: Context, assetPath: String): Boolean {
        stop()
        return try {
            val afd = context.assets.openFd("flutter_assets/$assetPath")
            val mp = MediaPlayer()
            mp.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            mp.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
            afd.close()
            mp.setOnCompletionListener { stop() }
            mp.prepare()
            mp.start()
            mediaPlayer = mp
            true
        } catch (_: Exception) {
            false
        }
    }

    fun stop() {
        try {
            mediaPlayer?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }
        } catch (_: Exception) {
        } finally {
            mediaPlayer = null
        }
    }
}

class AdzanAlarmReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_TRIGGER = "id.moeslim.moeslim_mobile.ACTION_ADZAN_ALARM"
        const val ACTION_STOP = "id.moeslim.moeslim_mobile.ACTION_STOP_ADZAN"
        const val CHANNEL_ID = "moeslim_adzan_alarm_channel"
        const val NOTIFICATION_ID = 4100
        private val PRAYER_IDS = intArrayOf(100, 101, 102, 103, 104)

        fun scheduleAlarms(context: Context, alarms: List<Map<*, *>>, defaultAssetPath: String, defaultMuadzinName: String) {
            cancelAll(context)
            val am = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            val nowMs = System.currentTimeMillis()
            for (item in alarms) {
                val id = (item["id"] as? Number)?.toInt() ?: continue
                val triggerAtMs = (item["triggerAtMs"] as? Number)?.toLong() ?: continue
                if (triggerAtMs <= nowMs) continue
                val intent = Intent(context, AdzanAlarmReceiver::class.java).apply {
                    action = ACTION_TRIGGER
                    putExtra("id", id)
                    putExtra("prayerLabel", item["prayerLabel"] as? String ?: "Salat")
                    putExtra("localTime", item["localTime"] as? String ?: "")
                    putExtra("locationName", item["locationName"] as? String ?: "")
                    putExtra("isFajr", item["isFajr"] as? Boolean ?: false)
                    putExtra("muadzinName", defaultMuadzinName)
                    putExtra("assetPath", defaultAssetPath)
                }
                val pi = PendingIntent.getBroadcast(
                    context,
                    id,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMs, pi)
                    } else {
                        am.setExact(AlarmManager.RTC_WAKEUP, triggerAtMs, pi)
                    }
                } catch (_: SecurityException) {
                    am.set(AlarmManager.RTC_WAKEUP, triggerAtMs, pi)
                }
            }
        }

        fun cancelAll(context: Context) {
            val am = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            for (id in PRAYER_IDS) {
                val intent = Intent(context, AdzanAlarmReceiver::class.java).apply { action = ACTION_TRIGGER }
                val pi = PendingIntent.getBroadcast(
                    context,
                    id,
                    intent,
                    PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
                )
                if (pi != null) {
                    am.cancel(pi)
                    pi.cancel()
                }
            }
        }
    }

    override fun onReceive(context: Context, intent: Intent?) {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        if (intent?.action == ACTION_STOP) {
            AdzanAudioPlayer.stop()
            nm?.cancel(NOTIFICATION_ID)
            return
        }
        if (intent?.action != ACTION_TRIGGER) return

        val prayerLabel = intent.getStringExtra("prayerLabel") ?: "Salat"
        val localTime = intent.getStringExtra("localTime") ?: ""
        val locationName = intent.getStringExtra("locationName") ?: ""
        val isFajr = intent.getBooleanExtra("isFajr", false)
        val muadzinName = intent.getStringExtra("muadzinName") ?: "Muadzin"
        val assetPath = intent.getStringExtra("assetPath") ?: "assets/audio/adzan/makkah.wav"

        AdzanAudioPlayer.playAsset(context, assetPath)

        if (nm != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Alarm Adzan Waktu Salat",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Peringatan suara adzan otomatis saat masuk waktu salat setempat"
                enableVibration(true)
            }
            nm.createNotificationChannel(channel)

            val openIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val contentPi = PendingIntent.getActivity(
                context,
                0,
                openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val stopIntent = Intent(context, AdzanAlarmReceiver::class.java).apply { action = ACTION_STOP }
            val stopPi = PendingIntent.getBroadcast(
                context,
                999,
                stopIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val locSuffix = if (locationName.isNotEmpty()) " • $locationName" else ""
            val fajrNote = if (isFajr) "Ash-shalaatu khairum minan-nauum • " else ""
            val notification = android.app.Notification.Builder(context, CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("Waktu Adzan $prayerLabel ($localTime$locSuffix)")
                .setContentText("${fajrNote}Muadzin: $muadzinName")
                .setContentIntent(contentPi)
                .setAutoCancel(true)
                .addAction(
                    android.app.Notification.Action.Builder(
                        null,
                        "Matikan Adzan",
                        stopPi
                    ).build()
                )
                .build()
            nm.notify(NOTIFICATION_ID, notification)
        }
    }
}
