
TrackSales = LibStub("AceAddon-3.0"):NewAddon("TrackSales", "AceConsole-3.0", "AceHook-3.0")

function TrackSales:OnInitialize()	

	self:Hook("TakeInboxMoney", true)
	self:Hook("AutoLootMailItem", true)

	if not TrackSalesDB then
		self:Print("is null")

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

function TrackSales:Debug(var)

	TrackSalesDB = var

  local prof1, prof2, sec1, sec2, sec3, sec4 = self:LookupProfessions()
  
  self:Print(prof1, prof2, sec1, sec2, sec3, sec4)
end 

function TrackSales:CV(...)

	TrackSalesDB = nil

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
		{ Name = prof1Name, IsPrimary = true },
		{ Name = prof2Name, IsPrimary = true },
		{ Name = sec1Name, IsPrimary = false },
		{ Name = sec2Name, IsPrimary = false },
		{ Name = sec3Name, IsPrimary = false },
		{ Name = sec4Name, IsPrimary = false },
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

function TrackSales:PrintMoney()
	local res = GetCoinTextureString(10000)

local res2 = GetCoinTextureString(500050)

local res3 = GetCoinTextureString(123456)

	self:Print(res)
	self:Print(res2)
	self:Print(res3)
end

function TrackSales:SetDefaults()
	local professions = self:LookupProfessions()

	local db = {
		Professions = {	}	 
	 }

	for index, value in ipairs(professions) do 
		if value.Name then
			table.insert(db.Professions, value)
		end
	end

	for index, value in ipairs(db.Professions) do 
		self:Print(tostring(index).." : "..value.Name.." "..tostring(value.IsPrimary))
	end

end