package id.moeslim.moeslim_mobile

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import java.io.File
import java.util.concurrent.CopyOnWriteArraySet

data class ActiveAlarmInfo(
    val prayer: String,
    val prayerLabel: String,
    val localTime: String,
    val locationName: String,
    val muadzinName: String,
    val isFajr: Boolean,
    val themeMode: String = "system",
    val language: String = "id",
    val startedAtMs: Long = System.currentTimeMillis()
) {
    fun toMap(): Map<String, Any> = mapOf(
        "prayer" to prayer,
        "prayerLabel" to prayerLabel,
        "localTime" to localTime,
        "locationName" to locationName,
        "muadzinName" to muadzinName,
        "isFajr" to isFajr,
        "themeMode" to themeMode,
        "language" to language,
        "startedAtMs" to startedAtMs
    )
}

object AdzanAudioPlayer {
    private var mediaPlayer: MediaPlayer? = null
    private var audioManager: AudioManager? = null
    private var focusRequest: AudioFocusRequest? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var lastAppContext: Context? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private val alarmObservers = CopyOnWriteArraySet<(ActiveAlarmInfo?) -> Unit>()

    @Volatile
    var activeAlarm: ActiveAlarmInfo? = null
        private set

    fun addAlarmObserver(observer: (ActiveAlarmInfo?) -> Unit) {
        alarmObservers.add(observer)
    }

    fun removeAlarmObserver(observer: (ActiveAlarmInfo?) -> Unit) {
        alarmObservers.remove(observer)
    }

    private fun notifyObservers(info: ActiveAlarmInfo?) {
        mainHandler.post {
            for (obs in alarmObservers) {
                try {
                    obs(info)
                } catch (_: Exception) {
                }
            }
        }
    }

    fun playAsset(
        context: Context,
        assetPath: String,
        isPreview: Boolean = false,
        alarmInfo: ActiveAlarmInfo? = null,
        onComplete: (() -> Unit)? = null
    ): Boolean {
        val appContext = context.applicationContext
        lastAppContext = appContext

        // Hindari pemutaran ganda bila AlarmManager dan timer Flutter memicu slot waktu yang sama.
        val current = activeAlarm
        val isPlayingNow = try {
            mediaPlayer?.isPlaying == true
        } catch (_: Exception) {
            false
        }
        if (!isPreview && alarmInfo != null && current != null && isPlayingNow &&
            current.prayer == alarmInfo.prayer &&
            (System.currentTimeMillis() - current.startedAtMs) < 90_000L
        ) {
            AdzanAlarmReceiver.showRingingNotification(appContext, current)
            notifyObservers(current)
            return true
        }

        stop(appContext)
        val am = appContext.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
        audioManager = am

        val attrs = AudioAttributes.Builder()
            .setUsage(if (isPreview) AudioAttributes.USAGE_MEDIA else AudioAttributes.USAGE_ALARM)
            .setContentType(if (isPreview) AudioAttributes.CONTENT_TYPE_SPEECH else AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        requestAudioFocus(am, attrs, isPreview)

        if (!isPreview) {
            try {
                val pm = appContext.getSystemService(Context.POWER_SERVICE) as? PowerManager
                wakeLock = pm?.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "moeslim:adzan_alarm")?.apply {
                    setReferenceCounted(false)
                    acquire(4 * 60 * 1000L)
                }
            } catch (_: Exception) {
            }
        }

        return try {
            val mp = MediaPlayer()
            mp.setAudioAttributes(attrs)
            mp.setVolume(1.0f, 1.0f)

            val fullKey = "flutter_assets/$assetPath"
            var loaded = false
            try {
                val afd = appContext.assets.openFd(fullKey)
                mp.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                afd.close()
                loaded = true
            } catch (_: Exception) {
                // Fallback bila aset terkompresi (mis. pada distribusi App Bundle).
            }

            if (!loaded) {
                val tmp = File(appContext.cacheDir, "adzan_active_${assetPath.substringAfterLast('/')}")
                appContext.assets.open(fullKey).use { input ->
                    tmp.outputStream().use { output ->
                        input.copyTo(output)
                    }
                }
                mp.setDataSource(tmp.absolutePath)
            }

            mp.setOnCompletionListener {
                stop(appContext)
                if (onComplete != null) {
                    mainHandler.post { onComplete() }
                }
            }
            mp.setOnErrorListener { _, _, _ ->
                stop(appContext)
                if (onComplete != null) {
                    mainHandler.post { onComplete() }
                }
                true
            }
            mp.prepare()
            mp.start()
            mediaPlayer = mp
            if (!isPreview && alarmInfo != null) {
                activeAlarm = alarmInfo
                notifyObservers(alarmInfo)
            }
            true
        } catch (_: Exception) {
            stop(appContext)
            false
        }
    }

