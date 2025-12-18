package com.example.fittrack

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class DateChangeReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return

        when (action) {
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> {
                Log.d("DateChangeReceiver", "Date/time change detected: $action")

                val prefs = context.getSharedPreferences(
                    "FlutterSharedPreferences",
                    Context.MODE_PRIVATE
                )

                prefs.edit()
                    .putBoolean("flutter.force_day_reset", true)
                    .apply()
            }
        }
    }
}