# Campfly | Stage 2 — Measures and validation

## Scope and status
Copy-paste-ready DAX for the Stage 1 schema. Source totals were independently checked in Python; DAX has not been executed in Power BI Desktop. This is not a built PBIX. Stop after this stage and wait for next before designing the six report pages.

## Beginner build steps
1. Finish Stage 1, including the marked DimDate, all single-direction relationships, and inactive Ship Date relationship.
2. Modeling > New table: paste the _Measures definition below. Do not relate this table to anything. Hide Placeholder in report view.
3. Select _Measures > New measure. Paste ONE measure block at a time, in the order below. Do not paste this complete guide into a single formula bar. Each definition before '=' is its measure name.
4. Set each measure's Home table to _Measures if necessary. Use the catalog to set its Display folder and format. Hide helper measures only after completing QA.
5. Money is formatted #,0.00, not a generic '$' symbol: NZD cards must be labeled NZD and original-currency cards must show Original Currency Code. Percentages use 0.0%; counts #,0; lead time 0.0 days.
6. Make a temporary QA page: FX Status card; Missing FX Rows card; table of core measures; Year slicer from DimDate; Currency Code slicer from DimCurrency. Default NZD measures should be blank with all currencies until rates are supplied.
7. Select NZD only and compare results against QA_Expected_Results.csv. Clear Year and all other filters for the base checks; select 2019 only for the three comparable-period checks.
8. Select USD alone: original-currency revenue should display, but NZD revenue should stay blank while USD's rate is missing. Select NZD + USD: original-currency revenue should be blank. These are intentional safeguards.
9. Add valid documented non-NZD rates in Power Query and refresh. Combined NZD amounts should then display. Do not interpret assumed-rate results as historical FX financial reporting.
10. Test year/month, customer, product, channel and warehouse selections. Keep dates on visuals sourced from DimDate, not FactSales or auto hierarchies.

## Interpretation rules
- All Total Revenue/Cost/Profit, AOV, ASP and finance/rank/time measures are in NZD. Connected Currency Code filters which transactions enter calculations; it does NOT change the reporting unit.
- Original-currency measures require exactly one DimCurrency currency in context and do not require conversion rates. They are blank when all five currencies are selected.
- Cost/profit still assume source unit costs are in the transaction's Currency Code. Confirm before making financial claims.
- Missing FX is guarded at transaction scope. Rankings additionally guard the entire selected ranking universe so customers with missing rates cannot disappear silently.
- Standard YoY and MoM compare the shifted visible date window. 2019 annual standard YoY compares incomplete 2019 to full 2018. December 2019 MoM compares partial December to full November. Label these honestly or use a narrower matched date window.
- Comparable-period measures deliberately take one selected year, ignore lower-level date filters, preserve non-date filters, and use the GLOBAL source cutoff. With 2019 selected they compare Jan 1-Dec 12 2019 with Jan 1-Dec 12 2018. Do not put these measures on a monthly chart or imply a guarantee of no missing days within the source period.
- Rolling 3-Month Revenue is trailing three months through MAX(DimDate[Date]); use Year Month on the axis. At month end it is three calendar months, not 90 days; partial months remain partial. Initial windows are truncated by available source data. It intentionally allows the window to extend beyond a Year slicer's boundary.
- Customer/Product rank is within ALLSELECTED of that dimension, keeps non-dimension slicers, is dense and gives ties the same rank. Comparison rounds revenue to two decimals only for ranking, not the base sums. Rank <= 5 may contain more than five members if tied. Top 5 customer share uses an ID tie-breaker and at most five customers.
- Use dimension names on rank visual axes. A visual Top N filter can change the ALLSELECTED universe; do not combine a native Top N filter with the concentration/Pareto denominators and then present them as full-population shares. Prefer a measure rank filter for ranked bars and leave concentration cards unfiltered by that bar's Top N.
- Pareto requires all selected customers (not a Top 10-filtered chart) and sorting by rounded revenue descending with Customer Index as tie-breaker. Final point should be 100%. If tied names cannot be ordered natively, use a table to verify the cumulative line, or provide an explicit deterministic sort field in the later visual design.
- % of Total Revenue uses the selected visual grand total (ALLSELECTED with no argument). Customer Revenue Share % removes only the customer visual row, preserving year/other axes; useful in the customer-by-year matrix.
- Average lead time is calendar days, not working days. One order per source row makes the row average order-weighted. Monitor Duplicate Order Rows after refresh; altered grain would require revisiting operations averages.
- Late is strictly >10 calendar days, a project analytical assumption rather than a proven SLA. Exactly 10 days is not late. Use shipment-date numerator and denominator together on the late trend.
- USERELATIONSHIP activates the existing Ship Date relationship for that calculation; filter dates using DimDate. Direct FactSales Order Date filters would remain and could intersect the shipment cohort.
- Missing dates/no transactions or unavailable prior periods return blank rather than invented zero. NZD margin is weighted profit/revenue, not mean row margin. DIVIDE protects zero denominators.

