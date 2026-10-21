@ignore
Feature: Flujo reutilizable de creación de reserva

  # Uso:  * def created = call read('classpath:features/common/booking/create-booking.feature') { booking: '#(booking)' }
  # Entrada: booking (ver data/booking/*.json). Opcional: expectedStatus (por defecto 200).
  # Salida: created.bookingId, created.response, created.responseStatus.
  Background:
    * def expected = read('classpath:data/responses/booking/booking.json')
    * def bookingSchema = read('classpath:schemas/booking-response.json')
    * def expectedStatus = karate.get('expectedStatus', expected.status.ok)
    * def schema = expectedStatus == expected.status.ok ? { bookingid: '#number', booking: '#(bookingSchema)' } : '#present'

  Scenario: Crear una reserva
    Given url baseUrl
    And path 'booking'
    And header Accept = 'application/json'
    And request read('classpath:requests/booking/booking.json')
    When method post
    Then match responseStatus == expectedStatus
    And match response == schema
    * def bookingId = expectedStatus == expected.status.ok ? response.bookingid : null
