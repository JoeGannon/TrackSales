
TrackSales = LibStub("AceAddon-3.0"):NewAddon("TrackSales", "AceConsole-3.0", "AceHook-3.0")

function TrackSales:OnInitialize()	

	self:Hook("TakeInboxMoney", true)
	self:Hook("AutoLootMailItem", true)	

end

function TrackSales:TakeInboxMoney(...)
	
	self:Print("Take Money")

	local mailIndex  = ...

	local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(mailIndex);

	if invoiceType and invoiceType == "seller" then
		self:Print("invoiceType, itemName, playerName, bid, buyout, deposit, consignment - ", invoiceType, itemName, playerName, bid, buyout, deposit, consignment)
	else 

		local _, _, sender, subject, money = GetInboxHeaderInfo(mailIndex);

		self:Print(sender, subject, money)
	end
end 


function TrackSales:AutoLootMailItem(...)
	self:Print("Auto Loot Mail Item")
	self:TakeInboxMoney(...)
end 

function TrackSales:Debug(...)

  local prof1, prof2, sec1, sec2, sec3, sec4 = self:GetProfessionDetails()

  self:Print(prof1, prof2, sec1, sec2, sec3, sec4)
end 

function TrackSales:GetProfessionDetails()

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
		local name = GetProfessionInfo(index); 
		
		return name
	else 
		return nil
	end
end