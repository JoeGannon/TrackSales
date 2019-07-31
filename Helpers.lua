
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

function ts:IsProfessionCommand(arg)
    return self:IsAddCommand(arg) or self:IsRemoveCommand(arg)
end 

function ts:IsAddCommand(arg)
    return arg == "a" or arg == "add"
end

function ts:IsRemoveCommand(arg)
    return arg == "r" or arg == "remove"
end

function ts:IsDisplayCommand(arg)
    return self:IsShowCommand(arg) or self:IsHideCommand(arg) or self:IsOrderCommand(arg)
end

function ts:IsShowCommand(arg)
    return arg == "s" or arg == "show"
end

function ts:IsHideCommand(arg)
    return arg == "h" or arg == "hide"
end

function ts:IsOrderCommand(arg)
    return arg == "o" or arg == "order"
end

function ts:MatchProfession(item)

    local matches = self:ContainsItem(ts.alchemyItems, item)

    if matches then
        return "Alchemy"
    end

    matches = self:ContainsItem(ts.blacksmithItems, item)

    if matches then
        return "Blacksmithing"
    end

    matches = self:ContainsItem(ts.cookingItems, item)

    if matches then
        return "Cooking"
    end

    matches = self:ContainsItem(ts.enchantingItems, item)

    if matches then
        return "Enchanting"
    end

    matches = self:ContainsItem(ts.engineeringItems, item)

    if matches then
        return "Engineering"
    end

    matches = self:ContainsItem(ts.firstaidItems, item)

    if matches then
        return "First Aid"
    end

    matches = self:ContainsItem(ts.fishingItems, item)

    if matches then
        return "Fishing"
    end

    matches = self:ContainsItem(ts.herbalismItems, item)

    if matches then
        return "Herbalism"
    end

    matches = self:ContainsItem(ts.leatherworkingItems, item)

    if matches then
        return "Leatherworking"
    end

    matches = self:ContainsItem(ts.miningItems, item)

    if matches then
        return "Mining"
    end

    matches = self:ContainsItem(ts.skinningItems, item)

    if matches then
        return "Skinning"
    end

    matches = self:ContainsItem(ts.tailoringItems, item)

    if matches then
        return "Tailoring"
    end

    return nil
end

function ts:ContainsItem(list, item)
    for index, value in ipairs(list) do 
        if (value == item) then
            return true
        end
    end

    return false
end