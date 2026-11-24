package id.moeslim.moeslim_mobile

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
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
import java.util.concurrent.atomic.AtomicLong
import kotlin.math.ceil

data class ActiveAlarmInfo(
    val prayer: String,
    val prayerLabel: String,
    val localTime: String,
    val locationName: String,
    val muadzinName: String,
    val isFajr: Boolean,
    val themeMode: String = "light",
    val language: String = "id",
    val adzanVolume: Float = 0.85f,
    val overrideDeviceVolume: Boolean = true,
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
        "adzanVolume" to adzanVolume.toDouble(),
        "overrideDeviceVolume" to overrideDeviceVolume,
        "startedAtMs" to startedAtMs
    )
}

object AdzanAudioPlayer {
    private var mediaPlayer: MediaPlayer? = null
    private var audioManager: AudioManager? = null
    private var focusRequest: AudioFocusRequest? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var lastAppContext: Context? = null
    private var savedAlarmStreamVolume: Int? = null
    private var currentStreamType: Int = AudioManager.STREAM_ALARM
    private var completionGuard: Runnable? = null
    private val playGeneration = AtomicLong(0L)
    private val mainHandler = Handler(Looper.getMainLooper())
    private val alarmObservers = CopyOnWriteArraySet<(ActiveAlarmInfo?) -> Unit>()

    @Volatile
    var activeAlarm: ActiveAlarmInfo? = null
        private set

    fun isActivelyPlaying(): Boolean {
        val mp = mediaPlayer
        if (mp != null) {
            return try {
                mp.isPlaying
            } catch (_: Exception) {
                false
            }
        }
        return activeAlarm != null
    }

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

    private fun applyVolume(
        am: AudioManager?,
        mp: MediaPlayer?,
        volume: Float,
        overrideDeviceVolume: Boolean
    ) {
        val clamped = volume.coerceIn(0f, 1f)
        if (clamped <= 0.001f) {
            try {
                mp?.setVolume(0f, 0f)
            } catch (_: Exception) {
            }
            return
        }

        if (overrideDeviceVolume && am != null && currentStreamType == AudioManager.STREAM_ALARM) {
            try {
                val maxVol = am.getStreamMaxVolume(AudioManager.STREAM_ALARM).coerceAtLeast(1)
                if (savedAlarmStreamVolume == null) {
                    savedAlarmStreamVolume = am.getStreamVolume(AudioManager.STREAM_ALARM)
                }
                val targetStep = ceil(clamped * maxVol).toInt().coerceIn(1, maxVol)
                am.setStreamVolume(AudioManager.STREAM_ALARM, targetStep, 0)
                val stepFraction = targetStep.toFloat() / maxVol.toFloat()
                val fineGain = (clamped / stepFraction).coerceIn(0f, 1f)
                mp?.setVolume(fineGain, fineGain)
                return
            } catch (_: SecurityException) {
                // Jika perangkat sedang mengunci perubahan volume via DND ketat, lanjutkan lewat gain MediaPlayer.
            } catch (_: Exception) {
            }
        }

        try {
            mp?.setVolume(clamped, clamped)
        } catch (_: Exception) {
        }
    }

    private fun restoreDeviceAlarmVolume() {
        val prev = savedAlarmStreamVolume ?: return
        savedAlarmStreamVolume = null
        val am = audioManager ?: return
        try {
            am.setStreamVolume(AudioManager.STREAM_ALARM, prev, 0)
        } catch (_: Exception) {
        }
    }

    fun setLiveVolume(context: Context, volume: Float, overrideDeviceVolume: Boolean) {
        AdzanAlarmReceiver.saveAudioPreferences(context, volume, overrideDeviceVolume)
        val mp = mediaPlayer ?: return
        val am = audioManager ?: (context.applicationContext.getSystemService(Context.AUDIO_SERVICE) as? AudioManager)
        if (!overrideDeviceVolume) {
            restoreDeviceAlarmVolume()
        }
        applyVolume(am, mp, volume, overrideDeviceVolume)
    }

    fun playAsset(
        context: Context,
        assetPath: String,
        isPreview: Boolean = false,
        alarmInfo: ActiveAlarmInfo? = null,
        volume: Float = AdzanAlarmReceiver.savedAdzanVolume(context),
        overrideDeviceVolume: Boolean = AdzanAlarmReceiver.savedOverrideDeviceVolume(context),
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
            val remainingMs = try {
                val mp = mediaPlayer
                if (mp != null && mp.duration > mp.currentPosition) {
                    (mp.duration - mp.currentPosition).toLong() + 2_000L
                } else {
                    180_000L
                }
            } catch (_: Exception) {
                180_000L
            }
            AdzanAlarmReceiver.showRingingNotification(appContext, current, timeoutAfterMs = remainingMs)
            notifyObservers(current)
            return true
        }

