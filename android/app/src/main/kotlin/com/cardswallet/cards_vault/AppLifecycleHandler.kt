package com.cardswallet.cards_vault

import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Tracks the whole app, including the native card scanner, rather than Flutter alone. */
class AppLifecycleHandler(
    private val application: Application,
    flutterEngine: FlutterEngine,
) : Application.ActivityLifecycleCallbacks, AutoCloseable {
    private val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "cards_wallet/app_lifecycle",
    )
    private val handler = Handler(Looper.getMainLooper())
    private val startedActivities = mutableSetOf<Activity>()
    private var foreground = true
    private val checkBackground = Runnable {
        if (startedActivities.isEmpty() && foreground) {
            foreground = false
            channel.invokeMethod("foregroundChanged", false)
        }
    }

    init {
        application.registerActivityLifecycleCallbacks(this)
    }

    override fun onActivityStarted(activity: Activity) {
        handler.removeCallbacks(checkBackground)
        startedActivities.add(activity)
        if (!foreground) {
            foreground = true
            channel.invokeMethod("foregroundChanged", true)
        }
    }

    override fun onActivityStopped(activity: Activity) {
        startedActivities.remove(activity)
        // Let a same-app activity handoff finish before reporting an exit.
        if (startedActivities.isEmpty()) handler.post(checkBackground)
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
    override fun onActivityResumed(activity: Activity) {}
    override fun onActivityPaused(activity: Activity) {}
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
    override fun onActivityDestroyed(activity: Activity) {}

    override fun close() {
        handler.removeCallbacks(checkBackground)
        application.unregisterActivityLifecycleCallbacks(this)
        startedActivities.clear()
    }
}
