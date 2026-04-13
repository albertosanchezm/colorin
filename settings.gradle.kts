pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "Colorin"

include(
    ":app",
    ":core_model",
    ":core_data",
    ":core_ui",
    ":feature_catalog",
    ":feature_paint",
    ":feature_progress",
)