    @Suppress("DEPRECATION")
    private fun requestAudioFocus(am: AudioManager?, attrs: AudioAttributes, isPreview: Boolean) {
        if (am == null) return
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val req = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                    .setAudioAttributes(attrs)
                    .setAcceptsDelayedFocusGain(false)
                    .setOnAudioFocusChangeListener { change ->
                        if (change == AudioManager.AUDIOFOCUS_LOSS) {
                            stop(lastAppContext)
                        }
                    }
                    .build()
                focusRequest = req
                am.requestAudioFocus(req)
            } else {
                val stream = if (isPreview) AudioManager.STREAM_MUSIC else AudioManager.STREAM_ALARM
                am.requestAudioFocus(null, stream, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
            }
        } catch (_: Exception) {
        }
    }

    @Suppress("DEPRECATION")
    private fun abandonAudioFocus() {
        val am = audioManager ?: return
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                focusRequest?.let { am.abandonAudioFocusRequest(it) }
                focusRequest = null
            } else {
                am.abandonAudioFocus(null)
            }
        } catch (_: Exception) {
        }
    }

    fun stop(context: Context? = null) {
        val ctx = context?.applicationContext ?: lastAppContext
        val hadActive = activeAlarm != null
        activeAlarm = null
        try {
            mediaPlayer?.let {
                try {
                    if (it.isPlaying) it.stop()
                } catch (_: Exception) {
                }
                it.release()
            }
        } catch (_: Exception) {
        } finally {
            mediaPlayer = null
            abandonAudioFocus()
            try {
                if (wakeLock?.isHeld == true) wakeLock?.release()
            } catch (_: Exception) {
            }
            wakeLock = null
            if (ctx != null) {
                try {
                    val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                    nm?.cancel(AdzanAlarmReceiver.NOTIFICATION_ID)
                } catch (_: Exception) {
                }
            }
            if (hadActive) {
                notifyObservers(null)
            }
        }
    }
}

class AdzanAlarmReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_TRIGGER = "id.moeslim.moeslim_mobile.ACTION_ADZAN_ALARM"
        const val ACTION_STOP = "id.moeslim.moeslim_mobile.ACTION_STOP_ADZAN"
        private const val LEGACY_CHANNEL_ID = "moeslim_adzan_alarm_channel"
        const val CHANNEL_ID = "moeslim_adzan_alarm_v2"
        const val NOTIFICATION_ID = 4100
        private const val PREFS_NAME = "moeslim_adzan_prefs"
        private const val KEY_THEME_MODE = "theme_mode"
        private const val KEY_LANGUAGE = "language"
        private val PRAYER_IDS = intArrayOf(100, 101, 102, 103, 104)

        fun saveUiPreferences(context: Context, themeMode: String?, language: String?) {
            val prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().apply {
                if (!themeMode.isNullOrBlank()) putString(KEY_THEME_MODE, themeMode)
                if (!language.isNullOrBlank()) putString(KEY_LANGUAGE, language)
            }.apply()
        }

        fun savedThemeMode(context: Context): String =
            context.applicationContext
                .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getString(KEY_THEME_MODE, "system") ?: "system"

        fun savedLanguage(context: Context): String =
            context.applicationContext
                .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getString(KEY_LANGUAGE, "id") ?: "id"

        /**
         * Menentukan apakah pop-up adzan memakai tema gelap atau terang:
         * - "dark" -> gelap
         * - "light" -> terang
         * - "system" (default / auto) -> mengikuti mode Gelap/Terang sistem HP pengguna.
         */
        fun isDarkTheme(context: Context, themeMode: String? = null): Boolean {
            val mode = themeMode?.takeIf { it.isNotBlank() } ?: savedThemeMode(context)
            return when (mode) {
                "dark" -> true
                "light" -> false
                else -> {
                    val nightMask = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
                    nightMask == Configuration.UI_MODE_NIGHT_YES
                }
            }
        }

        fun ensureChannel(context: Context) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return
            try {
                nm.deleteNotificationChannel(LEGACY_CHANNEL_ID)
            } catch (_: Exception) {
            }
            if (nm.getNotificationChannel(CHANNEL_ID) != null) return
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Alarm Adzan Waktu Salat",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Pop-up notifikasi & tombol Matikan Adzan saat masuk waktu salat"
                enableVibration(true)
                setSound(null, null)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                setBypassDnd(true)
            }
            nm.createNotificationChannel(channel)
        }

        @Suppress("DEPRECATION")
        fun showRingingNotification(context: Context, info: ActiveAlarmInfo) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return
            ensureChannel(context)

            val alertIntent = AdzanAlertActivity.createIntent(context, info)
            val alertPi = PendingIntent.getActivity(
                context,
                4101,
                alertIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val stopIntent = Intent(context, AdzanAlarmReceiver::class.java).apply { action = ACTION_STOP }
            val stopPi = PendingIntent.getBroadcast(
                context,
                4102,
                stopIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val locSuffix = if (info.locationName.isNotEmpty()) " • ${info.locationName}" else ""
            val timePart = if (info.localTime.isNotEmpty()) " (${info.localTime}$locSuffix)" else locSuffix
            val fajrNote = if (info.isFajr) "Ash-shalaatu khairum minan-nauum • " else ""
            val isEn = info.language == "en"
            val dark = isDarkTheme(context, info.themeMode)
            val accentColor = Color.parseColor(if (dark) "#5FD1AE" else "#087E65")

            val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(context, CHANNEL_ID)
            } else {
                Notification.Builder(context)
                    .setPriority(Notification.PRIORITY_MAX)
                    .setDefaults(Notification.DEFAULT_VIBRATE)
            }

            val notificationTitle = if (isEn) {
                "Adhan Time: ${info.prayerLabel}$timePart"
            } else {
                "Waktu Adzan ${info.prayerLabel}$timePart"
            }
            val stopLabel = if (isEn) "Stop Adhan" else "Matikan Adzan"

            val notification = builder
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setColor(accentColor)
                .setContentTitle(notificationTitle)
                .setContentText("${fajrNote}Muadzin: ${info.muadzinName}")
                .setCategory(Notification.CATEGORY_ALARM)
                .setVisibility(Notification.VISIBILITY_PUBLIC)
                .setOngoing(true)
                .setAutoCancel(false)
                .setContentIntent(alertPi)
                .setFullScreenIntent(alertPi, true)
                .setDeleteIntent(stopPi)
                .addAction(
                    Notification.Action.Builder(
                        null,
                        stopLabel,
                        stopPi
                    ).build()
                )
                .build()

            try {
                nm.notify(NOTIFICATION_ID, notification)
            } catch (_: SecurityException) {
                // Izin POST_NOTIFICATIONS belum diberikan oleh pengguna.
            }
        }

        fun scheduleAlarms(
            context: Context,
            alarms: List<Map<*, *>>,
            defaultAssetPath: String,
            defaultMuadzinName: String,
            themeMode: String = "system",
            language: String = "id"
        ) {
            saveUiPreferences(context, themeMode, language)
            ensureChannel(context)
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
                    putExtra("prayer", item["prayer"] as? String ?: "fajr")
                    putExtra("prayerLabel", item["prayerLabel"] as? String ?: "Salat")
                    putExtra("localTime", item["localTime"] as? String ?: "")
                    putExtra("locationName", item["locationName"] as? String ?: "")
                    putExtra("isFajr", item["isFajr"] as? Boolean ?: false)
                    putExtra("muadzinName", defaultMuadzinName)
                    putExtra("assetPath", defaultAssetPath)
                    putExtra("themeMode", themeMode)
                    putExtra("language", item["language"] as? String ?: language)
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
        if (intent?.action == ACTION_STOP) {
            AdzanAudioPlayer.stop(context)
            return
        }
        if (intent?.action != ACTION_TRIGGER) return

        val info = ActiveAlarmInfo(
            prayer = intent.getStringExtra("prayer") ?: "fajr",
            prayerLabel = intent.getStringExtra("prayerLabel") ?: "Salat",
            localTime = intent.getStringExtra("localTime") ?: "",
            locationName = intent.getStringExtra("locationName") ?: "",
            muadzinName = intent.getStringExtra("muadzinName") ?: "Muadzin",
            isFajr = intent.getBooleanExtra("isFajr", false),
            themeMode = intent.getStringExtra("themeMode") ?: savedThemeMode(context),
            language = intent.getStringExtra("language") ?: savedLanguage(context)
        )
        val assetPath = intent.getStringExtra("assetPath") ?: "assets/audio/adzan/makkah.mp3"

        AdzanAudioPlayer.playAsset(context, assetPath, isPreview = false, alarmInfo = info)
        showRingingNotification(context, info)
    }
}
