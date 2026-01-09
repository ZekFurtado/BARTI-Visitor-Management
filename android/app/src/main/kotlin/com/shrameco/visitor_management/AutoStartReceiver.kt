package com.shrameco.visitor_management

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class AutoStartReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AutoStartReceiver", "Received broadcast: ${intent.action}")
        
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON" -> {
                startBackgroundService(context)
            }
        }
    }
    
    private fun startBackgroundService(context: Context) {
        try {
            val serviceIntent = Intent(context, BackgroundService::class.java)
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
                Log.d("AutoStartReceiver", "Started foreground background service")
            } else {
                context.startService(serviceIntent)
                Log.d("AutoStartReceiver", "Started background service")
            }
        } catch (e: Exception) {
            Log.e("AutoStartReceiver", "Failed to start background service", e)
        }
    }
}