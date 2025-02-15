CREATE TABLE continents(
    continent_id INT PRIMARY KEY,
    continent_name VARCHAR(30)
);

CREATE TABLE countries(
    country_id INT PRIMARY KEY,
    continent_id INT REFERENCES continents(continent_id),
    country_name VARCHAR(50),
    population INT,
    land_area INT
);

CREATE TABLE people(
    person_id INT PRIMARY KEY,
    person_name VARCHAR(100)
);

CREATE TABLE citizenships(
    country_id INT REFERENCES countries(country_id),
    person_id INT REFERENCES people(person_id)
);

INSERT INTO continents VALUES
                           (1, 'Africa'),
                           (2, 'Asia'),
                           (3, 'Europe'),
                           (4, 'North America'),
                           (5, 'South America'),
                           (6, 'Australia'),
                           (7, 'Antarctica');

INSERT INTO countries VALUES
    (1, 1, 'Nigeria', 206000000, 923768),
    (2, 1, 'Egypt', 104000000, 1002450),
    (3, 1, 'South Africa', 60000000, 1219090),
    (4, 1, 'Kenya', 53700000, 580367),
    (5, 1, 'Morocco', 37000000, 446550),
    (6, 2, 'China', 1402000000, 9596961),
    (7, 2, 'India', 1380000000, 3287263),
    (8, 2, 'Japan', 126000000, 377975),
    (9, 2, 'South Korea', 52000000, 100210),
    (10, 2, 'Indonesia', 273000000, 1904569),
    (11, 3, 'Germany', 83000000, 357022),
    (12, 3, 'France', 67000000, 551695),
    (13, 3, 'Italy', 60000000, 301340),
    (14, 3, 'Spain', 47000000, 505992),
    (15, 3, 'United Kingdom', 66000000, 243610),
    (16, 4, 'United States', 331000000, 9833517),
    (17, 4, 'Canada', 38000000, 9984670),
    (18, 4, 'Mexico', 128000000, 1964375),
    (19, 4, 'Cuba', 11000000, 109884),
    (20, 4, 'Panama', 4300000, 75417),
    (21, 5, 'Brazil', 212000000, 8515767),
    (22, 5, 'Argentina', 45000000, 2780400),
    (23, 5, 'Chile', 19000000, 756102),
    (24, 5, 'Colombia', 51000000, 1141748),
    (25, 5, 'Peru', 33000000, 1285216),
    (26, 6, 'Australia', 26000000, 7692024),
    (27, 6, 'New Zealand', 5000000, 268021),
    (28, 6, 'Fiji', 900000, 18274),
    (29, 6, 'Papua New Guinea', 9000000, 462840),
    (30, 6, 'Samoa', 200000, 2842),
    (31, 7, 'Antarctica', 1000, 14000000),
    (32, 3, 'Poland', 38000000, 312696),
    (33, 3, 'Netherlands', 17400000, 41850),
    (34, 3, 'Belgium', 11500000, 30528),
    (35, 3, 'Greece', 10700000, 131957),
    (36, 2, 'Thailand', 70000000, 513120),
    (37, 2, 'Vietnam', 97000000, 331212),
    (38, 2, 'Malaysia', 32000000, 330803),
    (39, 2, 'Philippines', 109000000, 300000),
    (40, 2, 'Pakistan', 220000000, 881913),
    (41, 1, 'Ghana', 31000000, 238533),
    (42, 1, 'Uganda', 45000000, 241038),
    (43, 1, 'Sudan', 44000000, 1861484),
    (44, 1, 'Ethiopia', 115000000, 1104300),
    (45, 1, 'Algeria', 43000000, 2381741),
    (46, 5, 'Venezuela', 28000000, 916445),
    (47, 5, 'Paraguay', 7100000, 406752),
    (48, 5, 'Bolivia', 11600000, 1098581),
    (49, 5, 'Ecuador', 17600000, 283561),
    (50, 5, 'Uruguay', 3500000, 176215);

INSERT INTO people
SELECT generate_series(1, 100),'Person_' || (random() * 99 + 1)::INT;

