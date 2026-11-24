package id.moeslim.moeslim_mobile

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowInsetsController
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Layar pop-up alarm adzan saat waktu salat tiba (tampil di atas layar kunci / heads-up)
 * agar pengguna dapat langsung mematikan suara adzan dengan satu ketukan.
 * Tema otomatis mengikuti 10 pilihan tema tampilan aplikasi (default: Terang).
 */
class AdzanAlertActivity : Activity() {
    companion object {
        const val EXTRA_PRAYER_LABEL = "prayerLabel"
        const val EXTRA_LOCAL_TIME = "localTime"
        const val EXTRA_LOCATION_NAME = "locationName"
        const val EXTRA_MUADZIN_NAME = "muadzinName"
        const val EXTRA_IS_FAJR = "isFajr"
        const val EXTRA_THEME_MODE = "themeMode"
        const val EXTRA_LANGUAGE = "language"

        fun createIntent(context: Context, info: ActiveAlarmInfo): Intent =
            Intent(context, AdzanAlertActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra(EXTRA_PRAYER_LABEL, info.prayerLabel)
                putExtra(EXTRA_LOCAL_TIME, info.localTime)
                putExtra(EXTRA_LOCATION_NAME, info.locationName)
                putExtra(EXTRA_MUADZIN_NAME, info.muadzinName)
                putExtra(EXTRA_IS_FAJR, info.isFajr)
                putExtra(EXTRA_THEME_MODE, info.themeMode)
                putExtra(EXTRA_LANGUAGE, info.language)
            }
    }

    private val stopObserver: (ActiveAlarmInfo?) -> Unit = { active ->
        if (active == null && !isFinishing) {
            runOnUiThread { finish() }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableShowOverLockscreen()
        AdzanAudioPlayer.addAlarmObserver(stopObserver)
        renderContent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        renderContent(intent)
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        renderContent(intent)
    }

    override fun onResume() {
        super.onResume()
        if (!AdzanAudioPlayer.isActivelyPlaying() && !isFinishing) {
            AdzanAudioPlayer.stop(applicationContext)
            finish()
        }
    }

    override fun onDestroy() {
        AdzanAudioPlayer.removeAlarmObserver(stopObserver)
        super.onDestroy()
    }

    @Suppress("DEPRECATION")
    private fun enableShowOverLockscreen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val km = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
            km?.requestDismissKeyguard(this, null)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    @Suppress("DEPRECATION")
    private fun applySystemBarsTheme(isDark: Boolean, surfaceColor: Int) {
        window.statusBarColor = surfaceColor
        window.navigationBarColor = surfaceColor
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val controller = window.insetsController ?: return
            val mask = WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS or
                WindowInsetsController.APPEARANCE_LIGHT_NAVIGATION_BARS
            val appearance = if (isDark) 0 else mask
            controller.setSystemBarsAppearance(appearance, mask)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            var flags = window.decorView.systemUiVisibility
            flags = if (isDark) {
                flags and View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR.inv()
            } else {
                flags or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                flags = if (isDark) {
                    flags and View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR.inv()
                } else {
                    flags or View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR
                }
            }
            window.decorView.systemUiVisibility = flags
        }
    }

