@integration @booking
Feature: Actualización de reserva - flujo de integración

  Background:
    * def expected = read('classpath:data/responses/booking/booking.json')
    * def auth = callonce read('classpath:features/common/auth/login.feature')
    * def createBooking = read('classpath:features/common/booking/create-booking.feature')
    * def updateBooking = read('classpath:features/common/booking/update-booking.feature')
    * def getBooking = read('classpath:features/common/booking/get-booking.feature')
    * def deleteBooking = read('classpath:features/common/booking/delete-booking.feature')
    * def newBooking = read('classpath:data/booking/booking-new.json')
    * def updatedBooking = read('classpath:data/booking/booking-update.json')

  @smoke
  Scenario: Crear, actualizar, verificar y eliminar una reserva
    * def created = call createBooking { booking: '#(newBooking)' }
    * def bookingId = created.bookingId

    * def updated = call updateBooking { bookingId: '#(bookingId)', booking: '#(updatedBooking)', token: '#(auth.authToken)' }
    * match updated.response.firstname == updatedBooking.firstname
    * match updated.response.totalprice == updatedBooking.totalprice

    * def fetched = call getBooking { bookingId: '#(bookingId)' }
    * match fetched.response == updated.response

    * call deleteBooking { bookingId: '#(bookingId)', token: '#(auth.authToken)' }
    * def missing = call getBooking { bookingId: '#(bookingId)', expectedStatus: '#(expected.status.notFound)' }
    * match missing.response == expected.messages.notFound

  @regression
  Scenario: PUT sin token no modifica la reserva
    * def created = call createBooking { booking: '#(newBooking)' }
    * def bookingId = created.bookingId

    * def rejected = call updateBooking { bookingId: '#(bookingId)', booking: '#(updatedBooking)', expectedStatus: '#(expected.status.forbidden)' }
    * match rejected.response == expected.messages.forbidden

    * def fetched = call getBooking { bookingId: '#(bookingId)' }
    * match fetched.response == created.response.booking

    * call deleteBooking { bookingId: '#(bookingId)', token: '#(auth.authToken)' }
