.PHONY: ios macos android bundle clean setup help

ADDON_DIR = addons/godot-haptic-feedback
IOS_GDEXT_DIR = ios-gdextension
ANDROID_DIR = android

# REPO_ROOT walks up to the BeatCells monorepo when this plugin is built as a
# submodule; falls back to the plugin's own root standalone (game/addons sync
# becomes a no-op).
REPO_ROOT := $(shell git rev-parse --show-superproject-working-tree 2>/dev/null || git rev-parse --show-toplevel)
GAME_ADDON_IOS := $(REPO_ROOT)/game/addons/godot-haptic-feedback/bin/ios
GAME_ADDON_MACOS := $(REPO_ROOT)/game/addons/godot-haptic-feedback/bin/macos
GAME_ADDON_ANDROID := $(REPO_ROOT)/game/addons/godot-haptic-feedback/bin/android

XCBUILD_PRODUCTS_IOS := $(IOS_GDEXT_DIR)/.build-xcode/Build/Products/Release-iphoneos/PackageFrameworks
XCBUILD_PRODUCTS_MACOS := $(IOS_GDEXT_DIR)/.build-xcode-macos/Build/Products/Release/PackageFrameworks

help:
	@echo "Targets: ios | macos | android | bundle | clean | setup"
	@echo "  ios      Build iOS .framework + dSYM, sync to addons/ + game (monorepo)"
	@echo "  macos    Build macOS noop stub .framework for editor"
	@echo "  android  Build Android .aar (requires JDK 17 + Android SDK)"
	@echo "  bundle   ios + macos + android (full build)"
	@echo "  clean    Remove all build artifacts"
	@echo "  setup    Verify ../SwiftGodot present"

setup:
	@echo "Ensure SwiftGodot is available at ../SwiftGodot"
	@test -d ../SwiftGodot || (echo "ERROR: ../SwiftGodot not found" && exit 1)
	@echo "Setup OK"

# ── iOS ──────────────────────────────────────────────
# DEBUG_INFORMATION_FORMAT=dwarf-with-dsym for symbolication (Q-07 pattern).
ios: setup
	cd $(IOS_GDEXT_DIR) && xcodebuild \
		-scheme GodotHapticFeedback \
		-sdk iphoneos \
		-destination 'generic/platform=iOS' \
		-configuration Release \
		-derivedDataPath .build-xcode \
		DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
		build
	@echo "Extracting dSYM sidecars"
	dsymutil $(XCBUILD_PRODUCTS_IOS)/GodotHapticFeedback.framework/GodotHapticFeedback -o $(XCBUILD_PRODUCTS_IOS)/GodotHapticFeedback.framework.dSYM
	mkdir -p $(ADDON_DIR)/bin/ios
	rm -rf $(ADDON_DIR)/bin/ios/*.framework $(ADDON_DIR)/bin/ios/*.framework.dSYM
	cp -R $(XCBUILD_PRODUCTS_IOS)/GodotHapticFeedback.framework $(ADDON_DIR)/bin/ios/
	cp -R $(XCBUILD_PRODUCTS_IOS)/GodotHapticFeedback.framework.dSYM $(ADDON_DIR)/bin/ios/
	@if [ -d "$(REPO_ROOT)/game/addons" ]; then \
		echo "Refreshing game addon (BeatCells monorepo)"; \
		mkdir -p $(GAME_ADDON_IOS); \
		rm -rf $(GAME_ADDON_IOS)/GodotHapticFeedback.framework $(GAME_ADDON_IOS)/GodotHapticFeedback.framework.dSYM; \
		cp -R $(XCBUILD_PRODUCTS_IOS)/GodotHapticFeedback.framework $(GAME_ADDON_IOS)/; \
		cp -R $(XCBUILD_PRODUCTS_IOS)/GodotHapticFeedback.framework.dSYM $(GAME_ADDON_IOS)/; \
	fi

# ── macOS (noop stub for editor) ─────────────────────
macos: setup
	cd $(IOS_GDEXT_DIR) && xcodebuild \
		-scheme GodotHapticFeedback \
		-sdk macosx \
		-destination 'platform=macOS,arch=arm64' \
		-configuration Release \
		-derivedDataPath .build-xcode-macos \
		build
	mkdir -p $(ADDON_DIR)/bin/macos
	rm -rf $(ADDON_DIR)/bin/macos/*.framework
	cp -R $(XCBUILD_PRODUCTS_MACOS)/GodotHapticFeedback.framework $(ADDON_DIR)/bin/macos/
	@if [ -d "$(REPO_ROOT)/game/addons" ]; then \
		echo "Refreshing game addon macos (BeatCells monorepo)"; \
		mkdir -p $(GAME_ADDON_MACOS); \
		rm -rf $(GAME_ADDON_MACOS)/GodotHapticFeedback.framework; \
		cp -R $(XCBUILD_PRODUCTS_MACOS)/GodotHapticFeedback.framework $(GAME_ADDON_MACOS)/; \
	fi

# ── Android ──────────────────────────────────────────
# Requires JDK 17 + Android SDK env (ANDROID_HOME). See README.
android:
	cd $(ANDROID_DIR) && ./gradlew assembleRelease
	mkdir -p $(ADDON_DIR)/bin/android
	rm -f $(ADDON_DIR)/bin/android/*.aar
	cp $(ANDROID_DIR)/build/outputs/aar/android-release.aar $(ADDON_DIR)/bin/android/godot-haptic-feedback.aar
	@if [ -d "$(REPO_ROOT)/game/addons" ]; then \
		echo "Refreshing game addon android (BeatCells monorepo)"; \
		mkdir -p $(GAME_ADDON_ANDROID); \
		rm -f $(GAME_ADDON_ANDROID)/godot-haptic-feedback.aar; \
		cp $(ANDROID_DIR)/build/outputs/aar/android-release.aar $(GAME_ADDON_ANDROID)/godot-haptic-feedback.aar; \
	fi

bundle: ios macos android

clean:
	cd $(IOS_GDEXT_DIR) && swift package clean 2>/dev/null || true
	rm -rf $(IOS_GDEXT_DIR)/.build $(IOS_GDEXT_DIR)/.build-xcode $(IOS_GDEXT_DIR)/.build-xcode-macos
	cd $(ANDROID_DIR) && ./gradlew clean 2>/dev/null || true
	rm -rf $(ANDROID_DIR)/build $(ANDROID_DIR)/.gradle
	rm -rf $(ADDON_DIR)/bin/ios/*.framework $(ADDON_DIR)/bin/ios/*.framework.dSYM
	rm -rf $(ADDON_DIR)/bin/macos/*.framework
	rm -f $(ADDON_DIR)/bin/android/*.aar
