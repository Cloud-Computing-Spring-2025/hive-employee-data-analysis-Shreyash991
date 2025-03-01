SELECT job_role, COUNT(*) AS count 
FROM employees 
GROUP BY job_role;