let
    Selected = Table.SelectColumns(FactSales, {"Channel"}),
    Unique = Table.Distinct(Selected),
    Sorted = Table.Sort(Unique, {{"Channel", Order.Ascending}})
in
    Sorted