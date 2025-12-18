package com.example.fittrack

import android.content.Intent
import android.os.Build
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "fittrack/step_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "startStepService" -> {
                    val intent = Intent(this, StepService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(true)
                }

                "getRawSteps" -> {
                    val prefs = getSharedPreferences("step_data", Context.MODE_PRIVATE)
                    val raw = prefs.getInt("raw_steps", 0)
                    result.success(raw)
                }

                else -> result.notImplemented()
            }
        }
    }
}