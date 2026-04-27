-- Create the project database
CREATE DATABASE esports_analysis;
GO

-- Switch to the project database
USE esports_analysis;
GO

-- Create the genre dimension table
CREATE TABLE dim_genre (
    genre_id INT IDENTITY(1,1) PRIMARY KEY,
    genre_name VARCHAR(100) NOT NULL UNIQUE
);
GO

-- Create the game dimension table
CREATE TABLE dim_game (
    game_id INT IDENTITY(1,1) PRIMARY KEY,
    game_name VARCHAR(255) NOT NULL UNIQUE,
    release_year INT,
    genre_id INT,
    total_earnings DECIMAL(18,2),
    offline_earnings DECIMAL(18,2),
    percent_offline DECIMAL(10,6),
    total_players INT,
    total_tournaments INT,
    CONSTRAINT fk_dim_game_genre
        FOREIGN KEY (genre_id) REFERENCES dim_genre(genre_id)
);
GO

-- Create the date dimension table
CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT
);
GO

-- Create the fact table for historical esports performance
CREATE TABLE fact_esports_earnings (
    fact_id INT IDENTITY(1,1) PRIMARY KEY,
    date_id INT NOT NULL,
    game_id INT NOT NULL,
    earnings DECIMAL(18,2),
    players INT,
    tournaments INT,
    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    CONSTRAINT fk_fact_game
        FOREIGN KEY (game_id) REFERENCES dim_game(game_id)
);
GO

-- Create the general staging table
CREATE TABLE stg_general_esports (
    game_name VARCHAR(255),
    release_year INT,
    genre_name VARCHAR(100),
    total_earnings DECIMAL(18,2),
    offline_earnings DECIMAL(18,2),
    percent_offline DECIMAL(10,6),
    total_players INT,
    total_tournaments INT
);
GO

-- Create the historical staging table
CREATE TABLE stg_historical_esports (
    full_date DATE,
    game_name VARCHAR(255),
    earnings DECIMAL(18,2),
    players INT,
    tournaments INT,
    year INT,
    month INT
);
GO
