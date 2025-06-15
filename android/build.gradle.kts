allprojects {
    repositories {
        mavenCentral()
        google()
    }
}
//println("Gradle version: ${gradle.gradleVersion}")

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
//subprojects {
//    afterEvaluate {
//        if (project.hasProperty("android")) {
//            project.extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
//                if (!hasProperty("namespace") || namespace == null || namespace!!.isEmpty()) {
//                    // 分配基于项目名或group的默认命名空间
//                    namespace = project.group.toString().takeIf { it.isNotBlank() } ?: "com.icool.${project.name}"
//                }
//            }
//        }
//    }
//}
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
