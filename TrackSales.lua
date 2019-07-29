
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
	end
end 


function TrackSales:AutoLootMailItem(...)

	self:Print("Auto Loot Mail Item")
	self:TakeInboxMoney(...)
end 

function TrackSales:test(...)

	self:Print("test")	
	
end 