INSERT INTO citizenships
SELECT (random() * 49 + 1)::INT, (random() * 99 + 1)::INT
FROM generate_series(1, 100);

SELECT * FROM continents;
SELECT * FROM countries;
SELECT * FROM people;
SELECT * FROM citizenships;

--Country with the biggest population (id and name of the country)
SELECT * FROM countries
ORDER BY population DESC LIMIT 1;

--Top 10 countries with the lowest population density (names of the countries)
SELECT (population::float4/ land_area::float4) AS "Population density", country_name, population, land_area
FROM countries
ORDER BY "Population density" LIMIT 10;

--Countries with population density higher than average across all countries
SELECT (population::float4/ land_area::float4) AS "Population density", country_name
FROM countries
WHERE (population::float4 / land_area::float4) > (
    SELECT avg(population::float4 / land_area::float4) FROM countries
)
ORDER BY "Population density" DESC;

--Country with the longest name (if several countries have name of the same length, show all of them)
SELECT country_name, length(country_name) AS "Name length"
FROM countries
WHERE length(country_name) = (
    SELECT max(length(country_name)) FROM countries
    );

--All countries with name containing letter “F”, sorted in alphabetical order
SELECT country_name
FROM countries
WHERE country_name ILIKE '%F%'
ORDER BY country_name;

--Country which has a population, closest to the average population of all countries
SELECT country_name, population
FROM countries
WHERE abs(population - (SELECT avg(population) FROM countries)) = (
    SELECT min(abs(population - (SELECT avg(population) FROM countries))) FROM countries
    );

--Count of countries for each continent
SELECT continent_name, count(*) AS "Count of countries"
FROM continents LEFT JOIN countries c on continents.continent_id = c.continent_id
GROUP BY continent_name
ORDER BY "Count of countries" DESC;

--Total area for each continent (print continent name and total area), sorted by area from biggest to smallest
SELECT continent_name, sum(land_area) AS "Continent area"
FROM continents LEFT JOIN countries c on continents.continent_id = c.continent_id
GROUP BY continent_name
ORDER BY "Continent area";

--Average population density per continent
SELECT continent_name, avg(population::float4/ land_area::float4) AS "Continent population density"
FROM continents INNER JOIN countries c on continents.continent_id = c.continent_id
GROUP BY continent_name
ORDER BY "Continent population density";

--For each continent, find a country with the smallest area (print continent name, country name and area)
SELECT DISTINCT ON(continent_name) continent_name, country_name, land_area
FROM continents JOIN countries c on  continents.continent_id = c.continent_id
ORDER BY continent_name, land_area;

--Find all continents, which have average country population less than 20 million
SELECT continent_name, avg(population) AS "Average population"
FROM continents JOIN countries c on  continents.continent_id = c.continent_id
GROUP BY continent_name
HAVING avg(population) < 20000000
ORDER BY "Average population";

--Person with the biggest number of citizenships
SELECT person_name, count(country_id) AS "Citizenships count"
FROM people JOIN citizenships c on people.person_id = c.person_id
GROUP BY person_name
ORDER BY "Citizenships count" DESC LIMIT 1;

--All people who have no citizenship
SELECT *
FROM people LEFT JOIN citizenships c on people.person_id = c.person_id
WHERE country_id IS NULL;

--Country with the least people in People table
SELECT country_name, count(person_id) AS "People count"
FROM countries JOIN citizenships c on countries.country_id = c.country_id
GROUP BY country_name
ORDER BY "People count" LIMIT 1;

--Continent with the most people in People table
SELECT continent_name, count(person_id) AS "People count"
FROM continents
    JOIN countries c on continents.continent_id = c.continent_id
    JOIN citizenships c2 on c.country_id = c2.country_id
GROUP BY continent_name
ORDER BY "People count" DESC LIMIT 1;

--Find pairs of people with the same name - print 2 ids and the name
SELECT p1.person_id AS "Person 1 id", p2.person_id AS "Person 2 id", p1.person_name
FROM people p1 JOIN people p2 ON p1.person_name = p2.person_name
WHERE p1.person_id < p2.person_id