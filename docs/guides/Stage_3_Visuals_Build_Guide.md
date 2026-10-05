# Campfly | Stage 3 — Report design and interaction build guide

## What this is
Six-page build blueprint, exact visual-field and pixel-position specification, importable theme, extra visual-support DAX, and six design wireframes. It is NOT a built PBIX and the wireframes are NOT screenshots of a finished report. Continue from Stage 1/2. Stop after this stage and wait for next before the final insight/portfolio stage.

## 1. Prepare theme and canvas
1. Import Campfly_Theme.json using the report theme import command (View > Themes > Browse for themes, or the equivalent in your installed build). Theme schema validation passed Microsoft schema 2.157; a live Power BI import has not been tested here.
2. Create six visible pages, in order: Executive Overview; Product Analysis; Customer Analysis; Geographic Analysis; Operations; Details.
3. Set each canvas to Custom 1440 x 900. Canvas background #F4F7FB, transparency 0. Wallpaper same color.
4. Font Segoe UI. Page titles 24 pt; visual titles 14 pt; labels 10-11 pt; KPI values 24 pt; KPI labels 11 pt. Set explicitly where the theme does not control a visual-specific setting.
5. Add navy sidebar x=0,y=0,w=190,h=900. Add CAMPFLY title at x=24,y=26; subtitle Sales intelligence. Use white cards/visuals with pale border #D6E0EA, 8px rounded corners where supported, no heavy shadows.
6. Use content grid x=214 to1416. Main title x=214,y=22,w=1000,h=52. Slicers y=86,h=54. Status banner x=214,y=146,w=1202,h=34. KPI cards y=196,h=94. Upper analysis row y=312,h=256. Lower row y=588,h=266. Footer y=868. Set positions under Format > General > Properties (equivalent labels may vary).
7. Add footer: 'Revenue/profit in NZD unless labeled original | Order coverage ends 12 Dec 2019 | Assumed FX'. Do not imply 2019 is complete.

Palette: Navy #12304A; teal #007F7B; blue #2463A0; amber #C87800; violet #7C5AA6; red #C84B52; slate #64748B. Revenue teal, profit blue, late counts red, warning amber. Assign Channel explicitly: Wholesale teal, Distributor blue, Export amber. Never rely solely on red/green; include numeric values/labels.

## 2. Shared slicers and statuses
1. Five dropdown slicers on EVERY visible page (x=214,458,702,946,1190; each w=226): DimDate[Year], DimChannel[Channel], DimCurrency[Currency Code], DimWarehouse[Warehouse Code], DimProduct[Product Name]. Use dimensions, not fact copies.
2. Sync all five across the six pages. Default Year/Channel/Warehouse/Product all selected; default Currency NZD ONLY while non-NZD rates are missing. Leave currency multi-select available so users can test guarded all-currency reporting after supplying rates.
3. Label the Currency slicer 'Source currency'; the report is still NZD. Put [FX Status] in a card in the status banner. No FX exchange-rate values are provided in this stage.
4. Under View > Sync slicers, sync into hidden drill targets if retaining global selections, but do NOT make shared slicers visible on hidden drill targets; a shared source-currency slicer still applies there. The target drill-through field is a separate selection layer.
5. If all currencies are selected and FX missing, NZD finance visuals intentionally blank. Count/lead-time visuals remain valid. Expose [Missing FX Rows] in the help popover and explain this behavior.
6. Use DimDate Year Month sorted by Year Month Sort. Keep standard YTD/QTD/monthly measures separate from the comparable-year table.

## 3. Supporting DAX
Create the four additional measures below in _Measures; folder 05 Rankings. Percentage format for Customer Pareto Cumulative Tied %, whole-number format for positions. They address precise top-N membership and native Pareto tie ordering. The Stage 2 rank measures remain useful as dense ranks.
Create Region Label as a CALCULATED COLUMN in DimRegion. It uses only existing source values. Category Place; retain Latitude/Longitude categories and Do not summarize.

## 4. Exact page build
Use Visual_Field_and_Layout_Spec.csv: each visual has its ID, type, field wells, x/y/width/height, sorting, filters and special rules. Build one page at a time. For every financial title include NZD. Put margins on percent axes and do not plot them on money axes.

