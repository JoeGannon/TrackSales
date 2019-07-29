
TrackSales = LibStub("AceAddon-3.0"):NewAddon("TrackSales", "AceConsole-3.0", "AceHook-3.0")

function TrackSales:OnInitialize()	

	self:SecureHook("TakeInboxMoney")
	self:SecureHook("AutoLootMailItem")

	if not TrackSalesDB then
		self:Print("is null")
		self:SetDefaults()
	else 
		self:Print("is not null")
	end 

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

function TrackSales:PrintSales()
	for index, value in ipairs(TrackSalesDB.Professions) do 
	    local coinTexture = GetCoinTextureString(value.GoldMade)
		self:Print(value.Name.."       "..coinTexture..tostring(value.IsPrimary))
	end
end