@ignore
Feature: Flujo reutilizable de eliminación de reserva

  # Uso:  * call read('classpath:features/common/booking/delete-booking.feature') { bookingId: '#(bookingId)', token: '#(auth.authToken)' }
  # Entrada: bookingId. Opcional: token (si falta no se envía la cookie) y expectedStatus (por defecto 201).
  # Salida: deleted.response, deleted.responseStatus.
  Background:
    * def expected = read('classpath:data/responses/booking/booking.json')
    * def expectedStatus = karate.get('expectedStatus', expected.status.deleted)
    * def token = karate.get('token')

  Scenario: Eliminar una reserva
    Given url baseUrl
    And path 'booking', bookingId
    And header Cookie = token ? 'token=' + token : null
    When method delete
    Then match responseStatus == expectedStatus
