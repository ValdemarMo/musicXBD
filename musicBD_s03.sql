SELECT name, year FROM album
WHERE year = '1974-01-01';

--

SELECT name, duration FROM track
ORDER BY duration DESC
LIMIT 1;

--

SELECT name, duration FROM track
WHERE duration >= '00:03:30';

--

SELECT name FROM compilation
WHERE year BETWEEN '2005-01-01' AND '2007-01-01';

--

SELECT name FROM artist
WHERE name NOT LIKE '% %';

--

SELECT name FROM track
WHERE name LIKE '%man' OR name LIKE '%art%';