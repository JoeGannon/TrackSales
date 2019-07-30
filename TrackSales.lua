TrackSales = LibStub("AceAddon-3.0"):NewAddon("TrackSales", "AceConsole-3.0", "AceHook-3.0")

local _, ts = ...

function TrackSales:OnInitialize()		

	self:SecureHook("TakeInboxMoney")
	self:SecureHook("AutoLootMailItem")

	if not TrackSalesDB then
		self:Print("is null")
		TrackSales.Database:SetDefaults()
	else 
		self:Print("is not null")
	end 	

	TrackSales:RegisterChatCommand("ts", "SlashCommands")
end

function TrackSales:TakeInboxMoney(...)
	local mailIndex  = ...

	local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(mailIndex)

	if invoiceType and invoiceType == "seller" then

		TrackSales.Database:AddGold("Mining", bid)
	else 

		local _, _, sender, subject, money = GetInboxHeaderInfo(mailIndex)

		--assume it's a COD
		if money > 0  then 
			self:Print(sender, subject, money)
		end
	end
end 

function TrackSales:AutoLootMailItem(...)
	self:TakeInboxMoney(...)
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

	--/ts c 1 a 705025
	if self:IsValidCommand(args) then		
		local profession = TrackSales.Database:FindProfession(arg2)		
		local cmd = arg3
		local gold = arg4

		if TrackSales.Helpers.IsAddCommand(cmd) then 			

			TrackSales.Database:AddGold(profession, gold)
			self:Print("Added "..GetCoinTextureString(gold).." to "..profession)		
		end

		if TrackSales.Helpers.IsSubtractCommand(cmd) then 			
		
			TrackSales.Database:SubtractGold(profession, gold)
			self:Print("Subtracted "..GetCoinTextureString(gold).." from "..profession)
		end		

		if TrackSales.Helpers.IsSetCommand(cmd) then 			
		
			TrackSales.Database:SetGold(profession, gold)
			self:Print("Set "..profession.." to "..GetCoinTextureString(gold))
		end		

		return 
	end
end

function TrackSales:IsValidCommand(args)
	
	local option, arg2, arg3, arg4 = TrackSales:GetArgs(args, 4)

	local maxIndex = TrackSales.Database:MaxIndex()
	local idx = tonumber(arg2)	
	local gold = tonumber(arg4)
 
	if not TrackSales.Helpers.IsConfigCommand(option)  then
		self:Print("Invalid option! Did you mean config (c)?")
		return false
	end 

	if (not (idx and gold) or idx < 1 or idx > maxIndex) then 
		self:Print("Invalid index or gold amount!")
		return false
	end

	if not (arg3 and (TrackSales.Helpers.IsAddCommand(arg3) or TrackSales.Helpers.IsSubtractCommand(arg3) or TrackSales.Helpers.IsSetCommand(arg3))) then
		self:Print("Invalid Operation! Only add (a), subtract (s), and set are supported")
		return false
	end	

	return true
end

function TrackSales:PrintSales()
	for index, value in ipairs(TrackSalesDB.Professions) do 
	    local coinTexture = GetCoinTextureString(value.GoldMade)
		self:Print(value.Name.."       "..coinTexture)
	end
end

function TrackSales:PrintIndexes()
	for index, value in ipairs(TrackSalesDB.Professions) do 
		self:Print(tostring(index).."  "..value.Name)
	end
end