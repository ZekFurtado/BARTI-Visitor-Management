package com.shrameco.visitor_management

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val BATTERY_OPTIMIZATION_REQUEST = 1001
    private val CHANNEL = "visitor_management/background"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Create notification channels for Android 8.0+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannels()
        }
        
        // Request battery optimization exemption
        requestBatteryOptimizationExemption()
        
        // Start background service
        startBackgroundService()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestBatteryOptimizationExemption" -> {
                    requestBatteryOptimizationExemption()
                    result.success(null)
                }
                "startBackgroundService" -> {
                    startBackgroundService()
                    result.success(null)
                }
                "isBatteryOptimizationDisabled" -> {
                    val isDisabled = isBatteryOptimizationDisabled()
                    result.success(isDisabled)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun createNotificationChannels() {
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        
        // Main notification channel
        val mainChannel = NotificationChannel(
            "visitor_management_channel",
            "Visitor Management",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Notifications for visitor management app"
            enableLights(true)
            enableVibration(true)
            setShowBadge(true)
        }
        
        // Background service channel
        val backgroundChannel = NotificationChannel(
            "visitor_management_background",
            "Background Service",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Keeps the app running in background for visitor notifications"
            setShowBadge(false)
        }
        
        notificationManager.createNotificationChannel(mainChannel)
        notificationManager.createNotificationChannel(backgroundChannel)
        
        Log.d("MainActivity", "Notification channels created")
    }
    
    private fun requestBatteryOptimizationExemption() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val powerManager = getSystemService(POWER_SERVICE) as PowerManager
                val packageName = packageName
                
                if (!powerManager.isIgnoringBatteryOptimizations(packageName)) {
                    Log.d("MainActivity", "Requesting battery optimization exemption")
                    val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                        data = Uri.parse("package:$packageName")
                    }
                    startActivityForResult(intent, BATTERY_OPTIMIZATION_REQUEST)
                } else {
                    Log.d("MainActivity", "Battery optimization already disabled")
                }
            } catch (e: Exception) {
                Log.e("MainActivity", "Failed to request battery optimization exemption", e)
            }
        }
    }
    
    private fun isBatteryOptimizationDisabled(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(POWER_SERVICE) as PowerManager
            powerManager.isIgnoringBatteryOptimizations(packageName)
        } else {
            true
        }
    }
    
    private fun startBackgroundService() {
        try {
            val serviceIntent = Intent(this, BackgroundService::class.java)
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
                Log.d("MainActivity", "Started foreground background service")
            } else {
                startService(serviceIntent)
                Log.d("MainActivity", "Started background service")
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Failed to start background service", e)
        }
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == BATTERY_OPTIMIZATION_REQUEST) {
            if (isBatteryOptimizationDisabled()) {
                Log.d("MainActivity", "Battery optimization exemption granted")
            } else {
                Log.w("MainActivity", "Battery optimization exemption denied")
            }
        }
    }
}
