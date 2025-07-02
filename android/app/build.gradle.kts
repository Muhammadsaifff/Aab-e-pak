plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Must be last
}

android {
    namespace = "com.example.aab_e_pak"
    compileSdk = 35
    ndkVersion = "29.0.13599879"

    defaultConfig {
    applicationId = "com.example.aab_e_pak"
    minSdk = 23 // 👈 REQUIRED FIX (was 21)
    targetSdk = 35
    versionCode = 1
    versionName = "1.0"
}


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // ✅ Required for Java 8+ features
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug") // Replace with actual release config if needed
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Required for flutter_local_notifications when using Java 11 features
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Other dependencies managed by Flutter and plugins
}
