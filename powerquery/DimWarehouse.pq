let
    Selected = Table.SelectColumns(FactSales, {"Warehouse Code"}),
    Unique = Table.Distinct(Selected),
    Sorted = Table.Sort(Unique, {{"Warehouse Code", Order.Ascending}})
in
    Sorted