--1.количество исполнителей в каждом жанре;
SELECT g.name, COUNT(ag.artist_id) FROM genre g
	JOIN artist_genre ag ON ag.genre_id = g.id
	GROUP BY g.name
	ORDER by count(g.id) DESC;
--(проверочное) полный список
SELECT g.name, a.name FROM genre g
	JOIN artist_genre ag ON ag.genre_id = g.id
	JOIN artist a on a.id = ag.artist_id
	GROUP BY a.name, g.name
	ORDER by g.name;
	
--2.количество треков, вошедших в альбомы 1972-1975 годов;
SELECT COUNT(t.album_id) FROM album alb
	JOIN track t on t.album_id = alb.id
	WHERE alb.year <= '1975-01-01' AND alb.year >= '1972-01-01';
--(проверочное)
SELECT alb.name, alb.year, COUNT(t.album_id) FROM album alb
	JOIN track t on t.album_id = alb.id
	WHERE alb.year <= '1975-01-01' AND alb.year >= '1972-01-01'
	GROUP BY alb.name, alb.year
	ORDER BY alb.year;
	
--3.средняя продолжительность треков по каждому альбому; (помучался с выводом усреднённых секунд, как можно поменять формат отображения непонятно. И, да, вероятно проще было изначально работать с продолжительностью треков в секундах, а не интервалах. как вставить конвертер так и не понял, функции вроде есть (TIME_TO_SEC/SEC_TO_TIME), но синтаксис непонятен. год выхода альбома в формат не-дата тоже бы упростил ситуацию, но я ориентировался на iTunes там альбомы с полной датой зачем то.)  	
SELECT alb.name, alb.year, AVG(t.duration) FROM album alb
	JOIN track t on t.album_id = alb.id
	GROUP BY alb.name, alb.year
	ORDER BY alb.year;

--4.все исполнители, которые не выпустили альбомы в 1973 году;
SELECT DISTINCT(art.name) FROM artist art
	WHERE art.name NOT IN (
		SELECT distinct(art.name) FROM artist
			JOIN artist_album aa ON aa.artist_id = art.id
			JOIN album alb ON alb.id = aa.album_id
			WHERE alb.year BETWEEN '1973-01-01' AND '1973-12-31')
	ORDER BY art.name;
--(проверочное) список всех альбомов по-годам)
SELECT alb.year, art.name, alb.name FROM artist art
	JOIN artist_album aa ON aa.artist_id = art.id
	JOIN album alb ON alb.id = aa.album_id
	--WHERE alb.year BETWEEN '1973-01-01' AND '1973-12-31'
	GROUP BY alb.year, art.name, alb.name
	ORDER BY alb.year;
	
--5.названия сборников, в которых присутствует конкретный исполнитель (выберите сами);
SELECT DISTINCT(c.name) FROM track t
	JOIN compilation_track ct ON ct.track_id = t.id
	JOIN compilation c ON c.id = ct.compilation_id
	JOIN album alb ON t.album_id = alb.id
	JOIN artist_album aa ON aa.album_id = alb.id
	JOIN artist art ON art.id = aa.artist_id
	WHERE art.name = ('Bert Jansch')
	ORDER BY c.name;
--(проверочное) исполнитель/сборник/трек/альбом
SELECT art.name, c.name, t.name, alb.name FROM track t
	JOIN compilation_track ct ON ct.track_id = t.id
	JOIN compilation c ON c.id = ct.compilation_id
	JOIN album alb ON t.album_id = alb.id
	JOIN artist_album aa ON aa.album_id = alb.id
	JOIN artist art ON art.id = aa.artist_id
	ORDER BY art.name, c.name;

--6.название альбомов, в которых присутствуют исполнители более 1 жанра;
SELECT DISTINCT(alb.name) FROM artist art
	JOIN artist_album aa ON aa.artist_id = art.id
	JOIN album alb ON alb.id = aa.album_id
	JOIN artist_genre ag ON ag.artist_id = art.id
	JOIN genre g ON ag.genre_id = g.id 
	GROUP BY alb.name
	HAVING COUNT(alb.name) > 1
	ORDER BY alb.name;
--(проверочное) оба варианта [1 артист - 2 жанра] и [2 артиста по 1 жанру] отрабатываются нормально
SELECT alb.name, art.name, g.name FROM artist art
	JOIN artist_album aa ON aa.artist_id = art.id
	JOIN album alb ON alb.id = aa.album_id
	JOIN artist_genre ag ON ag.artist_id = art.id
	JOIN genre g ON ag.genre_id = g.id 
	GROUP BY art.name, g.name, alb.name
	ORDER BY alb.name;

--7.наименование треков, которые не входят в сборники - таких 29 из 47;
SELECT t.name FROM track t
	WHERE t.name NOT IN (
		SELECT t.name FROM track t
			JOIN compilation_track ct ON ct.track_id = t.id
			JOIN compilation c ON c.id = ct.compilation_id)
	ORDER by t.name;
--(проверочное) то что входит в сборники - таких 24 из 47 (есть треки входящие в несколько сборников)
SELECT t.name, c.name FROM track t
	JOIN compilation_track ct ON ct.track_id = t.id
	JOIN compilation c ON c.id = ct.compilation_id
	ORDER by t.name, c.name;
--(проверочное) то что входит в сборники - уникальное 18 из 47 (все сходится 29+18=47)
SELECT DISTINCT(t.name) FROM track t
	JOIN compilation_track ct ON ct.track_id = t.id
	JOIN compilation c ON c.id = ct.compilation_id
	ORDER BY t.name;

--8.исполнителя(-ей), написавшего самый короткий по продолжительности трек (теоретически таких треков может быть несколько);
SELECT art.name, alb.name FROM artist art
	JOIN artist_album aa ON aa.artist_id = art.id
	JOIN album alb ON alb.id = aa.album_id
	WHERE alb.name = (
		SELECT alb.name FROM track t
			JOIN album alb ON t.album_id = alb.id
			WHERE t.duration = (SELECT MIN(duration) FROM track));
--(проверочное) таблица альбом/трек/продолжительность
SELECT alb.name, t.name, t.duration FROM track t
	JOIN album alb ON t.album_id = alb.id
	ORDER BY t.duration;
	
--9.название альбомов, содержащих наименьшее количество треков. 
SELECT alb.name FROM album alb
	JOIN track t ON t.album_id = alb.id
	GROUP BY alb.name
	HAVING COUNT(t.name) = (
		SELECT COUNT(t.name) FROM album alb
		JOIN track t ON t.album_id = alb.id
		GROUP BY alb.name
		ORDER BY COUNT(t.name)
		LIMIT 1)
	ORDER BY alb.name;
--(проверочное) количество треков в альбомах 
SELECT alb.name, COUNT(t.name) FROM album alb
	JOIN track t ON t.album_id = alb.id
	GROUP BY alb.name
	ORDER BY COUNT(t.name);
