# 📦 Case Study 1: Spark Augmented Reality (AR) Filter Engagement Metrics

## 🧠 Business Scenario

As a member of the Marketing Analytics team at Meta, you are tasked with evaluating the performance of branded AR filters. Your goal is to identify which filters are driving the highest user interactions and shares to inform future campaign strategies for brands using the Spark AR platform. By analyzing engagement data, your team aims to provide actionable insights that will enhance campaign effectiveness and audience targeting.

---

## 🧾 Table format 

1. ar_filter_engagements(engagement_id, filter_id, interaction_count, engagement_date)
2. ar_filters(filter_id, filter_name)

---

## ❓ Questions & SQL Solutions

Ques 1: Which AR filters have generated user interactions in July 2024? List the filters by name.

```sql
SELECT DISTINCT b.filter_name
FROM ar_filter_engagements as a
JOIN ar_filters as b
ON a.filter_id = b.filter_id
WHERE a.interaction_count > 0 AND a.engagement_date LIKE "2024-07%"

```
Ques 2: How many total interactions did each AR filter receive in August 2024? Return only filter names that received over 1000 interactions, and their respective interaction counts.
```sql
SELECT b.filter_name , SUM(a.interaction_count) as total_count
FROM ar_filter_engagements as a
JOIN ar_filters as b
ON a.filter_id = b.filter_id
WHERE a.engagement_date LIKE "2024-08%" 
GROUP BY a.filter_id 
HAVING total_count > 1000; 
```

Ques 3: What are the top 3 AR filters with the highest number of interactions in September 2024, and how many interactions did each receive?

```sql
 SELECT b.filter_name, SUM(a.interaction_count) as count_of_interactions
FROM ar_filter_engagements as a
JOIN ar_filters as b
ON a.filter_id = b.filter_id
WHERE a.engagement_date LIKE "2024-09%"
GROUP BY a.filter_id 
ORDER BY count_of_interactions DESC
LIMIT 3;

```