-- 10 nodes, 30 edges, distances in range [1, 10]

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
INSERT INTO nodes VALUES (6, 'Node6');
INSERT INTO nodes VALUES (7, 'Node7');
INSERT INTO nodes VALUES (8, 'Node8');
INSERT INTO nodes VALUES (9, 'Node9');
INSERT INTO nodes VALUES (10, 'Node10');

-- Edges
INSERT INTO node_adjacency VALUES (2, 4, 7);
INSERT INTO node_adjacency VALUES (4, 7, 5);
INSERT INTO node_adjacency VALUES (9, 7, 8);
INSERT INTO node_adjacency VALUES (5, 1, 9);
INSERT INTO node_adjacency VALUES (1, 7, 6);
INSERT INTO node_adjacency VALUES (6, 3, 3);
INSERT INTO node_adjacency VALUES (4, 3, 6);
INSERT INTO node_adjacency VALUES (1, 10, 2);
INSERT INTO node_adjacency VALUES (1, 5, 8);
INSERT INTO node_adjacency VALUES (9, 4, 6);
INSERT INTO node_adjacency VALUES (2, 3, 4);
INSERT INTO node_adjacency VALUES (9, 6, 3);
INSERT INTO node_adjacency VALUES (1, 3, 10);
INSERT INTO node_adjacency VALUES (9, 5, 10);
INSERT INTO node_adjacency VALUES (3, 7, 10);
INSERT INTO node_adjacency VALUES (4, 10, 3);
INSERT INTO node_adjacency VALUES (7, 3, 5);
INSERT INTO node_adjacency VALUES (9, 10, 4);
INSERT INTO node_adjacency VALUES (1, 9, 9);
INSERT INTO node_adjacency VALUES (6, 9, 9);
INSERT INTO node_adjacency VALUES (6, 7, 5);
INSERT INTO node_adjacency VALUES (6, 4, 1);
INSERT INTO node_adjacency VALUES (2, 9, 10);
INSERT INTO node_adjacency VALUES (7, 4, 3);
INSERT INTO node_adjacency VALUES (8, 5, 3);
INSERT INTO node_adjacency VALUES (10, 5, 3);
INSERT INTO node_adjacency VALUES (2, 10, 7);
INSERT INTO node_adjacency VALUES (4, 5, 4);
INSERT INTO node_adjacency VALUES (5, 4, 6);
INSERT INTO node_adjacency VALUES (1, 4, 1);

-- Calculated all-points shortest paths distances:
--     1 ->   1 =   0
--     1 ->   2 = UNREACHABLE
--     1 ->   3 =   7
--     1 ->   4 =   1
--     1 ->   5 =   5
--     1 ->   6 =  12
--     1 ->   7 =   6
--     1 ->   8 = UNREACHABLE
--     1 ->   9 =   9
--     1 ->  10 =   2
--     2 ->   1 =  19
--     2 ->   2 =   0
--     2 ->   3 =   4
--     2 ->   4 =   7
--     2 ->   5 =  10
--     2 ->   6 =  13
--     2 ->   7 =  12
--     2 ->   8 = UNREACHABLE
--     2 ->   9 =  10
--     2 ->  10 =   7
--     3 ->   1 =  26
--     3 ->   2 = UNREACHABLE
--     3 ->   3 =   0
--     3 ->   4 =  13
--     3 ->   5 =  17
--     3 ->   6 =  38
--     3 ->   7 =  10
--     3 ->   8 = UNREACHABLE
--     3 ->   9 =  35
--     3 ->  10 =  16
--     4 ->   1 =  13
--     4 ->   2 = UNREACHABLE
--     4 ->   3 =   6
--     4 ->   4 =   0
--     4 ->   5 =   4
--     4 ->   6 =  25
--     4 ->   7 =   5
--     4 ->   8 = UNREACHABLE
--     4 ->   9 =  22
--     4 ->  10 =   3
--     5 ->   1 =   9
--     5 ->   2 = UNREACHABLE
--     5 ->   3 =  12
--     5 ->   4 =   6
--     5 ->   5 =   0
--     5 ->   6 =  21
--     5 ->   7 =  11
--     5 ->   8 = UNREACHABLE
--     5 ->   9 =  18
--     5 ->  10 =   9
--     6 ->   1 =  14
--     6 ->   2 = UNREACHABLE
--     6 ->   3 =   3
--     6 ->   4 =   1
--     6 ->   5 =   5
--     6 ->   6 =   0
--     6 ->   7 =   5
--     6 ->   8 = UNREACHABLE
--     6 ->   9 =   9
--     6 ->  10 =   4
--     7 ->   1 =  16
--     7 ->   2 = UNREACHABLE
--     7 ->   3 =   5
--     7 ->   4 =   3
--     7 ->   5 =   7
--     7 ->   6 =  28
--     7 ->   7 =   0
--     7 ->   8 = UNREACHABLE
--     7 ->   9 =  25
--     7 ->  10 =   6
--     8 ->   1 =  12
--     8 ->   2 = UNREACHABLE
--     8 ->   3 =  15
--     8 ->   4 =   9
--     8 ->   5 =   3
--     8 ->   6 =  24
--     8 ->   7 =  14
--     8 ->   8 =   0
--     8 ->   9 =  21
--     8 ->  10 =  12
--     9 ->   1 =  16
--     9 ->   2 = UNREACHABLE
--     9 ->   3 =   6
--     9 ->   4 =   4
--     9 ->   5 =   7
--     9 ->   6 =   3
--     9 ->   7 =   8
--     9 ->   8 = UNREACHABLE
--     9 ->   9 =   0
--     9 ->  10 =   4
--    10 ->   1 =  12
--    10 ->   2 = UNREACHABLE
--    10 ->   3 =  15
--    10 ->   4 =   9
--    10 ->   5 =   3
--    10 ->   6 =  24
--    10 ->   7 =  14
--    10 ->   8 = UNREACHABLE
--    10 ->   9 =  21
--    10 ->  10 =   0
