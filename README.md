# godot-haptic-feedback

Godot 4.6 haptic feedback plugin — iOS UIKit `UIFeedbackGenerator` family + Android `VibrationEffect` (createPredefined ≥ API 29, OneShot ≥ API 26, vibrate-legacy ≥ API 24).

## Native API

GDScript-exposed class `GodotHapticFeedback` (RefCounted), instantiated via `ClassDB.instantiate(&"GodotHapticFeedback")`. 10 methods:

```
# Impact (5)
impact_light(), impact_medium(), impact_heavy(), impact_soft(), impact_rigid()
# Notification (3)
notification_success(), notification_warning(), notification_error()
# Selection (1)
selection_changed()
# Lifecycle
prepare_all(), release_all()
# Diagnostics
is_available() -> bool
```

## Build

```bash
make ios       # Builds iOS .framework + macOS noop stub
make android   # Builds Android .aar (requires JDK 17 + Android SDK)
make bundle    # Sync to game/addons/godot-haptic-feedback (monorepo only)
make clean     # Clean all build artifacts
```

## Pattern

This plugin follows the OURS SwiftGodot pattern used by `godot-connection-state`, `godot-app-integrity`, `godot-google-signin`. See `plugins/SwiftGodot` for the binding library.
