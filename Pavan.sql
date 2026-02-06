-- ============================================
-- CS621 Spatial Databases Project
-- Title: F1 Circuits WorldWide
-- Studen number: 25251028
-- ============================================

CREATE EXTENSION IF NOT EXISTS postgis;

-- Verify PostGIS is installed
SELECT PostGIS_Version();

DROP TABLE IF EXISTS f1_circuits CASCADE;
DROP VIEW IF EXISTS circuits_by_length CASCADE;
DROP VIEW IF EXISTS circuits_per_country CASCADE;
DROP VIEW IF EXISTS circuit_distances CASCADE;
DROP VIEW IF EXISTS country_circuit_centers CASCADE;
DROP VIEW IF EXISTS nearest_circuits CASCADE;
DROP VIEW IF EXISTS circuits_within_500km CASCADE;
DROP VIEW IF EXISTS circuits_for_qgis CASCADE;
DROP VIEW IF EXISTS circuit_distance_lines CASCADE;

-- Create main F1 circuits table with spatial data
CREATE TABLE f1_circuits (
    circuit_id SERIAL PRIMARY KEY,
    circuit_name VARCHAR(200) NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100),
    length_km NUMERIC(5,3) CHECK (length_km > 0),
    first_gp_year INTEGER CHECK (first_gp_year >= 1950 AND first_gp_year <= 2030),
    last_gp_year INTEGER CHECK (last_gp_year >= 1950 AND last_gp_year <= 2030),
    total_gps INTEGER CHECK (total_gps >= 0),
    circuit_type VARCHAR(50),
    status VARCHAR(20),
    geom GEOMETRY(Point, 4326),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_circuits_geom ON f1_circuits USING GIST(geom);
CREATE INDEX idx_circuits_country ON f1_circuits(country);
CREATE INDEX idx_circuits_status ON f1_circuits(status);
CREATE INDEX idx_circuits_length ON f1_circuits(length_km);

-- Add table and column comments
COMMENT ON TABLE f1_circuits IS 'Formula 1 race circuits worldwide with spatial coordinates for CS621 project';
COMMENT ON COLUMN f1_circuits.geom IS 'Point geometry in WGS84 (EPSG:4326) coordinate system';
COMMENT ON COLUMN f1_circuits.length_km IS 'Circuit length in kilometers';
COMMENT ON COLUMN f1_circuits.circuit_type IS 'Type: Permanent, Street, or Hybrid';
COMMENT ON COLUMN f1_circuits.status IS 'Status: Active, Inactive, or Historic';


-- PART 4: INSERT F1 CIRCUIT DATA
-- ================================================================

