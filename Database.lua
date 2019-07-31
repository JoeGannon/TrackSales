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
	
	local prof = self:FindTrackedProfession(profession)

	if prof and prof.Name == profession then 
		return 
	end	

	profession = self:ConsoleHack(profession, true)

	for index, value in ipairs(professions) do
		if value == profession then			

			local isPrimary = not (profession == "Cooking" or profession == "Fishing" or profession == "First Aid")	
			
			if (string.match(profession, "Skills")) then			
				profession = string.sub(profession, 0, string.len(profession) - 7)				
			end

			local prof = { 
					Name = profession,
					GoldMade = 0,
					IsPrimary = isPrimary,
					IsVisible = true 
				}
			
			table.insert(TrackSalesDB.Professions, prof)

			self:Print("Now tracking "..prof.Name)
			return
		end	
	end	

	if log then
		self:Print("Profession not found "..profession.."(professions are case sensitive)")
	end
end

function TrackSales.db:RemoveProfession(profession, temporary)	
	 
	profession = self:ConsoleHack(profession) 
	local prof = self:FindTrackedProfession(profession)
	 
	 if temporary and prof then		
		prof.IsVisible = false
		self:Print(profession.." is now hidden")
		return		
	 end

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

--hack to allow /ts p a FirstAid
--First Aid is parsed as 2 arguments
function TrackSales.db:ConsoleHack(arg, superHack)	
	if arg == "FirstAid" then
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

	return arg:gsub("^%l", string.upper)
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
		{ Name = prof1Name, GoldMade = 0, IsPrimary = true, IsVisible = true },
		{ Name = prof2Name, GoldMade = 0, IsPrimary = true, IsVisible = true },
		{ Name = sec1Name,  GoldMade = 0, IsPrimary = false, IsVisible = true },
		{ Name = sec2Name,  GoldMade = 0, IsPrimary = false, IsVisible = true },
		{ Name = sec3Name,  GoldMade = 0, IsPrimary = false, IsVisible = true },
		{ Name = sec4Name,  GoldMade = 0, IsPrimary = false, IsVisible = true },
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

function TrackSales.db:MaxIndex()	
	local i = 0
	for index, value in ipairs(TrackSalesDB.Professions) do 
		i = i + 1
	end
	return i
end

function TrackSales.db:Clear()

	TrackSalesDB = nil

	self:Print("Database cleared")

end 