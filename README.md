# Netflix-Content-Strategy-Analysis-SQL-
📌 Project Overview  This project performs an Exploratory Data Analysis (EDA) on a Netflix titles dataset using SQL, with the goal of uncovering content strategy insights rather than just answering technical questions.

The analysis focuses on how Netflix structures, acquires, and experiments with content across movies and TV shows, using data-driven reasoning aligned with real business decisions

🎯 Business Questions Answered
1️⃣ Movies vs TV Shows Over Time
How has Netflix’s content mix evolved over time?

2️⃣ Content Age Analysis (Release Year vs Date Added)
How “fresh” is Netflix’s catalog?
What is the average and median content age?
How is content distributed across age buckets?
Buckets used:
0–1 years (New Releases)
2–5 years
6–10 years
10+ years (Catalog)
Why it matters:
Indicates whether Netflix prioritizes fresh content or leverages long-tail licensing.

3️⃣ Ratings Distribution by Type
What ratings dominate Netflix’s catalog?
Are TV shows more mature than movies?
Why it matters:
Confirms Netflix’s target demographics and adult-content positioning.

4️⃣ Director Productivity & Specialization
Do directors work exclusively on movies, TV shows, or both?
Are high-volume directors more likely to specialize?
Categories analyzed:
Movie-only directors
TV-only directors
Directors working in both formats
Why it matters:
Reveals partnership patterns and long-term creative collaboration strategies.

5️⃣ Cast Size & Production Scale
How many cast members are involved per title?
Do TV shows generally have larger casts?
Why it matters:
Cast size acts as a proxy for production scale and investment.

6️⃣ Movie Duration Distribution
What is the typical Netflix movie length?
Does Netflix avoid very long movies?
Duration buckets:
≤ 90 minutes
91–120 minutes
121+ minutes
Why it matters:
Indicates pacing preferences and audience consumption behavior.

7️⃣ TV Show Season Analysis
How many seasons do Netflix shows typically have?
How prevalent are single-season shows?
Buckets used:
1 season
2–3 seasons
4+ seasons
Why it matters:
Highlights Netflix’s experimentation and cancellation model.

8️⃣ Description Keyword & Theme Analysis
What recurring themes appear in content descriptions?
How do themes differ by type and rating?
Why it matters:
Helps understand genre positioning and adult vs family-oriented language.

9️⃣ Missing Data Analysis
What percentage of metadata is missing per column?
Which fields suffer most from incomplete data?
Focus columns:
Director
Cast
Country
Why it matters:
Demonstrates analytical maturity and transparency about data limitations.

🛠 Tech Stack
SQL (PostgreSQL)
CTEs
Window Functions
Percentiles
Text processing (string split)
Exploratory Data Analysis
Business-focused analytical storytelling

📂 Dataset
Netflix titles dataset
Time range: 2008 – 2021

Includes movies and TV shows with metadata such as:
Show id
Type
Title
Director
Cast
Country
Date Added
Release Year
Rating
Duration
Listed In (Genres)
Description

📈 Key Takeaways
- For the time span of 2008 - 2021 6,126 Movie were added to netflix and 2,664 TV Show
- Movies consistently dominate Netflix’s catalog across all years in the dataset, representing the largest share of total titles added annually.
- TV shows begin to show a noticeable acceleration in 2020–2021, indicating a recent strategic shift rather than a full crossover point.
  The late surge in TV shows 
- Movies show a balanced catalog strategy, with nearly half of titles being new releases and a meaningful share coming from older licensed content.
- TV shows, however, are heavily skewed toward new releases, indicating a freshness-first and originality-driven approach rather than long-term catalog accumulation.
- Adult-rated content (TV-MA, TV-14) dominates, especially for TV shows.
- High specialization exists among directors, with TV show directors often forming longer partnerships.
- A large share of TV shows have only one season, reinforcing Netflix’s experimentation-first strategy.

  
👤 Author
Hady Ayman
Aspiring Data Analyst
Focused on SQL, data storytelling, and business insights

📫 Let’s connect on LinkedIn! www.linkedin.com/in/hady-ayman-8a0a091bb