### Executive Overview
- Five KPI cards: revenue, profit, margin, orders, AOV.
- Monthly revenue/profit line, channel donut, annual revenue columns, and comparable-year matrix.
- Monthly trend is by ORDER DATE; both series use same NZD axis. Tooltips show orders/margin.
- Annual revenue title must identify '2019 partial through 12 Dec'. Comparable table uses matched cutoffs and no total row; 2017 PY is blank.
- Channel donut labels: channel name and percent; keep only three channel colors.
- Channel slice can filter other visuals. Trend/year selection can filter cards; do not interpret annual matched-cutoff measures as lower-level date selections.

### Product Analysis
- Five KPI cards: revenue/profit/margin/quantity/ASP.
- Full product matrix, quantity-versus-margin scatter, top-five/bottom-five revenue bars.
- Scatter: put Product Name in the per-point Details/Values/category bucket supplied by your installed Power BI build. X quantity, Y margin, bubble size revenue; without product field it collapses to one bubble.
- Use Product Position <=5 and not blank on top-five bar; Product Bottom Position <=5 and not blank on bottom-five bar. These give exact membership where five products exist; ties break by Product Index.
- Do not use a native Top N filter AND the ALLSELECTED rank measure together.
- Keep top/bottom bars from cross-filtering one another or the full-product matrix; otherwise their ranking universes can shrink. Their clicks may filter cards and scatter. Test interaction settings individually.

### Customer Analysis
- Five KPI cards: revenue, orders, AOV, top-five share, margin.
- Top-ten bar uses Customer Position <=10 and not blank, not native Top N. All-customer column chart shows revenue by customer: a category distribution, not a numeric histogram.
- Pareto combo: every selected customer on x axis; columns revenue; lines Customer Pareto Cumulative Tied % and Pareto 80% Target. Sort revenue DESC; secondary line axis 0-1, percent format. No native top filter. Tied revenues share a cumulative value, avoiding the need to dynamically sort a physical customer column.
- Use the tied cumulative measure here rather than Stage 2's ID-ordered measure. Final point must equal 100% under valid rates.
- Customer-by-year matrix uses Revenue and Customer Revenue Share %, so shares total 100% within each year when all selected customers appear.
- Disable cross-filtering from the top-ten/distribution/Pareto charts into the concentration card and between those three charts. Otherwise a single customer click could misleadingly make top-five share 100%. Global slicers still apply. Matrix and cards may be filtered by a selected customer where explicitly intended, but label scope.

### Geographic Analysis
- KPI cards: revenue/profit/margin/orders/quantity.
- Azure Maps with region-level markers: Region Label in Location; Latitude and Longitude from DimRegion; revenue Size. Include full address in tooltip. Confirm marker coordinates aren't summed. Map initially centered on New Zealand.
- Report Maps depend on tenant/network availability; verify relevant permissions. Do not claim suburb polygons or a choropleth: this source has coordinates, not boundary geometry.
- Top-ten region bar uses native Top N by Revenue, allowed here because no ranking/share denominator is computed inside this visual. Exact ten with tied values is not guaranteed; label 'Top regions' if tie membership expands.
- Region-by-channel matrix shows all selected regions. City can be added as a hierarchy parent before Region Label; do not geocode ambiguous city names when coordinates are supplied.
- If maps are disabled, replace map with a city-revenue bar at the same bounds and an all-region coordinate table. This is a fallback, not a rendered map. Map drill-through uses the same Region Label field as the target.

### Operations
- KPI cards: orders/average lead days/late orders/late %/quantity. Default cards are order-date cohorts.
- Warehouse matrix: orders, revenue NZD, average lead, late %. Lead-time columns use the existing integer Lead Time (days), not invented dates or working-day calculations.
- Late shipment combo is by SHIP DATE, using Late Orders by Ship Date and Late Shipment % by Ship Date. Format secondary line axis %. Distinguish title/date role from all other order-date visuals.
- Disable the ship-month trend's interaction with order-date cards/warehouse/distribution visuals; those would otherwise receive an order-date year-month filter and show a different cohort. Allow clicks only to the ship-period drill-through button/target described below.
- Lead days >10 is an analytical rule, not an SLA. A 10-day threshold reference line may be placed on the histogram x axis if supported; otherwise use an explanatory text badge. Do not set a target late-rate without evidence.

