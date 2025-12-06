# 📦 Case Study: Marketing & Sales Performance Analytics

## 🧠 Business Scenario

As a Data Analyst for a retail ecosystem, you are tasked with auditing the entire lifecycle of the business—from Lead Acquisition to Post-Sale Feedback. The key stakeholders (Marketing Managers, Sales Directors, and Data Engineers) require actionable insights to:

1.  **Optimize Marketing Spend:** By identifying which lead sources have conversion rates higher than the global average.
2.  **Reward Loyalty:** By finding customers who consistently provide high-value feedback.
3.  **Evaluate Sales Performance:** By calculating individual salesperson contribution to regional revenue.
4.  **Audit Data Integrity:** By detecting logical errors in the recording of sales and lead timestamps.

-----

## 📋 Problem 1: High-Performing Lead Sources

**The Ask:** The Marketing Director wants to know which acquisition sources (e.g., Organic, Social, Email) are converting leads into customers at a rate *higher* than the overall company average.

**Table Format**

1.  `q1_leads` (lead\_id, source, created\_date)
2.  `q1_transactions` (transaction\_id, lead\_id, transaction\_date, amount)

**💡 Solution**

```sql
/* Logic: 
   1. Calculate the conversion rate for each source.
   2. Calculate the global average conversion rate.
   3. Filter for sources where Source Rate > Global Average.
*/

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
```

-----

## 📋 Problem 2: Identify Consistent "Super-Users"

**The Ask:** The Customer Success team wants to identify "Super Users" for a reward program. These are users who have submitted at least 5 reviews in the last 6 months and maintain a high average rating.

**Table Format**

1.  `q2_customer_feedback` (customer\_id, rating, review\_date)

**💡 Solution**

```sql
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
```

-----

## 📋 Problem 3: Regional Sales Contribution

**The Ask:** The Sales VP needs to see the contribution percentage of each salesperson to their specific region's total revenue for the latest month.

**Table Format**

1.  `Q3_sales` (salesperson, region, revenue, month)

**💡 Solution**

```sql
SELECT
    s.salesperson,
    s.region,
    ROUND( SUM(s.revenue) * 100.0 / rt.total_region_revenue , 2 ) AS contribution_percent
FROM Q3_sales s
JOIN (
        -- Subquery to get total revenue per region for the latest month
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
```

-----

## 📋 Problem 4: Campaign vs. Channel Benchmark

**The Ask:** Identify specific campaigns that are outperforming the average sales metrics of their parent channel. This helps identify "Star Campaigns" within "Average Channels."

**Table Format**

1.  `q4_leads` (lead\_id, campaign\_id)
2.  `q4_sales` (lead\_id, sale\_amount)
3.  `q4_campaigns` (campaign\_id, channel)

**💡 Solution**

```sql
SELECT
    c.campaign_id,
    c.channel,
    ROUND(c.campaign_avg_sale, 2) AS campaign_avg_sale
FROM
    (
        -- Calculate Average Sales per Campaign
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
        -- Calculate Average Sales per Channel (Benchmark)
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
```

-----

## 📋 Problem 5: Data Integrity Audit

**The Ask:** A Data Engineering check. We need to find impossible records where a sale appears to have occurred *before* the lead was even created.

**Table Format**

1.  `q4_sales` (lead\_id, sale\_date)
2.  `q1_leads` (lead\_id, created\_date)

**💡 Solution**

```sql
SELECT * FROM q4_sales s
JOIN q1_leads l USING (lead_id) 
WHERE s.sale_date < l.created_date;
```
