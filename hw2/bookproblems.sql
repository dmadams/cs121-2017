-- [Problem 1a]
SELECT DISTINCT name 
    FROM student JOIN takes JOIN course
        ON student.ID = takes.ID
        AND course.course_id = takes.course_id
    WHERE course.dept_name = 'Comp. Sci.';


-- [Problem 1b]
SELECT dept_name, MAX(salary)
    FROM instructor GROUP BY dept_name;


-- [Problem 1c]
SELECT MIN(salary) FROM instructor
    WHERE salary IN (
        SELECT MAX(salary)
            FROM instructor GROUP BY dept_name);


-- [Problem 1d]
WITH ms AS (
    SELECT MAX(salary) AS max_salary
        FROM instructor GROUP BY dept_name)
SELECT MIN(max_salary) FROM ms;


-- [Problem 2a]
ALTER TABLE course
    MODIFY credits decimal(2, 0) DEFAULT NULL CHECK ('credits' >= 0);
INSERT INTO course
    VALUES ('CS-001', 'Weekly Seminar', 'Comp. Sci.', 0);


-- [Problem 2b]
INSERT INTO section
    VALUES ('CS-001', '1', 'Fall', 2009, NULL, NULL, NULL);


-- [Problem 2c]
INSERT INTO takes
    SELECT student.ID, course.course_id, section.sec_id, section.semester,
    section.year, NULL
        FROM student, course, section
        WHERE student.dept_name = 'Comp. Sci.' AND course.course_id = 'CS-001'
        AND course.course_id = section.course_id;


-- [Problem 2d]
DELETE takes FROM takes JOIN student
    USING (ID)
    WHERE student.name = 'Chavez' AND takes.course_id = 'CS-001';


-- [Problem 2e]
-- All rows in takes and section, not just those in course, with 
-- course_id = 'CS-001' will also be deleted.

DELETE FROM course WHERE course_id = 'CS-001';


-- [Problem 2f]
DELETE takes FROM takes JOIN course
    USING (course_id)
    WHERE LOWER(course.title) LIKE ('%database%');


-- [Problem 3a]
SELECT DISTINCT name FROM member NATURAL JOIN book NATURAL JOIN borrowed
    WHERE publisher = 'McGraw-Hill';


-- [Problem 3b]
WITH c1 AS (SELECT COUNT(publisher) AS count FROM book
        WHERE publisher = 'McGraw-Hill'),
    c2 AS (SELECT name, COUNT(publisher) AS count FROM member NATURAL JOIN book
    NATURAL JOIN borrowed
        WHERE publisher = 'McGraw-Hill'
        GROUP BY name)
SELECT name FROM c2 JOIN c1
    USING (count);


-- [Problem 3c]
SELECT publisher, name FROM member NATURAL JOIN book NATURAL JOIN borrowed
    GROUP BY publisher, name
    HAVING COUNT(name) > 5;


-- [Problem 3d]
SELECT AVG(count) FROM(
    SELECT COUNT(isbn) AS count FROM member LEFT JOIN borrowed
        USING (memb_no)
        GROUP BY name) AS c;


-- [Problem 3e]
WITH c AS (
    SELECT COUNT(isbn) AS count FROM member LEFT JOIN borrowed
        USING (memb_no)
        GROUP BY name)
SELECT AVG(count) FROM c;