### Details
- Five context cards, then order-level table as specified in CSV. No native drill-through field on this visible page: ordinary navigation makes it available under synced slicers.
- Raw transaction revenue/cost/profit remain original currency; rename their visual headers accordingly. NZD measures are separate columns. Never sum the raw mixed-currency columns: all table total rows OFF.
- Use Order Number as a column so each row keeps original grain. Set raw numeric detail fields to Do not summarize where permitted. Use per-order dimensions from their related tables. Dates show yyyy-MM-dd; money 2 decimals; quantity integer.
- No promise of a printable one-screen table: 20 columns need horizontal/vertical scrolling. Prioritize order/customer/product/currency/original revenue/NZD revenue/lead days; place the other columns to the right.
- Export permissions are tenant/report settings; do not assume every reader can export the underlying data.

## 5. Sidebar navigation
1. Insert a native Page navigator; position x=14,y=150,w=162,h=390; vertical orientation; six visible pages only. Hide tooltip/drill-target pages so they do not appear.
2. Button style: normal navy fill/white text, selected teal fill/white text, hover lighter navy. Include page names rather than icons alone. Add sufficient padding for readable labels.
3. Add a Reset filters bookmark button at x=24,y=780 and Currency/help button at x=24,y=824. Help uses selected-visual bookmarks below. Use native Page navigator for page navigation, not a separate data-capturing bookmark per page.
4. On hidden drill targets use a Back action button, not a direct navigation button, so the source page/filter context is restored. Test in reading mode; Desktop action buttons may require Ctrl+click.

## 6. Bookmarks: exact settings
### Local filter reset (one per visible page)
- Set the shared slicers to default (Year all; Channel all; Currency NZD; Warehouse all; Product all) and select the five slicer visuals only.
- Add bookmark '<Page> — Reset filters': Data ON; Display OFF; Current page OFF; Selected visuals ON. Update bookmark with only those five slicers selected. Assign the local reset button to its local bookmark.
- Name it Reset filters, NOT Reset entire report. It resets those selected slicers, not arbitrary filter-pane filters, personal bookmarks, or every cross-selection. Synced slicers propagate those choices. Verify separately in the Service.

### Currency/help overlay (one per page)
- Group overlay shapes/text/cards as '<Page> Help': x=980,y=184,w=430,h=340; include [Original Currency Status], [Revenue Original Currency], [Profit Original Currency], [Missing FX Rows] and a concise assumed-FX/source-cost note. Cards explicitly label Original currency.
- It only provides ORIGINAL-CURRENCY summary cards, not a global currency-mode switch. All underlying main-page charts stay NZD. Title this unambiguously.
- Capture '<Page> Help open' and '<Page> Help closed': Data OFF; Display ON; Current page OFF; Selected visuals ON; only overlay group selected. Show/hide via Selection pane before Update. Assign help button and close X button accordingly.
- Test that opening/closing does not change any slicer. This prevents a bookmark from unexpectedly replacing user filters.

## 7. Tooltips
Create three hidden tooltip pages, page size Tooltip 320x240, Page information > Tooltip ON (equivalent properties may vary). Set Tooltip type Report page on source visuals and choose the intended page. The field/context from the source must exist in its data; verify by hovering different members.
- TT Financial: cards Total Revenue, Total Profit, Profit Margin %, Total Orders, Average Order Value, and a static 'NZD; assumed FX' footer. Assign to product/customer/channel/region charts and order-date trend; tooltip honors source context. Do not assign to percent-only reference line or totals without meaning.
- TT Product: revenue/profit/margin/quantity/ASP cards. Assign to scatter/product bars; source point has Product Name.
- TT Operations: Orders by Ship Date, Late Orders by Ship Date, Late Shipment % by Ship Date, Average Lead Time by Ship Date. Assign ONLY to ship-date trend. Create a separate order-date variant if assigning a tooltip to warehouse or lead-time plots.
No invented tooltip metrics or screenshots. Include accessible alt text on each chart, e.g. 'Monthly NZD revenue and profit by order month; 2019 stops on 12 December.'

## 8. Drill-through — safe dimension-specific routing
A single target with customer+product+region+warehouse+channel fields is a compound context target, not a universal OR target. Do not add every dimension to one Details drill-through well and claim it works from any chart. KPI cards also have no selected entity row to drill through.

