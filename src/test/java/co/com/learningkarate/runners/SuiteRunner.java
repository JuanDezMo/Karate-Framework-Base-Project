package co.com.learningkarate.runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Ejecución paralela común a todos los runners por tipo de prueba.
 * <p>
 * Propiedades: {@code -Dthreads=4}, {@code -Dkarate.tags=@smoke} (se combina con el tag de tipo),
 * {@code -Dkarate.env=dev}. Los escenarios {@code @ignore} nunca se ejecutan.
 */
final class SuiteRunner {

    private static final String OUTPUT_DIR = System.getProperty("karate.output.dir", "build/karate-reports");

    private SuiteRunner() {
    }

    static void run(String typeTag) {
        int threads = Integer.getInteger("threads", 4);

        List<String> tags = new ArrayList<>();
        tags.add(typeTag);
        tags.add("~@ignore");
        String extra = System.getProperty("karate.tags");
        if (extra != null && !extra.isBlank()) {
            tags.add(extra);
        }

        Results results = Runner.path("classpath:features")
                .tags(tags)
                .reportDir(OUTPUT_DIR)
                .parallel(threads);

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
