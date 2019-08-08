TrackSales = LibStub("AceAddon-3.0"):NewAddon("TrackSales", "AceConsole-3.0", "AceHook-3.0")

local _, ts = ...

function TrackSales:OnInitialize()				

	self:SecureHook("TakeInboxMoney")
	self:SecureHook("AutoLootMailItem")	

	TrackSales:RegisterChatCommand("ts", "SlashCommands")
	TrackSales:RegisterChatCommand("tracksales", "SlashCommands")

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
	frame:RegisterEvent("TRADE_ACCEPT_UPDATE")	
	frame:SetScript("OnEvent", function(this, event, ...)
		TrackSales[event](TrackSales, ...) end)
end

function TrackSales:OnEnable()	

	if not TrackSalesDB then		
		TrackSales.db:SetDefaults()
		self:Print("Welcome to TrackSales. To view sales run /ts or /tracksales. For more options run /ts help")	
	end
end

function TrackSales:TakeInboxMoney(...)
	local mailIndex  = ...

	local invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(mailIndex)

	if invoiceType and invoiceType == "seller" then
		self:Print(itemName)
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

--due to limitations of the client, https://wowwiki.fandom.com/wiki/Events/Trade#TRADE_ACCEPT_UPDATE
--it's not guaranteed TRADE_ACCEPT_UPDATE will fire with both Player and Target having "accepted"
--this is a hack in an attempt to not double count transactions through trade
local recordedTrades = { }

function TrackSales:TRADE_ACCEPT_UPDATE(...)
	local playerAccepted, _ = ...
	local gold = GetTargetTradeMoney()
	
	if playerAccepted == 1 and gold > 0 then

		self:Print("accepted")

		local time = GetTime()
		local targetName = UnitName("target")
	
		for i, v in ipairs(recordedTrades) do
			if v.Target == targetName and v.Gold == gold and time - v.Time < 150 then 
				--assume transaction was already recorded
				self:Print("Recorded")
				return 
			end
		end		

		table.insert(recordedTrades, { Target = targetName, Gold = gold, Time = time })

		for i = 1, MAX_TRADE_ITEMS, 1 do 
			
			local itemName, _, _, _, _, enchantment = GetTradePlayerItemInfo(i)

			local matchedProfession = TrackSales.db:MatchProfession(itemName)
			
			if matchedProfession and i ~= MAX_TRADE_ITEMS then
				TrackSales.db:AddGold(matchedProfession, gold)				 				
				return
			end

			if i == MAX_TRADE_ITEMS then

				if enchantment then 
					self:Print("Adding Enchanting")
					TrackSales.db:AddGold("Enchanting", gold)
				end
			end
		end
	end
end

function TrackSales:LEARNED_SPELL_IN_TAB(...)
	local spellId = ...

	local skillName = GetSpellInfo(spellId)	

	TrackSales.db:TryAddNewProfession(skillName)	
end

function TrackSales:SlashCommands(args)
	local arg1, arg2, arg3, arg4 = TrackSales:GetArgs(args, 4)	
	
	ts:HandleCommand(arg1, arg2, arg3, arg4)	
end

function TrackSales:PrintMessage(text)		
	self:Print(text)
end