Use the visible Details page as a layout template. Duplicate it to the hidden targets below, add ONLY the listed drill-through field, and enable Keep all filters. Use the EXACT same field in source and target:
- DT Customer: DimCustomer[Customer Names]. From customer bar/column/Pareto/matrix rows.
- DT Product: DimProduct[Product Name]. From product bars/scatter/matrix rows.
- DT Region: DimRegion[Region Label]. From map/top-region bar/region matrix rows.
- DT Channel: DimChannel[Channel]. From channel donut/region matrix columns.
- DT Warehouse: DimWarehouse[Warehouse Code]. From warehouse matrix/bar.
- DT Order Month: DimDate[Year Month]. From monthly ORDER-date trend.
- DT Order Year: DimDate[Year]. From annual order revenue columns or annual matrix rows.
- DT Currency (optional if you build a source currency chart): DimCurrency[Currency Code]. Source slicer alone is not a drill-through entity chart.

On each hidden target: remove global Page navigator or replace with Back; keep the details table and context cards; add a text title with scope/date-role. Set filter on the single drilled dimension using the drill-through well, not a static manual filter. Click source point, right-click > Drill through, or provide a Drill through action button to the relevant target. Source and target must match field identity, not merely a similar label.

### Special shipment-period target (required for the ship-date trend)
An ordinary Details target with Year Month would filter FactSales through the ACTIVE ORDER relationship, yielding the wrong cohort for ship-date trend. Build a separate hidden DT Ship Month:
1. Duplicate Details; sole drill-through field DimDate[Year Month]; Keep all filters ON.
2. Remove its standard finance/lead cards or replace with Orders by Ship Date, Revenue by Ship Date, Late Orders by Ship Date, Late Shipment % by Ship Date, Average Lead Time by Ship Date.
3. For its detail table ONLY, do not use related dimension columns on row groups: use FactSales[Order Number], [Order Date], [Ship Date], [Customer Index], [Product Index], [Region Index], [Channel], [Warehouse Code], [Currency Code], [Order Quantity], [Total Revenue], [Total Cost], [Profit], [Lead Time (days)]. This keeps row-grain fields on the fact table, allowing the row-membership measure below to control date-role filtering without dimension auto-exist eliminating candidates.
4. Add Ship Detail Row Visible as a visual-level filter =1. Add Ship Detail Revenue NZD as a value if converted amounts are wanted. Under normal hidden-ID policy unhide fact IDs temporarily to author this table, then hide again; its grouped columns remain in the visual.
5. With no other order-date raw filter applied, test known orders whose Order Date and Ship Date fall in different months. If the installed visual still prunes candidate rows through the active relationship, do NOT ship the target as correct: use a separate disconnected ship-date selector/model enhancement or omit monthly row drill-through and provide the shipment summary tooltip instead. Validate the table in Desktop before relying on it.
6. Both DT Order Month and DT Ship Month may appear in the context menu because the same date field exists. Provide a prominent routed 'View shipped orders' drill-through button pointing to DT Ship Month; label the other target Order-date details. Do not imply the right-click menu can infer measure relationship intent.

### Limits of 'from any visual'
Enable entity drill-through from compatible categorical visuals. For scalar KPI cards or charts without the target entity, provide 'View orders' Page navigation to the visible Details page: synced slicers persist, but a clicked entity isn't automatically passed. This distinction must be explained to readers. A single universal drill-through target would need a more complex selector/model pattern; do not invent native behavior.

## 9. Interaction QA and handoff
- All six visible pages have synced slicers, correct page selection indicator and consistent units.
- Test NZD-only first against Stage 2 QA benchmarks. Then test missing FX with multiple currencies selected; cards blank with visible warning.
- Test original help with USD alone: original amount displays, converted main charts blank until USD rate supplied. Open/close bookmarks must not change filters.
- Test top/bottom five and top-ten filters; confirm blank positions excluded and membership count <= requested N.
- Pareto all-customer final point is 100%; ties share cumulative values and sorting remains revenue DESC. Top-five share card is not filtered by top-ten/Pareto interactions.
- Month axis ascending, percentages not formatted as money, year-2019 partial note visible.
- Map dots match supplied coordinates and region identity; no city-name geocoding substitution.
- Details originals NEVER have mixed-currency total rows. Converted per-order totals match source rows under NZD selection.
- Warehouse/order metrics and ship-month metrics have correct date roles. Especially test ship-period target with a cross-month shipment before accepting it.
- All hidden targets and tooltips excluded from page navigator. Back returns to origin. Every routed drill button enables only for a compatible selected point.
- Test keyboard navigation/tab order and alt text. Keep at least 4.5:1 normal text contrast where practical; do not use color alone.
- Do not call wireframes report screenshots. Capture actual screenshots only after the report is built and validated in Desktop, for Stage 4.

