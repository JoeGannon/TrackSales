
local _, ts = ...

function ts:HandleCommand(...)

    local arg1, arg2, arg3, arg4 = ...
    
    --/ts
	if not arg1 or arg1 == "a" then		
		if arg1 == "a" then 
			self:PrintSales(true)
		else 
			self:PrintSales()
		end
		return 
    end	
    
    --/ts help
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
	
	--/ts d o 321
	--/ts d Fishing h
	if ts:IsDisplayCommand(arg1, arg3) or ts:IsOrderCommand(arg2) then		

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

		if ts:IsOrderCommand(arg2) then			

			if not tonumber(arg3) then
				TrackSales:PrintMessage(TrackSales, "Invalid argument!")
				TrackSales:PrintMessage(TrackSales, "Must pass Indexes ie 4321")
			return 	
			end			

			local  ordered = TrackSales.db:OrderProfessions(arg3)

			if ordered then
				TrackSales:PrintMessage("New Order:")
				self:PrintSales()
			end
			return 
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
	if self:IsValidConfigCommand(arg1, arg2, arg3, arg4) then		
		
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
			TrackSales:PrintMessage("Added "..GetCoinTextureString(gold).." to "..name)		
		end

		if ts:IsSubtractCommand(cmd) then 			
		
			TrackSales.db:SubtractGold(name, gold)
			TrackSales:PrintMessage("Subtracted "..GetCoinTextureString(gold).." from "..name)
		end		

		if ts:IsSetCommand(cmd) then 			
		
			TrackSales.db:SetGold(name, gold)
			TrackSales:PrintMessage("Set "..name.." to "..GetCoinTextureString(gold))
		end		

		return 
	end
end

function ts:IsValidConfigCommand(...)
	
	local option, arg2, arg3, arg4 = ...
	
	local maxIndex = TrackSales.db:MaxIndex()

	local idx = tonumber(arg2)
	local gold = tonumber(arg4)
 
	if not ts:IsBalanceCommand(option) or not gold  then
		TrackSales:PrintMessage("Invalid Command!")
		TrackSales:PrintMessage(option, arg2, arg3, arg4)
		return false
	end 

	arg2 = TrackSales.db:ConsoleHack(arg2)

	local profession = TrackSales.db:FindTrackedProfession(arg2)	
	
	if (not (idx and gold) or idx < 1 or idx > maxIndex) and not profession then 
		TrackSales:PrintMessage("Invalid profession or gold amount!")
		return false
	end	

	if not (arg3 and (ts:IsAddCommand(arg3) or ts:IsSubtractCommand(arg3) or ts:IsSetCommand(arg3))) then
		TrackSales:PrintMessage("Invalid Operation! Only add (a), subtract (s), and set are supported")
		return false
	end		

	return true
end

function ts:PrintSales(showHidden)		
	local isEmpty = true
	
	for index, value in ipairs(TrackSalesDB.Professions) do 
		isEmpty = false
		local coinTexture = GetCoinTextureString(value.GoldMade)	
		
		if showHidden or value.IsVisible then 
			TrackSales:PrintMessage(value.Name.."       "..coinTexture)
		end		
	end	

	if isEmpty then 
		TrackSales:PrintMessage("You haven't learned any professions. Go learn some or enter /ts help for more info")	
	end
end

function ts:PrintHelp()
	TrackSales:PrintMessage("Available Commands:")
	TrackSales:PrintMessage("     balance     - modify gold for professions")
	TrackSales:PrintMessage("     display      - modify sales report")
	TrackSales:PrintMessage("     track         - modify tracked professions")
	TrackSales:PrintMessage("")
	TrackSales:PrintMessage("Enter a command to see its options")
	TrackSales:PrintMessage("All commands and arguments can be abbreviated to the first character")
	TrackSales:PrintMessage("Run /ts or /tracksales to view sales (/ts a to show hidden professions)")
end

function ts:PrintBalanceHelp()
	TrackSales:PrintMessage("Args:")
	TrackSales:PrintMessage("    /ts balance {Profession} {Operation} {GoldAmount}")		
	TrackSales:PrintMessage("Operation:")
	TrackSales:PrintMessage("    add")
	TrackSales:PrintMessage("    subtract")
	TrackSales:PrintMessage("    set (can't be abbreviated)")
	TrackSales:PrintMessage("")
	TrackSales:PrintMessage("Examples:")
	TrackSales:PrintMessage("    /ts balance Fishing add 20000  (Add 2 gold to Fishing)")			
	TrackSales:PrintMessage("    /ts balance Fishing s 20000  (Subtract 2 gold from Fishing)")		
	TrackSales:PrintMessage("    /ts balance Fishing set 100000  (Set Fishing to 10 gold)")	
end

function ts:PrintDisplayHelp()
	TrackSales:PrintMessage("Args:")
	TrackSales:PrintMessage("    /ts display {Profession} {Operation}")		
	TrackSales:PrintMessage("Operation:")
	TrackSales:PrintMessage("    show")
	TrackSales:PrintMessage("    hide")			
	TrackSales:PrintMessage("Examples:")
	TrackSales:PrintMessage("    /ts display Cooking hide  (Hide cooking but continue to track)")			
	TrackSales:PrintMessage("    /ts display Cooking show  (Show cooking)")			
	TrackSales:PrintMessage("")
	TrackSales:PrintMessage("Args:")
	TrackSales:PrintMessage("    /ts display order {NewOrder}")		
	TrackSales:PrintMessage("Examples (assuming 4 professions are tracked):")
	TrackSales:PrintMessage("    /ts display order 2134 (Swap the order of the first two elements)")
	TrackSales:PrintMessage("    /ts display order 4321 (Reverse the order)")
	TrackSales:PrintMessage("    /ts display order 1234 (Keep order the same)")
end

function ts:PrintTrackHelp()
	TrackSales:PrintMessage("Args:")
	TrackSales:PrintMessage("    /ts track {Profession} {Operation}")		
	TrackSales:PrintMessage("Operation:")
	TrackSales:PrintMessage("    add")
	TrackSales:PrintMessage("    remove")
	TrackSales:PrintMessage("Examples:")
	TrackSales:PrintMessage("    /ts track Mining add (Track mining)")			
	TrackSales:PrintMessage("    /ts track Mining remove  (Stop tracking mining)")			
end