        stop(appContext)
        val token = playGeneration.incrementAndGet()
        val safeVol = volume.coerceIn(0f, 1f)

        // Bila volume adzan di aplikasi sengaja dibisukan (0%) saat alarm tiba:
        // tampilkan notifikasi visual singkat lalu otomatis hilang tanpa suara.
        if (!isPreview && alarmInfo != null && safeVol <= 0.001f) {
            activeAlarm = alarmInfo
            val silentTimeoutMs = 20_000L
            AdzanAlarmReceiver.showRingingNotification(appContext, alarmInfo, timeoutAfterMs = silentTimeoutMs)
            notifyObservers(alarmInfo)
            val guard = Runnable {
                if (playGeneration.get() == token) {
                    stop(appContext)
                    onComplete?.invoke()
                }
            }
            completionGuard = guard
            mainHandler.postDelayed(guard, silentTimeoutMs)
            return true
        }
        if (isPreview && safeVol <= 0.001f) {
            if (onComplete != null) mainHandler.post { onComplete() }
            return true
        }

        val am = appContext.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
        audioManager = am

        // Mode mandiri (default): pakai USAGE_ALARM agar suara adzan & pratinjau memakai pengaturan volume
        // aplikasi sendiri dan tidak mengikuti mode hening / dering HP pengguna.
        // Bila dimatikan: ikuti aturan suara HP (USAGE_NOTIFICATION untuk alarm, USAGE_MEDIA untuk pratinjau).
        val useAlarmStream = overrideDeviceVolume
        val usage = when {
            useAlarmStream -> AudioAttributes.USAGE_ALARM
            isPreview -> AudioAttributes.USAGE_MEDIA
            else -> AudioAttributes.USAGE_NOTIFICATION
        }
        currentStreamType = when {
            useAlarmStream -> AudioManager.STREAM_ALARM
            isPreview -> AudioManager.STREAM_MUSIC
            else -> AudioManager.STREAM_NOTIFICATION
        }

        val attrs = AudioAttributes.Builder()
            .setUsage(usage)
            .setContentType(if (isPreview) AudioAttributes.CONTENT_TYPE_SPEECH else AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        requestAudioFocus(am, attrs, currentStreamType)

        return try {
            val mp = MediaPlayer()
            mp.setAudioAttributes(attrs)

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
                if (playGeneration.get() == token) {
                    stop(appContext)
                    if (onComplete != null) {
                        mainHandler.post { onComplete() }
                    }
                }
            }
            mp.setOnErrorListener { _, _, _ ->
                if (playGeneration.get() == token) {
                    stop(appContext)
                    if (onComplete != null) {
                        mainHandler.post { onComplete() }
                    }
                }
                true
            }

            mp.prepare()
            val durationMs = mp.duration.toLong().takeIf { it > 0L } ?: (4 * 60 * 1000L)

            if (!isPreview) {
                try {
                    val pm = appContext.getSystemService(Context.POWER_SERVICE) as? PowerManager
                    wakeLock = pm?.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "moeslim:adzan_alarm")?.apply {
                        setReferenceCounted(false)
                        acquire(durationMs + 10_000L)
                    }
                } catch (_: Exception) {
                }
            }

            applyVolume(am, mp, safeVol, overrideDeviceVolume)
            mp.start()
            mediaPlayer = mp

            // Penjaga cadangan bila OnCompletionListener tertunda pada sebagian perangkat Android/OEM.
            val guard = Runnable {
                if (playGeneration.get() == token) {
                    stop(appContext)
                    onComplete?.invoke()
                }
            }
            completionGuard = guard
            mainHandler.postDelayed(guard, durationMs + 1_500L)

