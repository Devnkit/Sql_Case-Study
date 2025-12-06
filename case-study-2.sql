CREATE DATABASE ASBL_assignment;
USE ASBL_assignment;

-- 1.Conversion Rate per Source --
     SELECT COUNT(*) AS leads_count FROM q1_leads;
SELECT COUNT(*) AS txns_count FROM q1_transactions;
SELECT * FROM q1_leads LIMIT 5;
SELECT * FROM q1_transactions LIMIT 5;
CREATE INDEX idx_leads_source ON q1_leads(source);
CREATE INDEX idx_txn_lead ON q1_transactions(lead_id);
WITH total_leads AS (
  SELECT source,
         COUNT(*) AS total_leads
  FROM q1_leads
  GROUP BY source
),
converted AS (
  SELECT l.source,
         COUNT(DISTINCT t.lead_id) AS converted_leads
  FROM q1_leads l
  LEFT JOIN q1_transactions t
    ON l.lead_id = t.lead_id
  GROUP BY l.source
),
conversion AS (
  SELECT
    tl.source,
    tl.total_leads,
    IFNULL(c.converted_leads,0) AS converted_leads,
    (IFNULL(c.converted_leads,0) * 100.0 / tl.total_leads) AS conversion_rate
  FROM total_leads tl
  LEFT JOIN converted c USING (source)
),
overall_avg AS (
  SELECT AVG(conversion_rate) AS avg_conversion_rate
  FROM conversion
)
SELECT c.source,
       ROUND(c.conversion_rate,2) AS conversion_rate
FROM conversion c
CROSS JOIN overall_avg oa
WHERE c.conversion_rate > oa.avg_conversion_rate
ORDER BY c.conversion_rate DESC;

SELECT
    l.source,
    ROUND((COUNT(DISTINCT t.lead_id) * 100.0 / COUNT(*)), 2) AS conversion_rate
FROM q1_leads l
LEFT JOIN q1_transactions t
    ON l.lead_id = t.lead_id
GROUP BY l.source
HAVING conversion_rate >
(
    SELECT AVG(conv_rate)
    FROM (
        SELECT
            COUNT(DISTINCT t2.lead_id) * 100.0 / COUNT(*) AS conv_rate
        FROM q1_leads l2
        LEFT JOIN q1_transactions t2
            ON l2.lead_id = t2.lead_id
        GROUP BY l2.source
    ) AS temp
)
ORDER BY conversion_rate DESC;

-- 2.Top Consistent Feedback Givers --
SELECT
    customer_id,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(*) AS feedback_count
FROM q2_customer_feedback
WHERE review_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY customer_id
HAVING COUNT(*) >= 5         
ORDER BY avg_rating DESC      
LIMIT 3;                      

-- 3. Sales Contribution by Salesperson --
SELECT
    s.salesperson,
    s.region,
    ROUND( SUM(s.revenue) * 100.0 / rt.total_region_revenue , 2 ) AS contribution_percent
FROM Q3_sales s
JOIN (
        SELECT
            region,
            SUM(revenue) AS total_region_revenue
        FROM Q3_sales
        WHERE month = (SELECT MAX(month) FROM Q3_sales)
        GROUP BY region
     ) rt
     ON s.region = rt.region
WHERE s.month = (SELECT MAX(month) FROM Q3_sales)
GROUP BY s.region, s.salesperson
ORDER BY s.region, contribution_percent DESC;

-- 4.High-Performing Campaigns by Channel --
SELECT
    c.campaign_id,
    c.channel,
    ROUND(c.campaign_avg_sale, 2) AS campaign_avg_sale
FROM
    (
        SELECT
            l.campaign_id,
            cmp.channel,
            AVG(s.sale_amount) AS campaign_avg_sale
        FROM q4_leads l
        JOIN q4_sales s ON l.lead_id = s.lead_id
        JOIN q4_campaigns cmp ON l.campaign_id = cmp.campaign_id
        GROUP BY l.campaign_id, cmp.channel
    ) AS c
JOIN
    (
        SELECT
            channel,
            AVG(campaign_avg_sale) AS channel_avg_sale
        FROM
            (
                SELECT
                    l.campaign_id,
                    cmp.channel,
                    AVG(s.sale_amount) AS campaign_avg_sale
                FROM q4_leads l
                JOIN q4_sales s ON l.lead_id = s.lead_id
                JOIN q4_campaigns cmp ON l.campaign_id = cmp.campaign_id
                GROUP BY l.campaign_id, cmp.channel
            ) AS x
        GROUP BY channel
    ) AS ch
ON c.channel = ch.channel
WHERE c.campaign_avg_sale > ch.channel_avg_sale
ORDER BY c.channel, c.campaign_avg_sale DESC;



-- 5.Data Integrity --
SELECT * 
FROM q4_sales s
JOIN q1_leads l USING (lead_id)	
WHERE sale_date < created_date;


