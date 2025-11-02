-- Task 1: Creating and Timing the Query
SELECT 'Task 1: Creating and Timing the Query' as task;

SELECT 'Task 1: EXPLAIN' as TASK_1;

EXPLAIN QUERY PLAN
SELECT movies.title AS movie_title, people.name AS actor_name
FROM people
    INNER JOIN stars ON people.id = stars.person_id
    INNER JOIN movies ON stars.movie_id = movies.id
WHERE
    people.name = 'Burgess Meredith';

SELECT 'Task 1: QUERY Burgess Meredith' as TASK_1;

SELECT movies.title AS movie_title, people.name AS actor_name
FROM people
    INNER JOIN stars ON people.id = stars.person_id
    INNER JOIN movies ON stars.movie_id = movies.id
WHERE
    people.name = 'Burgess Meredith';
-- -- Run Time: real 1.456 user 0.959666 sys 0.477311

-- Task 2: Speeding Up the Query
SELECT 'Task 2: Speeding Up the Query' as TASK_2;

SELECT 'Task 2: DROP INDEX (before cleanup)' as TASK_2;

DROP INDEX IF EXISTS idx_people_name;
DROP INDEX IF EXISTS idx_fk_stars_person_id;

SELECT 'Task 2: CREATE INDEXES - people(name) and stars(person_id)' as TASK_2;

CREATE INDEX idx_people_name ON people (name);
CREATE INDEX idx_fk_stars_person_id ON stars (person_id);

SELECT 'Task 2: EXPLAIN with INDEX created' as TASK_2;

EXPLAIN QUERY PLAN
SELECT movies.title AS movie_title, people.name AS actor_name
FROM people
    INNER JOIN stars ON people.id = stars.person_id
    INNER JOIN movies ON stars.movie_id = movies.id
WHERE
    people.name = 'Burgess Meredith';

SELECT 'Task 2: QUERY Burgess Meredith with INDEX created' as TASK_2;

SELECT movies.title AS movie_title, people.name AS actor_name
FROM people
    INNER JOIN stars ON people.id = stars.person_id
    INNER JOIN movies ON stars.movie_id = movies.id
WHERE
    people.name = 'Burgess Meredith';
-- Run Time: real 0.000 user 0.000078 sys 0.000082

--      Explanation:
--          The previous query uses people.name to identify/filter records so it makes sense that this column should be indexed.
--          In addition, searching/filtering also required JOIN, and stars.person_id is a good column to index. While other ids are using in the
--          JOINs, stars.person is only FK which is not automatically indexed.
--          Result:
--              Before creating indexes: Run Time: real 1.338 user 0.913435 sys 0.423742
--              After creating indexes: Run Time: real 0.000 user 0.000078 sys 0.000082 (improved)

-- Task 3: Effect of Indexes on Delete

SELECT 'Task 3: Effect of Indexes on Delete' as TASK_3;

-- Note: I swapped position of WITHOUT and WITH - to reduce creating & dropping index actions
SELECT 'now deleting stars WITH indexes (refer to 3rd Run Time below)' AS status;

BEGIN TRANSACTION;
DELETE FROM stars
WHERE
    rowid > 10000;
ROLLBACK;

SELECT 'Task 3: DROP INDEX (cleanup before delete without index)' as TASK_3;

DROP INDEX IF EXISTS idx_people_name;
DROP INDEX IF EXISTS idx_fk_stars_person_id;

SELECT 'now deleting stars without indexes (refer to 3rd Run Time below)' AS status;
BEGIN TRANSACTION;
DELETE FROM stars
WHERE
    rowid > 10000;
ROLLBACK;

--      Explanation:  
--          Result: 
--              With indexes: Run Time: real 1.263 user 1.150135 sys 0.109029
--              Without indexes: Run Time: real 0.512 user 0.449261 sys 0.061724 (improved!)
--          While searching can be faster with indexes, every changing operation (DELETE, INSERT, UPDATE) 
--          such as deleting rows in table will require deletion of rows in the index/es. 
--          This is the overhead that comes with having indexes for searching.