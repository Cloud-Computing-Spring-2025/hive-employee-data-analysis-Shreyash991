SELECT * FROM (
    SELECT emp_id, name, department, salary, 
           RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
    FROM employees_cleaned
) ranked_employees
WHERE salary_rank <= 3;