# 📦 Case Study 4: User Playlist Retention and Discovery Rates

## 🧠 Business Scenario

You are a Data Scientist on the Apple Music Personalization Team, tasked with evaluating the effectiveness of recommendation algorithms in engaging users with new music. Your goal is to analyze user playlist interactions to determine how many users add recommended tracks to their playlists, the average number of recommended tracks added per user, and identify users who add non-recommended tracks. This analysis will help your team decide if the recommendation engine needs refinement to enhance user engagement and retention.

---

## 🧾 Table format 

1. tracks_added(interaction_id, user_id, track_id, added_date, is_recommended)
2. users(user_id, user_name)

---

## ❓ Questions & SQL Solutions

Ques 1: How many unique users have added at least one recommended track to their playlists in October 2024?

```sql
SELECT COUNT(DISTINCT user_id) as total_users
FROM tracks_added 
WHERE is_recommended = 1 AND added_date LIKE "2024-10%" ;


```
Ques 2: Among the users who added recommended tracks in October 2024, what is the average number of recommended tracks added to their playlists? Please round this to 1 decimal place for better readability.

```sql
 SELECT ROUND(AVG(sub.total_tracks) , 1) as average
FROM (
   SELECT user_id , COUNT(track_id) as total_tracks
  FROM tracks_added 
  WHERE is_recommended = 1 AND added_date LIKE "2024-10%" 
  GROUP BY user_id
) as sub ;
```

Ques 3: Can you give us the name(s) of users who added a non-recommended track to their playlist on October 2nd, 2024?

```sql
 SELECT DISTINCT b.user_name 
FROM tracks_added as a 
JOIN users as b
ON a.user_id = b.user_id
WHERE is_recommended = 0 AND added_date = "2024-10-02" ;

```