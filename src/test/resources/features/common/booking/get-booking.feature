@ignore
Feature: Flujo reutilizable de consulta de reserva

  # Uso:  * def fetched = call read('classpath:features/common/booking/get-booking.feature') { bookingId: '#(bookingId)' }
  # Entrada: bookingId. Opcional: expectedStatus (por defecto 200).
  # Salida: fetched.response, fetched.responseStatus.
  Background:
    * def expected = read('classpath:data/responses/booking/booking.json')
    * def bookingSchema = read('classpath:schemas/booking-response.json')
    * def expectedStatus = karate.get('expectedStatus', expected.status.ok)
    * def schema = expectedStatus == expected.status.ok ? bookingSchema : '#present'

  Scenario: Consultar una reserva
    Given url baseUrl
    And path 'booking', bookingId
    And header Accept = 'application/json'
    When method get
    Then match responseStatus == expectedStatus
    And match response == schema
