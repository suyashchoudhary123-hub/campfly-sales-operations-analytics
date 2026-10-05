# Campfly | Sales & Operations Intelligence

A Power BI project built on a 7,991-order sales workbook (New Zealand, Jan 2017 to 12 Dec 2019): star-schema data model, 47 documented DAX measures, a six-page report blueprint and a custom theme.

**Live project page:** `https://suyashchoudhary123-hub.github.io/campfly-sales-operations-analytics/` (enable GitHub Pages, see [Deploy](#deploy-to-github-pages))

> **Status: build package.** The Power Query, DAX, theme and layout specs are complete, but the `.pbix` has not yet been built or tested in Power BI Desktop, and the images in `docs/assets/` (other than the model diagram) are **design wireframes, not screenshots**. After you build the report, add real screenshots and a `.pbix` (see [Next steps](#next-steps)).

## Data

| Sheet | Rows | Role |
|---|---|---|
| Sales Orders | 7,991 | Fact: one record per order |
| Customers | 50 | Dimension |
| Regions | 100 | Dimension (suburb, city, postcode, latitude, longitude) |
| Products | 15 | Dimension (14 appear in sales) |

Order dates run 2017-01-01 to **2019-12-12**, so **2019 is a partial year**. Revenue is recorded in five currencies (NZD 3,026 orders, USD 2,323, AUD 1,309, GBP 669, EUR 664) and the workbook contains **no exchange rates**.

## Repository layout

```
data/            Source workbook
powerquery/      M queries: pFilePath, SourceWorkbook, FactSales, Dim* tables
model/           DimDate (DAX calendar) and relationships.csv
dax/
  Create_Measures_Table.dax
  measures/      47 measures, one file each (numbered build order)
  report-support/ ranking, Pareto, region label and ship-date helpers
theme/           Campfly_Theme.json (Power BI report theme)
docs/
  index.html     GitHub Pages landing page
  guides/        Stage 1 (model), Stage 2 (DAX), Stage 3 (visuals), Stage 4 (insights, portfolio, checklist)
  reference/     Measure catalog, QA benchmarks, per-visual layout spec
  assets/        Model diagram and page wireframes
```

## Build the report in Power BI Desktop

1. Put the workbook somewhere local and edit the path in `powerquery/pFilePath.pq`.
2. Follow `docs/guides/Stage_1_Build_Guide.md`: create the parameter and queries (paste each `.pq`), load, create `DimDate` from `model/DimDate.dax`, and set the relationships in `model/relationships.csv` (the Ship Date relationship is inactive).
3. Follow `docs/guides/Stage_2_DAX_Build_Guide.md`: create `_Measures`, then paste each file in `dax/measures/` in numeric order. Formats and display folders are in `docs/reference/Measure_Catalog.csv`.
4. Follow `docs/guides/Stage_3_Visuals_Build_Guide.md`: import `theme/Campfly_Theme.json`, add the helpers from `dax/report-support/`, then build each page from `docs/reference/Visual_Field_and_Layout_Spec.csv`.
5. Check your numbers against `docs/reference/QA_Expected_Results.csv`.

## Currency policy (read before trusting any revenue number)

- `DimCurrency[Rate to NZD]` is NZ dollars per one unit of source currency. NZD = 1. USD, AUD, GBP and EUR are **deliberately blank**.
- Until you enter documented rates, NZD revenue, cost and profit are blank for any selection containing a non-NZD order. This is intended: the measures never silently drop rows or add currencies together.
- Fixed rates over 2017 to 2019 are a scenario assumption, not historical FX accounting. Record the source and date of whatever rates you use.
- Profit conversion assumes each row's unit cost is in that row's currency. The workbook does not confirm this.

## Key findings

From the workbook (money figures are NZD orders only, 37.9% of orders, because no exchange rates were supplied):

- Sales are flat: 2019 to 12 Dec is 1.85% below the same period of 2018, not a full-year decline.
- Wholesale is 54.1% of NZD revenue; margin is about 37% in every channel.
- The top 5 of 14 selling products make 73.2% of NZD revenue.
- Customer concentration is low: the top 5 customers make 12.7%, and 38 of 50 are needed to reach 80%.
- 49.3% of all orders ship in more than 10 days, spread evenly across warehouses and channels.

Full table, recommendations, resume bullets and the publishing checklist: `docs/guides/Stage_4_Insights_and_Portfolio.md`.

## Verified benchmarks (computed from the workbook)

| Selection | Measure | Expected |
|---|---|---|
| All | Total Orders | 7,991 |
| All | Total Quantity | 67,579 |
| All | Average Lead Time | 10.44 days |
| All | Orders shipped late (> 10 days) | 3,940 (49.3%) |
| NZD only | Revenue / Cost / Profit | 58,149,949.90 / 36,445,236.12 / 21,704,713.78 |
| NZD only | Profit margin | 37.3% |
| NZD only, 2019 vs 2018 to 12 Dec | Comparable revenue change | -1.85% |

"Late" is an analytical threshold, not a documented SLA. These were computed in Python; the DAX still needs to be checked against them in Desktop.

## Deploy to GitHub Pages

GitHub cannot render a `.pbix`, so the repo publishes a static project page from `docs/`.

```bash
cd campfly-sales-operations-analytics
git init
git add .
git commit -m "Add Campfly Power BI project"
git branch -M main
git remote add origin https://github.com/suyashchoudhary123-hub/campfly-sales-operations-analytics.git
git push -u origin main
```

Then on GitHub: **Settings > Pages > Build and deployment > Deploy from a branch > `main` / `/docs` > Save**. The site appears at `https://suyashchoudhary123-hub.github.io/campfly-sales-operations-analytics/` after a minute or two.

## Next steps

1. Build the report in Desktop and save `Campfly.pbix` (use Git LFS if it exceeds 50 MB, or keep it out of the repo and link it).
2. Capture real screenshots into `docs/assets/` and add them to this README and `docs/index.html`.
3. Optional: publish to the Power BI Service and add a "Publish to web" link. That makes the data public, so check you are allowed to share it.
4. Re-check the insights in `docs/guides/Stage_4_Insights_and_Portfolio.md` once exchange rates are decided.

## License

MIT. See `LICENSE`.