Official reference basis: Microsoft Learn report themes, bookmarks, report page tooltips, drill-through; Azure Maps marker layers. UI labels depend on installed build. Native report construction/interaction testing has not been executed in this sandbox.

## Supporting code — separate definitions

### Customer Pareto Cumulative Tied %
```dax
Customer Pareto Cumulative Tied % =
// Native visual-safe Pareto: customers tied at two-decimal revenue share a cumulative value.
// Sort the complete selected customer chart by Total Revenue descending.
VAR CurrentRevenue = [Total Revenue]
VAR Universe = ALLSELECTED ( DimCustomer )
VAR Missing = CALCULATE ( [Missing FX Rows], Universe )
VAR Scored = FILTER (
    ADDCOLUMNS ( Universe, "@Revenue", CALCULATE ( [Total Revenue] ) ),
    NOT ISBLANK ( [@Revenue] )
)
VAR RunningRows = FILTER ( Scored, ROUND ( [@Revenue], 2 ) >= ROUND ( CurrentRevenue, 2 ) )
RETURN
    IF ( NOT HASONEVALUE ( DimCustomer[Customer Index] ) ||
         ISBLANK ( CurrentRevenue ) || Missing > 0,
         BLANK (), DIVIDE ( SUMX ( RunningRows, [@Revenue] ), SUMX ( Scored, [@Revenue] ) ) )
```

### Customer Position
```dax
Customer Position =
// Unique revenue position: use <=10 for EXACTLY ten customers where available.
VAR CurrentRevenue = [Total Revenue]
VAR CurrentKey = SELECTEDVALUE ( DimCustomer[Customer Index] )
VAR Universe = ALLSELECTED ( DimCustomer )
VAR Missing = CALCULATE ( [Missing FX Rows], Universe )
VAR Scored = FILTER (
    ADDCOLUMNS ( Universe, "@Revenue", CALCULATE ( [Total Revenue] ) ),
    NOT ISBLANK ( [@Revenue] )
)
RETURN
    IF ( ISBLANK ( CurrentKey ) || ISBLANK ( CurrentRevenue ) || Missing > 0,
        BLANK (),
        1 + COUNTROWS ( FILTER ( Scored,
            ROUND ( [@Revenue], 2 ) > ROUND ( CurrentRevenue, 2 ) ||
            ( ROUND ( [@Revenue], 2 ) = ROUND ( CurrentRevenue, 2 ) &&
              DimCustomer[Customer Index] < CurrentKey ) ) ) )
```

### Product Position
```dax
Product Position =
// Unique descending position; Product Index breaks ties. Use <=5 for exactly five.
VAR CurrentRevenue = [Total Revenue]
VAR CurrentKey = SELECTEDVALUE ( DimProduct[Product Index] )
VAR Universe = ALLSELECTED ( DimProduct )
VAR Missing = CALCULATE ( [Missing FX Rows], Universe )
VAR Scored = FILTER (
    ADDCOLUMNS ( Universe, "@Revenue", CALCULATE ( [Total Revenue] ) ),
    NOT ISBLANK ( [@Revenue] )
)
RETURN
    IF ( ISBLANK ( CurrentKey ) || ISBLANK ( CurrentRevenue ) || Missing > 0,
        BLANK (),
        1 + COUNTROWS ( FILTER ( Scored,
            ROUND ( [@Revenue], 2 ) > ROUND ( CurrentRevenue, 2 ) ||
            ( ROUND ( [@Revenue], 2 ) = ROUND ( CurrentRevenue, 2 ) &&
              DimProduct[Product Index] < CurrentKey ) ) ) )
```

### Product Bottom Position
```dax
Product Bottom Position =
// Unique ascending position; Product Index breaks ties. Use <=5 for exactly five.
VAR CurrentRevenue = [Total Revenue]
VAR CurrentKey = SELECTEDVALUE ( DimProduct[Product Index] )
VAR Universe = ALLSELECTED ( DimProduct )
VAR Missing = CALCULATE ( [Missing FX Rows], Universe )
VAR Scored = FILTER (
    ADDCOLUMNS ( Universe, "@Revenue", CALCULATE ( [Total Revenue] ) ),
    NOT ISBLANK ( [@Revenue] )
)
RETURN
    IF ( ISBLANK ( CurrentKey ) || ISBLANK ( CurrentRevenue ) || Missing > 0,
        BLANK (),
        1 + COUNTROWS ( FILTER ( Scored,
            ROUND ( [@Revenue], 2 ) < ROUND ( CurrentRevenue, 2 ) ||
            ( ROUND ( [@Revenue], 2 ) = ROUND ( CurrentRevenue, 2 ) &&
              DimProduct[Product Index] < CurrentKey ) ) ) )
```

