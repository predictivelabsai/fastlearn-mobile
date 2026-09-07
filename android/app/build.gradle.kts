import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val requireReleaseSigning =
    providers.environmentVariable("FASTLEARN_REQUIRE_RELEASE_SIGNING").orNull == "true"
val requiredSigningProperties = listOf("storePassword", "keyPassword", "keyAlias", "storeFile")
val missingSigningProperties =
    requiredSigningProperties.filter { keystoreProperties.getProperty(it).isNullOrBlank() }

if (keystorePropertiesFile.exists() && missingSigningProperties.isNotEmpty()) {
    throw GradleException(
        "android/key.properties is missing: ${missingSigningProperties.joinToString()}",
    )
}

if (requireReleaseSigning && !keystorePropertiesFile.exists()) {
    throw GradleException(
        "Release signing is required, but android/key.properties does not exist.",
    )
}

android {
    namespace = "fun.fastlearn.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "fun.fastlearn.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                null
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
