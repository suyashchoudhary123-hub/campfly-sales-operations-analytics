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