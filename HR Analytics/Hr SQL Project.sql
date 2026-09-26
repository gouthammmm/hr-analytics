-- HR Analytics: Workforce and Attrition Review
-- Dialect: MySQL 8+
-- Import the workbook data into hr_1 and hr_2 before running these queries.
-- Clean any UTF-8 BOM from imported headers (Age, Employee ID) first.

CREATE DATABASE IF NOT EXISTS HR_Analysis;
USE HR_Analysis;

-- 0. Data checks: duplicate employee IDs and coverage of the second table.
SELECT COUNT(*) AS hr_1_rows,
       COUNT(DISTINCT EmployeeNumber) AS distinct_employee_ids
FROM hr_1;

SELECT COUNT(*) AS hr_1_rows,
       COUNT(DISTINCT h1.EmployeeNumber) AS distinct_hr_1_employees,
       COUNT(DISTINCT h2.`Employee ID`) AS matched_hr_2_employees,
       SUM(h2.`Employee ID` IS NULL) AS unmatched_hr_1_rows
FROM hr_1 AS h1
LEFT JOIN hr_2 AS h2 ON h1.EmployeeNumber = h2.`Employee ID`;

-- 1. Workforce snapshot and overall attrition rate.
SELECT COUNT(DISTINCT EmployeeNumber) AS headcount,
       COUNT(DISTINCT CASE WHEN Attrition = 'Yes' THEN EmployeeNumber END) AS attrition_count,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN Attrition = 'Yes' THEN EmployeeNumber END)
             / NULLIF(COUNT(DISTINCT EmployeeNumber), 0), 2) AS attrition_rate_pct
FROM hr_1;

-- 2. Department mix and attrition. Rates stay numeric for charting.
SELECT Department,
       COUNT(DISTINCT EmployeeNumber) AS employees,
       COUNT(DISTINCT CASE WHEN Attrition = 'Yes' THEN EmployeeNumber END) AS attrition_count,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN Attrition = 'Yes' THEN EmployeeNumber END)
             / NULLIF(COUNT(DISTINCT EmployeeNumber), 0), 2) AS attrition_rate_pct
FROM hr_1
GROUP BY Department
ORDER BY attrition_rate_pct DESC, employees DESC;

-- 3. Attrition by age band and gender.
SELECT CASE
           WHEN Age < 25 THEN 'Under 25'
           WHEN Age < 35 THEN '25-34'
           WHEN Age < 45 THEN '35-44'
           WHEN Age < 55 THEN '45-54'
           ELSE '55+'
       END AS age_band,
       Gender,
       COUNT(DISTINCT EmployeeNumber) AS employees,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN Attrition = 'Yes' THEN EmployeeNumber END)
             / NULLIF(COUNT(DISTINCT EmployeeNumber), 0), 2) AS attrition_rate_pct
FROM hr_1
WHERE Age IS NOT NULL
GROUP BY age_band, Gender
ORDER BY age_band, Gender;

-- 4. Attrition by business travel category.
SELECT BusinessTravel,
       COUNT(DISTINCT EmployeeNumber) AS employees,
       COUNT(DISTINCT CASE WHEN Attrition = 'Yes' THEN EmployeeNumber END) AS attrition_count,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN Attrition = 'Yes' THEN EmployeeNumber END)
             / NULLIF(COUNT(DISTINCT EmployeeNumber), 0), 2) AS attrition_rate_pct
FROM hr_1
GROUP BY BusinessTravel
ORDER BY attrition_rate_pct DESC;

-- 5. Attrition by monthly-income band; employees without a match are excluded.
WITH income_segments AS (
    SELECT h1.EmployeeNumber, h1.Attrition,
           CASE
               WHEN h2.MonthlyIncome < 5000 THEN 'Under 5,000'
               WHEN h2.MonthlyIncome < 10000 THEN '5,000-9,999'
               WHEN h2.MonthlyIncome < 15000 THEN '10,000-14,999'
               ELSE '15,000+'
           END AS income_band
    FROM hr_1 AS h1
    JOIN hr_2 AS h2 ON h1.EmployeeNumber = h2.`Employee ID`
    WHERE h2.MonthlyIncome IS NOT NULL
)
SELECT income_band,
       COUNT(DISTINCT EmployeeNumber) AS employees,
       COUNT(DISTINCT CASE WHEN Attrition = 'Yes' THEN EmployeeNumber END) AS attrition_count,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN Attrition = 'Yes' THEN EmployeeNumber END)
             / NULLIF(COUNT(DISTINCT EmployeeNumber), 0), 2) AS attrition_rate_pct
FROM income_segments
GROUP BY income_band
ORDER BY MIN(CASE income_band
                 WHEN 'Under 5,000' THEN 1
                 WHEN '5,000-9,999' THEN 2
                 WHEN '10,000-14,999' THEN 3
                 ELSE 4
             END);

-- 6. Attrition by years since last promotion.
SELECT YearsSinceLastPromotion AS years_since_promotion,
       COUNT(DISTINCT EmployeeNumber) AS employees,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN Attrition = 'Yes' THEN EmployeeNumber END)
             / NULLIF(COUNT(DISTINCT EmployeeNumber), 0), 2) AS attrition_rate_pct
FROM hr_1
GROUP BY YearsSinceLastPromotion
ORDER BY years_since_promotion;

-- 7. Work-life-balance responses by job role.
-- Scale labels: 1 Bad, 2 Good, 3 Better, 4 Best.
SELECT h1.JobRole,
       CASE h2.WorkLifeBalance
           WHEN 1 THEN 'Bad'
           WHEN 2 THEN 'Good'
           WHEN 3 THEN 'Better'
           WHEN 4 THEN 'Best'
           ELSE 'Unknown'
       END AS work_life_balance,
       COUNT(DISTINCT h1.EmployeeNumber) AS employees
FROM hr_1 AS h1
JOIN hr_2 AS h2 ON h1.EmployeeNumber = h2.`Employee ID`
GROUP BY h1.JobRole, work_life_balance
ORDER BY h1.JobRole, h2.WorkLifeBalance;

-- 8. Average total working years by department and attrition outcome.
SELECT h1.Department, h1.Attrition,
       COUNT(DISTINCT h1.EmployeeNumber) AS employees,
       ROUND(AVG(h2.TotalWorkingYears), 1) AS average_total_working_years
FROM hr_1 AS h1
JOIN hr_2 AS h2 ON h1.EmployeeNumber = h2.`Employee ID`
WHERE h2.TotalWorkingYears IS NOT NULL
GROUP BY h1.Department, h1.Attrition
ORDER BY h1.Department, h1.Attrition;

-- 9. Performance rating by department and attrition outcome.
SELECT h1.Department, h1.Attrition,
       COUNT(DISTINCT h1.EmployeeNumber) AS employees,
       ROUND(AVG(h2.PerformanceRating), 2) AS average_performance_rating
FROM hr_1 AS h1
JOIN hr_2 AS h2 ON h1.EmployeeNumber = h2.`Employee ID`
WHERE h2.PerformanceRating IS NOT NULL
GROUP BY h1.Department, h1.Attrition
ORDER BY h1.Department, h1.Attrition;
