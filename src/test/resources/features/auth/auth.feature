@component @auth
Feature: POST /auth - prueba de componente

  Background:
    * url baseUrl
    * path 'auth'
    * header Accept = 'application/json'
    * def authSchema = read('classpath:schemas/auth-response.json')
    * def expected = read('classpath:data/responses/auth/auth.json')
    * def authErrorSchema = read('classpath:schemas/auth-error-response.json')
    * def loginRequest = 'classpath:requests/auth/login.json'

  @smoke
  Scenario: Credenciales válidas devuelven un token
    Given request read(loginRequest)
    When method post
    Then match responseStatus == expected.status.ok
    And match response == authSchema

  @regression
  Scenario: Password incorrecto es rechazado
    * def password = 'password-incorrecto'
    Given request read(loginRequest)
    When method post
    Then match responseStatus == expected.status.authFailed
    And match response == authErrorSchema
    And match response.reason == expected.messages.badCredentials

  @regression
  Scenario Outline: Body inválido es rechazado - <caso>
    * def username = <username>
    * def password = <password>
    Given request read(loginRequest)
    When method post
    Then match responseStatus == expected.status.authFailed
    And match response == authErrorSchema
    And match response.reason == expected.messages.badCredentials

    Examples:
      | caso         | username | password  |
      | body vacío   | null     | null      |
      | sin password | 'admin'  | null      |
      | sin username | null     | 'secreto' |