    private fun dp(v: Int): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v.toFloat(), resources.displayMetrics).toInt()

    private fun renderContent(source: Intent?) {
        val active = AdzanAudioPlayer.activeAlarm
        val prayerLabel = source?.getStringExtra(EXTRA_PRAYER_LABEL) ?: active?.prayerLabel ?: "Salat"
        val localTime = source?.getStringExtra(EXTRA_LOCAL_TIME) ?: active?.localTime ?: ""
        val locationName = source?.getStringExtra(EXTRA_LOCATION_NAME) ?: active?.locationName ?: ""
        val muadzinName = source?.getStringExtra(EXTRA_MUADZIN_NAME) ?: active?.muadzinName ?: "Muadzin"
        val isFajr = source?.getBooleanExtra(EXTRA_IS_FAJR, active?.isFajr ?: false) ?: false
        val themeMode = source?.getStringExtra(EXTRA_THEME_MODE)
            ?: active?.themeMode
            ?: AdzanAlarmReceiver.savedThemeMode(this)
        val language = source?.getStringExtra(EXTRA_LANGUAGE)
            ?: active?.language
            ?: AdzanAlarmReceiver.savedLanguage(this)

        val isEn = language == "en"
        val palette = AdzanAlarmReceiver.themePalette(this, themeMode)
        val isDark = palette.isDark

        val bgColor = palette.bgColor
        val cardColor = palette.cardColor
        val borderColor = palette.borderColor
        val overlineColor = if (isDark) palette.calloutColor else palette.accentColor
        val titleColor = palette.titleColor
        val subtitleColor = palette.subtitleColor
        val calloutColor = palette.calloutColor
        val muadzinColor = palette.subtitleColor
        val stopBgColor = palette.stopBgColor
        val stopTextColor = palette.stopTextColor
        val secondaryStrokeColor = palette.secondaryStrokeColor
        val secondaryTextColor = palette.secondaryTextColor

        applySystemBarsTheme(isDark, bgColor)

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(bgColor)
            setPadding(dp(24), dp(36), dp(24), dp(36))
        }

        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dp(24), dp(28), dp(24), dp(24))
            elevation = if (isDark) 0f else dp(6).toFloat()
            background = GradientDrawable().apply {
                setColor(cardColor)
                cornerRadius = dp(24).toFloat()
                setStroke(dp(2), borderColor)
            }
        }

        val overline = TextView(this).apply {
            text = if (isEn) "PRAYER TIME" else "WAKTU SALAT TIBA"
            setTextColor(overlineColor)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            typeface = Typeface.DEFAULT_BOLD
            letterSpacing = 0.14f
        }

        val title = TextView(this).apply {
            text = if (isEn) "Adhan Time: $prayerLabel" else "Waktu Adzan $prayerLabel"
            setTextColor(titleColor)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 26f)
            typeface = Typeface.DEFAULT_BOLD
            gravity = Gravity.CENTER
            setPadding(0, dp(10), 0, dp(6))
        }

        val metaParts = listOf(localTime, locationName).filter { it.isNotBlank() }
        val subtitle = TextView(this).apply {
            text = metaParts.joinToString(" • ")
            setTextColor(subtitleColor)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            gravity = Gravity.CENTER
        }

        val callout = TextView(this).apply {
            text = if (isFajr) "Ash-shalaatu khairum minan-nauum" else "Hayya 'alash-shalaah"
            setTextColor(calloutColor)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.ITALIC)
            gravity = Gravity.CENTER
            setPadding(0, dp(16), 0, dp(4))
        }

        val muadzin = TextView(this).apply {
            text = "Muadzin: $muadzinName"
            setTextColor(muadzinColor)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13.5f)
            gravity = Gravity.CENTER
            setPadding(0, 0, 0, dp(24))
        }

        val stopButton = Button(this).apply {
            text = if (isEn) "Stop Adhan" else "Matikan Adzan"
            isAllCaps = false
            setTextColor(stopTextColor)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(stopBgColor)
                cornerRadius = dp(28).toFloat()
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(54)
            )
            setOnClickListener {
                AdzanAudioPlayer.stop(applicationContext)
                finish()
            }
        }

        val openAppButton = Button(this).apply {
            text = if (isEn) "Open Moeslim PM" else "Buka Moeslim PM"
            isAllCaps = false
            setTextColor(secondaryTextColor)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14.5f)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                setColor(Color.TRANSPARENT)
                cornerRadius = dp(26).toFloat()
                setStroke(dp(1), secondaryStrokeColor)
            }
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(48)
            ).apply {
                topMargin = dp(12)
            }
            setOnClickListener {
                val mainIntent = Intent(this@AdzanAlertActivity, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                startActivity(mainIntent)
                finish()
            }
        }

        card.addView(overline)
        card.addView(title)
        if (metaParts.isNotEmpty()) card.addView(subtitle)
        card.addView(callout)
        card.addView(muadzin)
        card.addView(stopButton)
        card.addView(openAppButton)

        root.addView(
            card,
            LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        )
        setContentView(root)
    }
}
