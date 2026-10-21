plugins {
    java
}

group = "co.com.learningkarate"
version = "0.1.0"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(libs.karate.junit5)
    testImplementation(libs.junit.jupiter)
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
    testImplementation(libs.logback.classic)
}

// Propiedades que se propagan de la línea de comandos a la JVM de pruebas.
val passthroughProps = listOf("karate.env", "karate.tags", "karate.options", "threads", "baseUrl", "feature")
val karateReportsDir = layout.buildDirectory.dir("karate-reports").get().asFile.absolutePath

tasks.withType<Test>().configureEach {
    useJUnitPlatform()

    passthroughProps.forEach { key ->
        System.getProperty(key)?.let { systemProperty(key, it) }
    }
    systemProperty("karate.output.dir", karateReportsDir)

    // Las pruebas dependen de un servicio externo: nunca se marcan como up-to-date.
    outputs.upToDateWhen { false }

    testLogging {
        events("passed", "failed", "skipped")
    }
}

// Pruebas de componente: un endpoint, aislado.
val componentTest by tasks.registering(Test::class) {
    group = "verification"
    description = "Ejecuta las pruebas de componente (@component)."
    testClassesDirs = sourceSets.test.get().output.classesDirs
    classpath = sourceSets.test.get().runtimeClasspath
    filter.includeTestsMatching("*ComponentTests")
}

// Pruebas de integración: flujos de varios pasos.
val integrationTest by tasks.registering(Test::class) {
    group = "verification"
    description = "Ejecuta las pruebas de integración (@integration)."
    testClassesDirs = sourceSets.test.get().output.classesDirs
    classpath = sourceSets.test.get().runtimeClasspath
    filter.includeTestsMatching("*IntegrationTests")
}