## QA checklist
- All currencies, only NZD rate supplied: Missing FX Rows = 4,965; NZD finance cards blank.
- NZD only: Missing FX Rows = 0; compare finance totals with the CSV.
- Global Latest Loaded Order Date = 2019-12-12, even under channel/customer filters.
- Revenue reconciliation difference, Negative Lead Time Rows, Duplicate Order Rows = 0.
- Without date filters Total Orders equals Orders by Ship Date. Monthly cohorts can differ.
- Selected customer shares total 100% when every customer is displayed; Pareto last point 100%.
- No prior-year data exists for 2017; 2017 growth is blank, not 100% or zero.

## Official DAX references
Microsoft Learn: SAMEPERIODLASTYEAR, USERELATIONSHIP, ALLSELECTED, DATESINPERIOD, RANKX, DIVIDE. These are function references, not proof that the generated formulas have been executed.

## Create the measures table
```dax
_Measures =
// A disconnected one-row table used only to organize measures.
DATATABLE ( "Placeholder", INTEGER, { { 1 } } )
```

## 1. Missing FX Rows
Folder: `00 Quality` | Format: `#,0`

```dax
Missing FX Rows =
// Count visible transactions without a positive, usable conversion rate.
COALESCE (
    COUNTROWS (
        FILTER (
            FactSales,
            VAR Rate = RELATED ( DimCurrency[Rate to NZD] )
            RETURN ISBLANK ( Rate ) || Rate <= 0
        )
    ), 0
)
```

## 2. FX Status
Folder: `00 Quality` | Format: `Text`

```dax
FX Status =
// Put on a card so blank financial KPIs have an explanation.
SWITCH (
    TRUE (),
    COUNTROWS ( FactSales ) = 0, "No transactions in this selection",
    [Missing FX Rows] > 0, "STOP: supply positive assumed FX rates for selected transactions",
    "FX complete for this selection; assumed fixed-rate scenario"
)
```

## 3. Total Revenue
Folder: `01 Finance` | Format: `#,0.00`

```dax
Total Revenue =
// NZD: convert each transaction BEFORE summing; never silently skip missing rates.
IF (
    [Missing FX Rows] > 0,
    BLANK (),
    SUMX ( FactSales, FactSales[Total Revenue] * RELATED ( DimCurrency[Rate to NZD] ) )
)
```

## 4. Total Cost
Folder: `01 Finance` | Format: `#,0.00`

```dax
Total Cost =
// NZD: convert each transaction BEFORE summing; never silently skip missing rates.
IF (
    [Missing FX Rows] > 0,
    BLANK (),
    SUMX ( FactSales, FactSales[Total Cost] * RELATED ( DimCurrency[Rate to NZD] ) )
)
```

## 5. Total Profit
Folder: `01 Finance` | Format: `#,0.00`

```dax
Total Profit =
// Guard against BLANK arithmetic; source costs assumed to share transaction currency.
VAR Revenue = [Total Revenue]
VAR Cost = [Total Cost]
RETURN IF ( ISBLANK ( Revenue ) || ISBLANK ( Cost ), BLANK (), Revenue - Cost )
```

## 6. Profit Margin %
Folder: `01 Finance` | Format: `0.0%`

```dax
Profit Margin % =
// Weighted margin, not an average of transaction margins.
DIVIDE ( [Total Profit], [Total Revenue] )
```

## 7. Total Orders
Folder: `01 Finance` | Format: `#,0`

```dax
Total Orders =
// Distinct orders; source currently has one record per order.
DISTINCTCOUNT ( FactSales[Order Number] )
```

## 8. Total Quantity
Folder: `01 Finance` | Format: `#,0`

```dax
Total Quantity =
// Units sold in the current selection.
SUM ( FactSales[Order Quantity] )
```

## 9. Average Order Value
Folder: `01 Finance` | Format: `#,0.00`

```dax
Average Order Value =
// NZD per distinct order.
DIVIDE ( [Total Revenue], [Total Orders] )
```