### Region Label calculated column
```dax
Region Label =
// Calculated COLUMN in DimRegion, not a measure. Prevents ambiguous suburb grouping.
DimRegion[Suburb] & ", " & DimRegion[City]
    & " [" & FORMAT ( DimRegion[Region Index], "0" ) & "]"
```

### Ship Detail Row Visible
```dax
Ship Detail Row Visible =
// For FACT-ONLY grouping on the hidden ship-month details table. Validate in Desktop.
VAR RowsByShip = CALCULATE (
    COUNTROWS ( FactSales ),
    CROSSFILTER ( DimDate[Date], FactSales[Order Date], NONE ),
    USERELATIONSHIP ( FactSales[Ship Date], DimDate[Date] )
)
RETURN IF ( RowsByShip > 0, 1, BLANK () )
```

### Ship Detail Revenue NZD
```dax
Ship Detail Revenue NZD =
// Ship-context conversion, disabling order relationship explicitly for row details.
CALCULATE (
    [Total Revenue],
    CROSSFILTER ( DimDate[Date], FactSales[Order Date], NONE ),
    USERELATIONSHIP ( FactSales[Ship Date], DimDate[Date] )
)
```

## Theme JSON
```json
{
  "name": "Campfly Sales & Operations \u2014 Navy Teal",
  "dataColors": [
    "#007F7B",
    "#2463A0",
    "#C87800",
    "#7C5AA6",
    "#C84B52",
    "#64748B"
  ],
  "background": "#F4F7FB",
  "foreground": "#12304A",
  "tableAccent": "#007F7B",
  "good": "#007F7B",
  "neutral": "#C87800",
  "bad": "#C84B52",
  "textClasses": {
    "title": {
      "fontFace": "Segoe UI",
      "fontSize": 14,
      "color": "#12304A"
    },
    "header": {
      "fontFace": "Segoe UI",
      "fontSize": 12,
      "color": "#12304A"
    },
    "label": {
      "fontFace": "Segoe UI",
      "fontSize": 10,
      "color": "#516579"
    },
    "callout": {
      "fontFace": "Segoe UI",
      "fontSize": 24,
      "color": "#12304A"
    }
  }
}
```

## Field and layout tables

### Executive Overview

- **K1 — Total Revenue** (Card), x=214, y=196, w=226, h=94. Fields: Value: [Total Revenue]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K2 — Total Profit** (Card), x=458, y=196, w=226, h=94. Fields: Value: [Total Profit]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K3 — Profit Margin %** (Card), x=702, y=196, w=226, h=94. Fields: Value: [Profit Margin %]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K4 — Total Orders** (Card), x=946, y=196, w=226, h=94. Fields: Value: [Total Orders]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K5 — Average Order Value** (Card), x=1190, y=196, w=226, h=94. Fields: Value: [Average Order Value]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **E1 — Monthly revenue and profit — NZD** (Line chart), x=214, y=312, w=790, h=256. Fields: X: DimDate[Year Month]; Y: [Total Revenue], [Total Profit]; tooltip: [Total Orders], [Profit Margin %]. Sort Year Month ascending. Revenue teal; profit blue. Default interaction: filter.
- **E2 — Revenue by channel — NZD** (Donut), x=1022, y=312, w=394, h=256. Fields: Legend: DimChannel[Channel]; Values: [Total Revenue]. Whole ring context; labels show channel and %. Channel colors fixed across pages.
- **E3 — Revenue by year — NZD** (Clustered column), x=214, y=588, w=592, h=266. Fields: X: DimDate[Year]; Y: [Total Revenue]. Label 2019 partial in title/footer. Sort year ascending.
- **E4 — Comparable annual performance** (Matrix), x=824, y=588, w=592, h=266. Fields: Rows: DimDate[Year]; Values: [Revenue Through Comparable Cutoff], [Revenue PY Through Comparable Cutoff], [Revenue Comparable YoY %]. 2019 uses Jan 1-Dec 12; other complete years use calendar year. Turn off grand total because measures need one year.

### Product Analysis

