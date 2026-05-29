-- Top 10 batters
SELECT batter, SUM(batsman_runs) AS total_runs
FROM deliveries_clean
GROUP BY batter
ORDER BY total_runs DESC
LIMIT 10;

-- Top wicket takers
SELECT bowler, COUNT(*) AS wickets
FROM deliveries_clean
WHERE dismissal_kind IN (
    'bowled','caught','lbw','stumped','caught and bowled','hit wicket'
)
GROUP BY bowler
ORDER BY wickets DESC
LIMIT 10;

-- Team matches played + wins + win percentage

WITH all_matches AS (
    SELECT team1 AS team FROM matches_clean
    UNION ALL
    SELECT team2 AS team FROM matches_clean
),

matches_played AS (
    SELECT team, COUNT(*) AS matches_played
    FROM all_matches
    GROUP BY team
),

matches_won AS (
    SELECT winner AS team, COUNT(*) AS matches_won
    FROM matches_clean
    WHERE winner IS NOT NULL
    GROUP BY winner
)

SELECT 
    mp.team,
    mp.matches_played,
    COALESCE(mw.matches_won, 0) AS matches_won,
    (COALESCE(mw.matches_won, 0) * 100.0 / mp.matches_played) AS win_percentage
FROM matches_played mp
LEFT JOIN matches_won mw
ON mp.team = mw.team
ORDER BY win_percentage DESC;

-- Batter strike rate (excluding wides)

SELECT 
    batter,
    SUM(batsman_runs) AS total_runs,
    SUM(CASE WHEN extras_type = 'wides' THEN 0 ELSE 1 END) AS balls_faced,
    (SUM(batsman_runs) * 100.0 / 
     SUM(CASE WHEN extras_type = 'wides' THEN 0 ELSE 1 END)) AS strike_rate
FROM deliveries_clean
GROUP BY batter
HAVING SUM(CASE WHEN extras_type = 'wides' THEN 0 ELSE 1 END) >= 300
ORDER BY strike_rate DESC
LIMIT 10;

-- Phase-wise runs by team

SELECT 
    batting_team,
    CASE 
        WHEN over <= 6 THEN 'Powerplay'
        WHEN over <= 15 THEN 'Middle Overs'
        ELSE 'Death Overs'
    END AS phase,
    SUM(total_runs) AS total_runs
FROM deliveries_clean
GROUP BY batting_team, phase
ORDER BY batting_team, phase;
