select * from `workspace`.`default`.`user_pfofiles` limit 100;

-----------------------------------------------------------------------------------------------------------------------------------------------
--Combining the 2 tables  (Our big data)
SELECT 
    u.*,
    v.*
FROM `workspace`.`default`.`user_pfofiles` AS U
FULL OUTER JOIN `workspace`.`default`.`viewership` AS V
    ON U.UserID = V.UserID;

-----------------------------------------------------------------------------------------------------
--Combining the 2 tables  (LEFT JOIN)
SELECT 
    u.*,
    v.*
FROM `workspace`.`default`.`user_pfofiles` AS U
LEFT JOIN `workspace`.`default`.`viewership` AS V
ON U.UserID = V.UserID;

-----------------------------------------------------------------------------------------------------
--Combining the 2 tables  (RIGHT JOIN)
SELECT 
    u.*,
    v.*
FROM `workspace`.`default`.`user_pfofiles` AS U
RIGHT JOIN `workspace`.`default`.`viewership` AS V
ON U.UserID = V.UserID;

-----------------------------------------------------------------------------------------------------

---Converting UTC time to SA time
SELECT 
    *,
    from_utc_timestamp(TO_TIMESTAMP(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg') AS sast_timestamp
FROM `workspace`.`default`.`viewership`;


-----------------------------------------------------------------------------------------------------------------------------------------------

--- A. USER + USAGE TRENDS (JOINED)
---Query 1. Finding Usage by Age Group to show Who drives consumption
SELECT 
    CASE 
        WHEN u.Age < 18 THEN 'Under 18'
        WHEN u.Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN u.Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN u.Age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END AS Age_group,
    COUNT(*) AS Total_sessions
FROM `workspace`.`default`.`user_pfofiles` U
JOIN `workspace`.`default`.`viewership` V
    ON u.UserID = v.userid
GROUP BY 
    CASE 
        WHEN u.Age < 18 THEN 'Under 18'
        WHEN u.Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN u.Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN u.Age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END
ORDER BY Total_sessions DESC;


-----------------------------------------------------------------------------------------------------------------------------------------------

----Query 2. Usage by Province to show Regional demand

SELECT 
    u.Province,
    COUNT(*) AS total_sessions
FROM `workspace`.`default`.`user_pfofiles` u
JOIN `workspace`.`default`.`viewership` v
    ON u.UserID = v.userid
GROUP BY u.Province
ORDER BY total_sessions DESC;


-----------------------------------------------------------------------------------------------------------------------------------------------
---Query 3. Peak Viewing Time (SA Time) to view Peak usage hours
SELECT 
    HOUR(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) AS Hour_SA,
    COUNT(*) AS Total_sessions
FROM `workspace`.`default`.`viewership` v
JOIN `workspace`.`default`.`user_pfofiles` u
    ON u.UserID = v.userid
GROUP BY HOUR(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS)
ORDER BY Hour_SA;


-----------------------------------------------------------------------------------------------------------------------------------------------
---Query 4. Usage by Day of Week to view Weekend vs weekday behavior
SELECT 
    date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS, 'EEEE') AS Day_name,
    COUNT(*) AS Total_sessions
FROM `workspace`.`default`.`viewership` v
JOIN `workspace`.`default`.`user_pfofiles` u
    ON u.UserID = v.userid
GROUP BY Day_name
ORDER BY Total_sessions DESC;


-----------------------------------------------------------------------------------------------------------------------------------------------

--- 2. FACTORS INFLUENCING CONSUMPTION
---Query A. Content Preference by Gender
SELECT 
    u.Gender,
    v.Channel2,
    COUNT(*) AS Total_views
FROM `workspace`.`default`.`user_pfofiles` u
JOIN `workspace`.`default`.`viewership` V
    ON u.UserID = v.userid
GROUP BY u.Gender, v.Channel2
ORDER BY Total_views DESC;


-----------------------------------------------------------------------------------------------------------------------------------------------
---Query B. Average Session Duration
SELECT 
    v.Channel2,
    AVG(
        (HOUR(v.`Duration 2`) * 3600) +
        (MINUTE(v.`Duration 2`) * 60) +
        SECOND(v.`Duration 2`)
    ) AS Avg_seconds
FROM `workspace`.`default`.`viewership` V
JOIN  `workspace`.`default`.`user_pfofiles` u
    ON u.UserID = v.userid
GROUP BY v.Channel2
ORDER BY Avg_seconds DESC;

-----------------------------------------------------------------------------------------------------------------------------------------------
---Query  C. AGE vs CONTENT
SELECT 
    u.Age,
    v.Channel2,
    COUNT(*) AS Total_views
FROM `workspace`.`default`.`user_pfofiles` u
JOIN `workspace`.`default`.`viewership` v
    ON u.UserID = v.userid
GROUP BY u.Age, v.Channel2
ORDER BY Total_views DESC;

-----------------------------------------------------------------------------------------------------------------------------------------------
--- 3. LOW-CONSUMPTION DAYS + CONTENT STRATEGY
---Query  A. Identify Lowest Days
SELECT 
    date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS, 'EEEE') AS Day_name,
    COUNT(*) AS Total_sessions