-- Insert current and historic F1 circuits
INSERT INTO f1_circuits (circuit_name, city, country, length_km, first_gp_year, last_gp_year, total_gps, circuit_type, status, geom)
VALUES
    -- EUROPE - Current Active Circuits
    ('Circuit de Monaco', 'Monte Carlo', 'Monaco', 3.337, 1950, 2024, 71, 'Street', 'Active', ST_SetSRID(ST_MakePoint(7.4246, 43.7347), 4326)),
    ('Silverstone Circuit', 'Silverstone', 'United Kingdom', 5.891, 1950, 2024, 57, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(-1.0166, 52.0786), 4326)),
    ('Autodromo Nazionale di Monza', 'Monza', 'Italy', 5.793, 1950, 2024, 73, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(9.2811, 45.6156), 4326)),
    ('Circuit de Spa-Francorchamps', 'Spa', 'Belgium', 7.004, 1950, 2024, 56, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(5.9714, 50.4372), 4326)),
    ('Red Bull Ring', 'Spielberg', 'Austria', 4.318, 1970, 2024, 39, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(14.7647, 47.2197), 4326)),
    ('Circuit Zandvoort', 'Zandvoort', 'Netherlands', 4.259, 1952, 2024, 33, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(4.5403, 52.3888), 4326)),
    ('Autodromo Enzo e Dino Ferrari', 'Imola', 'Italy', 4.909, 1980, 2024, 31, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(11.7167, 44.3439), 4326)),
    ('Circuit de Barcelona-Catalunya', 'Barcelona', 'Spain', 4.675, 1991, 2024, 33, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(2.2611, 41.5700), 4326)),
    ('Hungaroring', 'Budapest', 'Hungary', 4.381, 1986, 2024, 38, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(19.2486, 47.5789), 4326)),
    
    -- MIDDLE EAST - Current Active
    ('Bahrain International Circuit', 'Sakhir', 'Bahrain', 5.412, 2004, 2024, 20, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(50.5106, 26.0325), 4326)),
    ('Yas Marina Circuit', 'Abu Dhabi', 'UAE', 5.281, 2009, 2024, 15, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(54.6031, 24.4672), 4326)),
    ('Jeddah Corniche Circuit', 'Jeddah', 'Saudi Arabia', 6.174, 2021, 2024, 4, 'Street', 'Active', ST_SetSRID(ST_MakePoint(39.1043, 21.6319), 4326)),
    ('Losail International Circuit', 'Lusail', 'Qatar', 5.380, 2021, 2024, 3, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(51.4542, 25.4900), 4326)),
    
    -- ASIA - Current Active
    ('Suzuka Circuit', 'Suzuka', 'Japan', 5.807, 1987, 2024, 36, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(136.5358, 34.8431), 4326)),
    ('Marina Bay Street Circuit', 'Singapore', 'Singapore', 4.940, 2008, 2024, 16, 'Street', 'Active', ST_SetSRID(ST_MakePoint(103.8607, 1.2914), 4326)),
    ('Shanghai International Circuit', 'Shanghai', 'China', 5.451, 2004, 2024, 20, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(121.2197, 31.3389), 4326)),
    
    -- AMERICAS - Current Active
    ('Circuit of the Americas', 'Austin', 'USA', 5.513, 2012, 2024, 12, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(-97.6411, 30.1328), 4326)),
    ('Miami International Autodrome', 'Miami', 'USA', 5.410, 2022, 2024, 3, 'Street', 'Active', ST_SetSRID(ST_MakePoint(-80.2389, 25.9581), 4326)),
    ('Autódromo Hermanos Rodríguez', 'Mexico City', 'Mexico', 4.304, 1963, 2024, 23, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(-99.0907, 19.4042), 4326)),
    ('Autódromo José Carlos Pace', 'São Paulo', 'Brazil', 4.309, 1973, 2024, 50, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(-46.6972, -23.7014), 4326)),
    ('Circuit Gilles Villeneuve', 'Montreal', 'Canada', 4.361, 1978, 2024, 44, 'Permanent', 'Active', ST_SetSRID(ST_MakePoint(-73.5273, 45.5000), 4326)),
    ('Las Vegas Strip Circuit', 'Las Vegas', 'USA', 6.120, 2023, 2024, 2, 'Street', 'Active', ST_SetSRID(ST_MakePoint(-115.1728, 36.1147), 4326)),
    
    -- OCEANIA - Current Active
    ('Albert Park Circuit', 'Melbourne', 'Australia', 5.278, 1996, 2024, 27, 'Street', 'Active', ST_SetSRID(ST_MakePoint(144.9680, -37.8497), 4326));

