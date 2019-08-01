TrackSales.db = TrackSales:NewModule("DB", "AceConsole-3.0")

local _, ts = ...

function TrackSales.db:TrackSale(item, gold)

	local matchedProfession = ts:MatchProfession(item)

	self:AddGold(matchedProfession, gold)
end

function TrackSales.db:AddGold(profession, gold)

	local prof = self:FindTrackedProfession(profession)

	if prof then
		local goldMade = prof.GoldMade + gold

		--things get weird when the value is set to negative
		if goldMade < 0 then 
			prof.GoldMade = 0
		else 
			prof.GoldMade = goldMade
		end

		return
	end

	self:Print("Profession Not Found "..profession)
end

function TrackSales.db:SubtractGold(profession, gold)
	
	self:AddGold(profession, -gold)
end

function TrackSales.db:SetGold(profession, gold)

	local prof = self:FindTrackedProfession(profession)

	if prof then 
		prof.GoldMade = gold
		return 
	end

   self:Print("Profession Not Found "..profession)
end

local professions = {
	"Alchemy",
	"Blacksmithing",
	"Enchanting",
	"Engineering",
	"Herbalism Skills",
	"Leatherworking",
	"Mining Skills",
	"Skinning",
	"Tailoring",
	"Cooking",
	"First Aid",
	"Fishing"
}

function TrackSales.db:TryAddNewProfession(profession, log)

	local arg = profession:gsub("^%l", string.upper)
	
	local prof = self:FindTrackedProfession(arg)

	if prof and prof.Name == arg then 
		return 
	end	

	profession = self:ConsoleHack(profession, true)

	for index, value in ipairs(professions) do
		if value == profession then			

			if (string.match(profession, "Skills")) then			
				profession = string.sub(profession, 0, string.len(profession) - 7)				
			end

			local prof = { 
					Name = profession,
					GoldMade = 0,
					IsVisible = true 
				}
			
			table.insert(TrackSalesDB.Professions, prof)

			self:Print("Now tracking "..prof.Name)
			return
		end	
	end	

	if log then
		self:Print("Profession not found "..profession)
	end
end

function TrackSales.db:RemoveProfession(profession)	
	 
	profession = self:ConsoleHack(profession) 		

	for index, value in ipairs(TrackSalesDB.Professions) do
		if (value.Name == profession) then 
			table.remove(TrackSalesDB.Professions, index)
			self:Print(profession.." removed")
			return
		end
	end

	self:Print("Profession not found "..profession)
end

function TrackSales.db:ShowProfession(profession)	
	 
	profession = self:ConsoleHack(profession) 

	local prof = self:FindTrackedProfession(profession)

	if prof then 
		prof.IsVisible = true
		self:Print(profession.." is now shown")
		return
	end

	self:Print("Profession not found "..profession)
end

function TrackSales.db:HideProfession(profession)	
	 
	profession = self:ConsoleHack(profession) 

	local prof = self:FindTrackedProfession(profession)
	 
	 if prof then		
		prof.IsVisible = false
		self:Print(profession.." is now hidden")
		return		
	 end

	self:Print("Profession not found "..profession)
end

function TrackSales.db:OrderProfessions(order)

	local items = 0;
	local indexes = { }
	local hasDupes = false			
 	local test = false
	order:gsub(".", function(idx)
		items = items + 1
		local dupes = ts:ContainsItem(indexes, idx)		
		
		table.insert(indexes, idx)	
		
		if dupes then 			
			hasDupes = true
			return
		end		
	end)	
	
	local visibleProfs = self:MaxIndex(true)

	if hasDupes then 
		self:Print("Found duplicate Indexes! Must specify each index once")
		return
	end
	if items > visibleProfs then
		self:Print("Too many Indexes provivded!")
		self:Print("There are only "..visibleProfs.." visible Indexes. You provided "..items)
		return 
	end
	if items < visibleProfs then
		self:Print("Too few Indexes provivded!")
		self:Print("There are "..visibleProfs.." visible Indexes. You provided "..items)
		return 
	end	
	
	for index, value in ipairs(indexes) do 
	
		if tonumber(value) > visibleProfs then 
			self:Print("Invalid Index "..value)
			return
		end		
	end

	local newOrder = { }
	local isVisibleIndex = 0

	for index, value in ipairs(indexes) do 
		isVisibleIndex = 0
		for i, prof in ipairs(TrackSalesDB.Professions) do 			

			if prof.IsVisible then 
				isVisibleIndex = isVisibleIndex + 1
			end

			if prof.IsVisible and isVisibleIndex == tonumber(value) then 				
				table.insert(newOrder, prof)
			end
		end
	end	

	for i, prof in ipairs(TrackSalesDB.Professions) do 			
		if not prof.IsVisible then 
			table.insert(newOrder, prof)
		end
	end	

	TrackSalesDB.Professions = newOrder
end

--hack to allow /ts p a FirstAid
--First Aid is parsed as 2 arguments
function TrackSales.db:ConsoleHack(arg, superHack)	
		
	arg = arg:gsub("^%l", string.upper)

	if string.lower(arg) == "firstaid" then
		arg = "First Aid"
	end
	if superHack then
		if arg == "Herbalism" then
			arg = "Herbalism Skills"
		end
		if arg == "Mining" then
			arg = "Mining Skills"
		end
	end

	return arg
end

function TrackSales.db:FindTrackedProfession(profession)
	
	for index, value in ipairs(TrackSalesDB.Professions) do 
		if value.Name == profession then
			return value 
		end
	end

	return nil
end

function TrackSales.db:SetDefaults()
	
	TrackSalesDB = {
		Professions = {	}	 
	 }

	local professions = self:LookupProfessions()	

	for index, value in ipairs(professions) do 
		if value.Name then
			table.insert(TrackSalesDB.Professions, value)
		end
	end
end

function TrackSales.db:LookupProfessions()

	--todo check how many items classic returns
	local prof1, prof2, sec1, sec2, sec3, sec4 = GetProfessions()	
	
	local prof1Name = self:GetProfessionName(prof1)
	local prof2Name = self:GetProfessionName(prof2)
	local sec1Name = self:GetProfessionName(sec1)
	local sec2Name = self:GetProfessionName(sec2)
	local sec3Name = self:GetProfessionName(sec3)
	local sec4Name = self:GetProfessionName(sec4)

	return {
		{ Name = prof1Name, GoldMade = 0, IsVisible = true },
		{ Name = prof2Name, GoldMade = 0, IsVisible = true },
		{ Name = sec1Name,  GoldMade = 0, IsVisible = true },
		{ Name = sec2Name,  GoldMade = 0, IsVisible = true },
		{ Name = sec3Name,  GoldMade = 0, IsVisible = true },
		{ Name = sec4Name,  GoldMade = 0, IsVisible = true },
	}
end

function TrackSales.db:GetProfessionName(index)
	if index then
		local name = GetProfessionInfo(index)
		
		return name
	else 
		return nil
	end
end

function TrackSales.db:GetProfessionByIndex(idx)
	local val = ""
	
	for index, value in ipairs(TrackSalesDB.Professions) do 
	   if index == tonumber(idx) then
			val = value.Name
	   end
	end

	return val
end

function TrackSales.db:MaxIndex(visibleOnly)	
	local i = 0
	for index, value in ipairs(TrackSalesDB.Professions) do 

		if visibleOnly and value.IsVisible then 
			i = i + 1
		end
		if not visibleOnly then 
			i = i + 1
		end
	end
	return i
end

function TrackSales.db:Clear()

	TrackSalesDB = nil

	self:Print("Database cleared")

end 