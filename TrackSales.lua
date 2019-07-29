
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

	return prof1Name, prof2Name, sec1Name, sec2Name, sec3Name, sec4Name
end

function TrackSales:GetProfessionName(index)
	if (index) then
		local name = GetProfessionInfo(index)
		
		return name
	else 
		return nil
	end
end

function TrackSales:SetDefaults()
	local prof1, prof2, sec1, sec2, sec3, sec4 = self:LookupProfessions()

	local people = {
		Professions = {	}	 
	 }

	 people.Professions = {
		{
			name = "Fred",
			address = "16 Long Street",
			phone = "123456"
	   }
	  
		--  {
		-- 	name = "Wilma",
		-- 	address = "16 Long Street",
		-- 	phone = "123456"
		--  },
	  
		--  {
		-- 	name = "Barney",
		-- 	address = "17 Long Street",
		-- 	phone = "123457"
		--  } 	
		
	 }

	 local wilma = {
		name = "Wilma",
		address = "16 Long Street",
		phone = "123456"
	 }

	 table.insert(people.Professions, wilma)

	for index, value in ipairs(people.Professions) do 
		self:Print(tostring(index).." : "..value.name)
	end

end