-- Insert second batch - Historic and Inactive Circuits
INSERT INTO f1_circuits (circuit_name, city, country, length_km, first_gp_year, last_gp_year, total_gps, circuit_type, status, geom)
VALUES
    -- EUROPE - Historic Circuits
    ('Nürburgring Nordschleife', 'Nürburg', 'Germany', 22.810, 1951, 1976, 24, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(6.9475, 50.3356), 4326)),
    ('Hockenheimring', 'Hockenheim', 'Germany', 4.574, 1970, 2019, 36, 'Permanent', 'Inactive', ST_SetSRID(ST_MakePoint(8.5658, 49.3278), 4326)),
    ('Circuit Paul Ricard', 'Le Castellet', 'France', 5.842, 1971, 2022, 18, 'Permanent', 'Inactive', ST_SetSRID(ST_MakePoint(5.7917, 43.2506), 4326)),
    ('Magny-Cours', 'Nevers', 'France', 4.411, 1991, 2008, 18, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(3.1633, 46.8642), 4326)),
    ('Brands Hatch', 'Kent', 'United Kingdom', 4.206, 1964, 1986, 12, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(0.2633, 51.3569), 4326)),
    ('Estoril', 'Estoril', 'Portugal', 4.360, 1984, 1996, 13, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(-9.3942, 38.7500), 4326)),
    ('Jerez', 'Jerez', 'Spain', 4.428, 1986, 1997, 7, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(-6.0344, 36.7083), 4326)),
    ('Anderstorp', 'Anderstorp', 'Sweden', 4.018, 1973, 1978, 6, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(13.5994, 57.2636), 4326)),
    
    -- AMERICAS - Historic
    ('Indianapolis Motor Speedway', 'Indianapolis', 'USA', 4.192, 2000, 2007, 8, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(-86.2350, 39.7950), 4326)),
    ('Watkins Glen', 'Watkins Glen', 'USA', 5.430, 1961, 1980, 20, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(-76.9272, 42.3369), 4326)),
    ('Long Beach', 'Long Beach', 'USA', 3.275, 1976, 1983, 8, 'Street', 'Historic', ST_SetSRID(ST_MakePoint(-118.1678, 33.7678), 4326)),
    ('Buenos Aires', 'Buenos Aires', 'Argentina', 4.259, 1953, 1998, 20, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(-58.4847, -34.6886), 4326)),
    
    -- ASIA - Historic
    ('Sepang International Circuit', 'Kuala Lumpur', 'Malaysia', 5.543, 1999, 2017, 19, 'Permanent', 'Inactive', ST_SetSRID(ST_MakePoint(101.7381, 2.7608), 4326)),
    ('Korean International Circuit', 'Yeongam', 'South Korea', 5.615, 2010, 2013, 4, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(126.8836, 34.7333), 4326)),
    ('Buddh International Circuit', 'Greater Noida', 'India', 5.125, 2011, 2013, 3, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(77.5250, 28.3489), 4326)),
    ('Fuji Speedway', 'Oyama', 'Japan', 4.563, 1976, 2008, 4, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(138.9272, 35.3686), 4326)),
    
    -- AFRICA & OCEANIA - Historic
    ('Kyalami', 'Johannesburg', 'South Africa', 4.522, 1967, 1993, 20, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(28.0719, -25.9894), 4326)),
    ('Adelaide Street Circuit', 'Adelaide', 'Australia', 3.780, 1985, 1995, 11, 'Street', 'Historic', ST_SetSRID(ST_MakePoint(138.6200, -34.9275), 4326)),
    
    -- Additional Historic European Circuits
    ('Österreichring', 'Spielberg', 'Austria', 5.911, 1970, 1987, 18, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(14.7647, 47.2197), 4326)),
    ('Zolder', 'Zolder', 'Belgium', 4.011, 1973, 1984, 10, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(5.2567, 50.9897), 4326)),
    ('Dijon-Prenois', 'Dijon', 'France', 3.801, 1974, 1984, 5, 'Permanent', 'Historic', ST_SetSRID(ST_MakePoint(4.8994, 47.3628), 4326)),
    ('Reims-Gueux', 'Reims', 'France', 7.816, 1950, 1966, 11, 'Road', 'Historic', ST_SetSRID(ST_MakePoint(4.0367, 49.2472), 4326)),
    ('Ain-Diab', 'Casablanca', 'Morocco', 7.618, 1958, 1958, 1, 'Street', 'Historic', ST_SetSRID(ST_MakePoint(-7.6839, 33.5731), 4326)),
    ('Monsanto Park Circuit', 'Lisbon', 'Portugal', 5.440, 1959, 1959, 1, 'Street', 'Historic', ST_SetSRID(ST_MakePoint(-9.1953, 38.7211), 4326)),
    ('Pedralbes Circuit', 'Barcelona', 'Spain', 6.316, 1951, 1954, 2, 'Street', 'Historic', ST_SetSRID(ST_MakePoint(2.1142, 41.3897), 4326));

-- Verify total data insertion
SELECT COUNT(*) as total_circuits,
       MIN(first_gp_year) as first_gp,
       MAX(last_gp_year) as most_recent_gp,
       COUNT(CASE WHEN status = 'Active' THEN 1 END) as active_circuits
FROM f1_circuits;


-- View 1: Circuits ordered by length
CREATE VIEW circuits_by_length AS
SELECT 
    circuit_name,
    city,
    country,
    length_km,
    first_gp_year,
    last_gp_year,
    total_gps,
    status,
    ROUND(ST_X(geom)::numeric, 4) as longitude,
    ROUND(ST_Y(geom)::numeric, 4) as latitude
FROM f1_circuits
ORDER BY length_km DESC;

-- View 2: Circuits per country
CREATE VIEW circuits_per_country AS
SELECT 
    country,
    COUNT(*) as circuit_count,
    ROUND(AVG(length_km)::numeric, 3) as avg_length_km,
    MAX(length_km) as longest_circuit_km,
    SUM(total_gps) as total_gps_held,
    COUNT(CASE WHEN status = 'Active' THEN 1 END) as active_circuits
