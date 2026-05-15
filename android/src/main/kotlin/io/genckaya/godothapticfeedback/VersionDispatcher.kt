package io.genckaya.godothapticfeedback

import android.content.Context
import android.os.Build
import android.os.Vibrator
import android.os.VibratorManager
import android.os.VibrationEffect
import android.provider.Settings

/**
 * Translates GDScript-exposed haptic intents (impact_*, notification_*, selection_changed)
 * to the appropriate Android Vibrator path based on SDK_INT + hardware capability.
 *
 * Branching matrix (per spec §3.3 / §3.7):
 *   API ≥ 31: VibratorManager + createPredefined(EFFECT_*)
 *   API 29-30: deprecated Vibrator + createPredefined(EFFECT_*)
 *   API 26-28 + hasAmplitudeControl: Vibrator + createOneShot(ms, amplitude)
 *   API 26-28 + !hasAmplitudeControl: Vibrator + createOneShot(ms, DEFAULT_AMPLITUDE)
 *   API 24-25: deprecated Vibrator.vibrate(long ms)
 *
 * OS-level user setting respect (§3.9): every fire short-circuits if
 * Settings.System.HAPTIC_FEEDBACK_ENABLED == 0.
 */
class VersionDispatcher(private val context: Context) {

    private val sdk: Int = Build.VERSION.SDK_INT

    @Suppress("DEPRECATION")
    private val vibrator: Vibrator? = when {
        sdk >= Build.VERSION_CODES.S -> {
            (context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager)?.defaultVibrator
        }
        else -> context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
    }

    private val amplitudeSupported: Boolean =
        sdk >= Build.VERSION_CODES.O && (vibrator?.hasAmplitudeControl() == true)

    fun isAvailable(): Boolean = vibrator?.hasVibrator() == true

    /**
     * OS-level user-setting gate. Returns true if user has not disabled
     * "Touch haptic" in system settings; false → caller must short-circuit.
     */
    private fun osHapticEnabled(): Boolean {
        return try {
            Settings.System.getInt(
                context.contentResolver,
                Settings.System.HAPTIC_FEEDBACK_ENABLED,
                1
            ) == 1
        } catch (e: Settings.SettingNotFoundException) {
            true // assume enabled if setting absent
        }
    }

    // ── Impact: 5 styles ─────────────────────────────────

    fun impactLight() = fireImpact(durationMs = 10L, amplitude = 80, predefined = effectTickOrClick())

    fun impactMedium() = fireImpact(durationMs = 20L, amplitude = 128, predefined = effectClick())

    fun impactHeavy() = fireImpact(durationMs = 25L, amplitude = 200, predefined = effectHeavyClick())

    fun impactSoft() = fireImpact(durationMs = 15L, amplitude = 100, predefined = effectTickOrClick())

    fun impactRigid() = fireImpact(durationMs = 25L, amplitude = 180, predefined = effectClick())

    // ── Notification: 3 types ────────────────────────────

    fun notificationSuccess() = fireImpact(durationMs = 30L, amplitude = 180, predefined = effectClick())

    fun notificationWarning() = fireImpact(durationMs = 40L, amplitude = 220, predefined = effectHeavyClick())

    fun notificationError() = fireImpact(durationMs = 30L, amplitude = 200, predefined = effectDoubleClick())

    // ── Selection ────────────────────────────────────────

    fun selectionChanged() = fireImpact(durationMs = 10L, amplitude = 80, predefined = effectTickOrClick())

    // ── Internal dispatch ────────────────────────────────

    @Suppress("DEPRECATION")
    private fun fireImpact(durationMs: Long, amplitude: Int, predefined: Int?) {
        if (!osHapticEnabled()) return
        val v = vibrator ?: return
        if (!v.hasVibrator()) return

        when {
            sdk >= Build.VERSION_CODES.Q && predefined != null -> {
                v.vibrate(VibrationEffect.createPredefined(predefined))
            }
            amplitudeSupported -> {
                v.vibrate(VibrationEffect.createOneShot(durationMs, amplitude))
            }
            sdk >= Build.VERSION_CODES.O -> {
                v.vibrate(VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE))
            }
            else -> {
                v.vibrate(durationMs)
            }
        }
    }

    private fun effectClick(): Int? =
        if (sdk >= Build.VERSION_CODES.Q) VibrationEffect.EFFECT_CLICK else null

    private fun effectTickOrClick(): Int? =
        if (sdk >= Build.VERSION_CODES.Q) VibrationEffect.EFFECT_TICK else null

    private fun effectHeavyClick(): Int? =
        if (sdk >= Build.VERSION_CODES.Q) VibrationEffect.EFFECT_HEAVY_CLICK else null

    private fun effectDoubleClick(): Int? =
        if (sdk >= Build.VERSION_CODES.Q) VibrationEffect.EFFECT_DOUBLE_CLICK else null
}