## 10. Average Selling Price
Folder: `01 Finance` | Format: `#,0.00`

```dax
Average Selling Price =
// Quantity-weighted selling price, NZD per unit.
DIVIDE ( [Total Revenue], [Total Quantity] )
```

## 11. Original Currency Code
Folder: `02 Original Currency` | Format: `Text`

```dax
Original Currency Code =
// A connected currency slicer must select one currency for original-currency cards.
SELECTEDVALUE ( DimCurrency[Currency Code] )
```

## 12. Revenue Original Currency
Folder: `02 Original Currency` | Format: `#,0.00`

```dax
Revenue Original Currency =
// Do not aggregate incomparable currencies. This does not require FX rates.
IF (
    HASONEVALUE ( DimCurrency[Currency Code] ),
    SUM ( FactSales[Total Revenue] ),
    BLANK ()
)
```

## 13. Cost Original Currency
Folder: `02 Original Currency` | Format: `#,0.00`

```dax
Cost Original Currency =
// Do not aggregate incomparable currencies. This does not require FX rates.
IF (
    HASONEVALUE ( DimCurrency[Currency Code] ),
    SUM ( FactSales[Total Cost] ),
    BLANK ()
)
```

## 14. Profit Original Currency
Folder: `02 Original Currency` | Format: `#,0.00`

```dax
Profit Original Currency =
// Same-currency source cost assumption applies here too.
VAR Revenue = [Revenue Original Currency]
VAR Cost = [Cost Original Currency]
RETURN IF ( ISBLANK ( Revenue ) || ISBLANK ( Cost ), BLANK (), Revenue - Cost )
```

## 15. Margin Original Currency %
Folder: `02 Original Currency` | Format: `0.0%`

```dax
Margin Original Currency % =
// Available without FX when exactly one source currency is selected.
DIVIDE ( [Profit Original Currency], [Revenue Original Currency] )
```

## 16. Original Currency Status
Folder: `02 Original Currency` | Format: `Text`

```dax
Original Currency Status =
// No selected currency means ALL currencies, not NZD.
IF (
    HASONEVALUE ( DimCurrency[Currency Code] ),
    "Original currency: " & SELECTEDVALUE ( DimCurrency[Currency Code] ),
    "Select exactly one currency to view original amounts"
)
```

## 17. Revenue Previous Year
Folder: `03 Time Intelligence` | Format: `#,0.00`

```dax
Revenue Previous Year =
// Shift the date selection one calendar year; standard full-year selections remain full-year.
CALCULATE ( [Total Revenue], SAMEPERIODLASTYEAR ( DimDate[Date] ) )
```

## 18. Revenue vs Previous Year
Folder: `03 Time Intelligence` | Format: `#,0.00`

```dax
Revenue vs Previous Year =
// Absolute NZD difference. Blank when either period is unavailable.
VAR CurrentRevenue = [Total Revenue]
VAR PriorRevenue = [Revenue Previous Year]
RETURN
    IF ( ISBLANK ( CurrentRevenue ) || ISBLANK ( PriorRevenue ),
        BLANK (), CurrentRevenue - PriorRevenue )
```

## 19. Revenue YoY %
Folder: `03 Time Intelligence` | Format: `0.0%`

```dax
Revenue YoY % =
// Do not interpret partial 2019 versus full 2018 as like-for-like.
DIVIDE ( [Revenue vs Previous Year], [Revenue Previous Year] )
```

## 20. Revenue Previous Month
Folder: `03 Time Intelligence` | Format: `#,0.00`

```dax
Revenue Previous Month =
// Use with DimDate[Year Month] axis; it shifts the current date window one month.
CALCULATE ( [Total Revenue], DATEADD ( DimDate[Date], -1, MONTH ) )
```

## 21. Revenue MoM %
Folder: `03 Time Intelligence` | Format: `0.0%`

```dax
Revenue MoM % =
// Partial months require interpretation: December 2019 ends on December 12.
VAR CurrentRevenue = [Total Revenue]
VAR PriorRevenue = [Revenue Previous Month]
RETURN
    IF ( ISBLANK ( CurrentRevenue ) || ISBLANK ( PriorRevenue ),
        BLANK (), DIVIDE ( CurrentRevenue - PriorRevenue, PriorRevenue ) )
```

## 22. YTD Revenue
Folder: `03 Time Intelligence` | Format: `#,0.00`

```dax
YTD Revenue =
// Calendar-year cumulative NZD revenue.
CALCULATE ( [Total Revenue], DATESYTD ( DimDate[Date] ) )
```

