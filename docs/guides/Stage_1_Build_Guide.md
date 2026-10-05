# Campfly | Sales & Operations Intelligence
## Stage 1: Cleaning and model
This package contains copy-paste-ready Power Query M and a DAX calendar, not a built PBIX. Power BI Desktop execution remains to be performed.

## Verified source findings
- Sales: 7,991 rows and 7,991 distinct order numbers; no missing sales fields.
- Customers: 50, with 13 names needing whitespace trimming.
- Regions: 100. Products: 15 (including Product 20), not the 14 stated in the prompt.
- Order dates: 2017-01-01 through 2019-12-12. Ship dates: 2017-01-05 through 2019-12-28.
- No orphan customer, region or product keys; no duplicate dimension keys.
- Revenue equals quantity times unit price on all source rows; no negative lead times.
- Currencies: NZD 3026, USD 2323, AUD 1309, GBP 669, EUR 664.

## Build order
1. In Power BI Desktop choose Transform data. Create a text parameter pFilePath pointing to the actual workbook. Alternatively create a blank query named pFilePath and paste its supplied literal in Advanced Editor, changing the local path.
2. Create blank queries using the exact filenames' stems as query names. Paste each .pq into Advanced Editor: SourceWorkbook, FactSales, DimCustomer, DimRegion, DimProduct, DimCurrency, DimChannel, DimWarehouse.
3. Disable Enable load for SourceWorkbook and pFilePath if it is a query. Keep load enabled for the eight model tables. Close & Apply.
4. Use Modeling > New table and paste DimDate.dax. Mark DimDate as the date table with Date as its date column.
5. Create the relationships in relationships.csv. Remove conflicting automatically detected relationships. All use single direction from dimension to fact; shipment date is inactive.
6. Sort Month by Month Number, Quarter by Quarter Number, Year Month by Year Month Sort, Day of Week by Day of Week Number.
7. Set DimRegion Latitude/Longitude data categories; postcode is text and Do not summarize. Set geographical coordinates to Do not summarize. Hide dimension IDs and fact foreign keys from report view. Hide raw fact financial columns from report authoring once measures exist in Stage 2.
8. Optionally disable Auto date/time for this file and use DimDate fields consistently.
9. Save your Power BI project and verify row counts and model against this package.

## Currency policy
DimCurrency doubles as the exchange-rate table; Rate to NZD means NZD per one unit of source currency. NZD = 1 is exact. Non-NZD rates are deliberately null pending user-supplied documented assumptions; do not treat them as zero or 1. Edit constants in DimCurrency, then refresh. Fixed rates across 2017-2019 are a scenario assumption, not historical FX accounting. Record source, as-of date, and methodology in the final README. Source data does not prove which currency applies to unit cost; proposed profit conversion assumes costs share each row's Currency Code and must be confirmed before financial interpretation.
Stage 2 measures will convert revenue AND costs row-by-row before summing, and return blank rather than silently omit rows with missing rates. Original-currency measures will require exactly one selected currency, otherwise return blank. The connected Currency Code slicer filters transactions, not the display currency. Later reporting-currency mode can use a disconnected display selector if desired.

## Grain and limitations
Each Order Number is unique in this workbook, so its observed grain is one record per order with one recorded product. Do not assert line-item granularity beyond the source.
Keep Product 20, all original rows and full precision. Format monetary measures to two decimals later; do not round row-level values.
The 2019 order period is incomplete: a full-year comparison would be misleading. Stage 2 will include a matched-cutoff comparison. A complete calendar does not imply complete sales coverage.
Late shipment threshold (>10 days) is an analytical assumption, not a documented SLA; no promised delivery date exists.

## Next stages
Stage 2: dedicated _Measures table, commented financial/time-intelligence/rank/operations DAX and QA.
Stage 3: six report pages, fields, layout, theme JSON, navigation, tooltips and drill-through.
Stage 4: 6-8 verified insights, recommendations, final README, screenshots captured from the built report, resume bullets and Service/refresh checklist.
Wait for the user's next before continuing.

## Source references
Microsoft Learn: active vs inactive relationship guidance; create/manage relationships; Power Query Table.TransformColumns.

## Power Query code

### pFilePath
```powerquery
"C:\Campfly\Campfly Sales Analysis Dashboard.xlsx"
```

### SourceWorkbook
```powerquery
let
    Source = Excel.Workbook(File.Contents(pFilePath), null, true)
in
    Source
```

### FactSales
```powerquery
let
    Raw = SourceWorkbook{[Item="Sales Orders", Kind="Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Raw, [PromoteAllScalars=true]),
    Renamed = Table.RenameColumns(Headers, {
        {"OrderNumber", "Order Number"}, {"OrderDate", "Order Date"},
        {"Customer Name Index", "Customer Index"},
        {"Delivery Region Index", "Region Index"},
        {"Product Description Index", "Product Index"}}),
    Typed = Table.TransformColumnTypes(Renamed, {
        {"Order Number", type text}, {"Order Date", type date},
        {"Ship Date", type date}, {"Customer Index", Int64.Type},
        {"Channel", type text}, {"Currency Code", type text},
        {"Warehouse Code", type text}, {"Region Index", Int64.Type},
        {"Product Index", Int64.Type}, {"Order Quantity", Int64.Type},
        {"Unit Price", type number}, {"Total Unit Cost", type number},
        {"Total Revenue", type number}}),
    Trimmed = Table.TransformColumns(Typed, {
        {"Order Number", Text.Trim, type text},
        {"Channel", Text.Trim, type text},
        {"Currency Code", each Text.Upper(Text.Trim(_)), type text},
        {"Warehouse Code", Text.Trim, type text}}),
    Cost = Table.AddColumn(Trimmed, "Total Cost",
        each [Order Quantity] * [Total Unit Cost], type number),
    Profit = Table.AddColumn(Cost, "Profit",
        each [Total Revenue] - [Total Cost], type number),
    LeadTime = Table.AddColumn(Profit, "Lead Time (days)",
        each Duration.Days([Ship Date] - [Order Date]), Int64.Type)
in
    LeadTime
```

