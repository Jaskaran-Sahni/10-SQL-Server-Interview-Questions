create database topqna;
use topqna;

CREATE TABLE Employee (
EmpID int NOT NULL,
EmpName Varchar(50),
Gender Char,
Salary int,
City Char(20) )


INSERT INTO Employee
VALUES (1, 'Arjun', 'M', 75000, 'Pune'),
(2, 'Ekadanta', 'M', 125000, 'Bangalore'),
(3, 'Lalita', 'F', 150000 , 'Mathura'),
(4, 'Madhav', 'M', 250000 , 'Delhi'),
(5, 'Visakha', 'F', 120000 , 'Mathura')

CREATE TABLE EmployeeDetail (
EmpID int NOT NULL,
Project Varchar(50),
EmpPosition Char(20),
DOJ date )

INSERT INTO EmployeeDetail
VALUES (1, 'P1', 'Executive', '26-01-2019'),
(2, 'P2', 'Executive', '04-05-2020'),
(3, 'P1', 'Lead', '21-10-2021'),
(4, 'P3', 'Manager', '29-11-2019'),
(5, 'P2', 'Manager', '01-08-2020')

ALTER TABLE EmployeeDetail
alter column DOJ varchar(20);

UPDATE EmployeeDetail
SET DOJ = CONVERT(DATE, DOJ, 103);

ALTER TABLE EmployeeDetail
ALTER COLUMN DOJ date;

sp_help EmployeeDetail;

select * from Employee;
select * from EmployeeDetail;

--Q1(a): Find the list of employees whose salary ranges between 2L to 3L.
select EmpID,EmpName,Salary
from Employee
where Salary between 200000 and 300000
--or
select EmpID,EmpName,Salary
from Employee
where Salary > 200000 and Salary < 300000;

--Q1(b): Write a query to retrieve the list of employees from the same city.
select t1.EmpName,t1.City from employee t1
inner join employee t2
on t1.City=t2.City and 
t1.EmpID <> t2.EmpID;


--Q1(c): Query to find the null values in the Employee table.
select *
from Employee
where EmpID is null;

--Q2(a): Query to find the cumulative sum of employee’s salary.
SELECT EmpID, Salary, SUM(Salary) OVER (ORDER BY EmpID) AS CumulativeSum
FROM Employee;

