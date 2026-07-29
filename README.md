# Cyclistic-Bike-Share-Analysis
A data analysis case study identifying behavioral differences between casual riders and annual members to drive membership conversions.

# Cyclistic Bike-Share Data Analytics Case Study: Converting Casual Riders to Annual Members

## Introduction
In this case study, I analyzed 12 months of historical trip data (comprising over 3.9 million cleaned rides) for Cyclistic, a bike-share company in Chicago. The core business objective was to understand how annual members and casual riders use the service differently in order to design a targeted marketing strategy to convert casual users into profitable annual members. Utilizing **SQL** to process, clean, and aggregate the massive dataset, and **Tableau** to design an interactive data visualization dashboard, I identified two distinct user profiles: the "Weekday Commuter" and the "Weekend Cruiser." Based on these insights, I developed data-driven marketing recommendations—including a proposed weekend-focused membership tier—to successfully align Cyclistic's business model with actual casual rider behavior.

## The Business Task
Analyze historical bike trip data to identify how annual members and casual riders use Cyclistic bikes differently, and use these insights to design data-driven marketing strategies aimed at converting casual riders into annual members.

## Data Preparation & Cleaning (SQL)
To ensure high data integrity before analysis, I used SQL to process and clean the raw 12-month dataset. Key cleaning steps included:
* Standardizing data types and consolidating 12 separate monthly tables into one master dataset.
* Removing records with `NULL` values in critical fields (e.g., start/end station names).
* Filtering out invalid trips, specifically those with a `ride_length` of less than 1 minute (false starts) and greater than 24 hours (unreturned or stolen bikes).
* **Final cleaned dataset:** 3,900,705 valid rides ready for analysis.

## Primary Aggregations (Used in Visualizations)
The core narrative of the analysis was driven by aggregating ride volume, average ride length, and day-of-week trends grouped by user type. These highly aggregated outputs (`The high level overview (Member vs Causal).csv` and `weekly_trend_summary.csv`) were exported specifically to power the final Tableau dashboard.

### Secondary Aggregations (Excluded from Final Visualizations)
To ensure the final executive presentation remained highly focused on the "Commuter vs. Cruiser" dynamic, four additional exploratory aggregations were executed in SQL but deliberately omitted from the final visual dashboard to prevent clutter and maintain accessibility:

1. **Monthly Seasonality Trends:** Aggregated total rides by month. (Confirmed a massive drop in winter usage and a peak in July for both user types).

2. **Peak Hours of the Day:** Grouped start times by hour. (Revealed members peak at 8:00 AM and 5:00 PM, confirming commuter behavior, while casual riders peak steadily in the mid-afternoon).

3. **Most Popular Stations:** Counted the most frequented start and end stations. (Showed casual riders heavily favor coastal/park stations like Navy Pier, while members favor transit hubs and university stations).

4. **Rideable Type Preferences:** Grouped by classic vs. electric bikes. (Showed baseline preferences but did not significantly impact the membership conversion strategy).

## Data Visualization
The aggregated SQL data was exported to Tableau to build an interactive dashboard showcasing the volume, duration, and weekly trends of both user groups.

### Tableau Data Type Conversions 
[view the formulated field snippet here] (https://github.com/Alfredbab03/Cyclistic-Bike-Share-Analysis/blob/ba10ade5093d99426aa3c8283dd3f55c249b3778/Tableau%20Calculated%20Field%20Snippet.txt)
During the visualization phase, Tableau defaulted to reading specific duration metrics as Date/Time strings rather than continuous measures. To accurately plot the data on continuous axes and integrate it into tooltips, I engineered several calculated fields. These formulas were used to convert Date/Time formats to continuous decimal minutes, bypass 24-hour limits on string text, and format categorical axes.

📊 [View the interactive Tableau Dashboard here] (https://public.tableau.com/views/Cyclistic_Bike_Share_Analysis_2026_17852897098680/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

## Top 3 Strategic Recommendations
Based on the data visualizations, casual riders use the service for long-duration, weekend leisure rides, whereas members use it for short, mid-week commutes. To convert casuals, Cyclistic must pivot away from commuter-based marketing:

1. **Launch a "Weekend Cruiser" Membership Tier:** Casual riders dominate the weekends (peaking at over 288,000 rides on Saturdays) but avoid weekday commuting. Introducing a Friday–Sunday membership tier bridges the gap between single-ride passes and full annual commuter memberships.
2. **Shift Marketing Copy to Emphasize "Duration Savings":** Casual riders spend nearly twice as much time on the bikes per trip (averaging ~21.8 minutes) compared to annual members (~12.5 minutes). Marketing campaigns should mathematically prove how an annual membership eliminates per-minute surcharges, saving them money on their long weekend rides.
3. **Implement Post-Ride "Upgrade" Notifications (Driven by Volume & Duration):** Combining the high-volume weekend trend with the long-duration habits of casual riders, Cyclistic should trigger targeted in-app conversion prompts. Whenever a casual user completes a trip exceeding 20 minutes on a Saturday or Sunday, the app should instantly notify them of the exact cost savings they would have achieved had they been on an annual membership.

## Measuring Success (KPIs)
To track the effectiveness of these marketing strategies, the data analytics team should monitor the following Key Performance Indicators (KPIs) post-launch:
* **Casual-to-Member Conversion Rate:** Track the overall trip volume ratio month-over-month to see if the current ~65/35 (Member/Casual) split shifts toward a higher percentage of member rides.
* **Average Ride Length of New Members:** Monitor the duration of rides taken by newly converted members. If the duration stays high (~21 minutes), it proves the campaign successfully captured the intended "leisure" audience.
* **Weekend Membership Growth (YoY):** Measure the year-over-year increase in member rides strictly on Saturdays and Sundays to validate the success of the weekend-targeted membership tier.