## 23. QTD Revenue
Folder: `03 Time Intelligence` | Format: `#,0.00`

```dax
QTD Revenue =
// Calendar-quarter cumulative NZD revenue.
CALCULATE ( [Total Revenue], DATESQTD ( DimDate[Date] ) )
```

## 24. Rolling 3-Month Revenue
Folder: `03 Time Intelligence` | Format: `#,0.00`

```dax
Rolling 3-Month Revenue =
// Trailing three-month date window ending at the axis/context date.
// On a Year Month axis this gives three calendar months; an incomplete month stays incomplete.
VAR EndDate = MAX ( DimDate[Date] )
VAR Window = DATESINPERIOD ( DimDate[Date], EndDate, -3, MONTH )
RETURN
    CALCULATE ( [Total Revenue], REMOVEFILTERS ( DimDate ), Window )
```

## 25. Latest Loaded Order Date
Folder: `00 Quality` | Format: `yyyy-MM-dd`

```dax
Latest Loaded Order Date =
// Dataset-wide cutoff, intentionally unaffected by any report selection.
CALCULATE ( MAX ( FactSales[Order Date] ), REMOVEFILTERS () )
```

## 26. Revenue Through Comparable Cutoff
Folder: `04 Comparable Period` | Format: `#,0.00`

```dax
Revenue Through Comparable Cutoff =
// Use with ONE year selected, not a monthly chart. Intentionally ignores lower date filters.
VAR SelectedYear = SELECTEDVALUE ( DimDate[Year] )
VAR LastLoaded = [Latest Loaded Order Date]
VAR EndDate = IF ( SelectedYear = YEAR ( LastLoaded ),
    LastLoaded, DATE ( SelectedYear, 12, 31 ) )
VAR Window = DATESBETWEEN ( DimDate[Date], DATE ( SelectedYear, 1, 1 ), EndDate )
RETURN
    IF ( ISBLANK ( SelectedYear ) || SelectedYear > YEAR ( LastLoaded ),
        BLANK (), CALCULATE ( [Total Revenue], REMOVEFILTERS ( DimDate ), Window ) )
```

## 27. Revenue PY Through Comparable Cutoff
Folder: `04 Comparable Period` | Format: `#,0.00`

```dax
Revenue PY Through Comparable Cutoff =
// 2019 compares Jan 1-Dec 12 against Jan 1-Dec 12 2018.
VAR SelectedYear = SELECTEDVALUE ( DimDate[Year] )
VAR LastLoaded = [Latest Loaded Order Date]
VAR CurrentEnd = IF ( SelectedYear = YEAR ( LastLoaded ),
    LastLoaded, DATE ( SelectedYear, 12, 31 ) )
VAR PriorEnd = EDATE ( CurrentEnd, -12 )
VAR Window = DATESBETWEEN ( DimDate[Date], DATE ( SelectedYear - 1, 1, 1 ), PriorEnd )
RETURN
    IF ( ISBLANK ( SelectedYear ) || SelectedYear > YEAR ( LastLoaded ),
        BLANK (), CALCULATE ( [Total Revenue], REMOVEFILTERS ( DimDate ), Window ) )
```

## 28. Revenue Comparable YoY %
Folder: `04 Comparable Period` | Format: `0.0%`

```dax
Revenue Comparable YoY % =
// Safest annual comparison for this dataset; 2017 has no prior-year observations.
VAR CurrentRevenue = [Revenue Through Comparable Cutoff]
VAR PriorRevenue = [Revenue PY Through Comparable Cutoff]
RETURN IF ( ISBLANK ( CurrentRevenue ) || ISBLANK ( PriorRevenue ),
    BLANK (), DIVIDE ( CurrentRevenue - PriorRevenue, PriorRevenue ) )
```

## 29. Customer Rank
Folder: `05 Rankings` | Format: `0`

```dax
Customer Rank =
// Dense revenue rank within slicer-selected customers. Ties share a rank.
// Rounding at comparison time prevents floating-point equality surprises.
VAR CurrentRevenue = [Total Revenue]
VAR Universe = ALLSELECTED ( DimCustomer )
VAR MissingInUniverse = CALCULATE ( [Missing FX Rows], Universe )
VAR Scored = FILTER (
    ADDCOLUMNS ( Universe, "@Revenue", CALCULATE ( [Total Revenue] ) ),
    NOT ISBLANK ( [@Revenue] ) )
RETURN
    IF ( NOT HASONEVALUE ( DimCustomer[Customer Index] ) ||
         ISBLANK ( CurrentRevenue ) || MissingInUniverse > 0,
         BLANK (),
         RANKX ( Scored, ROUND ( [@Revenue], 2 ), ROUND ( CurrentRevenue, 2 ), DESC, DENSE ) )
```

