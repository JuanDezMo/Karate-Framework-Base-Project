pipeline {
    agent any

    options {
        timestamps()
        timeout(time: 20, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    parameters {
        choice(name: 'KARATE_ENV', choices: ['dev', 'qa'], description: 'Ambiente (config/<env>.json)')
        string(name: 'TAGS', defaultValue: '', description: 'Tags de Karate, ej: @smoke o @auth,@booking (vacío = todos)')
        string(name: 'THREADS', defaultValue: '4', description: 'Hilos en paralelo')
    }

    environment {
        PROJECT_SRC = '/workspace/project'
        REPORTS_OUT = '/reports'
    }

    stages {
        stage('Preparar código') {
            steps {
                deleteDir()
                sh '''
                    tar -C "$PROJECT_SRC" \
                        --exclude=./build --exclude=./.gradle --exclude=./.git \
                        --exclude=./ci --exclude=./.claude --exclude=./openspec \
                        -cf - . | tar -xf -
                    chmod +x gradlew
                '''
            }
        }

        stage('Pruebas de componente') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    withCredentials([string(credentialsId: 'booker-password', variable: 'BOOKER_PASSWORD')]) {
                        sh './gradlew componentTest -Dkarate.env="$KARATE_ENV" -Dthreads="$THREADS" ${TAGS:+-Dkarate.tags="$TAGS"}'
                    }
                }
            }
        }

        stage('Pruebas de integración') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    withCredentials([string(credentialsId: 'booker-password', variable: 'BOOKER_PASSWORD')]) {
                        sh './gradlew integrationTest -Dkarate.env="$KARATE_ENV" -Dthreads="$THREADS" ${TAGS:+-Dkarate.tags="$TAGS"}'
                    }
                }
            }
        }
    }

    post {
        always {
            junit allowEmptyResults: true, testResults: 'build/test-results/**/*.xml'

            publishHTML(target: [reportName: 'Karate - Componente', reportDir: 'build/karate-reports/component',
                                 reportFiles: 'karate-summary.html', keepAll: true, allowMissing: true, alwaysLinkToLastBuild: true])
            publishHTML(target: [reportName: 'Karate - Integración', reportDir: 'build/karate-reports/integration',
                                 reportFiles: 'karate-summary.html', keepAll: true, allowMissing: true, alwaysLinkToLastBuild: true])

            // Copia fuera del contenedor: ci/reports/<build>/ y ci/reports/latest/
            sh '''
                if [ -d build/karate-reports ]; then
                    rm -rf "$REPORTS_OUT/$BUILD_NUMBER" "$REPORTS_OUT/latest"
                    mkdir -p "$REPORTS_OUT/$BUILD_NUMBER"
                    cp -r build/karate-reports/. "$REPORTS_OUT/$BUILD_NUMBER/"
                    cp -r build/karate-reports "$REPORTS_OUT/latest"
                fi
            '''
        }
    }
}
