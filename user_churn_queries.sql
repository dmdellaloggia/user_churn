--Inspect the data

  SELECT * FROM subscriptions LIMIT 100;

  SELECT DISTINCT segment FROM subscriptions;

  SELECT MIN(subscription_start),
    MAX(subscription_start)
  FROM subscriptions;

--Calculate churn rate for each segment

--create 'months' table
  WITH months AS (
    SELECT
      '2017-01-01' AS first_day,
      '2017-01-31' AS last_day
    UNION
    SELECT
      '2017-02-01' AS first_day,
      '2017-02-28' AS last_day
    UNION
    SELECT
      '2017-03-01' AS first_day,
      '2017-03-31' AS last_day),
  SELECT * FROM months;

--join subscriptions and months tables
  cross_join AS (
    SELECT *
    FROM subscriptions
    CROSS JOIN months),
  SELECT * FROM cross_join LIMIT 5;

--create 'status' table from 'cross_join' that identified active and canceled users from each segment
  status AS (
    SELECT id,
      first_day AS 'month',
      segment,
    CASE
      WHEN (subscription_start < first_day)
       AND (subscription_end > first_day OR subscription_end IS NULL) THEN 1
      ELSE 0
    END AS 'is_active',
    CASE
      WHEN (subscription_end BETWEEN first_day AND last_day) THEN 1
      ELSE 0
    END AS 'is_canceled'
    FROM cross_join),
  SELECT * FROM mod_status LIMIT 5;

--create 'status_aggregate' temporary table that sums active and canceled subscriptions by segment
  status_aggregate AS (
    SELECT month,
      segment,
      SUM(is_active) AS 'sum_active',
      SUM(is_canceled) AS 'sum_canceled'
    FROM status
    GROUP BY month, segment)
  SELECT * FROM mod_status_aggregate;

--calculate churn rate for the two segments over the 3 month period
  SELECT month,
    segment,
    ROUND(1.0 * sum_canceled / sum_active, 2) AS 'churn_rate'
  FROM status_aggregate;