FROM f1_circuits
GROUP BY country
ORDER BY circuit_count DESC, total_gps_held DESC;

-- View 3: Circuit distances within same country
CREATE VIEW circuit_distances AS
SELECT 
    c1.circuit_name as circuit_1,
    c2.circuit_name as circuit_2,
    c1.country,
    ROUND((ST_Distance(c1.geom::geography, c2.geom::geography)/1000)::numeric, 2) as distance_km
FROM f1_circuits c1
JOIN f1_circuits c2 ON c1.country = c2.country AND c1.circuit_id < c2.circuit_id
ORDER BY c1.country, distance_km;

-- View 4: Geographic center of circuits by country
CREATE VIEW country_circuit_centers AS
SELECT 
    country,
    COUNT(*) as circuit_count,
    ST_AsText(ST_Centroid(ST_Collect(geom))) as center_point,
    ROUND(ST_X(ST_Centroid(ST_Collect(geom)))::numeric, 4) as center_longitude,
    ROUND(ST_Y(ST_Centroid(ST_Collect(geom)))::numeric, 4) as center_latitude,
    ST_Centroid(ST_Collect(geom)) as geom
FROM f1_circuits
GROUP BY country
HAVING COUNT(*) > 1;

-- View 5: Nearest neighbor for each circuit
CREATE VIEW nearest_circuits AS
SELECT DISTINCT ON (c1.circuit_id)
    c1.circuit_id,
    c1.circuit_name as circuit,
    c1.city,
    c1.country,
    c1.status,
    c2.circuit_name as nearest_circuit,
    c2.city as nearest_city,
    c2.country as nearest_country,
    ROUND((ST_Distance(c1.geom::geography, c2.geom::geography)/1000)::numeric, 2) as distance_km,
    c1.geom
FROM f1_circuits c1
CROSS JOIN f1_circuits c2
WHERE c1.circuit_id != c2.circuit_id
ORDER BY c1.circuit_id, ST_Distance(c1.geom, c2.geom);

-- View 6: Circuits within 500km
CREATE VIEW circuits_within_500km AS
SELECT 
    c1.circuit_name as reference_circuit,
    c1.city as reference_city,
    c1.country as reference_country,
    c2.circuit_name as nearby_circuit,
    c2.city as nearby_city,
    c2.country as nearby_country,
    c2.status as nearby_status,
    ROUND((ST_Distance(c1.geom::geography, c2.geom::geography)/1000)::numeric, 2) as distance_km
FROM f1_circuits c1
CROSS JOIN f1_circuits c2
WHERE c1.circuit_id != c2.circuit_id
    AND ST_DWithin(c1.geom::geography, c2.geom::geography, 500000)
ORDER BY c1.circuit_name, distance_km;

-- View 7: Circuit distance lines (for QGIS visualization)
CREATE VIEW circuit_distance_lines AS
SELECT 
    ROW_NUMBER() OVER() as line_id,
    c1.circuit_name as circuit_1,
    c2.circuit_name as circuit_2,
    c1.country,
    ST_MakeLine(c1.geom, c2.geom) as geom,
    ROUND((ST_Distance(c1.geom::geography, c2.geom::geography)/1000)::numeric, 2) as distance_km
FROM f1_circuits c1
JOIN f1_circuits c2 ON c1.country = c2.country AND c1.circuit_id < c2.circuit_id;

-- View 8: Main QGIS visualization view
CREATE VIEW circuits_for_qgis AS
SELECT 
    circuit_id,
    circuit_name,
    city,
    country,
    length_km,
    first_gp_year,
    last_gp_year,
    total_gps,
    circuit_type,
    status,
    CASE 
        WHEN length_km >= 6.0 THEN 'Very Long (6km+)'
        WHEN length_km >= 5.0 THEN 'Long (5-6km)'
        WHEN length_km >= 4.0 THEN 'Medium (4-5km)'
        ELSE 'Short (<4km)'
    END as length_category,
    CASE 
        WHEN first_gp_year < 1970 THEN 'Classic Era (1950s-1960s)'
        WHEN first_gp_year < 1990 THEN 'Modern Era (1970s-1980s)'
        WHEN first_gp_year < 2010 THEN 'Contemporary (1990s-2000s)'
        ELSE 'Recent (2010+)'
    END as era_category,
    2024 - first_gp_year as years_since_first_gp,
    geom
FROM f1_circuits;



