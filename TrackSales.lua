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

		TrackSales.db:TrackSale(itemName, bid)
	else 

		local _, _, sender, subject, money = GetInboxHeaderInfo(mailIndex)	

		--assume it's a COD
		if money > 0  then 

			local multiplesIndex = string.find(subject, "(", 1, true)

			local codPaymentPadding = 14
			
			if not multiplesIndex then 
				subject = string.sub(subject, codPaymentPadding)
			else 
				subject =  string.sub(subject, codPaymentPadding, multiplesIndex - 2)	
			end

			TrackSales.db:TrackSale(subject, money)
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

	--/ts p a Mining
	if (arg1 == "p" or arg1 == "profession") and ts:IsProfessionCommand(arg2) and arg3 then
		if ts:IsAddCommand(arg2) then
			TrackSales.db:TryAddNewProfession(arg3, true)
		end
		if ts:IsRemoveCommand(arg2) then			
			TrackSales.db:RemoveProfession(arg3)
		end
		return 
	end

	--/ts d h Fishing
	if (arg1 == "d" or arg1 == "display") and ts:IsDisplayCommand(arg2) and arg3 then
		
		if ts:IsHideCommand(arg2) then			
			TrackSales.db:RemoveProfession(arg3, true)
		end

		if ts:IsShowCommand(arg2) then			
			TrackSales.db:ShowProfession(arg3)
		end

		return
	end	

	--/ts c 1 a 705025
	if self:IsValidConfigCommand(args) then		
		local profession = TrackSales.db:GetProfessionByIndex(arg2)		
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

function TrackSales:IsValidConfigCommand(args)
	
	local option, arg2, arg3, arg4 = TrackSales:GetArgs(args, 4)

	local maxIndex = TrackSales.db:MaxIndex()
	local idx = tonumber(arg2)
	local gold = tonumber(arg4)
 
	if not ts:IsConfigCommand(option)  then
		self:Print("Invalid Command!")
		self:Print(option, arg2, arg3, arg4)
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
	
	local isEmpty = true
	
	for index, value in ipairs(TrackSalesDB.Professions) do 
		isEmpty = false
		local coinTexture = GetCoinTextureString(value.GoldMade)
		
		if value.IsVisible then 
			self:Print(value.Name.."       "..coinTexture)
		end
	end	

	if isEmpty then 
		self:Print("You haven't learned any professions. Go learn some or enter \"/ts help\" for more info")	
	end
end

function TrackSales:PrintIndexes()
		
	local isEmpty = true

	for index, value in ipairs(TrackSalesDB.Professions) do 
		self:Print(tostring(index).."  "..value.Name)
		isEmpty = false
	end

	if isEmpty then 
		self:Print("You haven't learned any professions. Go learn some or enter \"/ts help\" for more info")		
	end
end
