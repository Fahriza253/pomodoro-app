package com.dpzstudio.pomodoro_app

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.provider.Settings
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FocusPlatformHandler(private val context: Context) :
        MethodChannel.MethodCallHandler, EventChannel.StreamHandler, DefaultLifecycleObserver {

    companion object {
        private const val METHOD_CHANNEL = "com.dpzstudio.pomodoro_app/focus"
        private const val EVENT_CHANNEL = "com.dpzstudio.pomodoro_app/focus_events"
    }

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    private val mainHandler = Handler(Looper.getMainLooper())
    private var pollRunnable: Runnable? = null

    private var monitoring = false
    private var mode: String = "loose"
    private var whitelist: List<String> = emptyList()
    private var thresholdMs: Long = 5000
    private var pollIntervalMs: Long = 2000

    private var violationStartedAtMs: Long? = null
    private var appInForeground = true
    private val ownPackage: String = context.packageName

    fun register(flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel?.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
        eventChannel?.setStreamHandler(this)

        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
    }

    fun dispose() {
        stopMonitoringInternal()
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        ProcessLifecycleOwner.get().lifecycle.removeObserver(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasUsageAccess" -> result.success(hasUsageAccess())
            "openUsageAccessSettings" -> {
                openUsageAccessSettings()
                result.success(null)
            }
            "startMonitoring" -> {
                val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                mode = args["mode"] as? String ?: "loose"
                @Suppress("UNCHECKED_CAST")
                whitelist = (args["whitelist"] as? List<String>) ?: emptyList()
                thresholdMs = (args["thresholdMs"] as? Number)?.toLong() ?: 5000
                pollIntervalMs = (args["pollIntervalMs"] as? Number)?.toLong() ?: 2000
                startMonitoringInternal()
                result.success(null)
            }
            "stopMonitoring" -> {
                stopMonitoringInternal()
                result.success(null)
            }
            "listInstalledApps" -> result.success(listInstalledApps())
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onStart(owner: LifecycleOwner) {
        appInForeground = true
        resetViolationAccumulator()
    }

    override fun onStop(owner: LifecycleOwner) {
        appInForeground = false
        if (monitoring && (mode == "strict" || mode == "whitelist")) {
            beginViolationIfNeeded(ownPackage)
        }
    }

    private fun startMonitoringInternal() {
        monitoring = true
        resetViolationAccumulator()
        scheduleNextPoll()
    }

    private fun stopMonitoringInternal() {
        monitoring = false
        cancelPoll()
        resetViolationAccumulator()
    }

    private fun scheduleNextPoll() {
        cancelPoll()
        if (!monitoring) return

        val runnable = Runnable {
            if (monitoring) {
                evaluateForegroundApp()
                scheduleNextPoll()
            }
        }
        pollRunnable = runnable
        mainHandler.postDelayed(runnable, pollIntervalMs)
    }

    private fun cancelPoll() {
        pollRunnable?.let { mainHandler.removeCallbacks(it) }
        pollRunnable = null
    }

    private fun evaluateForegroundApp() {
        if (!monitoring || mode == "loose") return
        if (!appInForeground) {
            // Own-app background handled via lifecycle (immediate).
            return
        }

        val foreground = queryForegroundPackage() ?: return
        if (foreground == ownPackage) {
            resetViolationAccumulator()
            return
        }

        if (mode == "whitelist" && whitelist.contains(foreground)) {
            resetViolationAccumulator()
            return
        }

        beginViolationIfNeeded(foreground)
    }

    private fun beginViolationIfNeeded(packageName: String) {
        val now = System.currentTimeMillis()
        if (violationStartedAtMs == null) {
            violationStartedAtMs = now
        }
        val elapsed = now - (violationStartedAtMs ?: now)
        if (elapsed >= thresholdMs) {
            emitViolation(packageName, now)
            resetViolationAccumulator()
        }
    }

    private fun resetViolationAccumulator() {
        violationStartedAtMs = null
    }

    private fun emitViolation(packageName: String, atMs: Long) {
        eventSink?.success(
                mapOf(
                        "type" to "violation",
                        "packageOrUrl" to packageName,
                        "atUtcMs" to atMs,
                ),
        )
    }

    private fun queryForegroundPackage(): String? {
        if (!hasUsageAccess()) return null
        val usageStatsManager =
                context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val end = System.currentTimeMillis()
        val begin = end - pollIntervalMs * 2
        val events = usageStatsManager.queryEvents(begin, end)
        val event = UsageEvents.Event()
        var lastPackage: String? = null
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            // MOVE_TO_FOREGROUND (API < 29) was replaced by ACTIVITY_RESUMED (API 29+).
            val isForeground =
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        event.eventType == UsageEvents.Event.ACTIVITY_RESUMED
                    } else {
                        @Suppress("DEPRECATION")
                        event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND
                    }
            if (isForeground) {
                lastPackage = event.packageName
            }
        }
        return lastPackage
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val modeCheck =
                appOps.checkOpNoThrow(
                        AppOpsManager.OPSTR_GET_USAGE_STATS,
                        Process.myUid(),
                        context.packageName,
                )
        return modeCheck == AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageAccessSettings() {
        val intent =
                Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
        context.startActivity(intent)
    }

    private fun listInstalledApps(): List<Map<String, String>> {
        val pm = context.packageManager
        // Play-safe visibility: only apps that advertise a MAIN/LAUNCHER activity.
        val launcher = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val resolveFlags =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PackageManager.MATCH_ALL
                } else {
                    0
                }
        @Suppress("DEPRECATION")
        val activities =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    pm.queryIntentActivities(
                            launcher,
                            PackageManager.ResolveInfoFlags.of(resolveFlags.toLong()),
                    )
                } else {
                    pm.queryIntentActivities(launcher, resolveFlags)
                }

        val seen = HashSet<String>()
        return activities
                .mapNotNull { resolve ->
                    val info = resolve.activityInfo?.applicationInfo ?: return@mapNotNull null
                    val packageName = info.packageName
                    if (packageName == ownPackage || !seen.add(packageName)) {
                        return@mapNotNull null
                    }
                    val label = pm.getApplicationLabel(info).toString()
                    mapOf(
                            "packageName" to packageName,
                            "label" to label,
                    )
                }
                .sortedBy { it["label"]?.lowercase() }
    }
}
