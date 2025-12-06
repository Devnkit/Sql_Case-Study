# 📦 Case Study 6: Subscriber Growth in Emerging Markets

## 🧠 Business Scenario

Your final query for question 3 shows a solid understanding of how to aggregate data separately and then join, which is key to accurate analysis. This analysis will help Netflix understand the average marketing spend per new subscriber in each emerging market during Q1 2024, providing valuable insights to optimize marketing budgets and improve campaign efficiency.

---

## 🧾 Table format 

1. fact_marketing_spend(spend_id, country_id, campaign_date, amount_spent)
2. fact_daily_subscriptions(subscription_id, country_id, signup_date, num_new_subscribers)
3. dimension_country(country_id, country_name)

---

## ❓ Questions & SQL Solutions

Ques 1: Retrieve the total marketing spend in each country for Q1 2024 to help inform budget distribution across regions.

```sql
SELECT b.country_name , SUM(a.amount_spent) as total_marketing_spend
FROM fact_marketing_spend as a 
JOIN dimension_country as b
ON a.country_id = b.country_id
WHERE a.campaign_date >= "2024-01-01" AND a.campaign_date <= "2024-03-31"
GROUP BY a.country_id ;


```
Ques 2: List the number of new subscribers acquired in each country (with name) during January 2024, renaming the subscriber count column to 'new_subscribers' for clearer reporting purposes.

```sql
SELECT c.country_name , SUM(s.num_new_subscribers) as new_subscribers
FROM fact_daily_subscriptions as s
JOIN dimension_country as c
ON s.country_id = c.country_id
WHERE signup_date LIKE "2024-01%"
GROUP BY s.country_id ;
```

Ques 3: Determine the average marketing spend per new subscriber for each country in Q1 2024 by rounding up to the nearest whole number to evaluate campaign efficiency.

```sql
SELECT 
    d.country_name,
    CEIL(ms.total_marketing_spend * 1.0 / subs.total_subscribers) AS average
FROM (
    SELECT 
        country_id,
        SUM(amount_spent) AS total_marketing_spend
    FROM fact_marketing_spend
    WHERE campaign_date BETWEEN '2024-01-01' AND '2024-03-31'
    GROUP BY country_id
) AS ms
JOIN (
    SELECT 
        country_id,
        SUM(num_new_subscribers) AS total_subscribers
    FROM fact_daily_subscriptions
    WHERE signup_date BETWEEN '2024-01-01' AND '2024-03-31'
    GROUP BY country_id
) AS subs
ON ms.country_id = subs.country_id
JOIN dimension_country d
ON d.country_id = ms.country_id;


```