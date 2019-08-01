TrackSales = LibStub("AceAddon-3.0"):NewAddon("TrackSales", "AceConsole-3.0", "AceHook-3.0")

local _, ts = ...

function TrackSales:OnInitialize()				

	self:SecureHook("TakeInboxMoney")
	self:SecureHook("AutoLootMailItem")

	TrackSales:RegisterChatCommand("ts", "SlashCommands")
	TrackSales:RegisterChatCommand("tracksales", "SlashCommands")

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("LEARNED_SPELL_IN_TAB")	
	frame:SetScript("OnEvent", function(this, event, ...)
		TrackSales[event](TrackSales, ...) end)
end

function TrackSales:OnEnable()	
	if not TrackSalesDB then		
		TrackSales.db:SetDefaults()
		self:Print("Welcome to TrackSales. To view sales run /ts. For more options run /ts help")	
	end
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
	if not arg1 or arg1 == "a" then		
		if arg1 == "a" then 
			self:PrintSales(true)
		else 
			self:PrintSales()
		end
		return 
	end	

	if ts:IsHelpCommand(arg1) then 		
		self:PrintHelp()
		return
	end	
	
	--/ts t Mining a
	if ts:IsTrackCommand(arg1, arg3) then		

		if ts:IsHelpCommand(arg2) then
			self:PrintTrackHelp()					
			return 
		end
		
		if ts:IsAddCommand(arg3) then
			TrackSales.db:TryAddNewProfession(arg2, true)
		end
		if ts:IsRemoveCommand(arg3) then			
			TrackSales.db:RemoveProfession(arg2)
		end
		return 
	end
	
	--/ts d Fishing h
	if ts:IsDisplayCommand(arg1, arg3) then

		if (ts:IsHelpCommand(arg2)) then			
			self:PrintDisplayHelp()
			return 
		end
		
		if ts:IsHideCommand(arg3) then			
			TrackSales.db:HideProfession(arg2)
		end

		if ts:IsShowCommand(arg3) then			
			TrackSales.db:ShowProfession(arg2)
		end

		if ts:IsOrderCommand(arg3) then			

			if not tonumber(arg3) then
				self:Print("Invalid argument!")
				self:Print("Must pass Indexes  ie 4321")
			return 	
			end			

			TrackSales.db:OrderProfessions(arg3)
			self:Print("New Order:")
			self:PrintSales()
		end

		return
	end	

	--/ts b
	if ts:IsBalanceCommand(arg1) and ts:IsHelpCommand(arg2) then	
		self:PrintBalanceHelp()
		return 
	end

	--/ts b 1 a 705025
	--/ts b Fishing a 705025
	if self:IsValidConfigCommand(args) then	
		
		local option, arg2, arg3, arg4 = TrackSales:GetArgs(args, 4)		
		
		arg2 = TrackSales.db:ConsoleHack(arg2)

		local profession = TrackSales.db:FindTrackedProfession(arg2)		
		
		if not profession then 
		 	profession = TrackSales.db:GetProfessionByIndex(arg2)		
		end

		local name = profession.Name

		local cmd = arg3
		local gold = arg4		

		if tonumber(gold) < 0 then
			gold = 0
		end		

		if ts:IsAddCommand(cmd) then 			

			TrackSales.db:AddGold(name, gold)
			self:Print("Added "..GetCoinTextureString(gold).." to "..name)		
		end

		if ts:IsSubtractCommand(cmd) then 			
		
			TrackSales.db:SubtractGold(name, gold)
			self:Print("Subtracted "..GetCoinTextureString(gold).." from "..name)
		end		

		if ts:IsSetCommand(cmd) then 			
		
			TrackSales.db:SetGold(name, gold)
			self:Print("Set "..name.." to "..GetCoinTextureString(gold))
		end		

		return 
	end
end