-- Sample 1: Top 10 longest circuits
SELECT * FROM circuits_by_length LIMIT 10;

-- Sample 2: Circuits per country
SELECT * FROM circuits_per_country;

-- Sample 3: Distances between circuits in Italy
SELECT * FROM circuit_distances WHERE country = 'Italy';

-- Sample 4: Nearest neighbors
SELECT * FROM nearest_circuits LIMIT 10;

-- Sample 5: Circuits near Silverstone
SELECT * FROM circuits_within_500km WHERE reference_circuit = 'Silverstone Circuit';

-- Sample 6: Distance lines for visualization
SELECT * FROM circuit_distance_lines LIMIT 10;



-- Global circuit statistics
SELECT 
    'Global Statistics' as metric_category,
    COUNT(*) as total_circuits,
    COUNT(CASE WHEN status = 'Active' THEN 1 END) as active_circuits,
    COUNT(CASE WHEN status = 'Historic' THEN 1 END) as historic_circuits,
    ROUND(AVG(length_km)::numeric, 3) as avg_length_km,
    MAX(length_km) as longest_circuit_km,
    MIN(length_km) as shortest_circuit_km,
    SUM(total_gps) as total_gps_all_time
FROM f1_circuits;

-- Circuits by era
SELECT 
    CASE 
        WHEN first_gp_year < 1970 THEN 'Classic Era (1950s-1960s)'
        WHEN first_gp_year < 1990 THEN 'Modern Era (1970s-1980s)'
        WHEN first_gp_year < 2010 THEN 'Contemporary (1990s-2000s)'
        ELSE 'Recent (2010+)'
    END as era,
    COUNT(*) as circuit_count,
    ROUND(AVG(length_km)::numeric, 3) as avg_length_km,
    COUNT(CASE WHEN status = 'Active' THEN 1 END) as still_active
FROM f1_circuits
GROUP BY 
    CASE 
        WHEN first_gp_year < 1970 THEN 'Classic Era (1950s-1960s)'
        WHEN first_gp_year < 1990 THEN 'Modern Era (1970s-1980s)'
        WHEN first_gp_year < 2010 THEN 'Contemporary (1990s-2000s)'
        ELSE 'Recent (2010+)'
    END
ORDER BY MIN(first_gp_year);

-- Circuits by type and status
SELECT 
    circuit_type,
    status,
    COUNT(*) as count,
    ROUND(AVG(length_km)::numeric, 3) as avg_length_km
FROM f1_circuits
GROUP BY circuit_type, status
ORDER BY circuit_type, status;

-- Circuit clustering analysis (within 200km)
SELECT 
    c1.circuit_name,
    c1.city,
    c1.country,
    c1.status,
    COUNT(c2.circuit_id) - 1 as nearby_circuits_within_200km,
    CASE 
        WHEN COUNT(c2.circuit_id) - 1 >= 4 THEN 'High Density'
        WHEN COUNT(c2.circuit_id) - 1 >= 2 THEN 'Medium Density'
        WHEN COUNT(c2.circuit_id) - 1 >= 1 THEN 'Low Density'
        ELSE 'Isolated'
    END as density_category
FROM f1_circuits c1
LEFT JOIN f1_circuits c2 
    ON c1.circuit_id != c2.circuit_id 
    AND ST_DWithin(c1.geom::geography, c2.geom::geography, 200000)
GROUP BY c1.circuit_id, c1.circuit_name, c1.city, c1.country, c1.status
ORDER BY nearby_circuits_within_200km DESC;

-- Most isolated circuits
SELECT 
    c1.circuit_name,
    c1.city,
    c1.country,
    c1.status,
    ROUND(MIN(ST_Distance(c1.geom::geography, c2.geom::geography)/1000)::numeric, 2) as nearest_circuit_km
FROM f1_circuits c1
CROSS JOIN f1_circuits c2
WHERE c1.circuit_id != c2.circuit_id
GROUP BY c1.circuit_id, c1.circuit_name, c1.city, c1.country, c1.status
ORDER BY nearest_circuit_km DESC
LIMIT 10;

