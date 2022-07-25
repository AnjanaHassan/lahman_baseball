SELECT *
FROM people;

-- Qn:1 What range of years for baseball games played does the provided database cover? 
--pull years
SELECT MIN(year)
FROM homegames;
SELECT MAX(year)
FROM homegames;
--1871 TO 2016
SELECT MIN(yearid)
FROM collegeplaying;
SELECT MAX(yearid)
FROM collegeplaying;

--ans: 1864 to 2016

--Qn: 2
--Find the name and height of the shortest player in the database. 
--How many games did he play in? 
--What is the name of the team for which he played?

SELECT DISTINCT(playerid), namefirst, namelast
FROM people;

SELECT DISTINCT(p.playerid), a.playerid, namefirst, namelast, height, g_all,t.name
FROM people AS p
INNER JOIN appearances AS a ON a.playerid = p.playerid
INNER JOIN teams AS t ON t.yearid = a.yearid
GROUP BY p.playerid,a.playerid,g_all,t.name
ORDER BY height ASC;


WITH smallest_one AS (SELECT namefirst, namelast ,playerid, height
FROM people
WHERE height IS NOT NULL
ORDER BY height ASC
LIMIT 1)
SELECT smallest_one.namefirst,smallest_one.namelast, smallest_one.playerid, smallest_one.height, appearances.g_all, teams.name
FROM smallest_one
INNER JOIN appearances ON appearances.playerid = smallest_one.playerid
INNER JOIN teams ON teams.teamid = appearances.teamid
LIMIT 1;

WITH smallest_player AS (SELECT playerid, namegiven, height
							FROM people
							ORDER BY height ASC
							Limit 1)
SELECT teamid, namegiven, height, appearances.playerid,
       SUM(g_all) OVER(PARTITION BY appearances.playerid) AS appearances
FROM appearances FULL JOIN smallest_player ON appearances.playerid = smallest_player.playerid
WHERE appearances.playerid = smallest_player.playerid;


--qn:3
--Find all players in the database who played at Vanderbilt University. 
--Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
--Sort this list in descending order by the total salary earned. 
--Which Vanderbilt player earned the most money in the majors?

SELECT DISTINCT(p.namefirst), p.namelast,p.playerid,s.schoolname,sl.salary
FROM schools AS s
INNER JOIN collegeplaying AS c ON c.schoolid = s.schoolid
INNER JOIN people AS p ON p.playerid = c.playerid
INNER JOIN salaries AS sl ON sl.playerid = p.playerid
WHERE schoolname = 'Vanderbilt University'
ORDER BY sl.salary DESC;

--

SELECT p.playerid, p.namefirst, p.namelast,s.schoolname,sl.salary
FROM schools AS s
INNER JOIN collegeplaying AS c ON c.schoolid = s.schoolid
INNER JOIN people AS p ON p.playerid = c.playerid
INNER JOIN salaries AS sl ON sl.playerid = p.playerid
WHERE schoolname = 'Vanderbilt University'
ORDER BY sl.salary DESC;


WITH vandy_players AS (SELECT DISTINCT(playerid)
						FROM collegeplaying
						WHERE schoolid ILIKE 'vandy'),
						
	vandy_majors AS (SELECT people.playerid, CONCAT(namefirst, ' ', namelast) AS full_name
					FROM people INNER JOIN vandy_players ON people.playerid = vandy_players.playerid)
					
SELECT vandy_majors.playerid, full_name, SUM(salary)::numeric::money AS total_salary
FROM salaries INNER JOIN vandy_majors ON salaries.playerid = vandy_majors.playerid
GROUP BY full_name, vandy_majors.playerid
ORDER BY total_salary DESC;

--qn:4
--Using the fielding table, group players into three groups based on their position: 
--label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
--Determine the number of putouts made by each of these three groups in 2016.

SELECT * 
FROM fielding

SELECT SUM(po),
       CASE WHEN pos = 'OF' THEN 'Outfield'
	        WHEN pos = 'SS' THEN 'Infield'
			WHEN pos = '1B' THEN 'Infield'
			WHEN pos = '2B' THEN 'Infield'
			WHEN pos = '3B' THEN 'Infield'
			WHEN pos = 'P' THEN 'Battery'
			WHEN pos = 'C' THEN 'Battery'
		END AS playerposition
