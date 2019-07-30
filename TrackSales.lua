TrackSales = LibStub("AceAddon-3.0"):NewAddon("TrackSales", "AceConsole-3.0", "AceHook-3.0")

local _, ts = ...

function TrackSales:OnInitialize()			

	if not TrackSalesDB then
		self:Print("is null")
		TrackSales.db:SetDefaults()
	else 
		self:Print("is not null")
	end 	

	self:SecureHook("TakeInboxMoney")
	self:SecureHook("AutoLootMailItem")

	TrackSales:RegisterChatCommand("ts", "SlashCommands")
	TrackSales:RegisterChatCommand("tracksales", "SlashCommands")

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("LEARNED_SPELL_IN_TAB")	
	frame:SetScript("OnEvent", function(this, event, ...)
		TrackSales[event](TrackSales, ...) end)
end

function TrackSales:TakeInboxMoney(...)
	local mailIndex  = ...

	local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(mailIndex)

	if invoiceType and invoiceType == "seller" then

		TrackSales.db:AddGold("Mining", bid)
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

function TrackSales:LEARNED_SPELL_IN_TAB(...)
	local spellId = ...

	local skillName = GetSpellInfo(spellId)	

	TrackSales.db:TryAddNewProfession(skillName)	
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
		local profession = TrackSales.db:FindProfession(arg2)		
		local cmd = arg3
		local gold = arg4

		if tonumber(gold) < 0 then
			gold = 0
		end

		if ts:IsAddCommand(cmd) then 			

			TrackSales.db:AddGold(profession, gold)
			self:Print("Added "..GetCoinTextureString(gold).." to "..profession)		
		end

		if ts:IsSubtractCommand(cmd) then 			
		
			TrackSales.db:SubtractGold(profession, gold)
			self:Print("Subtracted "..GetCoinTextureString(gold).." from "..profession)
		end		

		if ts:IsSetCommand(cmd) then 			
		
			TrackSales.db:SetGold(profession, gold)
			self:Print("Set "..profession.." to "..GetCoinTextureString(gold))
		end		

		return 
	end
end

function TrackSales:IsValidCommand(args)
	
	local option, arg2, arg3, arg4 = TrackSales:GetArgs(args, 4)

	local maxIndex = TrackSales.db:MaxIndex()
	local idx = tonumber(arg2)
	local gold = tonumber(arg4)
 
	if not ts:IsConfigCommand(option)  then
		self:Print("Invalid option! Did you mean config (c)?")
		return false
	end 

	if (not (idx and gold) or idx < 1 or idx > maxIndex) then 
		self:Print("Invalid index or gold amount!")
		return false
	end

	if not (arg3 and (ts:IsAddCommand(arg3) or ts:IsSubtractCommand(arg3) or ts:IsSetCommand(arg3))) then
		self:Print("Invalid Operation! Only add (a), subtract (s), and set are supported")
		return false
	end	

	return true
end

function TrackSales:PrintSales()	
	
	if TrackSalesDB and TrackSalesDB.Professions then 
		for index, value in ipairs(TrackSalesDB.Professions) do 
			local coinTexture = GetCoinTextureString(value.GoldMade)
			self:Print(value.Name.."       "..coinTexture)
		end
		return
	end

	self:Print("You have no professions learned. Go learn some or add them via [insert command]")	
end

function TrackSales:PrintIndexes()
	if TrackSalesDB and TrackSalesDB.Professions then 
		for index, value in ipairs(TrackSalesDB.Professions) do 
			self:Print(tostring(index).."  "..value.Name)
		end
	return 
	end

	self:Print("You have no professions learned. Go learn some or add them via [insert command]")
end
