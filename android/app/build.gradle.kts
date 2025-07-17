import com.android.build.gradle.internal.dsl.SigningConfig
import java.io.FileInputStream
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use {
        keystoreProperties.load(it)
    }
} else {
    throw GradleException("key.properties file not found. Make sure it's in the project root of your Flutter project (e.g., C:\\tugas\\in_out\\key.properties).")
}

android {
    namespace = "com.ppkd.inout"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.ppkd.inout"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties.getProperty("storeFile") 
                ?: throw GradleException("storeFile not found in key.properties"))
            // Hapus satu kurung tutup di sini:
            storePassword = keystoreProperties.getProperty("storePassword") 
                ?: throw GradleException("storePassword not found in key.properties")
            // Hapus satu kurung tutup di sini:
            keyAlias = keystoreProperties.getProperty("keyAlias") 
                ?: throw GradleException("keyAlias not found in key.properties")
            // Hapus satu kurung tutup di sini:
            keyPassword = keystoreProperties.getProperty("keyPassword") 
                ?: throw GradleException("keyPassword not found in key.properties")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}