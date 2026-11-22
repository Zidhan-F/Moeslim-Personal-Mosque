package id.moeslim.moeslim_mobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import org.json.JSONObject

class MoeslimPrayerWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val rawJson = prefs.getString("flutter.home_widget_payload", null)
            val rawSettings = prefs.getString("flutter.settings", null)
            var isEn = false
            if (!rawSettings.isNullOrBlank()) {
                try {
                    isEn = JSONObject(rawSettings).optString("language", "id").equals("en", ignoreCase = true)
                } catch (_: Exception) {
                }
            }

            var nextPrayer = if (isEn) "Fajr" else "Subuh"
            var nextTime = "04:38"
            var location = "Jakarta"
            var hijri = if (isEn) "1447 AH" else "1447 H"
            var quote = if (isEn) {
                "Unquestionably, by the remembrance of Allah hearts are assured. (QS. Ar-Ra'd: 28)"
            } else {
                "Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram. (QS. Ar-Ra'd: 28)"
            }

            if (!rawJson.isNullOrBlank()) {
                try {
                    val obj = JSONObject(rawJson)
                    nextPrayer = obj.optString("lastSyncedNextPrayer", nextPrayer)
                    nextTime = obj.optString("lastSyncedNextTime", nextTime)
                    location = obj.optString("lastSyncedLocation", location)
                    hijri = obj.optString("lastSyncedHijri", hijri)
                    quote = obj.optString("lastSyncedQuote", quote)
                } catch (_: Exception) {
                }
            }

            val views = RemoteViews(context.packageName, R.layout.moeslim_prayer_widget)
            views.setTextViewText(R.id.widget_title, "Moeslim PM · $location")
            views.setTextViewText(R.id.widget_hijri, hijri)
            views.setTextViewText(R.id.widget_next_prayer, "$nextPrayer · $nextTime")
            views.setTextViewText(R.id.widget_quote, quote)

            val launchIntent = Intent(context, MainActivity::class.java)
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = PendingIntent.getActivity(context, 0, launchIntent, flags)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
