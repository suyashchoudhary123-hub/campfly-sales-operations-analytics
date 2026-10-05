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