- **K1 — Total Revenue** (Card), x=214, y=196, w=226, h=94. Fields: Value: [Total Revenue]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K2 — Total Profit** (Card), x=458, y=196, w=226, h=94. Fields: Value: [Total Profit]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K3 — Profit Margin %** (Card), x=702, y=196, w=226, h=94. Fields: Value: [Profit Margin %]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K4 — Total Quantity** (Card), x=946, y=196, w=226, h=94. Fields: Value: [Total Quantity]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K5 — Average Selling Price** (Card), x=1190, y=196, w=226, h=94. Fields: Value: [Average Selling Price]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **P1 — Product financial performance — NZD** (Matrix), x=214, y=312, w=700, h=256. Fields: Rows: DimProduct[Product Name]; Values: [Total Revenue], [Total Profit], [Profit Margin %], [Total Quantity]. Revenue DESC; data bars on revenue; diverging colors on margin. All selected products; no top filter.
- **P2 — Quantity vs margin** (Scatter), x=932, y=312, w=484, h=256. Fields: X: [Total Quantity]; Y: [Profit Margin %]; Size: [Total Revenue]; Details/Values: DimProduct[Product Name]. Each product must be a separate bubble; verify selected point count. Tooltip revenue, profit, ASP. Do not draw unsupported high/low quadrants.
- **P3 — Top 5 products by revenue — NZD** (Clustered bar), x=214, y=588, w=592, h=266. Fields: Y: DimProduct[Product Name]; X: [Total Revenue]; tooltip: [Total Profit], [Profit Margin %]. Visual filter: Product Position <=5 AND is not blank. Revenue DESC. Never native Top N + rank universe.
- **P4 — Bottom 5 products by revenue — NZD** (Clustered bar), x=824, y=588, w=592, h=266. Fields: Y: DimProduct[Product Name]; X: [Total Revenue]; tooltip: [Total Profit], [Profit Margin %]. Visual filter: Product Bottom Position <=5 AND is not blank. Revenue ASC. Exactly five where available.

### Customer Analysis

- **K1 — Total Revenue** (Card), x=214, y=196, w=226, h=94. Fields: Value: [Total Revenue]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K2 — Total Orders** (Card), x=458, y=196, w=226, h=94. Fields: Value: [Total Orders]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K3 — Average Order Value** (Card), x=702, y=196, w=226, h=94. Fields: Value: [Average Order Value]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K4 — Top 5 Customers Share of Revenue** (Card), x=946, y=196, w=226, h=94. Fields: Value: [Top 5 Customers Share of Revenue]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K5 — Profit Margin %** (Card), x=1190, y=196, w=226, h=94. Fields: Value: [Profit Margin %]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **C1 — Top 10 customers — NZD** (Clustered bar), x=214, y=312, w=592, h=256. Fields: Y: DimCustomer[Customer Names]; X: [Total Revenue]; tooltip: [Total Orders], [Average Order Value], [Customer Position]. Customer Position <=10 AND not blank. Sort revenue DESC. Card concentration must not receive this visual filter.
- **C2 — Customer revenue distribution — NZD** (Clustered column), x=824, y=312, w=592, h=256. Fields: X: DimCustomer[Customer Names]; Y: [Total Revenue]. All selected customers, revenue DESC; category distribution, NOT a numeric histogram. Hide crowded axis labels; use tooltips.
- **C3 — Customer Pareto — NZD** (Line and clustered column), x=214, y=588, w=592, h=266. Fields: X: DimCustomer[Customer Names]; Column Y: [Total Revenue]; Line Y: [Customer Pareto Cumulative Tied %], [Pareto 80% Target]. All selected customers, NO Top N. Sort revenue DESC. Line secondary axis 0-1 formatted %. Tie-aware cumulative; final point 100%.
- **C4 — Customer by year — NZD** (Matrix), x=824, y=588, w=592, h=266. Fields: Rows: DimCustomer[Customer Names]; Columns: DimDate[Year]; Values: [Total Revenue], [Customer Revenue Share %]. Revenue data bars. Share is within year, not whole matrix grand total. Scroll allowed.

### Geographic Analysis

