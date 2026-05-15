package io.genckaya.godothapticfeedback

import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.UsedByGodot

/**
 * Godot Android plugin v2 — exposes UIKit-equivalent haptic vocabulary
 * (5 impact + 3 notification + 1 selection) via VersionDispatcher.
 *
 * Symmetric with iOS GodotHapticFeedback (Swift @Godot class). Cross-platform
 * GDScript layer (HapticService.gd) instantiates this via
 * ClassDB.instantiate(&"GodotHapticFeedback").
 *
 * Lifecycle methods (prepare_all / release_all) are no-ops on Android —
 * Vibrator service is OS-managed and doesn't require warm-up.
 */
class GodotHapticFeedback(godot: Godot) : GodotPlugin(godot) {

    private val dispatcher: VersionDispatcher = VersionDispatcher(godot.activity!!.applicationContext)

    override fun getPluginName(): String = "GodotHapticFeedback"

    // ── Lifecycle ────────────────────────────────────────

    @UsedByGodot
    fun prepare_all() {
        // Android has no UIKit-style warm-up requirement — Vibrator service is
        // always ready. Kept for cross-platform symmetry with iOS plugin.
    }

    @UsedByGodot
    fun release_all() {
        // No-op on Android (no held resources).
    }

    // ── Impact: 5 styles ────────────────────────────────

    @UsedByGodot
    fun impact_light() {
        dispatcher.impactLight()
    }

    @UsedByGodot
    fun impact_medium() {
        dispatcher.impactMedium()
    }

    @UsedByGodot
    fun impact_heavy() {
        dispatcher.impactHeavy()
    }

    @UsedByGodot
    fun impact_soft() {
        dispatcher.impactSoft()
    }

    @UsedByGodot
    fun impact_rigid() {
        dispatcher.impactRigid()
    }

    // ── Notification: 3 types ───────────────────────────

    @UsedByGodot
    fun notification_success() {
        dispatcher.notificationSuccess()
    }

    @UsedByGodot
    fun notification_warning() {
        dispatcher.notificationWarning()
    }

    @UsedByGodot
    fun notification_error() {
        dispatcher.notificationError()
    }

    // ── Selection ───────────────────────────────────────

    @UsedByGodot
    fun selection_changed() {
        dispatcher.selectionChanged()
    }

    // ── Diagnostics ─────────────────────────────────────

    @UsedByGodot
    fun is_available(): Boolean = dispatcher.isAvailable()
}
