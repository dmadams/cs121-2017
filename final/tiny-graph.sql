-- 5 nodes, 10 edges, distances in range [1, 10]

-- Clean up old data
TRUNCATE TABLE shortest_paths;
TRUNCATE TABLE node_adjacency;
TRUNCATE TABLE nodes;

-- Nodes
INSERT INTO nodes VALUES (1, 'Node1');
INSERT INTO nodes VALUES (2, 'Node2');
INSERT INTO nodes VALUES (3, 'Node3');
INSERT INTO nodes VALUES (4, 'Node4');
INSERT INTO nodes VALUES (5, 'Node5');

-- Edges
INSERT INTO node_adjacency VALUES (3, 1, 9);
INSERT INTO node_adjacency VALUES (1, 5, 1);
INSERT INTO node_adjacency VALUES (1, 4, 4);
INSERT INTO node_adjacency VALUES (1, 2, 1);
INSERT INTO node_adjacency VALUES (3, 4, 5);
INSERT INTO node_adjacency VALUES (5, 2, 2);
INSERT INTO node_adjacency VALUES (3, 2, 5);
INSERT INTO node_adjacency VALUES (1, 3, 1);
INSERT INTO node_adjacency VALUES (4, 5, 10);
INSERT INTO node_adjacency VALUES (2, 5, 10);

-- Calculated all-points shortest paths distances:
--     1 ->   1 =   0
--     1 ->   2 =   1
--     1 ->   3 =   1
--     1 ->   4 =   4
--     1 ->   5 =   1
--     2 ->   1 = UNREACHABLE
--     2 ->   2 =   0
--     2 ->   3 = UNREACHABLE
--     2 ->   4 = UNREACHABLE
--     2 ->   5 =  10
--     3 ->   1 =   9
--     3 ->   2 =   5
--     3 ->   3 =   0
--     3 ->   4 =   5
--     3 ->   5 =  10
--     4 ->   1 = UNREACHABLE
--     4 ->   2 =  12
--     4 ->   3 = UNREACHABLE
--     4 ->   4 =   0
--     4 ->   5 =  10
--     5 ->   1 = UNREACHABLE
--     5 ->   2 =   2
--     5 ->   3 = UNREACHABLE
--     5 ->   4 = UNREACHABLE
--     5 ->   5 =   0
