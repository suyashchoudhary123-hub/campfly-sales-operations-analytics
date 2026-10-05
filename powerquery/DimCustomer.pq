let
    Raw = SourceWorkbook{[Item="Customers", Kind="Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Raw, [PromoteAllScalars=true]),
    Typed = Table.TransformColumnTypes(Headers, {
        {"Customer Index", Int64.Type}, {"Customer Names", type text}}),
    Cleaned = Table.TransformColumns(Typed, {
        {"Customer Names", each Text.Trim(Text.Clean(_)), type text}})
in
    Cleaned