allprojects {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
// 根项目 build.gradle.kts
buildscript {
    repositories {
        google() // 必须
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.2") // AGP 版本
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.20") // Kotlin 插件版本
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
