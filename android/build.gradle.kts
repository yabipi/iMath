import com.android.build.gradle.BaseExtension

allprojects {
    repositories {
        mavenCentral()
        google()
    }
}


//val namespace = "com.icool.coolmath"
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        if (hasProperty("android")) {
            //println("Gradle version==: ${gradle.gradleVersion}")
            extensions.getByType<BaseExtension>().apply {
                //println("haha")
                // 配置逻辑
                if (namespace == null) {
                    namespace = group.toString()
                }
            }
        }
        if (plugins.hasPlugin("com.android.application") ||
            plugins.hasPlugin("com.android.library")) {
            println("设置 compileSdkVersion")
            extensions.configure<com.android.build.gradle.BaseExtension> {
                compileSdkVersion(34)
                buildToolsVersion("34.0.0")
            }
        }
    }
    buildDir = "${rootProject.buildDir}/${name}"
}




subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
