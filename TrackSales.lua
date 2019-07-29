
TrackSales = LibStub("AceAddon-3.0"):NewAddon("TrackSales", "AceConsole-3.0", "AceHook-3.0")

function TrackSales:OnInitialize()	

	TrackSales:RegisterChatCommand("ts", "SlashCommands")

	self:SecureHook("TakeInboxMoney")
	self:SecureHook("AutoLootMailItem")

	if not TrackSalesDB then
		self:Print("is null")
		self:SetDefaults()
	else 
		self:Print("is not null")
	end 

end

function TrackSales:SlashCommands(args)

	local arg1, arg2, arg3, arg4 = TrackSales:GetArgs(args, 4)

	--/ts
	if not arg1 then
		self:PrintSales()
		return 
	end

	--/ts c
	if (arg1 == "c" or arg1 == "config") and not arg2 then
		self:PrintIndexes()
		return 
	end

	if self:IsValidCommand(args) then
		local profession = self:FindProfession(arg2)
		self:Print(arg3.."'ing' "..GetCoinTextureString(arg4).." to "..profession)
		return 
	end
end

function TrackSales:IsValidCommand(args)
	
	local option, arg2, arg3, arg4 = TrackSales:GetArgs(args, 4)

	local maxIndex = self:MaxIndex()
	local idx = tonumber(arg2)	
	local gold = tonumber(arg4)

	if not (option == "c" or option == "config")  then
		self:Print("Invalid option! Did you mean config (c)?")
		return false
	end 

	if not (idx and gold) then 
		self:Print("Invalid index or gold amount!")
		return false
	end

	if not (arg3 and (arg3 == "a" or arg3 == "add" or arg3 == "s" or arg3 == "subtract" or arg3 == "set")) then
		self:Print("Invalid Operation! Only add (a), subtract (s), and set are supported")
		return false
	end	

	return true
end

function TrackSales:TakeInboxMoney(...)
	
	self:Print("Take Money")

	local mailIndex  = ...

	local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(mailIndex)

	if invoiceType and invoiceType == "seller" then
		self:Print("invoiceType, itemName, playerName, bid, buyout, deposit, consignment - ", invoiceType, itemName, playerName, bid, buyout, deposit, consignment)
	else 

		local _, _, sender, subject, money = GetInboxHeaderInfo(mailIndex)

		self:Print(sender, subject, money)
	end
end 

function TrackSales:AutoLootMailItem(...)
	self:Print("Auto Loot Mail Item")
	self:TakeInboxMoney(...)
end 

function TrackSales:AddGold(profession, gold)

	for index, value in ipairs(TrackSalesDB.Professions) do 
		 if value.Name == profession then
			value.GoldMade = value.GoldMade + gold
			return
		 end
	end

	self:Print("Profession Not Found "..profession)
end

function TrackSales:SubtractGold(profession, gold)

	self:AddGold(profession, -gold)
end

function TrackSales:SetGold(profession, gold)

	for index, value in ipairs(TrackSalesDB.Professions) do 
		if value.Name == profession then
		   value.GoldMade = gold
		   return
		end
   end

   self:Print("Profession Not Found "..profession)
end

function TrackSales:CV(...)

	TrackSalesDB = nil

end 

function TrackSales:SetDefaults()
	
	local professions = self:LookupProfessions()

	TrackSalesDB = {
		Professions = {	}	 
	 }

	for index, value in ipairs(professions) do 
		if value.Name then
			table.insert(TrackSalesDB.Professions, value)
		end
	end

end

function TrackSales:LookupProfessions()

	--todo check how many items classic returns
	local prof1, prof2, sec1, sec2, sec3, sec4 = GetProfessions()	
	
	local prof1Name = self:GetProfessionName(prof1)
	local prof2Name = self:GetProfessionName(prof2)
	local sec1Name = self:GetProfessionName(sec1)
	local sec2Name = self:GetProfessionName(sec2)
	local sec3Name = self:GetProfessionName(sec3)
	local sec4Name = self:GetProfessionName(sec4)

	return {
		{ Name = prof1Name, GoldMade = 0, IsPrimary = true },
		{ Name = prof2Name, GoldMade = 0, IsPrimary = true },
		{ Name = sec1Name,  GoldMade = 0, IsPrimary = false },
		{ Name = sec2Name,  GoldMade = 0, IsPrimary = false },
		{ Name = sec3Name,  GoldMade = 0, IsPrimary = false },
		{ Name = sec4Name,  GoldMade = 0, IsPrimary = false },
	}
end

function TrackSales:GetProfessionName(index)
	if (index) then
		local name = GetProfessionInfo(index)
		
		return name
	else 
		return nil
	end
end

function TrackSales:FindProfession(idx)
	local val = ""
	
	for index, value in ipairs(TrackSalesDB.Professions) do 
	   if (index == tonumber(idx)) then
			val = value.Name
	   end
	end

	return val
end

function TrackSales:PrintSales()
	for index, value in ipairs(TrackSalesDB.Professions) do 
	    local coinTexture = GetCoinTextureString(value.GoldMade)
		self:Print(value.Name.."       "..coinTexture..tostring(value.IsPrimary))
	end
end

function TrackSales:PrintIndexes()
	for index, value in ipairs(TrackSalesDB.Professions) do 
		self:Print(tostring(index).."  "..value.Name)
	end
end

function TrackSales:MaxIndex()	
	local i = 0
	for index, value in ipairs(TrackSalesDB.Professions) do 
		i = i + 1
	end
	return i
end