## 30. Product Rank
Folder: `05 Rankings` | Format: `0`

```dax
Product Rank =
// Dense revenue rank within slicer-selected products. Ties share a rank.
// Rounding at comparison time prevents floating-point equality surprises.
VAR CurrentRevenue = [Total Revenue]
VAR Universe = ALLSELECTED ( DimProduct )
VAR MissingInUniverse = CALCULATE ( [Missing FX Rows], Universe )
VAR Scored = FILTER (
    ADDCOLUMNS ( Universe, "@Revenue", CALCULATE ( [Total Revenue] ) ),
    NOT ISBLANK ( [@Revenue] ) )
RETURN
    IF ( NOT HASONEVALUE ( DimProduct[Product Index] ) ||
         ISBLANK ( CurrentRevenue ) || MissingInUniverse > 0,
         BLANK (),
         RANKX ( Scored, ROUND ( [@Revenue], 2 ), ROUND ( CurrentRevenue, 2 ), DESC, DENSE ) )
```

## 31. Product Bottom Rank
Folder: `05 Rankings` | Format: `0`

```dax
Product Bottom Rank =
// Ascending dense rank: lowest revenue is rank 1; ties can produce >5 products.
VAR CurrentRevenue = [Total Revenue]
VAR Universe = ALLSELECTED ( DimProduct )
VAR MissingInUniverse = CALCULATE ( [Missing FX Rows], Universe )
VAR Scored = FILTER (
    ADDCOLUMNS ( Universe, "@Revenue", CALCULATE ( [Total Revenue] ) ),
    NOT ISBLANK ( [@Revenue] ) )
RETURN
    IF ( NOT HASONEVALUE ( DimProduct[Product Index] ) ||
         ISBLANK ( CurrentRevenue ) || MissingInUniverse > 0,
         BLANK (),
         RANKX ( Scored, ROUND ( [@Revenue], 2 ), ROUND ( CurrentRevenue, 2 ), ASC, DENSE ) )
```

## 32. Top 5 Customers Share of Revenue
Folder: `05 Rankings` | Format: `0.0%`

```dax
Top 5 Customers Share of Revenue =
// Exactly five where available: Customer Index breaks revenue ties deterministically.
// Respects noncustomer slicers and the selected customer universe.
VAR Universe = ALLSELECTED ( DimCustomer )
VAR MissingInUniverse = CALCULATE ( [Missing FX Rows], Universe )
VAR Scored = FILTER (
    ADDCOLUMNS ( Universe, "@Revenue", CALCULATE ( [Total Revenue] ) ),
    NOT ISBLANK ( [@Revenue] ) )
VAR TopCustomers = TOPN ( 5, Scored, [@Revenue], DESC, DimCustomer[Customer Index], ASC )
RETURN
    IF ( MissingInUniverse > 0, BLANK (),
        DIVIDE ( SUMX ( TopCustomers, [@Revenue] ), SUMX ( Scored, [@Revenue] ) ) )
```

## 33. % of Total Revenue
Folder: `05 Rankings` | Format: `0.0%`

```dax
% of Total Revenue =
// Share of selected visual total; retains external slicers.
// In a customer-by-year matrix the denominator is the selected grand total.
DIVIDE ( [Total Revenue], CALCULATE ( [Total Revenue], ALLSELECTED () ) )
```

## 34. Customer Revenue Share %
Folder: `05 Rankings` | Format: `0.0%`

```dax
Customer Revenue Share % =
// Within each year/matrix column, selected customer shares add to 100%.
DIVIDE ( [Total Revenue], CALCULATE ( [Total Revenue], ALLSELECTED ( DimCustomer ) ) )
```

## 35. Customer Pareto Cumulative %
Folder: `05 Rankings` | Format: `0.0%`

