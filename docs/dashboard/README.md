# Campfly · Sales Intelligence

A responsive, client-side analytics website generated from the supplied Campfly workbook. Ready for GitHub Pages: no npm installation, build process, backend, API key or database is needed.

## IMPORTANT: public data

The complete 7,991-order dataset, customer names and regional addresses are bundled in `data.js`. Anyone who can visit the site can download them. Filtering, pagination and hidden UI elements are NOT access control. Do not publish this version if the data is confidential or redistribution is prohibited. Anonymize the source before rebuilding if needed. A private repository does not by itself guarantee a private GitHub Pages website; check your organization's actual access-control configuration.

## Features

- Six sections: overview, products, customers, geography, operations, order details.
- Year, channel, source currency, warehouse and product filters.
- Converted NZD versus original-currency display; original totals require one selected currency.
- Order-date/ship-date selector and separate ship-month operational trend.
- Editable positive FX assumptions and lead-time threshold, persisted in each visitor's browser only.
- Interactive charts, region markers, and table row links that drill into orders.
- Searchable, paginated records and CSV export of the current filtered/searched dataset.
- Comparable annual periods, source-cutoff notes and explicit financial safeguards.
- Responsive mobile navigation, keyboard controls, labels and skip link.
- Bundled Plotly and Leaflet: chart scripts do not depend on a CDN. OpenStreetMap basemap tiles require internet; coordinates/tables remain available independently.

## Deploy to your existing GitHub repository (browser method)

1. Extract the website ZIP on your computer.
2. Open your existing repository on GitHub. Back up existing content and do not overwrite an existing website without reviewing it.
3. Choose **Add file → Upload files**.
4. Upload the CONTENTS of `Campfly_Website`, not the enclosing folder. The publishing root must contain `index.html`, `styles.css`, `app.js`, `data.js`, and the `vendor` directory. Preserve the folder structure. Include `.nojekyll` when your upload method permits hidden files.
5. Commit the upload to your chosen branch. If this repository already contains another site, use its `/docs` directory instead and select that directory in the next step.
6. Open **Settings → Pages**. Under **Build and deployment**, select **Deploy from a branch**.
7. Select the branch holding the website and **/(root)** (or **/docs** if that is where the site was placed). Save. You need repository permission to configure this.
8. Wait for the Pages deployment to complete; inspect the deployment status under Actions/Pages if there is an error.
9. Open the site address shown in the Pages settings. Verify default NZD totals, vendor script loading, mobile layout and map tile availability.

For an ordinary project repository the address normally includes your repository name. All site assets use relative paths, so no repository-name rewrite is required. Do not upload only the HTML file: the scripts, data, styles and vendor folder are required.

If you cannot see a Pages option, check repository permissions and your account/organization's Pages availability. No GitHub deployment was performed when this package was generated.

## Git alternative

Run this INSIDE a local clone of your existing repository, after copying the website contents into the desired publishing directory:

```bash
git status
git add index.html styles.css app.js data.js vendor README.md THIRD_PARTY_NOTICES.md QA_Report.json tools .nojekyll
git commit -m "Add Campfly interactive analytics website"
git push
```

Review `git status` first and do not stage unrelated changes. Then configure Pages as above. Use the correct branch for your existing repository; no branch name is assumed by the website.

## Preview locally

You can open `index.html` directly. Recommended for consistent browser behavior:

```bash
python -m http.server 8000
```

Run that from the website directory and open the local address printed by Python. This is a preview server only, not a GitHub hosting requirement.

## Data and currency policy

- 7,991 orders; 50 customers; 100 regions; 15 dimension products (Product 20 has no recorded sales).
- Orders: 1 Jan 2017–12 Dec 2019. Shipments: 5 Jan 2017–28 Dec 2019.
- Default selection: NZD only. Default money display: NZD; date basis: Order date.
- NZD rate is fixed at 1. USD/AUD/GBP/EUR are initially unset, NOT guessed.
- Converted totals multiply EACH row's revenue and cost by its rate before summing. Missing/invalid rates cause the relevant aggregate to be blank; visitors see a warning.
- Original currency mode requires one currency, and does not require FX assumptions.
- Positive rates entered by a visitor are fixed-rate scenarios across all years, not verified historical FX. They are stored in localStorage in that browser, not written to the repository. Reset filters does not clear saved assumptions; use Currency & methodology → Clear assumed rates → Save assumptions.
- Profit assumes recorded unit costs share the row currency. It is not net profit unless unrecorded overheads/tax/freight are separately established.
- Threshold-late defaults to lead time strictly >10 calendar days. This is not a verified SLA.
- Matched comparisons use Jan 1–Dec 12 for 2019 orders and Jan 1–Dec 28 for 2019 shipments, with the same prior-year window. The reference table deliberately ignores the Year dropdown; other nondate filters still apply.
- Operational late-shipment trend always uses SHIP DATE, regardless of the global Date basis setting; clicking a ship month sets the date basis to Ship date and opens that shipment cohort.
- Dense/unique ranks should not be interpreted as causal performance. Currency/subset changes can alter rankings.
- Product 20 remains visible as No sales instead of being dropped.
- This is historical static data. There is no automatic Excel refresh, Power BI Service connection, live market-rate feed or authentication.

## Update the workbook data

Keep the input workbook OUTSIDE your public repository if it must not be redistributed. The website still exposes the regenerated dataset unless it is anonymized first.

```bash
python -m pip install pandas openpyxl
python tools/rebuild_data.py "/path/to/Campfly Sales Analysis Dashboard.xlsx"
```

This replaces `data.js`, not the website code. Run validation again and update date labels/year options/source record-count labels if the source period or row count changes; those historical coverage labels are intentionally explicit in this version. The converter checks keys, arithmetic, unique order numbers and negative lead times; it does not anonymize or verify cost currency. Upload/commit the refreshed data only after permission and QA.

## Files

```text
index.html                Website shell
styles.css                Responsive design
app.js                    Filters, calculations, charts, drilldown and export
data.js                   Public source records and dimensions
vendor/                   Bundled Plotly/Leaflet and their licenses
.nojekyll                 Skip unnecessary Jekyll processing
QA_Report.json            Actual automated browser test results
tools/rebuild_data.py      Optional workbook-to-JavaScript converter
THIRD_PARTY_NOTICES.md     Library and tile attribution
```

## Verification

Automated local Chromium checks passed for all six pages, default NZD revenue, missing-FX blanks, original-USD revenue, retained Product 20, Product 7 drilldown, cross-month ship-date detail cohorts, positive-rate conversion scenarios, search, pagination, 7,991-row CSV export and 390px mobile layout. No JavaScript page errors were observed in these tested flows. See `QA_Report.json`.

Test assumptions were temporary browser-only values and are NOT embedded in the site's default rates. External tile availability, deployment permissions, all possible filter combinations and organization security policies were not exhaustively tested. This package is a working website, not a PBIX report.

## Official deployment reference

GitHub Docs — Configuring a publishing source for your GitHub Pages site:
https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site

## Ownership and licenses

The custom app code is provided for your project. Choose your repository's code license deliberately. Dataset redistribution permission is not established by the app code or bundled third-party licenses. Keep vendor license notices and visible OpenStreetMap attribution.