FROM fielding
WHERE yearid = 2016
GROUP BY playerposition;


SELECT yearid, SUM(po) AS total_putouts, 
CASE
	WHEN pos IN ('OF') THEN 'Outfield'
	WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
	WHEN pos IN ('P', 'C')  THEN 'Battery'
	ELSE 'Error' END AS field_pos
FROM fielding
WHERE yearid = '2016'
GROUP BY yearid, field_pos
ORDER BY total_putouts DESC;

------qn:5:
--Find the average number of strikeouts per game by decade since 1920. 
--Round the numbers you report to 2 decimal places. 
--Do the same for home runs per game?
--Do you see any trends?
SELECT *
FROM teams AS t;

SELECT ROUND(AVG(t.so),2)AS avg_strikeout, ROUND(AVG(t.g),2)AS avg_games
FROM teams AS t
WHERE t.yearid BETWEEN 1920 AND 1930;

SELECT ROUND(SUM(t.so),2) AS sum_so, ROUND(SUM(t.g),2)AS sum_g 
FROM teams AS t;

SELECT ROUND(SUM(t.so),2) AS sum_so, ROUND(SUM(t.g),2)AS sum_g, (ROUND(SUM(t.so),2)/ROUND(SUM(t.g),2))AS so_per_game,
       CASE WHEN t.yearid BETWEEN 1920 AND 1929 THEN '1920s'
	        WHEN t.yearid BETWEEN 1930 AND 1939 THEN '1930s'
			WHEN t.yearid BETWEEN 1940 AND 1949 THEN '1940s'
			WHEN t.yearid BETWEEN 1950 AND 1959 THEN '1950s'
			WHEN t.yearid BETWEEN 1960 AND 1969 THEN '1960s'
			WHEN t.yearid BETWEEN 1970 AND 1979 THEN '1970s'
			WHEN t.yearid BETWEEN 1980 AND 1989 THEN '1980s'
			WHEN t.yearid BETWEEN 1990 AND 1999 THEN '1990s'
			WHEN t.yearid BETWEEN 2000 AND 2009 THEN '2000s'
			WHEN t.yearid BETWEEN 2010 AND 2019 THEN '2010s'
				   END AS BY_DECADES
FROM teams AS t
WHERE yearid BETWEEN 1920 AND 2019
GROUP BY BY_DECADES
ORDER BY BY_DECADES DESC;

SELECT ROUND(SUM(t.hr),2)AS sum_hr, ROUND(SUM(t.g),2)AS sum_g, (ROUND(SUM(t.hr),2)/ROUND(SUM(t.g),2))AS hr_per_game,
       CASE WHEN t.yearid BETWEEN 1920 AND 1929 THEN '1920s'
	        WHEN t.yearid BETWEEN 1930 AND 1939 THEN '1930s'
			WHEN t.yearid BETWEEN 1940 AND 1949 THEN '1940s'
			WHEN t.yearid BETWEEN 1950 AND 1959 THEN '1950s'
			WHEN t.yearid BETWEEN 1960 AND 1969 THEN '1960s'
			WHEN t.yearid BETWEEN 1970 AND 1979 THEN '1970s'
			WHEN t.yearid BETWEEN 1980 AND 1989 THEN '1980s'
			WHEN t.yearid BETWEEN 1990 AND 1999 THEN '1990s'
			WHEN t.yearid BETWEEN 2000 AND 2009 THEN '2000s'
			WHEN t.yearid BETWEEN 2010 AND 2019 THEN '2010s'
	   END AS HR_BY_DECADES
FROM teams AS t
WHERE yearid BETWEEN 1920 AND 2019
GROUP BY HR_BY_DECADES
ORDER BY HR_BY_DECADES DESC;

--By joining these two set of codes into one:

