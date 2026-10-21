@ignore
Feature: Flujo reutilizable de login

  # Uso:  * def auth = callonce read('classpath:features/common/auth/login.feature')
  # Salida: auth.authToken. Se pueden pasar { username, password } para sobrescribir la config.
  Scenario: Obtener token de autenticación
    Given url baseUrl
    And path 'auth'
    And header Accept = 'application/json'
    And request { username: '#(username)', password: '#(password)' }
    When method post
    Then status 200
    And match response == { token: '#string' }
    * def authToken = response.token
