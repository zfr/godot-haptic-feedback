@tool
extends EditorPlugin


func _enter_tree() -> void:
	var android_plugin: GodotHapticFeedbackAndroidExport = GodotHapticFeedbackAndroidExport.new()
	add_export_plugin(android_plugin)

	var ios_plugin: GodotHapticFeedbackIosExport = GodotHapticFeedbackIosExport.new()
	add_export_plugin(ios_plugin)

	print("[GodotHapticFeedback] Plugin enabled")


func _exit_tree() -> void:
	print("[GodotHapticFeedback] Plugin disabled")


class GodotHapticFeedbackAndroidExport extends EditorExportPlugin:
	func _get_name() -> String:
		return "GodotHapticFeedbackAndroid"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_libraries(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		# .aar build deferred until operator JDK 17 + Android SDK env setup.
		# Path is forward-declared so Android export discovers it when present.
		return PackedStringArray(["res://addons/godot-haptic-feedback/bin/android/godot-haptic-feedback.aar"])

	func _get_android_dependencies(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		# Haptic plugin uses built-in android.os.Vibrator API — no Maven deps.
		return PackedStringArray()


class GodotHapticFeedbackIosExport extends EditorExportPlugin:
	func _get_name() -> String:
		return "GodotHapticFeedbackIos"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformIOS

	func _export_begin(_features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> void:
		# SwiftGodotRuntime.framework is provided by the canonical
		# res://addons/SwiftGodotRuntime/ addon — don't embed a per-plugin copy.
		add_apple_embedded_platform_embedded_framework(
			"res://addons/godot-haptic-feedback/bin/ios/GodotHapticFeedback.framework")
		print("[GodotHapticFeedback] iOS framework embedded")
