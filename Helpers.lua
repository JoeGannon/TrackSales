
TrackSales.Helpers = { }

function TrackSales.Helpers.IsConfigCommand(arg)
    return arg == "c" or arg == "config"
end 

function TrackSales.Helpers.IsAddCommand(arg)
    return arg == "a" or arg == "add"
end 

function TrackSales.Helpers.IsSubtractCommand(arg)
    return arg == "s" or arg == "subtract"
end 

function TrackSales.Helpers.IsSetCommand(arg)
    return arg == "set"
end 