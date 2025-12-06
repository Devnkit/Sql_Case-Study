# 📦 Case Study 5: User Engagement with Artist Recommendations

## 🧠 Business Scenario

You are a Data Analyst on the Apple Music Personalization Team. Your team is focused on evaluating the effectiveness of the recommendation algorithm for artist discovery. The goal is to analyze user interactions with recommended artists to enhance the recommendation engine and improve user engagement.

---

## 🧾 Table format 

1. user_streams(stream_id, user_id, artist_id, stream_date)
2. artist_recommendations(recommendation_id, user_id, artist_id, recommendation_date)

---

## ❓ Questions & SQL Solutions

Ques 1: How many unique users have streamed an artist on or after the date it was recommended to them?

```sql
SELECT COUNT(DISTINCT a.user_id) as unique_users
FROM user_streams as a
JOIN artist_recommendations as b
ON a.user_id = b.user_id AND a.artist_id = b.artist_id
WHERE a.stream_date >= b.recommendation_date ;


```
Ques 2: What is the average number of times a recommended artist is streamed by users in May 2024? Similar to the previous question, only include streams on or after the date the artist was recommended to them.

```sql
SELECT AVG(sub.number_of_streams) as average
FROM (
    SELECT COUNT(a.stream_id) as number_of_streams
    FROM user_streams as a
    JOIN artist_recommendations as b
    ON a.user_id = b.user_id AND a.artist_id = b.artist_id
    WHERE a.stream_date >= b.recommendation_date AND a.stream_date LIKE '2024-05%'
    GROUP BY a.user_id , a.artist_id
) as sub;
```

Ques 3: Across users who listened to at least one recommended artist, what is the average number of distinct recommended artists they listened to? As in the previous question, only include streams that occurred on or after the date the artist was recommended to the user.

```sql
SELECT AVG(count_of_artists)
FROM (
  SELECT a.user_id , COUNT(DISTINCT a.artist_id) as count_of_artists
  FROM user_streams as a
  JOIN artist_recommendations as b
  ON a.user_id = b.user_id AND a.artist_id = b.artist_id
  WHERE a.stream_date >= b.recommendation_date 
  GROUP BY a.user_id 
  ) ;

```