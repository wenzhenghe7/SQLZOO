/*https://sqlzoo.net/wiki/AdventureWorks*/

/*1.
Show the first name and the email address of customer with CompanyName 'Bike World'*/
select FirstName, EmailAddress, CompanyName
from Customer
where CompanyName = 'Bike World'

/*2.
Show the CompanyName for all customers with an address in City 'Dallas'.*/
select distinct CompanyName
from Customer as A
inner join CustomerAddress as B on A.CustomerID = B.CustomerID
inner join Address as C on B.AddressID = C.AddressID
where City = 'Dallas'


/*3.
How many items with ListPrice more than $1000 have been sold?*/
select count(*), sum(OrderQty)
from SalesOrderDetail as A
inner join Product as B on A.ProductID = B.ProductID
where ListPrice > 1000

/*4.
Give the CompanyName of those customers with orders over $100000. Include the subtotal plus tax plus freight.*/
select CompanyName
from Customer as A
inner join SalesOrderHeader as B on A.CustomerID = B.CustomerID
where SubTotal + TaxAmt + Freight > 100000

/*5.
Find the number of left racing socks ('Racing Socks, L') ordered by CompanyName 'Riding Cycles'*/
select sum(OrderQty)
from Customer as A
inner join SalesOrderHeader as B on A.CustomerID =B.CustomerID
inner join SalesOrderDetail as C on B.SalesOrderID = C.SalesOrderID
inner join Product as D on C.ProductID = D.ProductID
where CompanyName = 'Riding Cycles' and Name = 'Racing Socks, L'

/*6.
A "Single Item Order" is a customer order where only one item is ordered. Show the SalesOrderID and the UnitPrice for every Single Item Order.*/
select SalesOrderID, min(UnitPrice)
from SalesOrderDetail
group by SalesOrderID
having sum(OrderQty) = 1

/*7.
Where did the racing socks go? List the product name and the CompanyName for all Customers who ordered ProductModel 'Racing Socks'.*/
select D.Name, CompanyName
from Customer as A
inner join SalesOrderHeader as B on A.CustomerID =B.CustomerID
inner join SalesOrderDetail as C on B.SalesOrderID = C.SalesOrderID
inner join Product as D on C.ProductID = D.ProductID
inner join ProductModel as E on D.ProductModelID= E.ProductModelID
where E.Name = 'Racing Socks'

/*8.
Show the product description for culture 'fr' for product with ProductID 736.*/
select Description, Culture, A.ProductID
from Product as A
inner join ProductModelProductDescription as B on A.ProductModelID = B.ProductModelID
inner join ProductDescription as C on B. ProductDescriptionID = C.ProductDescriptionID
where Culture = 'fr' and A.ProductID = 736

/*9.
Use the SubTotal value in SaleOrderHeader to list orders from the largest to the smallest. For each order show the CompanyName and the SubTotal and the total weight of the order.*/
select A.SalesOrderID, CompanyName, SubTotal, sum(OrderQty*Weight) as TotalWeight
from SalesOrderHeader as A
inner join Customer as B on A.CustomerID = B.CustomerID
inner join SalesOrderDetail as C on A.SalesOrderID = C.SalesOrderID
inner join Product as D on C.ProductID = D.ProductID
group by A.SalesOrderID,CompanyName,SubTotal
order by SubTotal DESC

/*10.
How many products in ProductCategory 'Cranksets' have been sold to an address in 'London'?*/
select count(A.ProductID)
from Product as A
inner join ProductCategory as B on A.ProductCategoryID = B.ProductCategoryID
inner join SalesOrderDetail as C on A.ProductID = C.ProductID
inner join SalesOrderHeader as D on C.SalesOrderID = D.SalesOrderID
inner join Address as E on D.BillToAddressID = E.AddressID
where B.Name = 'Cranksets' and E.City = 'London'

/*11.
For every customer with a 'Main Office' in Dallas show AddressLine1 of the 'Main Office' and AddressLine1 of the 'Shipping' address - if there is no shipping address leave it blank. Use one row per customer.*/
select C.AddressLine1 as Main_office, E.AddressLine1 as Shipping, C.City
from Customer as A
inner join CustomerAddress as B on A.CustomerID = B.CustomerID
inner join Address as C on B.AddressID = C.AddressID
inner join SalesOrderHeader as D on A.CustomerID = D.CustomerID
inner join Address as E on D.ShipToAddressID = E.AddressID
where C.city = 'Dallas'


