TrackSales.db = TrackSales:NewModule("DB", "AceConsole-3.0")

local _, ts = ...

function TrackSales.db:TrackSale(item, gold)

	local matchedProfession = ts:MatchProfession(item)
	
	if self:IsTrackedProfession(matchedProfession)	 then
		self:AddGold(matchedProfession, gold)
	end 
end

function TrackSales.db:IsTrackedProfession(profession)
	
	for index, value in ipairs(TrackSalesDB.Professions) do 
		if value.Name == profession then
			return true
		end
	end

	return false
end

function TrackSales.db:AddGold(profession, gold)

	for index, value in ipairs(TrackSalesDB.Professions) do 
		 if value.Name == profession then

			local goldMade = value.GoldMade + gold

			--things get weird when the value is set to negative
			if goldMade < 0 then 
				value.GoldMade = 0
			else 
				value.GoldMade = goldMade
			end

			return
		 end
	end

	self:Print("Profession Not Found "..profession)
end

function TrackSales.db:SubtractGold(profession, gold)
	
	self:AddGold(profession, -gold)
end

function TrackSales.db:SetGold(profession, gold)

	for index, value in ipairs(TrackSalesDB.Professions) do 
		if value.Name == profession then
		   value.GoldMade = gold
		   return
		end
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

function TrackSales.db:TryAddNewProfession(skillName, log)
	
	if TrackSalesDB and TrackSalesDB.Professions then
		for index, value in ipairs(TrackSalesDB.Professions) do 
			if value.Name == skillName then
				return 
			end 
		end
	end

	skillName = self:ConsoleHack(skillName, true)

	for index, value in ipairs(professions) do
		if value == skillName then			

			local isPrimary = not (skillName == "Cooking" or skillName == "Fishing" or skillName == "First Aid")	
			
			if (string.match(skillName, "Skills")) then			
				skillName = string.sub(skillName, 0, string.len(skillName) - 7)				
			end

			local profession = { Name = skillName, GoldMade = 0, IsPrimary = isPrimary }
			
			table.insert(TrackSalesDB.Professions, profession)

			self:Print("Now tracking "..profession.Name)
			return
		end	
	end	

	if log then
		self:Print("Profession not found "..skillName.."(professions are case sensitive)")
	end
end

function TrackSales.db:RemoveProfession(profession)	
 	profession = self:ConsoleHack(profession)

		if TrackSalesDB and TrackSalesDB.Professions then
			for index, value in ipairs(TrackSalesDB.Professions) do
				if (value.Name == profession) then 
					table.remove(TrackSalesDB.Professions, index)
					self:Print(profession.." removed")
					return
				end
			end
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

	return arg
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
		{ Name = prof1Name, GoldMade = 0, IsPrimary = true },
		{ Name = prof2Name, GoldMade = 0, IsPrimary = true },
		{ Name = sec1Name,  GoldMade = 0, IsPrimary = false },
		{ Name = sec2Name,  GoldMade = 0, IsPrimary = false },
		{ Name = sec3Name,  GoldMade = 0, IsPrimary = false },
		{ Name = sec4Name,  GoldMade = 0, IsPrimary = false },
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

function TrackSales.db:FindProfession(idx)
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