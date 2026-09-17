create database HR_Analysis;
select * from hr_1;
select * from hr_2;


-- Total Head Count
select concat(round((count(EmployeeNumber)/1000),0),'K') as Total_Head_Count from hr_1;

-- Total Male Staff
select gender,count(EmployeeNumber) as Toatal_Male_Staff from hr_1 where gender="Male";

-- Total Female Staff
select gender,count(EmployeeNumber) as Total_Female_Staff from hr_1 where gender="Female";

-- Gender wise Average age 
select gender, round(avg(ï»¿Age)) as Avg_Age from hr_1 group by gender;


-- Avg Attrition Rate
select concat(round((sum(case attrition when 'Yes' then 1 else 0 end)/count(*))*100,2),"%") as Avg_Attrition from hr_1 ;


-- Department Wise Employees
select Department,count(*) as Employees_count from hr_1
group by Department 
order by count(*) desc;


----------------------------------- KPI-1
-- Departmeant wise Avg Attrition Rate
select Department,concat(round((sum(case attrition when 'Yes' then 1 else 0 end)/count(*))*100,2),"%") as Avg_Attrition from hr_1
group by Department order by Avg_Attrition desc;

----------------------------------- KPI-2

-- Average Hourly rate of Male Research Scientist
select department,gender,round(avg(hourlyrate)) as Avg_Hourly_Rate from hr_1 where gender="Male" and Department="Research & Development";

----------------------------------- KPI-3

-- Attrition rate Vs Monthly income stats      

select floor(monthlyincome/10000)*10000 as income_bin ,
sum(case attrition when 'yes' then 1 else 0 end)/count(employeecount)*100 as Atr_rate 
from  hr_1
inner join hr_2
on hr_1.EmployeeNumber = hr_2.`ï»¿Employee ID`
group by income_bin
order by income_bin ;

----------------------------------- KPI-4

-- Average working years for each Department

select h1.department,round(avg(h2.TotalWorkingYears)) as Avg_Working_Years from hr_1 as h1 join hr_2 as h2 on h1.EmployeeNumber=h2.`ï»¿Employee ID` 
group by h1.Department order by avg_working_years desc;

----------------------------------- KPI-5

-- Job Role Vs Work life balance
select h1.jobrole,
case 
	when h2.worklifebalance=1 then 'Excelent'
	when h2.WorkLifeBalance=2 then 'Good'
	when h2.WorkLifeBalance=3 then 'Average'
	when h2.WorkLifeBalance=4 then 'Poor'
	else 'Worst'
end as WorkLifeBalance
from hr_1 as h1 join hr_2 as h2 
 on h1.EmployeeNumber=h2.`ï»¿Employee ID`
group by h1.jobrole,h2.WorkLifeBalance;

----------------------------------- KPI-6

-- Attrition rate Vs Year since last promotion relation

select distinct YearsSinceLastPromotion, concat(round((sum(case attrition when 'Yes' then 1 else 0 end)/count(*))*100,2),"%") as Avg_Attrition from 
hr_1 join hr_2  on EmployeeNumber=`ï»¿Employee ID`
group by YearsSinceLastPromotion order by avg_attrition desc;
 
 ----------------------------------- KPI-7
 --  Marital Status Wise  attrition
 
 select maritalstatus, concat(round((sum(case attrition when 'Yes' then 1 else 0 end)/count(*))*100,2),"%") as Avg_Attrition 
 from hr_1 group by MaritalStatus;
 
----------------------------------- KPI-8
 
 -- Department Wise Average performance Rating
 
 select department,avg(PerformanceRating) as Avg_Performance_Rating from 
 hr_1 join hr_2  on EmployeeNumber=`ï»¿Employee ID`
 group by department order by avg_performance_rating desc;
 
 
 ----------------------------------- KPI-9
 
 -- Travel Wise Attrition Rate
 
 select BusinessTravel, concat(round((sum(case attrition when 'Yes' then 1 else 0 end)/count(*))*100,2),"%") as Avg_Attrition 
 from hr_1 group by BusinessTravel;

