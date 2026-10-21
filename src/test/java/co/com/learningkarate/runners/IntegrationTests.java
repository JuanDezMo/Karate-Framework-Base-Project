package co.com.learningkarate.runners;

import org.junit.jupiter.api.Test;

class IntegrationTests {

    @Test
    void runIntegrationTests() {
        SuiteRunner.run("@integration");
    }
}
