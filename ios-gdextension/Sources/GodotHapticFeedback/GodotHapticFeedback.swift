@preconcurrency import SwiftGodotRuntime
import Foundation

#if canImport(UIKit)
import UIKit
#endif

@Godot
class GodotHapticFeedback: RefCounted {

    // MARK: - Generator Pool (iOS only)
    //
    // Stored properties retain each generator instance for the lifetime of
    // gameplay. UIKit guidance recommends preparing each generator before
    // use and re-preparing after each fire so the underlying haptic engine
    // stays warm for rapid succession. Without warm-up, the first fire of
    // each session has a perceptible latency on real device.

    #if canImport(UIKit)
    private var impactLight: UIImpactFeedbackGenerator?
    private var impactMedium: UIImpactFeedbackGenerator?
    private var impactHeavy: UIImpactFeedbackGenerator?
    private var impactSoft: UIImpactFeedbackGenerator?
    private var impactRigid: UIImpactFeedbackGenerator?
    private var notification: UINotificationFeedbackGenerator?
    private var selection: UISelectionFeedbackGenerator?
    #endif

    // MARK: - Lifecycle

    @Callable
    func prepare_all() {
        #if canImport(UIKit)
        if impactLight == nil { impactLight = UIImpactFeedbackGenerator(style: .light) }
        if impactMedium == nil { impactMedium = UIImpactFeedbackGenerator(style: .medium) }
        if impactHeavy == nil { impactHeavy = UIImpactFeedbackGenerator(style: .heavy) }
        if impactSoft == nil { impactSoft = UIImpactFeedbackGenerator(style: .soft) }
        if impactRigid == nil { impactRigid = UIImpactFeedbackGenerator(style: .rigid) }
        if notification == nil { notification = UINotificationFeedbackGenerator() }
        if selection == nil { selection = UISelectionFeedbackGenerator() }

        impactLight?.prepare()
        impactMedium?.prepare()
        impactHeavy?.prepare()
        impactSoft?.prepare()
        impactRigid?.prepare()
        notification?.prepare()
        selection?.prepare()
        #endif
    }

    @Callable
    func release_all() {
        #if canImport(UIKit)
        impactLight = nil
        impactMedium = nil
        impactHeavy = nil
        impactSoft = nil
        impactRigid = nil
        notification = nil
        selection = nil
        #endif
    }

    // MARK: - Impact (5 styles)

    @Callable
    func impact_light() {
        #if canImport(UIKit)
        if impactLight == nil { impactLight = UIImpactFeedbackGenerator(style: .light); impactLight?.prepare() }
        impactLight?.impactOccurred()
        impactLight?.prepare()
        #endif
    }

    @Callable
    func impact_medium() {
        #if canImport(UIKit)
        if impactMedium == nil { impactMedium = UIImpactFeedbackGenerator(style: .medium); impactMedium?.prepare() }
        impactMedium?.impactOccurred()
        impactMedium?.prepare()
        #endif
    }

    @Callable
    func impact_heavy() {
        #if canImport(UIKit)
        if impactHeavy == nil { impactHeavy = UIImpactFeedbackGenerator(style: .heavy); impactHeavy?.prepare() }
        impactHeavy?.impactOccurred()
        impactHeavy?.prepare()
        #endif
    }

    @Callable
    func impact_soft() {
        #if canImport(UIKit)
        if impactSoft == nil { impactSoft = UIImpactFeedbackGenerator(style: .soft); impactSoft?.prepare() }
        impactSoft?.impactOccurred()
        impactSoft?.prepare()
        #endif
    }

    @Callable
    func impact_rigid() {
        #if canImport(UIKit)
        if impactRigid == nil { impactRigid = UIImpactFeedbackGenerator(style: .rigid); impactRigid?.prepare() }
        impactRigid?.impactOccurred()
        impactRigid?.prepare()
        #endif
    }

    // MARK: - Notification (3 types)

    @Callable
    func notification_success() {
        #if canImport(UIKit)
        if notification == nil { notification = UINotificationFeedbackGenerator(); notification?.prepare() }
        notification?.notificationOccurred(.success)
        notification?.prepare()
        #endif
    }

    @Callable
    func notification_warning() {
        #if canImport(UIKit)
        if notification == nil { notification = UINotificationFeedbackGenerator(); notification?.prepare() }
        notification?.notificationOccurred(.warning)
        notification?.prepare()
        #endif
    }

    @Callable
    func notification_error() {
        #if canImport(UIKit)
        if notification == nil { notification = UINotificationFeedbackGenerator(); notification?.prepare() }
        notification?.notificationOccurred(.error)
        notification?.prepare()
        #endif
    }

    // MARK: - Selection (1 type)

    @Callable
    func selection_changed() {
        #if canImport(UIKit)
        if selection == nil { selection = UISelectionFeedbackGenerator(); selection?.prepare() }
        selection?.selectionChanged()
        selection?.prepare()
        #endif
    }

    // MARK: - Diagnostics

    // Hardware capability check. Pre-iPhone 7 devices (iPhone 6/SE 1st gen)
    // lack the Taptic Engine; UIKit feedback generators silently no-op there.
    // Returns false on macOS (noop stub) so GDScript layer can skip lifecycle calls.
    @Callable
    func is_available() -> Bool {
        #if canImport(UIKit)
        // UIKit doesn't expose a public "has Taptic Engine" API; we approximate
        // by checking that we're on a phone form-factor (UIDevice.userInterfaceIdiom).
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }
}
