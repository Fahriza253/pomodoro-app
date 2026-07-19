package com.dpzstudio.pomodoro_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var focusHandler: FocusPlatformHandler? = null
    private var batteryHandler: BatteryPlatformHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        focusHandler = FocusPlatformHandler(this).also { it.register(flutterEngine) }
        batteryHandler = BatteryPlatformHandler(this).also { it.register(flutterEngine) }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        focusHandler?.dispose()
        focusHandler = null
        batteryHandler?.dispose()
        batteryHandler = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
