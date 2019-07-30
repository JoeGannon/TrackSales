TrackSales.db = TrackSales:NewModule("DB", "AceConsole-3.0")

function TrackSales.db:AddGold(profession, gold)

	for index, value in ipairs(TrackSalesDB.Professions) do 
		 if value.Name == profession then
			value.GoldMade = value.GoldMade + gold
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

function TrackSales.db:SetDefaults()
	
	local professions = self:LookupProfessions()

	TrackSalesDB = {
		Professions = {	}	 
	 }

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

function TrackSales.db:Clear(...)

	TrackSalesDB = nil

end 