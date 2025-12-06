# 📦 Case Study 3: Supplier Performance Metrics

## 🧠 Business Scenario

As a Data Analyst on the Supply Chain Procurement Team, you are tasked with assessing supplier performance to ensure reliable delivery of critical components. Your goal is to identify the most active suppliers, understand which suppliers dominate in specific manufacturing regions, and pinpoint any gaps in supply to the Asia region. By leveraging data, you will help optimize vendor selection strategies and mitigate potential supply chain risks.


---

## 🧾 Table format 

1. supplier_deliveries(supplier_id, delivery_date, component_count, manufacturing_region)
2. suppliers(supplier_id, supplier_name)

---

## ❓ Questions & SQL Solutions

Ques 1: We need to identify potential gaps in our supply chain for Asia. List all suppliers by name who have not delivered any components to the 'Asia' manufacturing region in December 2024.

```sql
SELECT supplier_name
FROM suppliers s
WHERE NOT EXISTS (
    SELECT 1
    FROM supplier_deliveries d
    WHERE d.supplier_id = s.supplier_id
      AND d.manufacturing_region = 'Asia'
      AND d.delivery_date LIKE "2024-12%"
);


```
Ques 2: We need to know who our most active suppliers are. Identify the top 5 suppliers based on the total volume of components delivered in October 2024.
```sql
SELECT b.supplier_name , SUM(a.component_count) as total_components
FROM supplier_deliveries as a
JOIN suppliers as b
ON a.supplier_id = b.supplier_id
WHERE a.delivery_date LIKE "2024-10%"
GROUP BY a.supplier_id
ORDER BY total_components DESC 
LIMIT 5 ;
```

Ques 3: For each region, find the supplier ID that delivered the highest number of components in November 2024. This will help us understand which supplier is handling the most volume per market.


```sql
SELECT manufacturing_region, supplier_id, total_components
FROM (
    SELECT 
        manufacturing_region,
        supplier_id,
        SUM(component_count) AS total_components,
        RANK() OVER (PARTITION BY manufacturing_region ORDER BY SUM(component_count) DESC) AS region_rank
    FROM supplier_deliveries
    WHERE delivery_date LIKE "2024-11%"
    GROUP BY manufacturing_region, supplier_id
) ranked_deliveries
WHERE region_rank = 1;

```