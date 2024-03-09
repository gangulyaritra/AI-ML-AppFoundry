CREATE TABLE employees (
  emp_id INT PRIMARY KEY, 
  emp_name VARCHAR(30), 
  job_name VARCHAR(20), 
  manager_id INT, 
  hire_date DATE, 
  salary DECIMAL(10, 2), 
  dept_id INT
);

CREATE TABLE department (
  dept_id INT PRIMARY KEY, 
  dept_name VARCHAR(30), 
  dept_location VARCHAR(20)
);

INSERT INTO employees (emp_id, emp_name, job_name, manager_id, hire_date, salary, dept_id)
VALUES
    (68319, 'KAYLING', 'PRESIDENT', NULL, '1991-11-18', 6000.00, 1001),
    (66928, 'BLAZE', 'MANAGER', 68319, '1991-05-01', 2750.00, 3001),
    (67832, 'CLARE', 'MANAGER', 68319, '1991-06-09', 2750.00, 1001),
    (65646, 'JONAS', 'MANAGER', 68319, '1991-04-02', 2957.00, 2001),
    (67858, 'SCARLET', 'ANALYST', 65646, '1997-04-19', 3100.00, 2001),
    (69062, 'FRANK', 'ANALYST', 65646, '1991-12-03', 3100.00, 2001),
    (63679, 'SANDRINE', 'CLERK', 69062, '1990-12-18', 900.00, 2001),
    (64989, 'ADELYN', 'SALESMAN', 66928, '1991-02-20', 1700.00, 3001),
    (65271, 'WADE', 'SALESMAN', 66928, '1991-02-22', 1350.00, 3001),
    (66564, 'MADDEN', 'SALESMAN', 66928, '1991-09-28', 1350.00, 3001),
    (68454, 'TUCKER', 'SALESMAN', 66928, '1991-09-08', 1600.00, 3001),
    (68736, 'ADNRES', 'CLERK', 67858, '1997-05-23', 1200.00, 2001),
    (69000, 'JULIUS', 'CLERK', 66928, '1991-12-03', 1050.00, 3001),
    (69324, 'MARKER', 'CLERK', 67832, '1992-01-23', 1400.00, 1001);
    

INSERT INTO department (dept_id, dept_name, dept_location)
VALUES
    (1001, 'IT', 'B Block'),
    (2001, 'HR', 'D Block'),
    (3001, 'Operations', 'E Block'),
    (4001, 'Finance', 'G Block');
    

# Question 1: Find the maximum salary earned by an employee.
SELECT MAX(salary) FROM employees;

# Question 2: Find the maximum salary earned by an employee in each department.
SELECT d.dept_name, MAX(e.salary) FROM employees e LEFT JOIN department d ON e.dept_id=d.dept_id GROUP BY d.dept_name;

# Question 3: Demonstration of Window function in SQL.
SELECT e.*, MAX(salary) OVER() AS 'max_salary' FROM employees e;

# Question 4: Extract the maximum salary corresponding to each department.
SELECT e.*, MAX(e.salary) OVER(PARTITION BY e.dept_id) AS 'max_salary' FROM employees e LEFT JOIN department d ON e.dept_id=d.dept_id ORDER BY e.dept_id;

# Question 5: ROW_NUMBER() - Assign a unique value to each of the records in the table.
SELECT e.*, ROW_NUMBER() OVER() AS 'rn' FROM employees e;

# Question 6: Assign a row number to all the records based on different department names.
SELECT e.*, ROW_NUMBER() OVER(PARTITION BY e.dept_id) AS 'rn' FROM employees e LEFT JOIN department d ON e.dept_id=d.dept_id ORDER BY e.dept_id;

# Question 7: Fetch the first 2 employees from each department to join the company.
-- Assume that the `emp_id` of employees who joined previously would be lower than the `emp_id` of employees who joined later.
SELECT * FROM (
	SELECT e.*, ROW_NUMBER() OVER(PARTITION BY e.dept_id ORDER BY e.hire_date) AS 'rn' 
    FROM employees e LEFT JOIN department d ON e.dept_id=d.dept_id
) x
WHERE x.rn < 3 ORDER BY x.dept_id;

# Question 8: RANK() Function - Fetch the TOP 3 employees in each department earning the maximum salary.
SELECT * FROM (
	SELECT e.*, RANK() OVER(PARTITION BY e.dept_id ORDER BY e.salary DESC) AS 'rnk' 
    FROM employees e LEFT JOIN department d ON e.dept_id=d.dept_id
) x
WHERE x.rnk < 4 ORDER BY x.dept_id;

# Question 9: DENSE_RANK() Function - Fetch the TOP 3 employees in each department earning the maximum salary.
SELECT * FROM (
	SELECT e.*, DENSE_RANK() OVER(PARTITION BY e.dept_id ORDER BY e.salary DESC) AS 'dense_rnk' 
    FROM employees e LEFT JOIN department d ON e.dept_id=d.dept_id
) x
WHERE x.dense_rnk < 4 ORDER BY x.dept_id;

# Question 10: Difference between RANK() and DENSE_RANK() Function in SQL.
SELECT 
	e.*,
	RANK() OVER(PARTITION BY e.dept_id ORDER BY e.salary DESC) AS 'rnk',
	DENSE_RANK() OVER(PARTITION BY e.dept_id ORDER BY e.salary DESC) AS 'dense_rnk' 
FROM employees e LEFT JOIN department d ON e.dept_id=d.dept_id ORDER BY e.dept_id;

# Question 11: LAG() Function - Fetch a Query to display if the salary of an employee is higher, lower or equal to the previous employee.
SELECT 
	e.*, 
	LAG(e.salary) OVER(PARTITION BY e.dept_id ORDER BY e.emp_id) AS 'prev_emp_salary', 
	LEAD(e.salary) OVER(PARTITION BY e.dept_id ORDER BY e.emp_id) AS 'next_emp_salary'
FROM employees e LEFT JOIN department d ON e.dept_id=d.dept_id ORDER BY e.dept_id;

SELECT e.*, LAG(e.salary) OVER(PARTITION BY e.dept_id ORDER BY e.emp_id) AS 'prev_emp_salary', 
CASE 
	WHEN e.salary > LAG(e.salary) OVER(PARTITION BY e.dept_id ORDER BY e.emp_id) THEN 'Higher than Previous Employee'
    WHEN e.salary < LAG(e.salary) OVER(PARTITION BY e.dept_id ORDER BY e.emp_id) THEN 'Lower than Previous Employee'
    WHEN e.salary = LAG(e.salary) OVER(PARTITION BY e.dept_id ORDER BY e.emp_id) THEN 'Same as Previous Employee'
    ELSE 'None'
END AS 'Salary Range'
FROM employees e LEFT JOIN department d ON e.dept_id=d.dept_id ORDER BY e.dept_id;
