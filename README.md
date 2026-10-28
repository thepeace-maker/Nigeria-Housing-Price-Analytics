
# 🏠 Nigeria Housing Price Analytics

> Where do Nigerian house prices really sit, which locations and features carry the premium, and where does a buyer get the most house for the money?

[Dashboard]<img width="875" height="492" alt="Screenshot 2026-10-28 055125" src="https://github.com/user-attachments/assets/13ac0bcc-bf9c-4fb4-84f2-5f6d3e5c1c17" />

## 🎯 The Problem

Property prices in Nigeria vary enormously by state, town and house type, and a few mansions make the average misleading. A buyer or investor needs to know **which locations and property features carry a real price premium, and where the value is**.

## 🔬 The Analysis

I analysed **24,326 property listings** (bedrooms, bathrooms, toilets, parking, house type, town, state, price in naira) using **SQL Server** for cleaning and analysis and **Power BI** for the dashboard.

**Cleaning decisions (all stated, since they affect the numbers):**
- Kept prices between **₦5M and ₦2B**. This removed 179 rows (0.7%), including a ₦1.8 trillion listing and prices as low as ₦90,000 that look like typos or rents.
- About **43% of rows were exact duplicates**, and Lekki was the worst (10,830 rows but only 3,379 distinct listings). Since there is no listing ID, I flagged the repeats and used the **13,707 distinct listings** for the analysis.
- Fixed a state typo (Anambara to Anambra) and converted the counts to whole numbers.
- Used **medians, not averages**: the average price is ₦156M, double the ₦75M median.
- Only compared states and towns with **30 or more listings**.

**Analysis steps:** median price by state, by Lagos town, price per bedroom, house type, a like-for-like comparison (4-bedroom houses in Lekki), price by bedrooms, and a check on how the duplicates affect the results.

## 💡 Key Insights

1. **Location drives price.** In Lagos, Ikoyi's median is ₦520M against ₦95M in Lekki (5.5x). Victoria Island is ₦175M, and the mainland is far cheaper: Ikorodu is ₦18.5M.
2. **Abuja and Lagos are priced alike** (₦82.5M and ₦82M), while Ogun is only ₦16M. Lagos holds 62% of the listings.
3. **House type matters less than it looks.** Citywide in Lagos, a detached duplex costs ₦132M against ₦25M for a detached bungalow, but duplexes are bigger (4.9 bedrooms on average against 3.4). Comparing 4-bedroom houses in Lekki, the detached-duplex premium is just **15% to 27%**.
4. **Value sits along the same road as Lekki.** Per bedroom, Lekki costs ₦22.5M, Ajah ₦13.3M (41% cheaper) and Ibeju Lekki ₦9.0M (60% cheaper).
5. **Price jumps with bedrooms, then flattens.** In Lagos the median roughly doubles from 3 to 4 bedrooms (₦35M to ₦74.5M) and again from 4 to 5 (₦150M), but a 6-bedroom house costs only about ₦10M more than a 5-bedroom.
6. **The duplicates don't change the story.** Using all rows raises most medians by up to 19% but keeps the ranking broadly the same. The exception is Isheri North (₦85M distinct against ₦135M on all rows), so it is flagged as unreliable.

## ✅ Recommendations

1. **Buyers priced out of Lekki should look at Ajah or Ibeju Lekki**: about half and about a third of Lekki's median price respectively, with plenty of listings (1,188 and 394).
2. **Don't pay the detached premium blindly.** Like-for-like, it is 15% to 27%, so semi-detached or terraced houses in the same area can be better value.
3. **If space matters, compare 5 and 6 bedrooms.** The extra bedroom costs little at the median in Lagos.
4. **Judge prices with medians and a location filter**, not citywide averages, which are inflated by luxury listings.

## ⚠️ Limitations

- These are **asking prices from listings, not sale prices**, and the data has **no dates, listing IDs or floor areas**.
- Repeated rows may be the same property advertised several times, or genuinely similar houses. I cannot prove which.
- The ₦5M to ₦2B price limits are a judgment call.
- Lagos is 62% of the data. Only 10 of 25 states have enough listings to compare.
- Price per bedroom is a rough value measure, because bigger houses sit in expensive towns.
- Isheri North's figure is sensitive to duplicates.

## 📁 Files

| File | Description |
|---|---|
| `NigeriaHousing.pbix` | Power BI dashboard |
| `NigeriaHousing_Queries.sql` | Cleaning views and analysis queries |
| `dashboard-images/housing-dashboard.png` | Dashboard screenshot |

## 🚀 Getting Started

1. Download the dataset: [dataset link on Kaggle] (licence: [licence from the Kaggle page]).
2. Import the CSV into SQL Server as `houses_raw` (Allow Nulls on all columns).
3. Run `NigeriaHousing_Queries.sql` to create the `houses` and `houses_distinct` views.
4. Open `NigeriaHousing.pbix` and point it to your SQL Server database.

## 🛠️ Tools

SQL Server (CTEs, window functions, `PERCENTILE_CONT`), Power BI (DAX, one-page dashboard design)
