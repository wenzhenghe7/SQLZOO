/*https://sqlzoo.net/wiki/Guest_House*/

/*1.
Guest 1183. Give the booking_date and the number of nights for guest 1183.*/

SELECT date_format(booking_date, '%Y-%m-%d') as date, nights
FROM booking JOIN guest ON guest_id = guest.id
 WHERE guest_id = 1183

 /*2.
When do they get here? List the arrival time and the first and last names for all guests due to arrive on 2016-11-05, order the output by time of arrival.*/
select arrival_time, first_name, last_name
from booking
inner join guest on guest_id = id
where DATE(booking_date) = DATE('2016-11-05')
order by arrival_time

/*3.
Look up daily rates. Give the daily rate that should be paid for bookings with ids 5152, 5165, 5154 and 5295. Include booking id, room type, number of occupants and the amount.*/
select booking_id, room_type_requested, occupants, amount
from booking
inner join rate on room_type_requested = room_type and occupants = occupancy
where booking_id IN ('5152', '5165', '5154','5295')

/*4.
Who’s in 101? Find who is staying in room 101 on 2016-12-03, include first name, last name and address.*/
select first_name, last_name, address
from booking
inner join guest on guest_id = id
where room_no = 101 and booking_date = '2016-12-03'

/*5.
How many bookings, how many nights? For guests 1185 and 1270 show the number of bookings made and the total number of nights. Your output should include the guest id and the total number of bookings and the total number of nights.*/
select guest_id, count(nights), sum(nights)
from booking
inner join guest on guest_id = id
where guest_id IN (1185,1270)
group by guest_id

/*6.
Ruth Cadbury. Show the total amount payable by guest Ruth Cadbury for her room bookings. You should JOIN to the rate table using room_type_requested and occupants.*/
SELECT sum(nights*amount)
FROM booking JOIN guest ON guest_id = guest.id
inner join rate on room_type_requested = room_type and occupants = occupancy
where first_name = 'Ruth' and last_name = 'Cadbury'

/*7.
Including Extras. Calculate the total bill for booking 5346 including extras.*/
SELECT min(rate.amount)*min(nights) + sum(extra.amount)
FROM booking JOIN extra ON booking.booking_id = extra.booking_id
inner join rate on room_type_requested = room_type and occupants = occupancy
where booking.booking_id = 5346

/*8.
Edinburgh Residents. For every guest who has the word “Edinburgh” in their address show the total number of nights booked. Be sure to include 0 for those guests who have never had a booking. Show last name, first name, address and number of nights. Order by last name then first name.*/
select last_name, first_name, address, sum(case when
nights is null then 0
else nights end) as nights
from booking
right join guest on guest_id = id
where address like '%Edinburgh%'
group by last_name, first_name, address

/*9.
How busy are we? For each day of the week beginning 2016-11-25 show the number of bookings starting that day. Be sure to show all the days of the week in the correct order.*/
select date_format(booking_date, '%Y-%m-%d'), count(*)
from booking
where DATE(booking_date) BETWEEN DATE('2016-11-25') AND DATE('2016-12-01')
group by booking_date

/*10.
How many guests? Show the number of guests in the hotel on the night of 2016-11-21. Include all occupants who checked in that day but not those who checked out.*/
select sum(occupants)
from booking
where date(booking_date) <= date('2016-11-21') and date(booking_date) + nights > date('2016-11-21')


/*11.
Coincidence. Have two guests with the same surname ever stayed in the hotel on the evening? Show the last name and both first names. Do not include duplicates.*/
select distinct B.last_name, A.first_name, B.first_name
from 
(select booking_date, nights, first_name, last_name
from booking
inner join guest on guest_id = id ) as A,
(select booking_date, nights, first_name, last_name
from booking
inner join guest on guest_id = id ) as B
where A.last_name = B.last_name and A.first_name <> B.first_name 
and 
date(A.booking_date) < date(B.booking_date) + B.nights 
and
date(A.booking_date) + A.nights > date(B.booking_date)

group by last_name
order by last_name

/*12.
Check out per floor. The first digit of the room number indicates the floor – e.g. room 201 is on the 2nd floor. For each day of the week beginning 2016-11-14 show how many rooms are being vacated that day by floor number. Show all days in the correct order.*/

/*13.
Free rooms? List the rooms that are free on the day 25th Nov 2016.*/
select id
from room
where id not in (
select distinct room_no
from booking
where date(booking_date) <= date('2016-11-25') and date(booking_date) + nights > date('2016-11-25'))

/*14.
Single room for three nights required. A customer wants a single room for three consecutive nights. Find the first available date in December 2016.*/
select id, booking_date, date(booking_date)+nights as check_out_date, 1 as row_number
from room
left join booking on room_no = id
where room_type = 'single' and date(booking_date) >= date('2016-12-01')

/*15.
Gross income by week. Money is collected from guests when they leave. For each Thursday in November and December 2016, show the total amount of money collected from the previous Friday to that day, inclusive.*/