SELECT ROUND(SUM(t.so),2) AS sum_so, ROUND(SUM(t.g),2)AS sum_g, (ROUND(SUM(t.so),2)/ROUND(SUM(t.g),2))AS so_per_game,
ROUND(SUM(t.hr),2)AS sum_hr, ROUND(SUM(t.g),2)AS sum_g, (ROUND(SUM(t.hr),2)/ROUND(SUM(t.g),2))AS hr_per_game,
            CASE WHEN t.yearid BETWEEN 1920 AND 1929 THEN '1920s'
	        WHEN t.yearid BETWEEN 1930 AND 1939 THEN '1930s'
			WHEN t.yearid BETWEEN 1940 AND 1949 THEN '1940s'
			WHEN t.yearid BETWEEN 1950 AND 1959 THEN '1950s'
			WHEN t.yearid BETWEEN 1960 AND 1969 THEN '1960s'
			WHEN t.yearid BETWEEN 1970 AND 1979 THEN '1970s'
			WHEN t.yearid BETWEEN 1980 AND 1989 THEN '1980s'
			WHEN t.yearid BETWEEN 1990 AND 1999 THEN '1990s'
			WHEN t.yearid BETWEEN 2000 AND 2009 THEN '2000s'
			WHEN t.yearid BETWEEN 2010 AND 2019 THEN '2010s'
			END AS BY_DECADES
FROM teams AS t
WHERE yearid BETWEEN 1920 AND 2019
GROUP BY BY_DECADES
ORDER BY BY_DECADES DESC;



SELECT ROUND((SUM(so)/(SUM(g)/2)::decimal), 2) AS so_avg, 
	   ROUND((SUM(hr)/(SUM(g)/2)::decimal), 2) AS hr_avg,
CASE 
	WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
	WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
	WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
	WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
	WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
	WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
	WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
	WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
END AS decade
FROM teams
WHERE
	yearid BETWEEN 1920 AND 2009
GROUP BY decade
ORDER BY decade ASC



--qn:6
-- Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. 
--(A stolen base attempt results either in a stolen base or being caught stealing.) 
--Consider only players who attempted _at least_ 20 stolen bases.

SELECT p.playerid,f.playerid, p.namefirst, p.namelast,f.sb,f.cs,f.yearid
FROM people AS p
INNER JOIN fielding AS f ON f.playerid = p.playerid
WHERE f.sb IS NOT NULL
AND f.cs IS NOT NULL
AND yearid = '2016'
AND f.sb > 20;


SELECT p.playerid,f.playerid, p.namefirst, p.namelast,f.sb,f.cs,f.yearid, ROUND((f.sb::decimal/(f.sb::decimal+f.cs::decimal)*100),2)AS percentsuccess
FROM people AS p
INNER JOIN fielding AS f ON f.playerid = p.playerid
WHERE f.sb IS NOT NULL
AND f.cs IS NOT NULL
AND yearid = '2016'
AND f.sb+f.cs >= 20
ORDER BY percentsuccess DESC;



SELECT batting.yearid, CONCAT(namefirst, ' ', namelast) AS name, sb, cs, ROUND(sb*100/(sb+cs)::decimal, 2) AS success_rate
FROM batting INNER JOIN people ON batting.playerid = people.playerid
WHERE sb + cs >= 20 AND yearid = '2016'
ORDER BY success_rate DESC;

--QN;7
--From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
--What is the smallest number of wins for a team that did win the world series? 
--Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
--Then redo your query, excluding the problem year. 
--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
--What percentage of the time?
SELECT *
FROM teams;
----------------
SELECT teamid,yearid,w, wswin
FROM teams
WHERE yearid BETWEEN  1970 AND 2016
AND wswin = 'N'
ORDER BY w DESC;
----------------------
SELECT teamid,yearid,w, wswin
FROM teams
WHERE yearid BETWEEN  1970 AND 2016
AND wswin = 'Y'
ORDER BY w ASC;
----------------
SELECT teamid,yearid,w, wswin
FROM teams
WHERE yearid BETWEEN  1970 AND 2016
AND yearid <> '1981'
AND wswin = 'Y'
ORDER BY w ASC;
-------------------------
SELECT teamid,yearid,w, wswin
FROM teams
WHERE yearid BETWEEN  1970 AND 2016
AND wswin = 'Y'
ORDER BY w DESC;
----------------

