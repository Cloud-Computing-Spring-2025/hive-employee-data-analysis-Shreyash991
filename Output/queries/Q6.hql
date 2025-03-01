SELECT department, COUNT(*) AS num_employees 
FROM employees 
GROUP BY department 
ORDER BY num_employees DESC 
LIMIT 1;