            if (!isPreview && alarmInfo != null) {
                activeAlarm = alarmInfo
                AdzanAlarmReceiver.showRingingNotification(
                    appContext,
                    alarmInfo,
                    timeoutAfterMs = durationMs + 2_000L
                )
                notifyObservers(alarmInfo)
            }
            true
        } catch (_: Exception) {
            stop(appContext)
            false
        }
    }

    @Suppress("DEPRECATION")
    private fun requestAudioFocus(am: AudioManager?, attrs: AudioAttributes, streamType: Int) {
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
                am.requestAudioFocus(null, streamType, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
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
        playGeneration.incrementAndGet()
        completionGuard?.let { mainHandler.removeCallbacks(it) }
        completionGuard = null
        val hadActive = activeAlarm != null
        val hadPlayer = mediaPlayer != null
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
            restoreDeviceAlarmVolume()
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
            if (hadActive || hadPlayer) {
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
        private const val KEY_ADZAN_VOLUME = "adzan_volume"
        private const val KEY_OVERRIDE_DEVICE_VOLUME = "override_device_volume"
        private val PRAYER_IDS = intArrayOf(100, 101, 102, 103, 104)

        fun saveUiPreferences(context: Context, themeMode: String?, language: String?) {
            val prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().apply {
                if (!themeMode.isNullOrBlank()) putString(KEY_THEME_MODE, themeMode)
                if (!language.isNullOrBlank()) putString(KEY_LANGUAGE, language)
            }.apply()
        }

        fun saveAudioPreferences(context: Context, adzanVolume: Float?, overrideDeviceVolume: Boolean?) {
            val prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().apply {
                if (adzanVolume != null) putFloat(KEY_ADZAN_VOLUME, adzanVolume.coerceIn(0f, 1f))
                if (overrideDeviceVolume != null) putBoolean(KEY_OVERRIDE_DEVICE_VOLUME, overrideDeviceVolume)
            }.apply()
        }

        fun savedThemeMode(context: Context): String =
            context.applicationContext
                .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getString(KEY_THEME_MODE, "light") ?: "light"

        fun savedLanguage(context: Context): String =
            context.applicationContext
                .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getString(KEY_LANGUAGE, "id") ?: "id"

        fun savedAdzanVolume(context: Context): Float =
            context.applicationContext
                .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getFloat(KEY_ADZAN_VOLUME, 0.85f)
                .coerceIn(0f, 1f)

        fun savedOverrideDeviceVolume(context: Context): Boolean =
            context.applicationContext
                .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getBoolean(KEY_OVERRIDE_DEVICE_VOLUME, true)

        data class AdzanThemePalette(
            val isDark: Boolean,
            val bgColor: Int,
            val cardColor: Int,
            val borderColor: Int,
            val accentColor: Int,
            val titleColor: Int,
            val subtitleColor: Int,
            val calloutColor: Int,
            val stopBgColor: Int,
            val stopTextColor: Int,
            val secondaryStrokeColor: Int,
            val secondaryTextColor: Int
        )

        fun isDarkTheme(context: Context, themeMode: String? = null): Boolean {
            val mode = themeMode?.takeIf { it.isNotBlank() } ?: savedThemeMode(context)
            return mode == "dark" || mode == "layl"
        }

        fun themePalette(context: Context, themeMode: String? = null): AdzanThemePalette {
            val mode = themeMode?.takeIf { it.isNotBlank() } ?: savedThemeMode(context)
            return when (mode) {
                "dark" -> AdzanThemePalette(
                    isDark = true,
                    bgColor = Color.parseColor("#041F1A"),
                    cardColor = Color.parseColor("#0A2E27"),
                    borderColor = Color.parseColor("#D9AB36"),
                    accentColor = Color.parseColor("#5FD1AE"),
                    titleColor = Color.parseColor("#F7F7F1"),
                    subtitleColor = Color.parseColor("#DCE6E3"),
                    calloutColor = Color.parseColor("#D9AB36"),
                    stopBgColor = Color.parseColor("#D9AB36"),
                    stopTextColor = Color.parseColor("#07372F"),
                    secondaryStrokeColor = Color.parseColor("#5FD1AE"),
                    secondaryTextColor = Color.parseColor("#F7F7F1")
                )
                "layl" -> AdzanThemePalette(
                    isDark = true,
                    bgColor = Color.parseColor("#0A1930"),
                    cardColor = Color.parseColor("#13284A"),
                    borderColor = Color.parseColor("#E5B852"),
                    accentColor = Color.parseColor("#8FC2FA"),
                    titleColor = Color.parseColor("#EEF4FC"),
                    subtitleColor = Color.parseColor("#C5DAF5"),
                    calloutColor = Color.parseColor("#E5B852"),
                    stopBgColor = Color.parseColor("#E5B852"),
                    stopTextColor = Color.parseColor("#081B38"),
                    secondaryStrokeColor = Color.parseColor("#8FC2FA"),
                    secondaryTextColor = Color.parseColor("#EEF4FC")
                )
                "nature" -> lightPalette("#EDF6EA", "#FAFFF7", "#266D2A", "#14351A", "#35543A")
                "sky" -> lightPalette("#EAF4FC", "#F9FCFF", "#1462B2", "#0E2C4D", "#365472")
                "twilight" -> lightPalette("#F4EEFA", "#FDFBFF", "#674299", "#2A1B47", "#53426E")
                "sahara" -> lightPalette("#FAF2E6", "#FFFDF8", "#845727", "#3A240E", "#62472B")
                "sakina" -> lightPalette("#F4F0FA", "#FCFAFF", "#6A4C9E", "#2B1B49", "#544370")
                "zamrud" -> lightPalette("#E5F5F3", "#F6FFFE", "#0D6B6A", "#0A3638", "#355C5E")
                "rosa" -> lightPalette("#FDF0F4", "#FFF9FB", "#A83E61", "#471828", "#6C3B4C")
                else -> lightPalette("#F7F7F1", "#FFFFFF", "#087E65", "#07372F", "#4B5B57")
            }
        }

        private fun lightPalette(
            bgHex: String,
            cardHex: String,
            primaryHex: String,
            titleHex: String,
            subtitleHex: String
        ): AdzanThemePalette {
            val primary = Color.parseColor(primaryHex)
            return AdzanThemePalette(
                isDark = false,
                bgColor = Color.parseColor(bgHex),
                cardColor = Color.parseColor(cardHex),
                borderColor = Color.argb(95, Color.red(primary), Color.green(primary), Color.blue(primary)),
                accentColor = primary,
                titleColor = Color.parseColor(titleHex),
                subtitleColor = Color.parseColor(subtitleHex),
                calloutColor = Color.parseColor("#8A6A14"),
                stopBgColor = primary,
                stopTextColor = Color.WHITE,
                secondaryStrokeColor = primary,
                secondaryTextColor = primary
            )
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
        fun showRingingNotification(
            context: Context,
            info: ActiveAlarmInfo,
            timeoutAfterMs: Long = 4 * 60 * 1000L
        ) {
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
            val accentColor = themePalette(context, info.themeMode).accentColor

            val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(context, CHANNEL_ID)
                    .setTimeoutAfter(timeoutAfterMs.coerceAtLeast(5_000L))
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
                .setOngoing(false)
                .setAutoCancel(true)
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
            themeMode: String = "light",
            language: String = "id",
            adzanVolume: Float = 0.85f,
            overrideDeviceVolume: Boolean = true
        ) {
            saveUiPreferences(context, themeMode, language)
            saveAudioPreferences(context, adzanVolume, overrideDeviceVolume)
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
                    putExtra("adzanVolume", adzanVolume.coerceIn(0f, 1f))
                    putExtra("overrideDeviceVolume", overrideDeviceVolume)
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

        val volume = if (intent.hasExtra("adzanVolume")) {
            intent.getFloatExtra("adzanVolume", savedAdzanVolume(context))
        } else {
            savedAdzanVolume(context)
        }
        val overrideDevice = if (intent.hasExtra("overrideDeviceVolume")) {
            intent.getBooleanExtra("overrideDeviceVolume", savedOverrideDeviceVolume(context))
        } else {
            savedOverrideDeviceVolume(context)
        }

        val info = ActiveAlarmInfo(
            prayer = intent.getStringExtra("prayer") ?: "fajr",
            prayerLabel = intent.getStringExtra("prayerLabel") ?: "Salat",
            localTime = intent.getStringExtra("localTime") ?: "",
            locationName = intent.getStringExtra("locationName") ?: "",
            muadzinName = intent.getStringExtra("muadzinName") ?: "Muadzin",
            isFajr = intent.getBooleanExtra("isFajr", false),
            themeMode = intent.getStringExtra("themeMode") ?: savedThemeMode(context),
            language = intent.getStringExtra("language") ?: savedLanguage(context),
            adzanVolume = volume,
            overrideDeviceVolume = overrideDevice
        )
        val assetPath = intent.getStringExtra("assetPath") ?: "assets/audio/adzan/makkah.mp3"

        // playAsset akan menampilkan notifikasi dengan timeout otomatis persis sesuai durasi adzan
        // dan menghapusnya segera saat adzan selesai.
        AdzanAudioPlayer.playAsset(
            context,
            assetPath,
            isPreview = false,
            alarmInfo = info,
            volume = volume,
            overrideDeviceVolume = overrideDevice
        )
    }
}
