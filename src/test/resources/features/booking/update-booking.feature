@component @booking
Feature: PUT /booking/{id} - prueba de componente

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json' }
    * def expected = read('classpath:data/responses/booking/booking.json')
    * def bookingSchema = read('classpath:schemas/booking-response.json')
    * def auth = callonce read('classpath:features/common/auth/login.feature')
    * def newBooking = read('classpath:data/booking/booking-new.json')
    * def created = call read('classpath:features/common/booking/create-booking.feature') { booking: '#(newBooking)' }
    * def bookingId = created.bookingId
    * configure afterScenario = function() { karate.call('classpath:features/common/booking/delete-booking.feature', { bookingId: bookingId, token: auth.authToken }) }
    * def booking = read('classpath:data/booking/booking-update.json')

  @smoke
  Scenario: Reserva actualizada con token válido
    Given path 'booking', bookingId
    And header Cookie = 'token=' + auth.authToken
    And request read('classpath:requests/booking/booking.json')
    When method put
    Then match responseStatus == expected.status.ok
    And match response == bookingSchema
    And match response.firstname == booking.firstname
    And match response.lastname == booking.lastname
    And match response.totalprice == booking.totalprice
    And match response.depositpaid == booking.depositpaid
    And match response.bookingdates == { checkin: '#(booking.checkin)', checkout: '#(booking.checkout)' }
    And match response.additionalneeds == booking.additionalneeds

  @regression
  Scenario: Sin token es rechazado
    Given path 'booking', bookingId
    And request read('classpath:requests/booking/booking.json')
    When method put
    Then match responseStatus == expected.status.forbidden
    And match response == expected.messages.forbidden

  @regression
  Scenario: Token inválido es rechazado
    Given path 'booking', bookingId
    And header Cookie = 'token=token-invalido'
    And request read('classpath:requests/booking/booking.json')
    When method put
    Then match responseStatus == expected.status.forbidden
    And match response == expected.messages.forbidden

  @regression
  Scenario Outline: Body incompleto es rechazado - sin <campo>
    * set booking.<campo> = null
    Given path 'booking', bookingId
    And header Cookie = 'token=' + auth.authToken
    And request read('classpath:requests/booking/booking.json')
    When method put
    Then match responseStatus == expected.status.badRequest
    And match response == expected.messages.badRequest

    Examples:
      | campo       |
      | firstname   |
      | lastname    |
      | totalprice  |
      | depositpaid |
      | checkin     |
      | checkout    |

  @regression
  Scenario: Reserva inexistente no se puede actualizar
    * def missingId = 999999999
    Given path 'booking', missingId
    And header Cookie = 'token=' + auth.authToken
    And request read('classpath:requests/booking/booking.json')
    When method put
    Then match responseStatus == expected.status.methodNotAllowed
    And match response == expected.messages.methodNotAllowed
