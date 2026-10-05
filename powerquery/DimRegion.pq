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