FROM `workspace`.`default`.`viewership` v
JOIN `workspace`.`default`.`user_pfofiles` u
    ON u.UserID = v.userid
GROUP BY Day_name
ORDER BY Total_sessions ASC;


-----------------------------------------------------------------------------------------------------------------------------------------------
---Query . Best Performing Content
SELECT 
    v.Channel2,
    COUNT(*) AS Total_views
FROM `workspace`.`default`.`viewership` v
JOIN `workspace`.`default`.`user_pfofiles` u
ON u.UserID = v.userid
GROUP BY v.Channel2
ORDER BY Total_views DESC
LIMIT 5;

-----------------------------------------------------------------------------------------------------------------------------------------------
---Query . Weak Content on Low Days (Monday/Tuesday)
SELECT 
    date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS, 'EEEE') AS Day_name,
    v.Channel2,
    COUNT(*) AS Total_views
FROM `workspace`.`default`.`viewership` v
JOIN `workspace`.`default`.`user_pfofiles` u
    ON u.UserID = v.userid
WHERE date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS, 'EEEE') IN ('Monday','Tuesday')
GROUP BY Day_name, v.Channel2
ORDER BY Total_views ASC;


-----------------------------------------------------------------------------------------------------------------------------------------------

---B. User Engagement Levels

SELECT 
    u.UserID,
    COUNT(v.UserID) AS total_sessions
FROM `workspace`.`default`.`user_pfofiles` u
LEFT JOIN `workspace`.`default`.`viewership` v
    ON u.UserID = v.UserID
GROUP BY u.UserID
ORDER BY total_sessions DESC;


-----------------------------------------------------------------------------------------------------------------------------------------------
---Query . Low Engagement Users (Target Group)
SELECT 
    u.UserID,
    COUNT(v.UserID) AS Total_sessions
FROM `workspace`.`default`.`user_pfofiles` u
LEFT JOIN `workspace`.`default`.`viewership` v
    ON u.UserID = v.UserID
GROUP BY u.UserID
HAVING COUNT(v.UserID) < 5;


-----------------------------------------------------------------------------------------------------------------------------------------------
---THE BIG DATA FOR DASHBAORD

SELECT 
    u.UserID,
    u.Age,
    u.Gender,
    u.Race,
    u.Province,
    v.Channel2,
    to_date(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) AS record_date,
    date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS, 'HH:mm:ss') AS record_time,
    HOUR(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) AS Hour_SA,
    date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS, 'EEEE') AS Day_Name,
    CASE
        WHEN hour(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) BETWEEN 6 AND 9 THEN 'Early Morning'
        WHEN hour(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) BETWEEN 10 AND 12 THEN 'Late Morning'
        WHEN hour(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) BETWEEN 13 AND 15 THEN 'Early Afternoon'
        WHEN hour(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) BETWEEN 16 AND 18 THEN 'Late Afternoon'
        WHEN hour(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) BETWEEN 19 AND 22 THEN 'Evening'
        ELSE 'Late Night'
    END AS Time_bucket,
    date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm'), 'MMMM') AS Month_name,
    (
        (HOUR(v.`Duration 2`) * 3600) +
        (MINUTE(v.`Duration 2`) * 60) +
        SECOND(v.`Duration 2`)
    ) AS Duration_Seconds,
    CASE
        WHEN u.Age < 18 THEN 'Under 18'
        WHEN u.Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN u.Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN u.Age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END AS Age_group
FROM `workspace`.`default`.`user_pfofiles` u
JOIN `workspace`.`default`.`viewership` v
    ON u.UserID = v.UserID;