SELECT yearid, MAX(w) AS most_w, wswin
FROM teams
WHERE yearid BETWEEN  1970 AND 2016
AND wswin = 'Y'
ORDER BY w DESC;

SELECT MAX(w)
FROM teams
WHERE yearid = '1977'

WITH wsmostw AS 
(SELECT yearid,MAX(w) AS most_w 
FROM teams
WHERE yearid BETWEEN  1970 AND 2016
 GROUP BY yearid)
 SELECT ROUND((count(DISTINCT(teams.yearid))::decimal)/47,2)
 FROM wsmostw
 INNER JOIN teams USING (yearid)
 WHERE w = most_w AND wswin = 'Y';
 
 ------------------------
--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
--What percentage of the time?
--Need to get- often, yearid, w, wswin

WITH max_w AS 
        (SELECT MAX(t.yearid) AS yearid,t.teamid, MAX(w) AS tmax_w
         FROM teams AS t
         WHERE yearid BETWEEN  1970 AND 2016
         GROUP BY t.teamid
         ORDER BY MAX(w) DESC)
SELECT DISTINCT(max_w.yearid), t.teamid, max_w.tmax_w, t.wswin
FROM max_w
INNER JOIN teams AS t ON t.yearid = max_w.yearid
WHERE t.yearid BETWEEN  1970 AND 2016
AND wswin = 'Y'
GROUP BY max_w.yearid, t.teamid,t.wswin,max_w.tmax_w
ORDER BY tmax_w DESC

-----------------------------
WITH max_w AS 
        (SELECT t.teamid, MAX(w) AS tmax_w
         FROM teams AS t
         WHERE yearid BETWEEN  1970 AND 2016
         GROUP BY t.teamid
         ORDER BY MAX(w) DESC)
SELECT t.teamid, max_w.tmax_w, t.wswin, t.name
FROM max_w
INNER JOIN teams AS t ON t.teamid = max_w.teamid
WHERE t.yearid BETWEEN  1970 AND 2016
AND wswin = 'Y'
GROUP BY t.teamid,t.wswin,max_w.tmax_w,t.name
ORDER BY tmax_w DESC
-----------------------------
WITH topwswinners AS ((SELECT yearid,
							 MAX(w) AS w
						FROM teams
						WHERE yearid BETWEEN 1970 AND 2016
						GROUP BY yearid
						ORDER BY yearid)
						INTERSECT
						(SELECT yearid,
							    w
						FROM teams
						WHERE wswin = 'Y'
						AND yearid BETWEEN 1970 AND 2016
						ORDER BY yearid))
SELECT teams.name, teams.yearid, teams.w, teams.wswin
FROM teams INNER JOIN topwswinners ON teams.yearid = topwswinners.yearid AND teams.w = topwswinners.w
WHERE teams.wswin = 'Y';

--
SELECT teamid, w, wswin, yearid
FROM teams
WHERE w = (SELECT max(w) FROM teams WHERE wswin = 'N' AND yearid >= 1970)
AND wswin = 'N'
and yearid >= 1970
--
SELECT teamid, w, wswin, yearid
FROM teams
WHERE w = (SELECT min(w) FROM teams WHERE wswin = 'Y' AND yearid != 1981 AND yearid >= 1970)
AND wswin = 'Y'
AND yearid >= 1970


--qn :8
--Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 
--(where average attendance is defined as total attendance divided by number of games). 
--Only consider parks where there were at least 10 games played. 
--Report the park name, team name, and average attendance. 
--Repeat for the lowest 5 average attendance.

SELECT*
FROM homegames

SELECT team, park, AVG(attendance)
FROM homegames
WHERE year = 2016
GROUP BY team, park
ORDER BY ROUND(AVG(attendance),2) DESC


SELECT team, park, SUM(games)AS number_games, SUM(attendance)AS sum_attendance, (SUM(attendance)/SUM(games))AS avg_attendance
FROM homegames
WHERE year = 2016
GROUP BY team, park
ORDER BY ROUND((SUM(attendance)/sum(games)),2) DESC



SELECT t.name, h.team, h.park, MAX(h.attendance), SUM(h.games)AS number_games, SUM(h.attendance)AS sum_attendance, (SUM(h.attendance)/SUM(h.games))AS avg_attendance,
       CASE WHEN h.year = 2016 THEN 'use'
	        WHEN sum(h.games) > 10 THEN 'useif'
			END AS criteria