--Q2(b): What’s the male and female employees ratio.
select * from employee;
SELECT
    (SUM(CASE WHEN [GENDER] = 'M' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS MALEPCT,
    (SUM(CASE WHEN [GENDER] = 'F' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS FEMALEPCT
FROM Employee;

--or
select count(*) as 'count' from employee;
select count(*) as 'm_count' from employee where Gender='M';
select count(*) as 'f_count' from employee where Gender='F';

select m_count *100/count as 'male_ratio', f_count*100/count as 'female_ratio'
from 
(select count(*) as 'm_count' from employee where Gender='M') t1,
(select count(*) as 'count' from employee) t2,
(select count(*) as 'f_count' from employee where Gender='F') t3

-- Q2(c): Write a query to fetch 50% records from the Employee table.
select * from employee
where EmpID<= (select count(*)/2 from employee);
--or

select * from
(select *, row_number() over(order by Empid) as 'Rn' from employee) t1
where Rn<= (select count(*)/2 from employee);

--Q3: Query to fetch the employee’s salary but replace the LAST 2 digits with ‘XX’
--i.e 12345 will be 123XX
select * from employee;
sp_help employee

SELECT 
    salary,
    CONCAT(
        LEFT(Salary, LEN(Salary) - 2),
        'XX'
    ) AS ModifiedSalary
FROM Employee;

--Q4: Write a query to fetch even and odd rows from Employee table.

--for even
SELECT * FROM
(SELECT *, ROW_NUMBER() OVER(ORDER BY EmpId) AS 'RowNumber' FROM Employee) AS Emp
WHERE Emp.RowNumber % 2 = 0;

 --for odd
SELECT * FROM
(SELECT *, ROW_NUMBER() OVER(ORDER BY EmpId) AS 'RowNumber' FROM Employee) AS Emp
WHERE Emp.RowNumber % 2 <> 0;

/*
Q5(a): Write a query to find all the Employee names whose name:
• Begin with ‘A’
• Contains ‘A’ alphabet at second place
• Contains ‘Y’ alphabet at second last place
• Ends with ‘L’ and contains 4 alphabets
• Begins with ‘V’ and ends with ‘A’
*/

SELECT * FROM Employee WHERE EmpName LIKE 'A%';
SELECT * FROM Employee WHERE EmpName LIKE '_a%';
SELECT * FROM Employee WHERE EmpName LIKE '%y_';
SELECT * FROM Employee WHERE EmpName LIKE '____l';
SELECT * FROM Employee WHERE EmpName LIKE 'V%a';

/*Q5(b): Write a query to find the list of Employee names which is:
• starting with vowels (a, e, i, o, or u), without duplicates
• ending with vowels (a, e, i, o, or u), without duplicates
• starting & ending with vowels (a, e, i, o, or u), without duplicates
*/

select * from Employee;

SELECT distinct EmpName
FROM Employee
WHERE EmpName like '[aeiou]%'

SELECT distinct EmpName
FROM Employee
WHERE EmpName like '%[aeiou]'

SELECT distinct EmpName
FROM Employee
WHERE EmpName like '[aeiou]%[aeiou]'

--Q6: Find Nth highest salary from employee table with and without using the
--TOP/LIMIT keywords. Calculate 2nd highest and 3rd highest
select * from Employee;
--2nd highest
select top 1 salary from employee where salary < (SELECT MAX(Salary) FROM Employee) order by salary desc
-- or 3rd highest
SELECT TOP 1 Salary
FROM Employee
WHERE Salary < (
SELECT MAX(Salary) FROM Employee)
AND Salary NOT IN (
SELECT TOP 2 Salary
FROM Employee
ORDER BY Salary DESC)
ORDER BY Salary DESC;

--or

SELECT Salary FROM Employee E1
WHERE 1 = 
(SELECT COUNT( DISTINCT(E2.Salary))
FROM Employee E2
WHERE E2.Salary > E1.Salary);

--Q7(a): Write a query to find and remove duplicate records from a table.
select * from Employee;

SELECT EmpID ,count(*) as 'count'
FROM Employee
GROUP BY EmpID
HAVING COUNT(*) > 1;

DELETE FROM Employee
WHERE EmpID IN
(SELECT EmpID FROM Employee
GROUP BY EmpID
HAVING COUNT(*) > 1);
--or

SELECT EmpID, EmpName, gender, Salary, city,COUNT(*) AS 'duplicate_count'
FROM Employee
GROUP BY EmpID, EmpName, gender, Salary, city
HAVING COUNT(*) > 1;

--Q7(b): Query to retrieve the list of employees working in same project.
select * from employee;
select * from employeedetail;

WITH CTE AS
(SELECT e.EmpID, e.EmpName, ed.Project
FROM Employee AS e
INNER JOIN EmployeeDetail AS ed
ON e.EmpID = ed.EmpID)

SELECT c1.EmpName, c2.EmpName, c1.project
FROM CTE c1, CTE c2
WHERE c1.Project = c2.Project AND c1.EmpID != c2.EmpID AND c1.EmpID < c2.EmpID

--Q8: Show the employee with the highest salary for each project
SELECT ed.Project, MAX(e.Salary) AS ProjectmaxSal,sum(e.salary) ProjectsumSal
FROM Employee AS e
INNER JOIN EmployeeDetail AS ed
ON e.EmpID = ed.EmpID
GROUP BY Project
ORDER BY ProjectmaxSal DESC;

-- or

WITH CTE AS
(SELECT project, EmpName, salary,
ROW_NUMBER() OVER (PARTITION BY project ORDER BY salary DESC) AS row_rank
FROM Employee AS e
INNER JOIN EmployeeDetail AS ed
ON e.EmpID = ed.EmpID)
SELECT project, EmpName, salary
FROM CTE
WHERE row_rank = 1;

--Q9: Query to find the total count of employees joined each year

select * from EmployeeDetail
select * from Employee

SELECT YEAR(DOJ) AS JoinYear, COUNT(*) AS EmployeeCount
FROM EmployeeDetail ed
inner join employee e
on ed.empid=e.empid
GROUP BY YEAR(DOJ)
ORDER BY YEAR(DOJ);

--Q10: Create 3 groups based on salary col, salary less than 1L is low, between 1 -
--2L is medium and above 2L is High

SELECT EmpName, Salary,
CASE
WHEN Salary > 200000 THEN 'High'
WHEN Salary >= 100000 AND Salary <= 200000 THEN 'Medium'
ELSE 'Low'
END AS SalaryStatus
FROM Employee;

/*Ques Query to pivot the data in the Employee table and retrieve the total
salary for each city.
The result should display the EmpID, EmpName, and separate columns for each city
(Mathura, Pune, Delhi), containing the corresponding total salary.
*/

SELECT
EmpID,
EmpName,
SUM(CASE WHEN City = 'Mathura' THEN Salary END) AS "Mathura",
SUM(CASE WHEN City = 'Pune' THEN Salary END) AS "Pune",
SUM(CASE WHEN City = 'Delhi' THEN Salary END) AS "Delhi"
FROM Employee
GROUP BY EmpID, EmpName;












