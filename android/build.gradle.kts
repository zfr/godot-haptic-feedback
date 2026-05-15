plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

val pluginName = "GodotHapticFeedback"
val pluginPackageName = "io.genckaya.godothapticfeedback"

android {
    namespace = pluginPackageName
    compileSdk = 35

    defaultConfig {
        minSdk = 24

        manifestPlaceholders["godotPluginName"] = pluginName
        manifestPlaceholders["godotPluginPackageName"] = pluginPackageName
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    // Godot Android library — provided by operator via local file or maven (matches godot-google-signin pattern)
    compileOnly(files("libs/godot-lib.4.6.1.stable.release.aar"))
}