/*12.
For each order show the SalesOrderID and SubTotal calculated three ways:
A) From the SalesOrderHeader
B) Sum of OrderQty*UnitPrice
C) Sum of OrderQty*ListPrice
*/
select A.SalesOrderID, min(SubTotal), Sum(OrderQty*UnitPrice), Sum(OrderQty*ListPrice)
from SalesOrderHeader as A
inner join SalesOrderDetail as B on A.SalesOrderID = B.SalesOrderID
inner join Product as C on B.ProductID = C.ProductID
group by A.SalesOrderID

/*13.
Show the best selling item by value.*/
select B.ProductID, C.Name, Sum(OrderQty) as TotalQty
from SalesOrderHeader as A
inner join SalesOrderDetail as B on A.SalesOrderID = B.SalesOrderID
inner join Product as C on B.ProductID = C.ProductID
group by B.ProductID,C.Name 
order by TotalQty DESC, B.ProductID

/*14.
Show how many orders are in the following ranges (in $):
Show how many orders are in the following ranges (in $):

    RANGE      Num Orders      Total Value
    0-  99
  100- 999
 1000-9999
10000-*/
SELECT range_, count(*), sum(SubTotal)
FROM(select SalesOrderID, 
case when SubTotal >=0 and SubTotal <=99 then '0-99'
when SubTotal >=100 and SubTotal <= 999 then '100-999'
when SubTotal >=1000 and SubTotal <= 9999 then '1000-9999'
else '10000-' end AS range_,
SubTotal
from SalesOrderHeader as A) AS B
group by range_

/*15.
Identify the three most important cities. Show the break down of top level product category against city.*/
select City, Name, TotalQty
from
(select City, Name, TotalQty, sum(id) over (partition by Name order by TotalQty DESC) as seq
from 
(select City, D.Name, sum(OrderQty) as TotalQty, 1 as id
from SalesOrderHeader as A
inner join SalesOrderDetail as B on A.SalesOrderID = B.SalesOrderID
inner join Product as C on B.ProductID = C.ProductID
inner join ProductCategory as D on C.ProductCategoryID = D.ProductCategoryID
inner join Address as E on A.ShipToAddressID = E.AddressID
group by City, D.ProductCategoryID, D.Name) as A) as B
where seq <= 3

/*resit questions*/
/*1.
List the SalesOrderNumber for the customer 'Good Toys' 'Bike World'*/
select A.SalesOrderID
from SalesOrderHeader as A 
inner join Customer as B on A.CustomerID = B.CustomerID
where CompanyName in ('Good Toys','Bike World')

/*2.
List the ProductName and the quantity of what was ordered by 'Futuristic Bikes'*/
select A.Name, OrderQty
from Product as A
inner join SalesOrderDetail as B on A.ProductID = B.ProductID
inner join SalesOrderHeader as C on B.SalesOrderID = C.SalesOrderID
inner join Customer as D on C.CustomerID = D.CustomerID
where D.CompanyName = 'Futuristic Bikes'

/*3.
List the name and addresses of companies containing the word 'Bike' (upper or lower case) and companies containing 'cycle' (upper or lower case). Ensure that the 'bike's are listed before the 'cycles's.*/
select AddressLine1, CompanyName, 
case 
when A.CompanyName like '%Bike%' or A.CompanyName like '%bike%' then 1
when A.CompanyName like '%Cycle%' or A.CompanyName like '%cycle%' then 2
else 0 end as id
from Customer as A
inner join CustomerAddress as B on A.CustomerID = B.CustomerID
inner join Address as C on B.AddressID = C.AddressID
having id > 0
order by id


/*4.
Show the total order value for each CountryRegion. List by value with the highest first.*/
select CountyRegion, sum(SubTotal) as TotalValue
from SalesOrderHeader as A
inner join Address as B on A.BillToAddressID = B.AddressID
group by CountyRegion
order by TotalValue DESC

/*5.
Find the best customer in each region.*/
select TotalValue, max(TotalValue) over (partition by CountyRegion) as 'MaxValue', CompanyName, CountyRegion
from (select sum(SubTotal) as TotalValue, A.CustomerID, A.CompanyName, C. CountyRegion
from Customer as A
inner join CustomerAddress as B on A.CustomerID = B.CustomerID
inner join Address as C on B.AddressID = C.AddressID
inner join SalesOrderHeader as D on A.CustomerID = D.CustomerID
group by A.CustomerID, A.CompanyName, C. CountyRegion
order by TotalValue DESC) as A
where MaxValue = TotalValue, 