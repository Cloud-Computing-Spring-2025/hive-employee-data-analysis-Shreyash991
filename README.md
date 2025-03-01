# Assignment #2: Hive - Employee and Department Data Analysis

## Problem Statement
You are provided with two datasets: `employees.csv` and `departments.csv`. The objective of this assignment is to analyze employee and department data using Hive queries.

## Dataset Details
### employees.csv
This dataset contains information about employees, including their department, job role, salary, and project assignment.

- `emp_id` - Unique employee ID  
- `name` - Employee's full name  
- `age` - Employee's age  
- `job_role` - Designation of the employee  
- `salary` - Annual salary of the employee  
- `project` - Assigned project (One of: Alpha, Beta, Gamma, Delta, Omega)  
- `join_date` - Date when the employee joined  
- `department` - Department to which the employee belongs (Used for partitioning)  

### departments.csv
This dataset contains information about different departments in the company.

- `dept_id` - Unique department ID  
- `department_name` - Name of the department  
- `location` - Location of the department  

## Tasks
1. Load data from `employees.csv` into a temporary Hive table.
2. Transform and move data to the actual partitioned table in Hive.
3. Ensure that data is loaded correctly into a partitioned table using the `ALTER TABLE` statement.
4. Perform the following queries:
   - Retrieve all employees who joined after 2015.
   - Find the average salary of employees in each department.
   - Identify employees working on the 'Alpha' project.
   - Count the number of employees in each job role.
   - Retrieve employees whose salary is above the average salary of their department.
   - Find the department with the highest number of employees.
   - Check for employees with null values in any column and exclude them from analysis.
   - Join the employees and departments tables to display employee details along with department locations.
   - Rank employees within each department based on salary.
   - Find the top 3 highest-paid employees in each department.
5. Provide the final output in both HQL queries (`.hql` files) and a README file (with SQL queries and commands for execution).

## Execution Steps
### Load Data into Hive Temporary Table
Upload the File to HDFS
Log into the Namenode container:
```sh
docker exec -it namenode /bin/bash
```

Upload `employees.csv` and `departments.csv` to HDFS:
```sh
hdfs dfs -put employees.csv /user/hive/warehouse/
hdfs dfs -put departments.csv /user/hive/warehouse/
```
Verify that the file is successfully uploaded:
```sh
hdfs dfs -ls /user/hive/warehouse/
```

Create a temporary table in Hive to load the employee data:
```sql
CREATE TABLE temp_employees (
    emp_id STRING,
    name STRING,
    age INT,
    job_role STRING,
    salary DOUBLE,
    project STRING,
    join_date STRING,
    department STRING
) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE;
```
Load data into the temporary table:
```sql
LOAD DATA INPATH '/user/hive/warehouse/employees.csv' 
INTO TABLE temp_employees;
```

### Transform and Move Data to a Partitioned Table
Create the partitioned table:
```sql
CREATE TABLE employees (
    emp_id STRING,
    name STRING,
    age INT,
    job_role STRING,
    salary DOUBLE,
    project STRING,
    join_date STRING
) 
PARTITIONED BY (department STRING)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
STORED AS PARQUET;
```
Insert data into the partitioned table:
```sql
SET hive.exec.dynamic.partition.mode=nonstrict;
INSERT INTO TABLE employees PARTITION (department)
SELECT emp_id, name, age, job_role, salary, project, join_date, department
FROM temp_employees;
```
Verify partitioning:
```sql
SHOW PARTITIONS employees;
```

## Query Execution
### Run Queries
1.Retrieve employees who joined after 2015:
```sql
SELECT * FROM employees WHERE year(join_date) > 2015;
```
2.Find the average salary of employees in each department:
```sql
SELECT department, AVG(salary) AS avg_salary 
FROM employees 
GROUP BY department;
```
3.Identify employees working on the 'Alpha' project:
```sql
SELECT * FROM employees WHERE project = 'Alpha';
```
4.Count the number of employees in each job role:
```sql
SELECT job_role, COUNT(*) AS count 
FROM employees 
GROUP BY job_role;
```
5.Retrieve employees whose salary is above the average salary of their department:
```sql
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
```
6.Find the department with the highest number of employees:
```sql
SELECT department, COUNT(*) AS num_employees 
FROM employees 
GROUP BY department 
ORDER BY num_employees DESC 
LIMIT 1;
```
7.Check for employees with null values and exclude them:
```sql
SELECT * FROM employees 
WHERE emp_id IS NOT NULL 
AND name IS NOT NULL 
AND age IS NOT NULL 
AND job_role IS NOT NULL 
AND salary IS NOT NULL 
AND project IS NOT NULL 
AND join_date IS NOT NULL 
AND department IS NOT NULL;
```
Create a New Cleaned Table

```sql
CREATE TABLE employees_cleaned AS 
SELECT * FROM employees 
WHERE emp_id IS NOT NULL 
AND name IS NOT NULL 
AND age IS NOT NULL 
AND job_role IS NOT NULL 
AND salary IS NOT NULL 
AND project IS NOT NULL 
AND join_date IS NOT NULL 
AND department IS NOT NULL;
```
8.Join the employees and departments tables to display employee details along with department locations.

```sql
SELECT e.*, d.location 
FROM employees_cleaned e 
JOIN departments d 
ON e.department = d.department_name;

```
9.Rank employees within each department based on salary.

```sql
SELECT emp_id, name, department, salary, 
       RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
FROM employees_cleaned;

```
10.Find the top 3 highest-paid employees in each department.

```sql
SELECT * FROM (
    SELECT emp_id, name, department, salary, 
           RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
    FROM employees_cleaned
) ranked_employees
WHERE salary_rank <= 3;
```

## How to Execute Each File in Hive
Run each `.hql` file and save the output:
```sh
hive -f employees_joined_after_2015.hql > output_joined_after_2015.txt
```

## Challenges Faced
- **Error: Dynamic Partitioning Strict Mode**: Resolved by setting `hive.exec.dynamic.partition.mode=nonstrict`.

- **Output Format Issues**: Ensured proper text formatting while writing results.

## Sample Input and Output
### Sample Query
```
SELECT department, AVG(salary) AS avg_salary 
FROM employees 
GROUP BY department;
```
### Sample Employee Data (CSV Format)
```csv
emp_id,name,age,job_role,salary,project,join_date,department
101,John Doe,30,Engineer,75000,Alpha,2018-06-15,IT
102,Jane Smith,28,Manager,90000,Beta,2016-09-10,HR
103,Mark Lee,35,Analyst,67000,Alpha,2014-03-20,Finance
```
### Expected Output (CSV Format)
```csv
department,avg_salary
Finance,93945.51874999996
HR,92448.81040816318
IT,93761.02570707069
Marketing,93146.16827586209

```

This document provides a structured approach to working with Hive queries and analyzing employee data efficiently.


