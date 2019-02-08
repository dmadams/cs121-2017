#=============================================================================
# SQL Schema for the Shortest Paths problem
#

DROP TABLE IF EXISTS shortest_paths;
DROP TABLE IF EXISTS node_adjacency;
DROP TABLE IF EXISTS nodes;


-- A table of nodes in the database.  Each node has a unique ID and a unique
-- name.
CREATE TABLE nodes (
    -- Unique ID for each node
    node_id INTEGER AUTO_INCREMENT PRIMARY KEY,

    -- Unique name of the node
    node_name VARCHAR(20) NOT NULL UNIQUE
);

-- A table describing which nodes are adjacent to which other nodes, along
-- with a "distance" attribute.
CREATE TABLE node_adjacency (
    -- The "from" side of the edge
    from_node_id INTEGER REFERENCES nodes (node_id),

    -- The "to" side of the edge
    to_node_id INTEGER REFERENCES nodes (node_id),

    -- The distance between the two nodes (whatever that might mean)
    distance INTEGER NOT NULL,

    PRIMARY KEY (from_node_id, to_node_id),
    CHECK (distance > 0)
);


-- A table that records the length of the shortest path between every pair of
-- nodes that have a path between them.  Every node can reach itself, with a
-- "total distance" of 0.
CREATE TABLE shortest_paths (
    -- The "from" side of the path
    from_node_id INTEGER REFERENCES nodes (node_id),

    -- The "to" side of the path
    to_node_id INTEGER REFERENCES nodes (node_id),

    -- The shortest-path distance between the two nodes
    total_distance INTEGER NOT NULL,

    PRIMARY KEY (from_node_id, to_node_id),
    CHECK (total_distance >= 0)
);
