USE esports_analysis;
GO

-- =========================================
-- 1. Top 10 games by total historical earnings
-- =========================================
SELECT TOP 10
    g.game_name,
    SUM(f.earnings) AS total_earnings
FROM fact_esports_earnings f
INNER JOIN dim_game g
    ON f.game_id = g.game_id
GROUP BY g.game_name
ORDER BY total_earnings DESC;
GO

-- =========================================
-- 2. Total earnings by genre
-- =========================================
SELECT
    ge.genre_name,
    SUM(f.earnings) AS total_earnings
FROM fact_esports_earnings f
INNER JOIN dim_game g
    ON f.game_id = g.game_id
INNER JOIN dim_genre ge
    ON g.genre_id = ge.genre_id
GROUP BY ge.genre_name
ORDER BY total_earnings DESC;
GO

-- =========================================
-- 3. Yearly total esports earnings
-- =========================================
SELECT
    d.year,
    SUM(f.earnings) AS total_earnings
FROM fact_esports_earnings f
INNER JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY d.year
ORDER BY d.year;
GO

-- =========================================
-- 4. Market share by game
-- =========================================
SELECT TOP 10
    g.game_name,
    SUM(f.earnings) AS total_earnings,
    CAST(
        100.0 * SUM(f.earnings) / SUM(SUM(f.earnings)) OVER ()
        AS DECIMAL(10,2)
    ) AS market_share_pct
FROM fact_esports_earnings f
INNER JOIN dim_game g
    ON f.game_id = g.game_id
GROUP BY g.game_name
ORDER BY total_earnings DESC;
GO

-- =========================================
-- 5. Top 5 games share of the total market
-- =========================================
WITH game_totals AS (
    SELECT
        g.game_name,
        SUM(f.earnings) AS total_earnings
    FROM fact_esports_earnings f
    INNER JOIN dim_game g
        ON f.game_id = g.game_id
    GROUP BY g.game_name
),
ranked_games AS (
    SELECT
        game_name,
        total_earnings,
        ROW_NUMBER() OVER (ORDER BY total_earnings DESC) AS game_rank
    FROM game_totals
)
SELECT
    SUM(total_earnings) AS top_5_total_earnings,
    CAST(
        100.0 * SUM(total_earnings) / (SELECT SUM(total_earnings) FROM game_totals)
        AS DECIMAL(10,2)
    ) AS top_5_market_share_pct
FROM ranked_games
WHERE game_rank <= 5;
GO

-- =========================================
-- 6. Top 10 games share of the total market
-- =========================================
WITH game_totals AS (
    SELECT
        g.game_name,
        SUM(f.earnings) AS total_earnings
    FROM fact_esports_earnings f
    INNER JOIN dim_game g
        ON f.game_id = g.game_id
    GROUP BY g.game_name
),
ranked_games AS (
    SELECT
        game_name,
        total_earnings,
        ROW_NUMBER() OVER (ORDER BY total_earnings DESC) AS game_rank
    FROM game_totals
)
SELECT
    SUM(total_earnings) AS top_10_total_earnings,
    CAST(
        100.0 * SUM(total_earnings) / (SELECT SUM(total_earnings) FROM game_totals)
        AS DECIMAL(10,2)
    ) AS top_10_market_share_pct
FROM ranked_games
WHERE game_rank <= 10;
GO

-- =========================================
-- 7. Top 5 games share by year
-- =========================================
WITH yearly_game_totals AS (
    SELECT
        d.year,
        g.game_name,
        SUM(f.earnings) AS total_earnings
    FROM fact_esports_earnings f
    INNER JOIN dim_date d
        ON f.date_id = d.date_id
    INNER JOIN dim_game g
        ON f.game_id = g.game_id
    GROUP BY d.year, g.game_name
),
ranked_yearly_games AS (
    SELECT
        year,
        game_name,
        total_earnings,
        ROW_NUMBER() OVER (
            PARTITION BY year
            ORDER BY total_earnings DESC
        ) AS game_rank
    FROM yearly_game_totals
),
yearly_totals AS (
    SELECT
        year,
        SUM(total_earnings) AS year_total_earnings
    FROM yearly_game_totals
    GROUP BY year
)
SELECT
    r.year,
    SUM(r.total_earnings) AS top_5_earnings,
    y.year_total_earnings,
    CAST(
        100.0 * SUM(r.total_earnings) / y.year_total_earnings
        AS DECIMAL(10,2)
    ) AS top_5_share_pct
FROM ranked_yearly_games r
INNER JOIN yearly_totals y
    ON r.year = y.year
WHERE r.game_rank <= 5
GROUP BY r.year, y.year_total_earnings
ORDER BY r.year;
GO


-- =========================================
-- 8. HHI by year
-- =========================================

-- Create or update a view that calculates yearly HHI
-- HHI measures how concentrated esports prize money is across games
-- Higher HHI means fewer games dominate the market
CREATE OR ALTER VIEW [dbo].[vw_hhi_by_year]
AS
SELECT
    s.year,
    CAST(SUM(POWER(s.market_share, 2)) AS DECIMAL(12,6)) AS hhi
FROM (
    SELECT
        d.year,
        g.game_name,
        SUM(f.earnings) * 1.0 /
        SUM(SUM(f.earnings)) OVER (PARTITION BY d.year) AS market_share
    FROM fact_esports_earnings f
    INNER JOIN dim_date d
        ON f.date_id = d.date_id
    INNER JOIN dim_game g
        ON f.game_id = g.game_id
    GROUP BY d.year, g.game_name
) s
GROUP BY s.year;
GO

-- Preview yearly HHI values
SELECT *
FROM dbo.vw_hhi_by_year
ORDER BY year;
GO
