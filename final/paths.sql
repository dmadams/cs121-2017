-- [Problem 2a]
DROP PROCEDURE IF EXISTS sp_compute_shortest_paths;
-- Computes the shortest path from every node to every node in node_adjacency
-- If a node cannot be reached from another node, that from to combination will
-- not be in shortest paths. Every node is reachable from itself with a total
-- distance of 0. This procedure works using a brute force method. It starts
-- by inserting every node to itself with a total_distance of 0 and all of the
-- edges given in node_adjacency. Then it iterates through every possible combo
-- of 3 nodes with node 1 being connected to node 2 and node 2 being connected
-- to node 3. If this is true and the total distance calculated from the
-- distances along these 2 edges is less than the current shortest path between
-- node 1 and node 3 or there is no current shortest path between node 1 and
-- node 3, the current shortest path from node 1 to node 3 (if there is one) is
-- replaced with the distance from node 1 to node 2 + the distance from node 2
-- to node 3. This process is repeated until no further improvements are made.
-- It is very slow.
end;
DELIMITER $
CREATE PROCEDURE sp_compute_shortest_paths()
BEGIN
-- Node 1
    DECLARE n1 INTEGER DEFAULT 1;
-- Node 2
    DECLARE n2 INTEGER DEFAULT 1;
-- Node 3
    DECLARE n3 INTEGER DEFAULT 1;
-- Counter
    DECLARE c INTEGER DEFAULT -1;
-- Distance
    DECLARE d INTEGER DEFAULT 0;
    DECLARE nm1 INTEGER DEFAULT (SELECT MAX(from_node_id) FROM node_adjacency);
    DECLARE nm2 INTEGER DEFAULT (SELECT MAX(to_node_id) FROM node_adjacency);
-- Node max the largest from_node_id or to_node_id
    DECLARE nm INTEGER DEFAULT 0;
-- Find largest node nm
    IF nm1 >= nm2 THEN
        SET nm = nm1;
    ELSE
        SET nm = nm2;
    END IF;

-- Delete everything from shortest_paths and insert all edges in node_adjacency
    DELETE FROM shortest_paths;
    INSERT INTO shortest_paths SELECT * FROM node_adjacency;

-- Insert (node, node, 0) for every node
    loop1: LOOP
        IF n1 > nm THEN
            LEAVE loop1;
        END IF;
        INSERT INTO shortest_paths VALUES (n1, n1, 0);
        SET n1 = n1 + 1;
    END LOOP;

-- Loop to check if last time through made improvements. If not, we are done.
    loop2: LOOP
        IF c = 0 THEN
            LEAVE loop2;
        END IF;

        SET c = 0;
-- Lots of ugly mysql loops to iterate though all n1, n2, n3 combos
        SET n1 = 1;
        loop3: LOOP
            IF n1 > nm THEN
                LEAVE loop3;
            END IF;

            SET n2 = 1;
            loop4: LOOP
                IF n2 > nm THEN
                    LEAVE loop4;
                END IF;

                SET n3 = 1;
                loop5: LOOP
                    IF n3 > nm THEN
                        LEAVE loop5;
                    END IF;

-- Set d to the total distance from n1 to n2 + total distance from n2 to n3
                    SET d = (SELECT total_distance FROM shortest_paths 
                                WHERE n1 = from_node_id AND n2 = to_node_id)
                          + (SELECT total_distance FROM shortest_paths 
                                WHERE n2 = from_node_id AND n3 = to_node_id);
-- If n3 is reachable from n1 and (d < current total distance from n1 to n3 or
-- no path from n1 to n3 is currently in shortest paths, delete the current
-- shortest path for n1 to n3 and insert into shortest paths the value
-- (n1, n3 d).
                    IF d IS NOT NULL AND
                        ((SELECT total_distance FROM shortest_paths
                            WHERE n1 = from_node_id AND n3 = to_node_id) IS NULL
                        OR d < (SELECT total_distance FROM shortest_paths
                            WHERE n1 = from_node_id AND n3 = to_node_id))
                        THEN
                            DELETE FROM shortest_paths WHERE n1 = from_node_id
                                AND n3 = to_node_id;
                            INSERT INTO shortest_paths VALUES (n1, n3, d);
                            SET c = c + 1;                  
                        END IF;

                    SET n3 = n3 + 1;
                END LOOP;

                SET n2 = n2 + 1;
            END LOOP;

            SET n1 = n1 + 1;
        END LOOP;

    END LOOP;
END$
DELIMITER ;


-- [Problem 2b]
WITH a AS (SELECT from_node_id, SUM(1 / total_distance) AS sum_1
        FROM shortest_paths GROUP BY from_node_id),
    b AS (SELECT (COUNT(node_id) - 1) AS tot_nodes_1 FROM nodes),
    c AS (SELECT from_node_id AS node_id, (sum_1 / tot_nodes_1) AS centrality
        FROM a, b)
SELECT node_id, node_name, centrality FROM c NATURAL JOIN nodes
    ORDER BY centrality DESC LIMIT 5;


