1.
Guest 1183. Give the booking_date and the number of nights for guest 1183.

SELECT date_format(booking_date, '%Y-%m-%d') as date, nights
FROM booking JOIN guest ON guest_id = guest.id
 WHERE guest_id = 1183