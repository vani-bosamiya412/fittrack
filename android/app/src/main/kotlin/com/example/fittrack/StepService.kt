package com.example.fittrack

import android.app.*
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class StepService : Service(), SensorEventListener {

    private lateinit var sensorManager: SensorManager
    private var stepSensor: Sensor? = null

    override fun onCreate() {
        super.onCreate()

        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        stepSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)

        startStepTrackingNotification()

        stepSensor?.also {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
    }

    // SERVICE STAYS ALIVE WHEN APP IS REMOVED FROM RECENTS
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    // 🚀 ADD THIS EXACT METHOD HERE ↓↓↓
    override fun onTaskRemoved(rootIntent: Intent?) {
        val restartServiceIntent = Intent(applicationContext, StepService::class.java)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            applicationContext.startForegroundService(restartServiceIntent)
        } else {
            applicationContext.startService(restartServiceIntent)
        }

        super.onTaskRemoved(rootIntent)
    }
    // 🚀 END OF ADDED METHOD

    private fun startStepTrackingNotification() {
        val channelId = "step_tracking_channel"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Step Tracking",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("FitTrack")
            .setContentText("Tracking your steps…")
            .setSmallIcon(android.R.drawable.ic_media_play)
            .build()

        startForeground(1, notification)
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return

        val rawSteps = event.values[0].toInt()

        val prefs = getSharedPreferences("step_data", Context.MODE_PRIVATE)
        prefs.edit().putInt("raw_steps", rawSteps).apply()
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onBind(intent: Intent?): IBinder? = null
}