FROM homegames AS h
INNER JOIN teams AS t ON t.attendance = h.attendance
GROUP BY h.team, t.name, h.park
ORDER BY ROUND((SUM(h.attendance)/sum(h.games)),2) DESC


SELECT team,teams.name, h.park, p.park_name, SUM(games)AS number_games, SUM(h.attendance)AS sum_attendance, (SUM(h.attendance)/SUM(games))AS avg_attendance
FROM homegames AS h
INNER JOIN teams ON teams.attendance = h.attendance
INNER JOIN parks  AS p ON p.park  = h.park
WHERE teams.yearid = 2016
GROUP BY team, teams.name, h.park,p.park_name
ORDER BY ROUND((SUM(h.attendance)/sum(games)),2) DESC


SELECT team,teams.name, h.park, p.park_name, SUM(games)AS number_games, SUM(h.attendance)AS sum_attendance, (SUM(h.attendance)/SUM(games))AS avg_attendance
FROM homegames AS h
INNER JOIN teams ON teams.attendance = h.attendance
INNER JOIN parks  AS p ON p.park  = h.park
WHERE teams.yearid = 2016
GROUP BY team, teams.name, h.park,p.park_name
ORDER BY ROUND((SUM(h.attendance)/sum(games)),2) ASC



SELECT  park_name, franchname, (homegames.attendance / games) AS atd_avg
FROM homegames 
		LEFT JOIN parks ON homegames.park = parks.park 
		LEFT JOIN teams ON teams.teamid = homegames.team 
		LEFT JOIN teamsfranchises ON teamsfranchises.franchid = teams.franchid
WHERE year = 2016 AND games >= 10
GROUP BY franchname, park_name, games, homegames.attendance
ORDER BY atd_avg DESC




--qn 10:
--Find all players who hit their career highest number of home runs in 2016. 
--Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
--Report the players' first and last names and the number of home runs they hit in 2016.

SELECT CONCAT(p.namefirst,' ', p.namelast), t.hr  
FROM people AS p
INNER JOIN batting AS b ON b.playerid = p.playerid
INNER JOIN teams AS t ON b.yearid = t.yearid
WHERE t.yearid  = 2016
ORDER BY t.hr DESC


WITH max_hr AS (SELECT playerid, MAX(hr) as max_hr
			    FROM batting
				GROUP BY playerid
			    ORDER BY playerid)
				
SELECT DISTINCT CONCAT(namegiven, ' ',namelast), max_hr
FROM max_hr INNER JOIN people USING (playerid)
INNER JOIN batting USING (playerid)
WHERE (2016 - EXTRACT(YEAR FROM debut::date)) >= 10
AND yearid = 2016
AND hr = max_hr
AND max_hr > 0
ORDER BY max_hr DESC


--QN:9
--Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
--Give their full name and the teams that they were managing when they won the award.

WITH NL_award AS (SELECT DISTINCT namegiven, namelast, playerid AS pid_nl, awardsmanagers.yearid AS year_nl
				  FROM awardsmanagers INNER JOIN people USING (playerid)
				  					  INNER JOIN managers USING (playerid) 	
				  WHERE awardid LIKE 'TSN%' AND awardsmanagers.lgid = 'NL'),
	 AL_award AS (SELECT DISTINCT playerid AS pid_al, awardsmanagers.yearid AS year_al
				  FROM awardsmanagers INNER JOIN people USING (playerid)
				  					  INNER JOIN managers USING (playerid) 	
				  WHERE awardid LIKE 'TSN%' AND awardsmanagers.lgid = 'AL')
				  
SELECT DISTINCT CONCAT(namegiven, ' ', namelast) as name, year_nl, n.teamid, year_al, a.teamid
FROM NL_award INNER JOIN AL_award ON NL_award.pid_nl = AL_award.pid_al
              INNER JOIN managers as n on pid_nl = n.playerid AND year_nl = n.yearid
			  INNER JOIN managers as a on pid_al = a.playerid AND year_al = a.yearid
---------------------------------------------------
