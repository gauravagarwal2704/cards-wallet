package com.cardswallet.cards_vault

import android.content.Context
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Reads public Material You resources, including the user's system palette style. */
class SystemPaletteHandler(private val context: Context) {
    private var channel: MethodChannel? = null

    fun register(engine: FlutterEngine) {
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, "cards_wallet/appearance").also {
            it.setMethodCallHandler { call, result ->
                if (call.method != "getSystemPalette") {
                    result.notImplemented()
                } else if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                    result.success(null)
                } else {
                    try {
                        result.success(readPalette())
                    } catch (error: Exception) {
                        result.error("palette_unavailable", "Device colors are unavailable.", null)
                    }
                }
            }
        }
    }

    @Suppress("DiscouragedApi")
    private fun color(name: String): Int? {
        val id = context.resources.getIdentifier(name, "color", "android")
        return if (id == 0) null else context.getColor(id)
    }

    private fun readPalette(): Map<String, Any> {
        val palette = mutableMapOf<String, Any>()
        val shades = listOf(0, 10, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000)
        for (name in listOf("accent1", "accent2", "accent3", "neutral1", "neutral2")) {
            palette[name] = shades.associate { shade ->
                // Android shade 0 is Material tone 100; shade 1000 is tone 0.
                (100 - shade / 10).toString() to
                    checkNotNull(color("system_${name}_$shade"))
            }
        }
        if (Build.VERSION.SDK_INT >= 34) {
            val roles = listOf(
                "primary", "on_primary", "primary_container", "on_primary_container",
                "secondary", "on_secondary", "secondary_container", "on_secondary_container",
                "tertiary", "on_tertiary", "tertiary_container", "on_tertiary_container",
                "surface", "on_surface", "surface_variant", "on_surface_variant",
                "outline", "outline_variant", "inverse_surface", "inverse_on_surface",
                "inverse_primary", "surface_dim", "surface_bright", "surface_container_lowest",
                "surface_container_low", "surface_container", "surface_container_high",
                "surface_container_highest", "error", "on_error", "error_container", "on_error_container"
            )
            for (mode in listOf("light", "dark")) {
                palette[mode] = roles.mapNotNull { role ->
                    color("system_${role}_$mode")?.let { role to it }
                }.toMap()
            }
        }
        return palette
    }

    fun close() {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}
