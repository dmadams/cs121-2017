-- [Problem 1]
SELECT A FROM r;


-- [Problem 2]
SELECT * FROM r
    WHERE B = 17;


-- [Problem 3]
SELECT * FROM r, s;


-- [Problem 4]
SELECT A, F
    FROM r JOIN s
        ON r.C = s.D;


-- [Problem 5]
SELECT * FROM r1 
UNION
SELECT * FROM r2;


-- [Problem 6]
SELECT DISTINCT * FROM r1 NATURAL JOIN r2;


-- [Problem 7]
SELECT r1.A, r1.B, r1.C FROM r1 LEFT JOIN r2
    USING (A)
    WHERE r2.B IS NULL AND r2.C IS NULL;


