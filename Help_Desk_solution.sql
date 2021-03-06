/*https://sqlzoo.net/wiki/Help_Desk*/
/*Part 1 Easy*/
/*1.
There are three issues that include the words "index" and "Oracle". Find the call_date for each of them*/
SELECT call_date, call_ref FROM Issue
where Detail LIKE '%index%' and Detail LIKE '%Oracle%'

/*2.
Samantha Hall made three calls on 2017-08-14. Show the date and time for each*/
select call_date, first_name, last_name
from Caller
inner join Issue on Caller.Caller_id = Issue.Caller_id
where first_name = 'Samantha' and last_name = 'Hall' and DATE(call_date) = DATE('2017-08-14')

/*3.
There are 500 calls in the system (roughly). Write a query that shows the number that have each status.*/
select status, count(status) as volumn
from Issue
group by status

/*4.
Calls are not normally assigned to a manager but it does happen. How many calls have been assigned to staff who are at Manager Level?*/
select count(*)
from Issue
inner join Staff on Assigned_to = Staff_code
inner join Level on Staff.Level_code = Level.Level_code
where Manager = 'Y'

/*5.
Show the manager for each shift. Your output should include the shift date and type; also the first and last name of the manager.*/
select Shift_date, Shift_type, first_name, last_name
from Shift
inner join Staff on Manager = Staff_code

/*Part 2 Medium*/
/*6.
List the Company name and the number of calls for those companies with more than 18 calls.*/
select Company_name, count(*) as cc
from Issue
inner join Caller on Issue.Caller_id = Caller.Caller_id
inner join Customer on Caller.Company_ref = Customer.Company_ref
group by Company_name
having cc > 18

/*7.
Find the callers who have never made a call. Show first name and last name*/
select first_name, last_name
from Caller
left join Issue on Issue.Caller_id = Caller.Caller_id
where call_date is NULL

/*8.
For each customer show: Company name, contact name, number of calls where the number of calls is fewer than 5*/
select Company_name, count(*) as cc, A.first_name, A.last_name
from Issue
inner join Caller on Issue.Caller_id = Caller.Caller_id
inner join Customer on Caller.Company_ref = Customer.Company_ref
inner join Caller A on Customer.Contact_id = A.Caller_id
group by Company_name, A.first_name, A.last_name
having cc < 5

/*9.
For each shift show the number of staff assigned. Beware that some roles may be NULL and that the same person might have been assigned to multiple roles (The roles are 'Manager', 'Operator', 'Engineer1', 'Engineer2').*/
select shift_date, shift_type, count(distinct(role))
from
(select shift_date, shift_type, manager as role
from Shift
UNION ALL
select shift_date, shift_type, operator as role
from Shift
UNION ALL
select shift_date, shift_type, Engineer1 as role
from Shift
UNION ALL
select shift_date, shift_type, Engineer2 as role
from Shift) as A
group by Shift_date, Shift_type

/*10.
Caller 'Harry' claims that the operator who took his most recent call was abusive and insulting. Find out who took the call (full name) and when.*/
select Staff.First_name, Staff.Last_name, call_date
from Caller
inner join Issue on Caller.Caller_id = Issue.Caller_id
inner join Staff on Staff_code = Taken_by
where Caller.First_name = 'Harry'
order by call_date DESC
LIMIT 1

/*11.Show the manager and number of calls 
received for each hour of the day on 2017-08-12*/
select Manager, A.hour,count(*)
from Shift AS B
inner join 
(select DATE(call_date) as date, DATE_FORMAT(call_date,'%Y-%m-%d %H') as hour, 
case when HOUR(call_date) > 8 then 'Early'
     else 'Late' END AS Shift_type
     from Issue) A on B.Shift_date = A.date AND B.Shift_type= A.Shift_type
where A.date = DATE('2017-08-12')
group by Manager, A.hour

/*12.
80/20 rule. It is said that 80% of the calls are generated by 20% of the callers. Is this true? What percentage of calls are generated by the most active 20% of callers.
Note - Andrew has not managed to do this in one query - but he believes it is possible*/
select sum(call_count)/min(total_count)
from 
(select caller_id, call_count, 
sum(row_count) over (order by call_count DESC) AS row_count_cum, 
sum(row_count) over (partition by 1) as total_num_caller,
sum(call_count) over (partition by 1) as total_count
from
(select distinct caller_id, count(*) over (partition by caller_id) as call_count, 1 as row_count
from Issue) as A 
order by row_count_cum DESC) as B
where row_count_cum/total_num_caller <= 0.2