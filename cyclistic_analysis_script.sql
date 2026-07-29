-- Creating Database
CREATE DATABASE cyclistic_db;
USE cyclistic_db;


-- Creating table for load bulk file of import of csv 
CREATE TABLE trips_2026_06 (
    ride_id VARCHAR(255),
    rideable_type VARCHAR(255),
    started_at VARCHAR(255),
    ended_at VARCHAR(255),
    start_station_name VARCHAR(255),
    start_station_id VARCHAR(255),
    end_station_name VARCHAR(255),
    end_station_id VARCHAR(255),
    start_lat DOUBLE,
    start_lng DOUBLE,
    end_lat DOUBLE,
    end_lng DOUBLE,
    member_casual VARCHAR(50)
);

-- To load/import each csv file as bulk to safe time and make work fast and also nulling blank spaces in the columns
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/Cyclistic_TripData_202606_v01.csv'
INTO TABLE trips_2026_06
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    @start_lat,
    @start_lng,
    @end_lat,
    @end_lng,
    member_casual
)
SET 
    start_lat = NULLIF(@start_lat, ''),
    start_lng = NULLIF(@start_lng, ''),
    end_lat = NULLIF(@end_lat, ''),
    end_lng = NULLIF(@end_lng, '');
    
-- To change the started at and ended at column to datetime with nano-sec (3)
ALTER TABLE trips_2026_06 
MODIFY COLUMN started_at DATETIME(3),
MODIFY COLUMN ended_at DATETIME(3);

-- To Find the location of MySQL Upload folder
SHOW VARIABLES LIKE 'secure_file_priv';


-- Sorting and Filtering 
SELECT 
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    end_station_name,
    member_casual,
    TIMEDIFF(ended_at, started_at) AS ride_length,
    DAYOFWEEK(started_at) AS day_of_week
FROM trips_2025_07
WHERE 
    -- 1. Remove Missing Data
    start_station_name IS NOT NULL AND start_station_name != ''
    AND end_station_name IS NOT NULL AND end_station_name != ''
    AND start_lat IS NOT NULL 
    AND end_lat IS NOT NULL
    
    -- 2. Filter Invalid Ride Lengths & Outliers
    AND TIMESTAMPDIFF(MINUTE, started_at, ended_at) >= 1
    AND TIMESTAMPDIFF(HOUR, started_at, ended_at) <= 24
    
    -- 3. Remove Internal Company Testing 
    AND LOWER(start_station_name) NOT LIKE '%maintenance%'
    AND LOWER(start_station_name) NOT LIKE '%test%'
    AND LOWER(start_station_name) NOT LIKE '%base - 2132 w hubbard%'
    
    -- 4. Secure the Business Task Variables
    AND member_casual IN ('member', 'casual')
    
-- 5. Sort the Data Chronologically
ORDER BY started_at ASC;

-- Processing and Cleaning
CREATE TABLE trips_full_year_raw AS
SELECT * FROM trips_2025_07
UNION ALL
SELECT * FROM trips_2025_08
UNION ALL
SELECT * FROM trips_2025_09
UNION ALL
SELECT * FROM trips_2025_10
UNION ALL
SELECT * FROM trips_2025_11
UNION ALL
SELECT * FROM trips_2025_12
UNION ALL
SELECT * FROM trips_2026_01
UNION ALL
SELECT * FROM trips_2026_02
UNION ALL
SELECT * FROM trips_2026_03
UNION ALL
SELECT * FROM trips_2026_04
UNION ALL
SELECT * FROM trips_2026_05
UNION ALL
SELECT * FROM trips_2026_06;

CREATE TABLE trips_full_year_clean AS
SELECT 
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    end_station_name,
    member_casual,
    TIMEDIFF(ended_at, started_at) AS ride_length,
    DAYOFWEEK(started_at) AS day_of_week
FROM trips_full_year_raw
WHERE 
    -- 1. Remove Missing Data
    start_station_name IS NOT NULL AND start_station_name != ''
    AND end_station_name IS NOT NULL AND end_station_name != ''
    AND start_lat IS NOT NULL 
    AND end_lat IS NOT NULL
    
    -- 2. Filter Invalid Ride Lengths & Outliers
    AND TIMESTAMPDIFF(MINUTE, started_at, ended_at) >= 1
    AND TIMESTAMPDIFF(HOUR, started_at, ended_at) <= 24
    
    -- 3. Remove Internal Company Testing 
    AND LOWER(start_station_name) NOT LIKE '%maintenance%'
    AND LOWER(start_station_name) NOT LIKE '%test%'
    AND LOWER(start_station_name) NOT LIKE '%base - 2132 w hubbard%'
    
    -- 4. Secure the Business Task Variables
    AND member_casual IN ('member', 'casual')
    
-- 5. Sort the Data Chronologically
ORDER BY started_at ASC;

-- Sanity Check
SELECT 
    COUNT(*) AS total_clean_rides,
    MIN(ride_length) AS shortest_ride,
    MAX(ride_length) AS longest_ride,
    SUM(CASE WHEN start_station_name IS NULL THEN 1 ELSE 0 END) AS remaining_nulls
FROM trips_full_year_clean;

-- Summary Statistics
SELECT 
    COUNT(ride_id) AS total_clean_rides,
    MIN(ride_length) AS shortest_ride,
    MAX(ride_length) AS longest_ride,
    SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length))) AS average_ride_length
FROM trips_full_year_clean;

-- The High-Level Overview (Member vs. Casual), This first query compares the overall volume and duration of rides between your two user types.
SELECT 
    member_casual,
    COUNT(ride_id) AS total_rides,
    SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length))) AS average_ride_length,
    MAX(ride_length) AS longest_ride
FROM trips_full_year_clean
GROUP BY member_casual;

-- The Weekly Trend Analysis (By Day of the Week)
SELECT 
    day_of_week,
    member_casual,
    COUNT(ride_id) AS total_rides,
    SEC_TO_TIME(AVG(TIME_TO_SEC(ride_length))) AS average_ride_length
FROM trips_full_year_clean
GROUP BY 
    day_of_week, 
    member_casual
ORDER BY 
    day_of_week ASC, 
    member_casual;

-- Additional Metrics
-- Hourly Usage Trends
SELECT 
    HOUR(started_at) AS hour_of_day,
    member_casual,
    COUNT(ride_id) AS total_rides
FROM trips_full_year_clean
GROUP BY 
    hour_of_day, 
    member_casual
ORDER BY 
    hour_of_day ASC, 
    member_casual;

-- Seasonal (Monthly Dropoff)
SELECT 
    DATE_FORMAT(started_at, '%Y-%m') AS ride_month,
    member_casual,
    COUNT(ride_id) AS total_rides
FROM trips_full_year_clean
GROUP BY 
    ride_month, 
    member_casual
ORDER BY 
    ride_month ASC, 
    member_casual;

-- Geographical Hotspots (Hot Stations)
SELECT 
    start_station_name,
    member_casual,
    COUNT(ride_id) AS total_rides
FROM trips_full_year_clean
GROUP BY 
    start_station_name, 
    member_casual
ORDER BY 
    total_rides DESC
LIMIT 50;

-- Bike type preferences
SELECT 
    rideable_type,
    member_casual,
    COUNT(ride_id) AS total_rides
FROM trips_full_year_clean
GROUP BY 
    rideable_type, 
    member_casual
ORDER BY 
    member_casual ASC, 
    total_rides DESC;