-- Active circuits by region
SELECT 
    CASE 
        WHEN country IN ('United Kingdom', 'Italy', 'Germany', 'France', 'Spain', 'Belgium', 'Austria', 'Netherlands', 'Monaco', 'Hungary', 'Portugal', 'Sweden') THEN 'Europe'
        WHEN country IN ('USA', 'Canada', 'Mexico', 'Brazil', 'Argentina') THEN 'Americas'
        WHEN country IN ('Japan', 'China', 'Singapore', 'Malaysia', 'South Korea', 'India') THEN 'Asia'
        WHEN country IN ('Bahrain', 'UAE', 'Saudi Arabia', 'Qatar') THEN 'Middle East'
        WHEN country IN ('Australia') THEN 'Oceania'
        WHEN country IN ('South Africa', 'Morocco') THEN 'Africa'
        ELSE 'Other'
    END as region,
    COUNT(*) as circuit_count,
    COUNT(CASE WHEN status = 'Active' THEN 1 END) as active_count,
    ROUND(AVG(length_km)::numeric, 3) as avg_length_km
FROM f1_circuits
GROUP BY 
    CASE 
        WHEN country IN ('United Kingdom', 'Italy', 'Germany', 'France', 'Spain', 'Belgium', 'Austria', 'Netherlands', 'Monaco', 'Hungary', 'Portugal', 'Sweden') THEN 'Europe'
        WHEN country IN ('USA', 'Canada', 'Mexico', 'Brazil', 'Argentina') THEN 'Americas'
        WHEN country IN ('Japan', 'China', 'Singapore', 'Malaysia', 'South Korea', 'India') THEN 'Asia'
        WHEN country IN ('Bahrain', 'UAE', 'Saudi Arabia', 'Qatar') THEN 'Middle East'
        WHEN country IN ('Australia') THEN 'Oceania'
        WHEN country IN ('South Africa', 'Morocco') THEN 'Africa'
        ELSE 'Other'
    END
ORDER BY circuit_count DESC;

-- Evolution of circuit lengths over time
SELECT 
    CASE 
        WHEN first_gp_year < 1970 THEN '1950s-1960s'
        WHEN first_gp_year < 1990 THEN '1970s-1980s'
        WHEN first_gp_year < 2010 THEN '1990s-2000s'
        ELSE '2010s-2020s'
    END as decade_group,
    COUNT(*) as circuits_introduced,
    ROUND(AVG(length_km)::numeric, 3) as avg_length_km,
    ROUND(MAX(length_km)::numeric, 3) as max_length_km,
    ROUND(MIN(length_km)::numeric, 3) as min_length_km
FROM f1_circuits
GROUP BY 
    CASE 
        WHEN first_gp_year < 1970 THEN '1950s-1960s'
        WHEN first_gp_year < 1990 THEN '1970s-1980s'
        WHEN first_gp_year < 2010 THEN '1990s-2000s'
        ELSE '2010s-2020s'
    END
ORDER BY MIN(first_gp_year);

-- Bounding box of all circuits
SELECT 
    ST_AsText(ST_Envelope(ST_Collect(geom))) as bounding_box,
    ROUND(ST_XMin(ST_Envelope(ST_Collect(geom)))::numeric, 4) as min_longitude,
    ROUND(ST_YMin(ST_Envelope(ST_Collect(geom)))::numeric, 4) as min_latitude,
    ROUND(ST_XMax(ST_Envelope(ST_Collect(geom)))::numeric, 4) as max_longitude,
    ROUND(ST_YMax(ST_Envelope(ST_Collect(geom)))::numeric, 4) as max_latitude
FROM f1_circuits;



-- Final project summary
SELECT 
    'F1 PROJECT SUMMARY' as section,
    (SELECT COUNT(*) FROM f1_circuits) as total_circuits,
    (SELECT COUNT(DISTINCT country) FROM f1_circuits) as countries_covered,
    (SELECT circuit_name FROM f1_circuits ORDER BY length_km DESC LIMIT 1) as longest_circuit,
    (SELECT MAX(length_km) FROM f1_circuits) as longest_length_km,
    (SELECT COUNT(*) FROM f1_circuits WHERE status = 'Active') as active_circuits,
    (SELECT country FROM f1_circuits GROUP BY country ORDER BY COUNT(*) DESC LIMIT 1) as country_with_most_circuits;

-- List all created views
SELECT 
    table_name as view_name,
    'View for F1 ' || table_name as description
FROM information_schema.views
WHERE table_schema = 'public' 
    AND table_name LIKE '%circuit%'
ORDER BY table_name;


-- Verify f1_circuits table exists and count circuits
SELECT COUNT(*) as total_circuits FROM f1_circuits;


-- View sample data
SELECT 
    circuit_name,
    country,
    length_km,
    status
FROM f1_circuits
LIMIT 5;




