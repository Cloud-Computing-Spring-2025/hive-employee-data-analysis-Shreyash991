SELECT e.*, d.location 
FROM employees_cleaned e 
JOIN departments d 
ON e.department = d.department_name;