```dax
Customer Pareto Cumulative % =
// Sort customer bars by rounded revenue DESC, then Customer Index ASC.
// Ties are broken by Customer Index so the cumulative curve is deterministic.
VAR CurrentRevenue = [Total Revenue]
VAR CurrentKey = SELECTEDVALUE ( DimCustomer[Customer Index] )
VAR Universe = ALLSELECTED ( DimCustomer )
VAR MissingInUniverse = CALCULATE ( [Missing FX Rows], Universe )
VAR Scored = FILTER (
    ADDCOLUMNS ( Universe, "@Revenue", CALCULATE ( [Total Revenue] ) ),
    NOT ISBLANK ( [@Revenue] ) )
VAR RunningRows = FILTER ( Scored,
    ROUND ( [@Revenue], 2 ) > ROUND ( CurrentRevenue, 2 ) ||
    ( ROUND ( [@Revenue], 2 ) = ROUND ( CurrentRevenue, 2 ) &&
      DimCustomer[Customer Index] <= CurrentKey ) )
RETURN
    IF ( ISBLANK ( CurrentKey ) || ISBLANK ( CurrentRevenue ) || MissingInUniverse > 0,
        BLANK (), DIVIDE ( SUMX ( RunningRows, [@Revenue] ), SUMX ( Scored, [@Revenue] ) ) )
```

## 36. Pareto 80% Target
Folder: `05 Rankings` | Format: `0.0%`

```dax
Pareto 80% Target =
// Reference line for the Pareto chart.
0.8
```

## 37. Average Lead Time
Folder: `06 Operations` | Format: `0.0`

```dax
Average Lead Time =
// Order-weighted mean: one source record per order, measured in calendar days.
AVERAGE ( FactSales[Lead Time (days)] )
```

## 38. Orders Shipped Late
Folder: `06 Operations` | Format: `#,0`

```dax
Orders Shipped Late =
// Analytical definition: lead time strictly OVER 10 calendar days; not a verified SLA.
CALCULATE ( [Total Orders], KEEPFILTERS ( FactSales[Lead Time (days)] > 10 ) )
```

## 39. Late Shipment %
Folder: `06 Operations` | Format: `0.0%`

```dax
Late Shipment % =
// By order date unless shipment-date measures below are used.
DIVIDE ( [Orders Shipped Late], [Total Orders] )
```

## 40. Orders by Ship Date
Folder: `06 Operations` | Format: `#,0`

```dax
Orders by Ship Date =
// Uses inactive shipment relationship instead of active order-date relationship.
CALCULATE ( [Total Orders], USERELATIONSHIP ( FactSales[Ship Date], DimDate[Date] ) )
```

## 41. Revenue by Ship Date
Folder: `06 Operations` | Format: `#,0.00`

```dax
Revenue by Ship Date =
// Converted NZD revenue attributed to shipment date, with the same FX safeguards.
CALCULATE ( [Total Revenue], USERELATIONSHIP ( FactSales[Ship Date], DimDate[Date] ) )
```

## 42. Late Orders by Ship Date
Folder: `06 Operations` | Format: `#,0`

```dax
Late Orders by Ship Date =
// Use this for the Operations late-shipment trend.
CALCULATE ( [Orders Shipped Late], USERELATIONSHIP ( FactSales[Ship Date], DimDate[Date] ) )
```

## 43. Late Shipment % by Ship Date
Folder: `06 Operations` | Format: `0.0%`

```dax
Late Shipment % by Ship Date =
// Shipment-date numerator and denominator must use the same date role.
DIVIDE ( [Late Orders by Ship Date], [Orders by Ship Date] )
```

## 44. Average Lead Time by Ship Date
Folder: `06 Operations` | Format: `0.0`

```dax
Average Lead Time by Ship Date =
// Mean lead time for orders shipped in the selected date window.
CALCULATE ( [Average Lead Time], USERELATIONSHIP ( FactSales[Ship Date], DimDate[Date] ) )
```

## 45. Revenue Reconciliation Difference
Folder: `00 Quality` | Format: `0.000000`

```dax
Revenue Reconciliation Difference =
// QA in raw currency units only: test row arithmetic, NOT an economic mixed-currency total.
SUMX ( FactSales, FactSales[Total Revenue] - FactSales[Order Quantity] * FactSales[Unit Price] )
```

## 46. Negative Lead Time Rows
Folder: `00 Quality` | Format: `#,0`

```dax
Negative Lead Time Rows =
// Expected zero for the supplied workbook.
COALESCE ( COUNTROWS ( FILTER ( FactSales, FactSales[Lead Time (days)] < 0 ) ), 0 )
```

## 47. Duplicate Order Rows
Folder: `00 Quality` | Format: `#,0`

```dax
Duplicate Order Rows =
// Expected zero; monitors whether source grain changes on later refreshes.
COUNTROWS ( FactSales ) - DISTINCTCOUNT ( FactSales[Order Number] )
```
