DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era) 
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, people.playerid, yearid
  FROM people INNER JOIN halloffame ON people.playerid = halloffame.playerid
  WHERE inducted = 'Y'
  ORDER BY yearid DESC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, people.playerid, schools.schoolid, halloffame.yearid
  FROM people, halloffame, schools, collegeplaying
  WHERE people.playerid = halloffame.playerid
  AND halloffame.inducted = 'Y'
  AND people.playerid = collegeplaying.playerid
  AND schools.schoolid = collegeplaying.schoolid
  AND schools.schoolstate = 'CA'
  ORDER BY halloffame.yearid DESC, schoolid, playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT people.playerid, namefirst, namelast, collegeplaying.schoolid
  FROM people INNER JOIN halloffame ON people.playerid = halloffame.playerid
  LEFT OUTER JOIN collegeplaying ON people.playerid = collegeplaying.playerid
  WHERE inducted = 'Y'
  ORDER BY people.playerid DESC, schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT people.playerid, namefirst, namelast, yearid, CAST(h + h2b + 2*h3b + 3*hr AS float)/CAST(ab AS float) AS slg
  FROM people LEFT OUTER JOIN batting ON people.playerid = batting.playerid
  WHERE ab > 50
  ORDER BY slg DESC, yearid, playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT people.playerid, namefirst, namelast, CAST(SUM(h + h2b + 2*h3b + 3*hr) AS float)/CAST(SUM(ab) AS float) AS lslg
  FROM people LEFT OUTER JOIN batting ON people.playerid = batting.playerid
  GROUP BY people.playerid
  HAVING SUM(ab) > 50
  ORDER BY lslg DESC, people.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, CAST(SUM(h + h2b + 2*h3b + 3*hr) AS float)/CAST(SUM(ab) AS float) AS lslg
  FROM people INNER JOIN batting ON people.playerid = batting.playerid
  GROUP BY people.playerid
  HAVING SUM(ab) > 50
  AND SUM(h + h2b + 2*h3b + 3*hr)/CAST(SUM(ab) AS float) > (
    SELECT SUM(h + h2b + 2*h3b + 3*hr)/CAST(SUM(ab) AS float)
    FROM people INNER JOIN batting ON people.playerid = batting.playerid
    WHERE people.playerid = 'mayswi01'
  )
  ORDER BY namefirst
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  SELECT yearid, MIN(salary) AS min, MAX(salary) AS max, AVG(salary) AS avg, STDDEV(salary) AS stddev
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH stat AS (
    SELECT MIN(salary) AS min, MAX(salary) AS max
    FROM salaries
    WHERE yearid = 2016
  ),
  bucket AS (
    SELECT width_bucket(salaries.salary, stat.min, stat.max+1, 10)-1 AS binid, AVG(stat.min) as min, AVG(stat.max) as max, COUNT(salary) as count
    FROM salaries, stat
    WHERE salaries.yearid = 2016
    GROUP BY binid
    ORDER BY binid
  )

  SELECT binid, min + binid*(max-min)/10, min + (binid+1)*(max-min)/10, count
  FROM bucket
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH compare AS (
    SELECT yearid, MIN(salary) as min, MAX(salary) as max, AVG(salary) as avg
    FROM salaries
    WHERE yearid > 1985
    GROUP BY yearid
    ORDER BY yearid
  ),

  origin AS (
    SELECT yearid,MIN(salary) as min, MAX(salary) as max, AVG(salary) as avg
    FROM salaries
    GROUP BY yearid
    ORDER BY yearid
  )

  SELECT compare.yearid, compare.min - origin.min AS mindiff, compare.max - origin.max AS maxdiff, compare.avg - origin.avg AS avgdiff
  FROM compare, origin
  WHERE compare.yearid = origin.yearid + 1
  ORDER BY compare.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  WITH stat AS(
    SELECT MAX(salary) AS max, yearid
    FROM salaries
    WHERE yearid = 2000 OR yearid = 2001
    GROUP BY yearid
  )

  SELECT people.playerid, namefirst, namelast, salaries.salary, salaries.yearid
  FROM people, salaries, stat
  WHERE people.playerid = salaries.playerid
  AND salaries.yearid = stat.yearid
  AND salaries.salary = stat.max

;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
   SELECT teamid, (MAX(salary) - MIN(salary)) AS diffAvg
   FROM
    (SELECT playerid, teamid FROM allstarfull WHERE yearid = 2016) AS a
        INNER JOIN
    (SELECT playerid, salary FROM salaries WHERE yearid = 2016) AS s
    ON a.playerid = s.playerid
   GROUP BY teamid
   ORDER BY teamid
;

