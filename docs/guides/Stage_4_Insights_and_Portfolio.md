# Stage 4: Insights, portfolio write-up and publishing checklist

## How these numbers were produced
All figures below were computed directly from the workbook in Python, not from Power BI. Because the workbook has **no exchange rates**, money figures use **NZD orders only (3,026 of 7,991 orders, 37.9%)**. Order counts, quantities and lead times use all orders. Once you supply documented rates, re-check the revenue insights in the finished report; the shape of the findings may change.

## Insights

| # | Finding | Evidence |
|---|---|---|
| 1 | **Sales are flat, not falling.** 2019 looks lower only because the data ends on 12 Dec. | NZD revenue: 2017 19.96M, 2018 19.99M. Matched 1 Jan to 12 Dec: 2019 18.21M vs 2018 18.55M (-1.85%). Orders to 12 Dec (all currencies): 2,560 / 2,574 / 2,540. |
| 2 | **Wholesale drives the business, but margins are the same everywhere.** | NZD revenue share: Wholesale 54.1%, Distributor 32.1%, Export 13.8%. Margin: 37.1%, 37.7%, 37.4%. |
| 3 | **A handful of products carry the revenue.** | Top 5 products (7, 1, 2, 11, 5) = 73.2% of NZD revenue. Bottom 5 (8, 4, 3, 14, 6) = 9.5%. |
| 4 | **Margin differs more by product than by channel.** | Product 4 has the highest margin (41.5%); Product 8 the lowest (33.6%). Both are in the bottom 5 by revenue. |
| 5 | **Customer concentration risk is low.** | Top 5 customers = 12.7% of NZD revenue, top 10 = 24.1%. It takes 38 of 50 customers to reach 80%. Largest customer (Medline) = 3.3%. |
| 6 | **Revenue is spread across many locations.** | 45 cities. Top four (Hamilton, Christchurch, Waitakere, Manukau) = 29.3% of NZD revenue. |
| 7 | **Almost half of all orders ship in more than 10 days, with no obvious bottleneck.** | 3,940 of 7,991 orders (49.3%). Lead times spread almost evenly from 3 to 18 days (mean 10.4). Late rate by warehouse: 46.0% (FLR025) to 50.4% (AXW291); by channel: 47.9% (Distributor) to 51.7% (Export). |

## Recommendations (hypotheses to test, not conclusions)
1. Report 2019 against a matched cutoff, never as a full year. Re-run once full-year data exists.
2. Find out why Product 4 earns the best margin on small volume, and why Product 8 earns the least. Check price and cost before changing the mix.
3. Because margin is nearly identical across channels, channel strategy can focus on volume. Test whether Export's higher late rate is a transport issue.
4. Warehouse AXW291 handles 47% of all orders and has the highest late rate (50.4%). Check capacity there, but note the gap to other warehouses is only a few points.
5. The lead-time spread is unusually uniform. Confirm the 10-day threshold with the business (it is an analytical assumption, not an SLA) and ask whether this is a sample dataset.
6. Obtain documented exchange rates and confirm unit costs share each order's currency before presenting any all-currency profit figure.

## Portfolio text

**Project title:** Campfly | Sales & Operations Intelligence

**One-line summary:** A Power BI project that turns a five-currency, 7,991-order sales workbook into a star-schema model, 47 documented DAX measures and a six-page report blueprint, with safeguards against mixed-currency totals and partial-year comparisons.

**Resume bullets** (edit the wording once the report is built and tested in Desktop):
- Designed a star-schema Power BI model (1 fact table, 7 dimensions) from a 7,991-order sales workbook, with Power Query cleaning for text, dates, postcodes and keys.
- Wrote 47 commented DAX measures, including currency-safe revenue that returns blank instead of a misleading total when exchange rates are missing, and a matched-cutoff year-over-year measure for a partial final year.
- Specified a six-page report with a custom theme, exact layouts, bookmarks, tooltips and drill-through, and published the project documentation on GitHub Pages.

## Publishing checklist

**GitHub (static project page)**
- [x] Repo created and pushed

- [ ] Settings > Pages > Deploy from a branch > `main` / `/docs`
- [ ] Open the Pages URL and check images load
- [ ] Add the Pages URL to the repo's About box

**Power BI report**
- [ ] Build the report from the guides and save `Campfly.pbix`
- [ ] Enter documented exchange rates in `DimCurrency` (or leave blank and keep NZD-only default)
- [ ] Check every number against `docs/reference/QA_Expected_Results.csv`
- [ ] Replace wireframes with real screenshots in `docs/assets/` and the README
- [ ] Add the `.pbix` to the repo (Git LFS if over 50 MB) or link to it

**Power BI Service (optional)**
- [ ] Publish to a workspace; set the data source path or move the workbook to OneDrive/SharePoint for scheduled refresh
- [ ] Check the Azure Maps visual is allowed by your tenant
- [ ] "Publish to web" makes the report public: only use it for data you may share
