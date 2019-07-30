
local _, ts = ...

function ts:IsConfigCommand(arg)
    return arg == "c" or arg == "config"
end 

function ts:IsAddCommand(arg)
    return arg == "a" or arg == "add"
end 

function ts:IsSubtractCommand(arg)
    return arg == "s" or arg == "subtract"
end 

function ts:IsSetCommand(arg)
    return arg == "set"
end 