function TrackSales:IsValidConfigCommand(args)
	
	local option, arg2, arg3, arg4 = TrackSales:GetArgs(args, 4)	
	
	local maxIndex = TrackSales.db:MaxIndex()

	local idx = tonumber(arg2)
	local gold = tonumber(arg4)
 
	if not ts:IsBalanceCommand(option) or not gold  then
		self:Print("Invalid Command!")
		self:Print(option, arg2, arg3, arg4)
		return false
	end 

	arg2 = TrackSales.db:ConsoleHack(arg2)

	local profession = TrackSales.db:FindTrackedProfession(arg2)	
	
	if (not (idx and gold) or idx < 1 or idx > maxIndex) and not profession then 
		self:Print("Invalid profession or gold amount!")
		return false
	end	

	if not (arg3 and (ts:IsAddCommand(arg3) or ts:IsSubtractCommand(arg3) or ts:IsSetCommand(arg3))) then
		self:Print("Invalid Operation! Only add (a), subtract (s), and set are supported")
		return false
	end		

	return true
end

function TrackSales:PrintSales(showHidden)	
	
	local isEmpty = true
	
	for index, value in ipairs(TrackSalesDB.Professions) do 
		isEmpty = false
		local coinTexture = GetCoinTextureString(value.GoldMade)	
		
		if showHidden or value.IsVisible then 
			self:Print(value.Name.."       "..coinTexture)
		end
		
	end	

	if isEmpty then 
		self:Print("You haven't learned any professions. Go learn some or enter /ts help for more info")	
	end
end

function TrackSales:PrintIndexes()
		
	local isEmpty = true

	for index, value in ipairs(TrackSalesDB.Professions) do 
		self:Print(tostring(index).."  "..value.Name)
		isEmpty = false
	end

	if isEmpty then 
		self:Print("You haven't learned any professions. Go learn some or enter /ts help for more info")		
	end
end

function TrackSales:PrintHelp()
	self:Print("Available Commands:")
	self:Print("     balance     - modify gold for professions")
	self:Print("     display      - modify sales report")
	self:Print("     track          - modify tracked professions")
	self:Print("")
	self:Print("Enter a command to see its options")
	self:Print("All commands and arguments can be abbreviated to the first character")
	self:Print("Run /ts to view sales (/ts a to show hidden professions)")
end

function TrackSales:PrintBalanceHelp()
	self:Print("Args:")
	self:Print("    /ts balance {Profession} {Operation} {GoldAmount}")		
	self:Print("Operation:")
	self:Print("    add")
	self:Print("    subtract")
	self:Print("    set (can't be abbreviated)")
	self:Print("")
	self:Print("Examples:")
	self:Print("    /ts balance Fishing add 20000  (Add 2 gold to Fishing)")			
	self:Print("    /ts b Fishing s 20000  (Subtract 2 gold from Fishing)")		
	self:Print("    /ts b Fishing set 100000  (Set Fishing to 10 gold)")	
end

function TrackSales:PrintDisplayHelp()
	self:Print("Args:")
	self:Print("    /ts display {Profession} {Operation}")		
	self:Print("Operation:")
	self:Print("    show")
	self:Print("    hide")			
	self:Print("Examples:")
	self:Print("    /ts display Cooking hide  (Hide cooking but continue to track)")			
	self:Print("    /ts display Cooking show  (Show cooking)")			
	self:Print("")
	self:Print("Args:")
	self:Print("    /ts display order {NewOrder}")		
	self:Print("Examples (assuming 4 professions are tracked):")
	self:Print("    /ts d Cooking order 2134 (Swap the order of the first two elements)")
	self:Print("    /ts d Cooking order 4321 (Reverse the order)")
	self:Print("    /ts d Cooking order 1234 (Keep order the same)")
end

function TrackSales:PrintTrackHelp()
	self:Print("Args:")
	self:Print("    /ts track {Profession} {Operation}")		
	self:Print("Operation:")
	self:Print("    add")
	self:Print("    remove")
	self:Print("Examples:")
	self:Print("    /ts track Mining add (Track mining)")			
	self:Print("    /ts t Mining r  (Stop tracking mining)")			
end