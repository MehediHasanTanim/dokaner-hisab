plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hisabdokan.dokanerhisab"
    // Deliberately pinned above flutter.compileSdkVersion (36). flutter_secure_storage
    // publishes AAR metadata requiring API 37, and it is load-bearing: AD-17 keeps the
    // SQLCipher key in the platform keystore, which is what makes the encrypted local
    // ledger meaningful. compileSdk only decides which APIs the code may reference and
    // is backward compatible — targetSdk (runtime behaviour) and minSdk (device reach)
    // are set from Flutter's values below and are unaffected.
    // AGP 9.1.0 warns that 36 is its maximum *recommended* compileSdk; the warning is
    // suppressed in gradle.properties. Revisit when AGP catches up to 37.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        // Required by flutter_local_notifications: it uses java.time APIs that do
        // not exist on older Android runtimes, so the build must rewrite them.
        // Without this the AAR metadata check fails outright — it is not optional.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hisabdokan.dokanerhisab"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // Version 2.1.4 is the one flutter_local_notifications documents and tests
    // against (its README pins exactly this). Do not bump it casually: the
    // desugaring library is coupled to the plugin's own expectations, and a
    // mismatch surfaces as a runtime NoSuchMethodError on old devices rather
    // than a build failure. AGP here is 9.1.0, well past the plugin's stated
    // 8.11.1 floor.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
