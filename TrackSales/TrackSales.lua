TrackSales = LibStub("AceAddon-3.0"):NewAddon("TrackSales", "AceConsole-3.0")

local _, ts = ...

function TrackSales:OnInitialize()				

	hooksecurefunc("TakeInboxMoney", function(...) TrackSales:TakeInboxMoney(...) end)
	hooksecurefunc("AutoLootMailItem", function(...) TrackSales:AutoLootMailItem(...) end)

	self:RegisterChatCommand("ts", "SlashCommands")
	self:RegisterChatCommand("tracksales", "SlashCommands")

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
	frame:RegisterEvent("TRADE_ACCEPT_UPDATE")	
	
	--todo this isn't efficient,
	--everything else I tried didn't work
	local function OnEvent(s, event, ...)
		if event == "TRADE_ACCEPT_UPDATE" then 
			self:TRADE_ACCEPT_UPDATE(...)
		elseif event == "LEARNED_SPELL_IN_TAB" then 
			self:LEARNED_SPELL_IN_TAB(...)
		end
	end

	frame:SetScript("OnEvent", OnEvent)
end

function TrackSales:OnEnable()	

	if not TrackSalesDB then		
		TrackSales.db:SetDefaults()
		self:Print("Welcome to TrackSales. To view sales run /ts or /tracksales. For more options run /ts help")	
	end
end

function TrackSales:TakeInboxMoney(mailId)	

	local invoiceType, itemName, _, bid = GetInboxInvoiceInfo(mailId)

	if invoiceType == "seller" then

		TrackSales.db:TrackSale(itemName, bid)
	else 

		local _, _, sender, subject, money = GetInboxHeaderInfo(mailId)	

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

function TrackSales:AutoLootMailItem(mailId)
	self:TakeInboxMoney(mailId)
end

--due to limitations of the client, https://wowwiki.fandom.com/wiki/Events/Trade#TRADE_ACCEPT_UPDATE
--it's not guaranteed TRADE_ACCEPT_UPDATE will fire with both Player and Target having "accepted"
--this is a hack in an attempt to not double count transactions through trade
local recordedTrades = { }

function TrackSales:TRADE_ACCEPT_UPDATE(...)
	local playerAccepted, _ = ...
	local gold = GetTargetTradeMoney()
	
	if playerAccepted == 1 and gold > 0 then

		local time = GetTime()
		local targetName = UnitName("target")

		for i, v in ipairs(recordedTrades) do
			if v.Target == targetName and v.Gold == gold and time - v.Time < 150 then 
				--assume transaction was already recorded
				return 
			end
		end		

		table.insert(recordedTrades, { Target = targetName, Gold = gold, Time = time })

		for i = 1, MAX_TRADE_ITEMS, 1 do 
			local itemName, _, _, _, _, _ = GetTradePlayerItemInfo(i)
		
			local matchedProfession = ts:MatchProfession(itemName)
			
			if matchedProfession and i ~= MAX_TRADE_ITEMS then
				TrackSales.db:AddGold(matchedProfession, gold)			
				return
			end

			if i == MAX_TRADE_ITEMS then				
				local _, _, _, _, _, enchantment = GetTradeTargetItemInfo(i)
				
				if enchantment then
					TrackSales.db:AddGold("Enchanting", gold)
				end
			end
		end
	end
end

local professions = {
	{ SpellId = 2259, Profession = "Alchemy" },
	{ SpellId = 2018, Profession = "Blacksmithing" },
	{ SpellId = 7411, Profession = "Enchanting" },
	{ SpellId = 4036, Profession = "Engineering" },
	{ SpellId = 2580, Profession = "Mining" },
	{ SpellId = 2383, Profession = "Herbalism" },
	{ SpellId = 2108, Profession = "Leatherworking" },
	{ SpellId = 3908, Profession = "Tailoring" },
	{ SpellId = 8613, Profession = "Skinning" },
	{ SpellId = 3273, Profession = "First Aid" },
	{ SpellId = 2550, Profession = "Cooking" },
	{ SpellId = 7620, Profession = "Fishing" }
}

function TrackSales:LEARNED_SPELL_IN_TAB(...)
	local spellId = ...
	for index, value in ipairs(professions) do 
        if value.SpellId == spellId then
			TrackSales.db:TryAddNewProfession(value.Profession)
        end
    end
end

function TrackSales:SlashCommands(args)
	local arg1, arg2, arg3, arg4 = TrackSales:GetArgs(args, 4)	
	
	ts:HandleCommand(arg1, arg2, arg3, arg4)	
end

function TrackSales:PrintMessage(text)		
	self:Print(text)
end