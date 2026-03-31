use my_project;
SELECT * FROM spy_close_price_5y;
-- Step 1: Calculate moving averages
WITH moving_averages AS (
    SELECT
        Date,
        Close,
        AVG(Close) OVER (
            ORDER BY Date
            ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
        ) AS MA_50,
        AVG(Close) OVER (
            ORDER BY Date
            ROWS BETWEEN 199 PRECEDING AND CURRENT ROW
        ) AS MA_200
    FROM spy_prices
);
-- Step 2: Create signal when 50-day MA is above 200-day MA
signals AS (
    SELECT
        Date,
        Close,
        MA_50,
        MA_200,
        CASE
            WHEN MA_50 > MA_200 THEN 1
            ELSE 0
        END AS signal
    FROM moving_averages
);

-- Step 3: Compare current signal to previous signal
crossovers AS (
    SELECT
        Date,
        Close,
        MA_50,
        MA_200,
        signal,
        LAG(signal) OVER (ORDER BY Date) AS previous_signal
    FROM signals
)

-- Step 4: Keep only Golden Cross events
SELECT
    Date,
    Close,
    MA_50,
    MA_200
FROM crossovers
WHERE signal = 1
  AND previous_signal = 0
ORDER BY Date;
