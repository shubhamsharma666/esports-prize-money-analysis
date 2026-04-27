USE esports_analysis;
GO

-- Copy data from the imported general CSV table into the general staging table
INSERT INTO stg_general_esports (
    game_name,
    release_year,
    genre_name,
    total_earnings,
    offline_earnings,
    percent_offline,
    total_players,
    total_tournaments
)
SELECT
    Game,
    ReleaseDate,
    Genre,
    TotalEarnings,
    OfflineEarnings,
    PercentOffline,
    TotalPlayers,
    TotalTournaments
FROM cleaned_general_esports_data;
GO

-- Copy data from the imported historical CSV table into the historical staging table
INSERT INTO stg_historical_esports (
    full_date,
    game_name,
    earnings,
    players,
    tournaments,
    year,
    month
)
SELECT
    [Date],
    Game,
    Earnings,
    Players,
    Tournaments,
    [Year],
    [Month]
FROM cleaned_historical_esports_data;
GO

-- Load unique genres into the genre dimension
INSERT INTO dim_genre (genre_name)
SELECT DISTINCT genre_name
FROM stg_general_esports
WHERE genre_name IS NOT NULL;
GO

-- Clear dim_game before loading, so reruns do not leave partial or duplicate records
DELETE FROM dim_game;
GO

-- Load one row per unique game into the game dimension
-- Duplicate game names are consolidated using GROUP BY
INSERT INTO dim_game (
    game_name,
    release_year,
    genre_id,
    total_earnings,
    offline_earnings,
    percent_offline,
    total_players,
    total_tournaments
)
SELECT
    s.game_name,
    s.release_year,
    g.genre_id,
    s.total_earnings,
    s.offline_earnings,
    s.percent_offline,
    s.total_players,
    s.total_tournaments
FROM (
    SELECT
        game_name,
        MAX(release_year) AS release_year,
        MAX(genre_name) AS genre_name,
        MAX(total_earnings) AS total_earnings,
        MAX(offline_earnings) AS offline_earnings,
        MAX(percent_offline) AS percent_offline,
        MAX(total_players) AS total_players,
        MAX(total_tournaments) AS total_tournaments
    FROM stg_general_esports
    GROUP BY game_name
) s
LEFT JOIN dim_genre g
    ON s.genre_name = g.genre_name;
GO

-- Load unique dates into the date dimension
INSERT INTO dim_date (
    date_id,
    full_date,
    year,
    month,
    month_name,
    quarter
)
SELECT DISTINCT
    CAST(CONVERT(VARCHAR(8), full_date, 112) AS INT) AS date_id,
    full_date,
    year,
    month,
    DATENAME(MONTH, full_date) AS month_name,
    DATEPART(QUARTER, full_date) AS quarter
FROM stg_historical_esports
WHERE full_date IS NOT NULL;
GO

-- Load the fact table by linking historical staging rows to date and game dimensions
INSERT INTO fact_esports_earnings (
    date_id,
    game_id,
    earnings,
    players,
    tournaments
)
SELECT
    d.date_id,
    g.game_id,
    s.earnings,
    s.players,
    s.tournaments
FROM stg_historical_esports s
INNER JOIN dim_date d
    ON s.full_date = d.full_date
INNER JOIN dim_game g
    ON s.game_name = g.game_name;
GO

-- Validate row counts in the final model
SELECT 'dim_genre' AS table_name, COUNT(*) AS row_count FROM dim_genre
UNION ALL
SELECT 'dim_game', COUNT(*) FROM dim_game
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL
SELECT 'fact_esports_earnings', COUNT(*) FROM fact_esports_earnings;
GO
