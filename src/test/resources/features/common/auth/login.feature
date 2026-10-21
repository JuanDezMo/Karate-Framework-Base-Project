@ignore
Feature: Flujo reutilizable de login

  # Uso:  * def auth = callonce read('classpath:features/common/auth/login.feature')
  # Salida: auth.authToken. Se pueden pasar { username, password } para sobrescribir la config.
  Background:
    * def authSchema = read('classpath:schemas/auth-response.json')
    * def expected = read('classpath:data/responses/auth/auth.json')

  Scenario: Obtener token de autenticación
    Given url baseUrl
    And path 'auth'
    And header Accept = 'application/json'
    And request read('classpath:requests/auth/login.json')
    When method post
    Then match responseStatus == expected.status.ok
    And match response == authSchema
    * def authToken = response.token
