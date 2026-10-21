@component @auth
Feature: POST /auth - prueba de componente

  Background:
    * url baseUrl
    * path 'auth'
    * header Accept = 'application/json'
    * def authSchema = read('classpath:schemas/auth-response.json')

  @smoke
  Scenario: Credenciales válidas devuelven un token
    Given request { username: '#(username)', password: '#(password)' }
    When method post
    Then status 200
    And match response == authSchema

  @regression
  Scenario: Password incorrecto es rechazado
    Given request { username: '#(username)', password: 'password-incorrecto' }
    When method post
    Then status 200
    And match response == { reason: 'Bad credentials' }

  @regression
  Scenario Outline: Body inválido es rechazado - <caso>
    Given request <body>
    When method post
    Then status 200
    And match response == { reason: 'Bad credentials' }

    Examples:
      | caso               | body                    |
      | body vacío         | {}                      |
      | sin password       | { username: 'admin' }   |
      | sin username       | { password: 'secreto' } |
