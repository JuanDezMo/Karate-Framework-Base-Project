@ignore
Feature: Flujo reutilizable de actualización de reserva (PUT)

  # Uso:  * def updated = call read('classpath:features/common/booking/update-booking.feature') { bookingId: '#(bookingId)', booking: '#(booking)', token: '#(auth.authToken)' }
  # Entrada: bookingId, booking. Opcional: token (si falta no se envía la cookie) y expectedStatus (por defecto 200).
  # Salida: updated.response, updated.responseStatus.
  Background:
    * def expected = read('classpath:data/responses/booking/booking.json')
    * def bookingSchema = read('classpath:schemas/booking-response.json')
    * def expectedStatus = karate.get('expectedStatus', expected.status.ok)
    * def schema = expectedStatus == expected.status.ok ? bookingSchema : '#present'
    * def token = karate.get('token')

  Scenario: Actualizar una reserva
    Given url baseUrl
    And path 'booking', bookingId
    And header Accept = 'application/json'
    And header Cookie = token ? 'token=' + token : null
    And request read('classpath:requests/booking/booking.json')
    When method put
    Then match responseStatus == expectedStatus
    And match response == schema
