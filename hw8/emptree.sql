-- [Problem 1]
DROP FUNCTION IF EXISTS total_salaries_adjlist;
-- Takes as input an employee id. Computes the total salary of the employee wih
-- that id and all employees in the subtree managed by that employee (the 
-- employees managed by the specified employee, the employees those employees
-- manage, and so on). Uses employee_adjlist.
DELIMITER $
CREATE FUNCTION total_salaries_adjlist(e_id INTEGER) RETURNS INTEGER
BEGIN
    DECLARE tot INTEGER DEFAULT 0;
    CREATE TEMPORARY TABLE st (
        emp_id      INTEGER  NOT NULL  PRIMARY KEY,
        salary      INTEGER  NOT NULL,
        manager_id  INTEGER
    );
    INSERT INTO st SELECT emp_id, salary, manager_id FROM employee_adjlist
        WHERE employee_adjlist.emp_id = e_id;
    loop1: LOOP
        IF ROW_COUNT() = 0 THEN
            LEAVE loop1;
        END IF;
        INSERT INTO st SELECT emp_id, salary, manager_id FROM employee_adjlist
            WHERE employee_adjlist.manager_id IN (SELECT emp_id FROM st)
            AND employee_adjlist.emp_id NOT IN (SELECT emp_id FROM st);
    END LOOP;
    SET tot = (SELECT SUM(salary) FROM st);
    DROP TEMPORARY TABLE st;
    RETURN tot;
END$
DELIMITER ;


-- [Problem 2]
DROP FUNCTION IF EXISTS total_salaries_nestset;
-- Takes as input an employee id. Computes the total salary of the employee wih
-- that id and all employees in the subtree managed by that employee (the 
-- employees managed by the specified employee, the employees those employees
-- manage, and so on). Uses employee_nestset.
DELIMITER $
CREATE FUNCTION total_salaries_nestset(e_id INTEGER) RETURNS INTEGER
BEGIN
    DECLARE tot INTEGER DEFAULT 0;
    DECLARE l INTEGER DEFAULT (SELECT low FROM employee_nestset
        WHERE employee_nestset.emp_id = e_id);
    DECLARE h INTEGER DEFAULT (SELECT high FROM employee_nestset
        WHERE employee_nestset.emp_id = e_id);
    SET tot = (SELECT SUM(salary) FROM employee_nestset WHERE low >= l
        AND high <= h);
    RETURN tot;
END$
DELIMITER ;


-- [Problem 3]
WITH m AS (SELECT DISTINCT manager_id FROM employee_adjlist)
SELECT emp_id, name, salary FROM employee_adjlist LEFT JOIN m
    ON employee_adjlist.emp_id = m.manager_id
    WHERE m.manager_id IS NULL;


-- [Problem 4]
WITH lh AS (SELECT low, high FROM employee_nestset),
    m AS (SELECT DISTINCT emp_id FROM employee_nestset, lh
        WHERE employee_nestset.low < lh.low AND employee_nestset.high > lh.high)
SELECT employee_nestset.emp_id, name, salary FROM employee_nestset LEFT JOIN m
    ON employee_nestset.emp_id = m.emp_id
    WHERE m.emp_id IS NULL;


-- [Problem 5]
DROP FUNCTION IF EXISTS tree_depth;
-- Calculates the depth of a tree using employee_adjlist. A tree with a single
-- node has a depth of 1. This function works by creating a temporary table
-- with the employee id, manager id, and depth for every employee, then 
-- returning the deepest depth. It starts by adding the employee with no manager
-- (the first node in the tree) to the temporary table with a depth of 1. Then
-- it adds every employee whose manager was the first employee with a depth of
-- 2. Then every employee whose manager was one of those employees with a depth
-- of 3, and so on until every employee has been added. I chose to use 
-- employee_adjlist for this function because the adjacency list model makes it
-- very easy to find the immediate children of every node, which if you continue
-- to do and simply keep track of the depth will give you the overall depth of
-- the tree.
DELIMITER $
CREATE FUNCTION tree_depth() RETURNS INTEGER
BEGIN
-- Counter to keep track of deepest depth
    DECLARE c INTEGER;
-- I am assuming that there will only be 1 tree in the file and thus only 1
-- employee with no manager (the boss)
    DECLARE boss INTEGER DEFAULT (SELECT emp_id FROM employee_adjlist
        WHERE manager_id IS NULL);
-- Keeping track of depth in the temporary table is not necessary, but could be
-- very useful for another purpose
    CREATE TEMPORARY TABLE emps (
        emp_id      INTEGER  NOT NULL PRIMARY KEY,
        manager_id  INTEGER,
        depth       INTEGER  NOT NULL
    );
    INSERT INTO emps SELECT emp_id, manager_id, 1 FROM employee_adjlist
        WHERE emp_id = boss;
-- Case where the tree is empty we want to return a depth of 0
    IF ROW_COUNT() = 0 THEN
        RETURN 0;
    END IF;
    SET c = 1;
    loop1: LOOP
        INSERT INTO emps SELECT emp_id, manager_id, c + 1 FROM employee_adjlist
            WHERE employee_adjlist.manager_id IN (SELECT emp_id FROM emps)
            AND employee_adjlist.emp_id NOT IN (SELECT emp_id FROM emps);
-- Check if last insert did anything. If not, leaves the loop
        IF ROW_COUNT() = 0 THEN
            LEAVE loop1;
        END IF;
        SET c = c + 1;
    END LOOP;
    DROP TEMPORARY TABLE emps;
    RETURN c;
END$
DELIMITER ;


-- [Problem 6]
DROP FUNCTION IF EXISTS emp_reports;
-- Computes the number of direct reports that an employee has given an employee
-- id. If there is no employee with the given id, -1 is returned. 
DELIMITER $
CREATE FUNCTION emp_reports(e_id INTEGER) RETURNS INTEGER
BEGIN
    DECLARE c INTEGER DEFAULT 0;
-- Keep track of the high value for the given employee id to be used later
    DECLARE h INTEGER DEFAULT (SELECT high FROM employee_nestset
        WHERE employee_nestset.emp_id = e_id);
    CREATE TEMPORARY TABLE dr (
        emp_id      INTEGER  NOT NULL  PRIMARY KEY
    );
-- Insert employee with given employee id into temporary table
    INSERT INTO dr SELECT emp_id FROM employee_nestset
        WHERE employee_nestset.emp_id = e_id;
-- Insert direct reports of given employee id into temporary table
-- Find and group employees that report to another employee and find the
-- employees that report to the given employee id based on the given employee
-- id's high value using a having clause
    INSERT INTO dr SELECT DISTINCT en1.emp_id
        FROM employee_nestset AS en1, employee_nestset AS en2
        WHERE en1.low > en2.low AND en1.high < en2.high
        GROUP BY en1.emp_id
        HAVING MIN(en2.high) = h;
    SET c = (SELECT COUNT(emp_id) - 1 FROM dr);
    DROP TEMPORARY TABLE dr;
    RETURN c;
END$
DELIMITER ;