- **K1 — Total Revenue** (Card), x=214, y=196, w=226, h=94. Fields: Value: [Total Revenue]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K2 — Total Profit** (Card), x=458, y=196, w=226, h=94. Fields: Value: [Total Profit]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K3 — Profit Margin %** (Card), x=702, y=196, w=226, h=94. Fields: Value: [Profit Margin %]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K4 — Total Orders** (Card), x=946, y=196, w=226, h=94. Fields: Value: [Total Orders]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K5 — Total Quantity** (Card), x=1190, y=196, w=226, h=94. Fields: Value: [Total Quantity]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **G1 — Regional revenue — NZD** (Azure Maps), x=214, y=312, w=700, h=542. Fields: Location: DimRegion[Region Label]; Latitude: DimRegion[Latitude]; Longitude: DimRegion[Longitude]; Size: [Total Revenue]. Coordinates Do not summarize; marker/bubble size revenue; tooltip revenue, profit, margin, orders, full address. NZ geographic extent. Do not substitute aggregated city centroids.
- **G2 — Top 10 regions — NZD** (Clustered bar), x=932, y=312, w=484, h=256. Fields: Y: DimRegion[Region Label]; X: [Total Revenue]. Native visual Top N 10 by Total Revenue; no share/rank/Pareto denominator here. Revenue DESC; exact tie count not guaranteed.
- **G3 — Region by channel — NZD** (Matrix), x=932, y=588, w=484, h=266. Fields: Rows: DimRegion[Region Label]; Columns: DimChannel[Channel]; Values: [Total Revenue]. Keep all selected regions; optional city hierarchy before region label. Grand totals on.

### Operations

- **K1 — Total Orders** (Card), x=214, y=196, w=226, h=94. Fields: Value: [Total Orders]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K2 — Average Lead Time** (Card), x=458, y=196, w=226, h=94. Fields: Value: [Average Lead Time]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K3 — Orders Shipped Late** (Card), x=702, y=196, w=226, h=94. Fields: Value: [Orders Shipped Late]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K4 — Late Shipment %** (Card), x=946, y=196, w=226, h=94. Fields: Value: [Late Shipment %]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K5 — Total Quantity** (Card), x=1190, y=196, w=226, h=94. Fields: Value: [Total Quantity]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **O1 — Warehouse performance** (Matrix), x=214, y=312, w=700, h=256. Fields: Rows: DimWarehouse[Warehouse Code]; Values: [Total Orders], [Total Revenue], [Average Lead Time], [Late Shipment %]. Warehouse metrics by ORDER date. Include conditional colors for late %; no invented target.
- **O2 — Lead-time distribution by order date** (Clustered column), x=932, y=312, w=484, h=256. Fields: X: FactSales[Lead Time (days)] (Do not summarize); Y: [Total Orders]. Sort lead days ASC. Numeric x bins are exact days, no synthetic column required.
- **O3 — Late shipments by ship month** (Line and clustered column), x=214, y=588, w=790, h=266. Fields: X: DimDate[Year Month]; Column Y: [Late Orders by Ship Date]; Line Y: [Late Shipment % by Ship Date]. Secondary line axis 0-1 %. Order date drill-through disabled here. Use special ship-period target defined in guide.
- **O4 — Average lead time by warehouse** (Clustered bar), x=1022, y=588, w=394, h=266. Fields: Y: DimWarehouse[Warehouse Code]; X: [Average Lead Time]. Order-date cohort; sort days DESC. Label calendar days.

### Details

- **K1 — Total Orders** (Card), x=214, y=196, w=226, h=94. Fields: Value: [Total Orders]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K2 — Total Revenue** (Card), x=458, y=196, w=226, h=94. Fields: Value: [Total Revenue]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K3 — Total Cost** (Card), x=702, y=196, w=226, h=94. Fields: Value: [Total Cost]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K4 — Total Profit** (Card), x=946, y=196, w=226, h=94. Fields: Value: [Total Profit]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **K5 — Average Lead Time** (Card), x=1190, y=196, w=226, h=94. Fields: Value: [Average Lead Time]. Finance values in NZD; counts/days/% keep explicit units. Cards do not support entity drill-through.
- **D1 — Order-level detail** (Table), x=214, y=312, w=1202, h=542. Fields: Order Number; Order Date; Ship Date; Customer Names; Product Name; Region Label; Channel; Warehouse Code; Currency Code; Order Quantity; Unit Price; Total Unit Cost; Total Revenue; Total Cost; Profit; Lead Time (days); [Total Revenue]; [Total Cost]; [Total Profit]. Rename raw fields for this visual to Revenue/Cost/Profit (original); converted measures to Revenue/Cost/Profit (NZD). Raw fields Do not summarize; totals OFF to avoid mixed-currency sums. Horizontal scroll expected.
