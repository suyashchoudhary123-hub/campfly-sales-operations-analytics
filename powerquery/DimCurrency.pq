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