### DimCustomer
```powerquery
let
    Raw = SourceWorkbook{[Item="Customers", Kind="Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Raw, [PromoteAllScalars=true]),
    Typed = Table.TransformColumnTypes(Headers, {
        {"Customer Index", Int64.Type}, {"Customer Names", type text}}),
    Cleaned = Table.TransformColumns(Typed, {
        {"Customer Names", each Text.Trim(Text.Clean(_)), type text}})
in
    Cleaned
```

### DimRegion
```powerquery
let
    Raw = SourceWorkbook{[Item="Regions", Kind="Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Raw, [PromoteAllScalars=true]),
    Renamed = Table.RenameColumns(Headers, {{"Index", "Region Index"}}),
    Typed = Table.TransformColumnTypes(Renamed, {
        {"Region Index", Int64.Type}, {"Suburb", type text},
        {"City", type text}, {"postcode", type text},
        {"Longitude", type number}, {"Latitude", type number},
        {"Full Address", type text}}),
    Cleaned = Table.TransformColumns(Typed, {
        {"Suburb", Text.Trim, type text}, {"City", Text.Trim, type text},
        {"Full Address", Text.Trim, type text},
        {"postcode", each Text.PadStart(Text.Trim(_), 4, "0"), type text}})
in
    Cleaned
```

### DimProduct
```powerquery
let
    Raw = SourceWorkbook{[Item="Products", Kind="Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Raw, [PromoteAllScalars=true]),
    Renamed = Table.RenameColumns(Headers, {{"Index", "Product Index"}}),
    Typed = Table.TransformColumnTypes(Renamed, {
        {"Product Index", Int64.Type}, {"Product Name", type text}}),
    Cleaned = Table.TransformColumns(Typed, {
        {"Product Name", Text.Trim, type text}})
in
    Cleaned
```

### DimCurrency
```powerquery
let
    // NZD per ONE unit of source currency. Null = not supplied, NOT zero.
    // Replace nulls with your documented assumed rates before NZD reporting.
    Rates = #table(
        type table [Currency Code = text, Rate to NZD = nullable number,
                    Rate Status = text],
        {
            {"NZD", 1.0, "Identity rate"},
            {"USD", null, "Missing - supply assumed rate"},
            {"AUD", null, "Missing - supply assumed rate"},
            {"GBP", null, "Missing - supply assumed rate"},
            {"EUR", null, "Missing - supply assumed rate"}
        }),
    Validated = if List.AnyTrue(List.Transform(Rates[Rate to NZD],
        each if _ = null then false else _ <= 0))
        then error "Exchange rates must be positive or null."
        else Rates
in
    Validated
```

### DimChannel
```powerquery
let
    Selected = Table.SelectColumns(FactSales, {"Channel"}),
    Unique = Table.Distinct(Selected),
    Sorted = Table.Sort(Unique, {{"Channel", Order.Ascending}})
in
    Sorted
```

### DimWarehouse
```powerquery
let
    Selected = Table.SelectColumns(FactSales, {"Warehouse Code"}),
    Unique = Table.Distinct(Selected),
    Sorted = Table.Sort(Unique, {{"Warehouse Code", Order.Ascending}})
in
    Sorted
```

## DAX calendar
```dax
DimDate =
// Include full calendar years covering both order and shipment dates.
VAR FirstDate = MINX ( FactSales, FactSales[Order Date] )
VAR LastDate = MAXX (
    FactSales,
    MAX ( FactSales[Order Date], FactSales[Ship Date] )
)
RETURN
    ADDCOLUMNS (
        CALENDAR ( DATE ( YEAR ( FirstDate ), 1, 1 ),
                   DATE ( YEAR ( LastDate ), 12, 31 ) ),
        "Year", YEAR ( [Date] ),
        "Quarter Number", QUARTER ( [Date] ),
        "Quarter", "Q" & QUARTER ( [Date] ),
        "Month Number", MONTH ( [Date] ),
        "Month", FORMAT ( [Date], "MMM" ),
        "Year Month", FORMAT ( [Date], "yyyy-MM" ),
        "Year Month Sort", YEAR ( [Date] ) * 100 + MONTH ( [Date] ),
        "Month Start", DATE ( YEAR ( [Date] ), MONTH ( [Date] ), 1 ),
        "Day", DAY ( [Date] ),
        "Day of Week Number", WEEKDAY ( [Date], 2 ),
        "Day of Week", FORMAT ( [Date], "ddd" )
    )
```
