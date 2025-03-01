WITH dept_avg AS (
    SELECT department, AVG(salary) AS avg_salary 
    FROM employees 
    GROUP BY department
)
SELECT e.* 
FROM employees e 
JOIN dept_avg d 
ON e.department = d.department 
WHERE e.salary > d.avg_salary;
