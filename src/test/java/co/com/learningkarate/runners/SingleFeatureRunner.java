package co.com.learningkarate.runners;

import com.intuit.karate.junit5.Karate;

/**
 * Runner para depurar un feature desde el IDE.
 * Cambia la ruta por defecto o pasa {@code -Dfeature=classpath:features/auth/auth.feature}.
 */
class SingleFeatureRunner {

    @Karate.Test
    Karate runSingle() {
        return Karate.run(System.getProperty("feature", "classpath:features/auth/auth.feature"));
    }
}
